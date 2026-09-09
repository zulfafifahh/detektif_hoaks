import 'package:flutter/foundation.dart';
import '../core/app_constants.dart';
import '../core/avatar_palette.dart';
import '../models/content_model.dart';
import '../services/supabase_service.dart';

class GameProvider with ChangeNotifier {
  String _userName = 'Detektif Baru';
  String _avatar = 'boy';
  String _hairColorHex = AvatarPalette.defaultHairHex;
  String _bgColorHex = AvatarPalette.defaultBgHex;
  int _totalScore = 0;

  final Map<int, int> _levelStars = {1: 0, 2: -1, 3: -1};
  final Map<int, bool> _isMateriRead = {1: false, 2: false, 3: false};

  final Map<int, int> _retryCount = {1: 0, 2: 0, 3: 0};
  final Map<int, bool> _hasEverCompleted = {1: false, 2: false, 3: false};
  static const int maxRetry = 3;

  List<SesiHasil> _riwayat = [];
  bool _isLoading = false;

  String get userName => _userName;
  String get avatar => _avatar;
  String get hairColorHex => _hairColorHex;
  String get bgColorHex => _bgColorHex;
  int get score => _totalScore;
  bool get isLoading => _isLoading;
  List<SesiHasil> get riwayat => List.unmodifiable(_riwayat);

  bool isLevelLocked(int level) => (_levelStars[level] ?? -1) == -1;
  int getStars(int level) => _levelStars[level] ?? -1;
  bool isMateriRead(int level) => _isMateriRead[level] ?? false;
  bool hasEverCompleted(int level) => _hasEverCompleted[level] ?? false;
  int getRetryCount(int level) => _retryCount[level] ?? 0;
  int getRetryLeft(int level) => maxRetry - (_retryCount[level] ?? 0);
  bool canRetry(int level) => (_retryCount[level] ?? 0) < maxRetry;

  void incrementRetry(int level) {
    if ((_retryCount[level] ?? 0) < maxRetry) {
      _retryCount[level] = (_retryCount[level] ?? 0) + 1;
      notifyListeners();
    }
  }

  void resetRetry(int level) {
    _retryCount[level] = 0;
    notifyListeners();
  }

  Future<void> loadGameData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        SupabaseService.getProfil(),
        SupabaseService.getAllProgress(),
        SupabaseService.getRiwayatRaw(),
      ]);

      final profil = results[0] as Map<String, dynamic>?;
      if (profil != null) {
        _userName = profil['nama'] as String? ?? 'Detektif Baru';
        _avatar = profil['avatar'] as String? ?? 'boy';
        _hairColorHex =
            profil['avatar_hair_color'] as String? ??
            AvatarPalette.defaultHairHex;
        _bgColorHex =
            profil['avatar_bg_color'] as String? ?? AvatarPalette.defaultBgHex;
        _totalScore = (profil['skor_total'] as num?)?.toInt() ?? 0;
      }

      final progressList = List<Map<String, dynamic>>.from(results[1] as List);
      for (final p in progressList) {
        final level = (p['level'] as num).toInt();
        _levelStars[level] = (p['bintang'] as num).toInt();
        _isMateriRead[level] = p['materi_dibaca'] as bool;
      }

      final rawRiwayat = results[2] as List<dynamic>;
      _riwayat = await compute(_parseRiwayatIsolate, rawRiwayat);
    } catch (e) {
      debugPrint('[GameProvider] loadGameData error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAvatar(String avatar) async {
    if (_avatar == avatar) return;
    final previous = _avatar;
    _avatar = avatar;
    notifyListeners();
    try {
      await SupabaseService.updateProfil(avatar: avatar);
    } catch (e) {
      // Rollback jika gagal disimpan ke server, agar UI tetap konsisten.
      _avatar = previous;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateAvatarColors({
    String? hairColorHex,
    String? bgColorHex,
  }) async {
    final hairChanged = hairColorHex != null && hairColorHex != _hairColorHex;
    final bgChanged = bgColorHex != null && bgColorHex != _bgColorHex;
    if (!hairChanged && !bgChanged) return;

    final prevHair = _hairColorHex;
    final prevBg = _bgColorHex;
    if (hairChanged) _hairColorHex = hairColorHex;
    if (bgChanged) _bgColorHex = bgColorHex;
    notifyListeners();

    try {
      await SupabaseService.updateAvatarColors(
        hairColorHex: hairChanged ? hairColorHex : null,
        bgColorHex: bgChanged ? bgColorHex : null,
      );
    } catch (e) {
      // Rollback jika gagal disimpan ke server, agar UI tetap konsisten.
      _hairColorHex = prevHair;
      _bgColorHex = prevBg;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markMateriAsRead(int level) async {
    if (_isMateriRead[level] == true) return;
    _isMateriRead[level] = true;
    notifyListeners();
    await SupabaseService.updateProgress(level: level, materiDibaca: true);
  }

  Future<void> completeLevel(int level, int starsEarned, SesiHasil sesi) async {
    final currentStars = _levelStars[level] ?? 0;
    _hasEverCompleted[level] = true;

    if (starsEarned > currentStars) {
      _levelStars[level] = starsEarned;
      await SupabaseService.updateProgress(level: level, bintang: starsEarned);

      final gain = (starsEarned - currentStars) * AppConstants.skorPerBintang;
      if (gain > 0) {
        _totalScore += gain;
        await SupabaseService.tambahSkorProfil(gain);
      }
    }

    if (starsEarned >= 1) {
      final next = level + 1;
      if (_levelStars.containsKey(next) && _levelStars[next] == -1) {
        _levelStars[next] = 0;
        await SupabaseService.bukaLevelBerikutnya(level);
      }
    }

    _riwayat.insert(0, sesi);
    if (_riwayat.length > AppConstants.maxRiwayat) {
      _riwayat = _riwayat.sublist(0, AppConstants.maxRiwayat);
    }
    await SupabaseService.simpanSesi(sesi);
    notifyListeners();
  }

  List<SesiHasil> getRiwayatByLevel(int level) =>
      _riwayat.where((s) => s.level == level).toList();

  Future<void> clearRiwayat() async {
    _riwayat.clear();
    notifyListeners();
    await SupabaseService.hapusSemuaSesi();
  }

  Future<void> resetAllData() async {
    await SupabaseService.signOut();
    _userName = 'Detektif Baru';
    _avatar = 'boy';
    _hairColorHex = AvatarPalette.defaultHairHex;
    _bgColorHex = AvatarPalette.defaultBgHex;
    _totalScore = 0;
    _levelStars.addAll({1: 0, 2: -1, 3: -1});
    _isMateriRead.addAll({1: false, 2: false, 3: false});
    _riwayat.clear();
    notifyListeners();
  }
}

List<SesiHasil> _parseRiwayatIsolate(List<dynamic> rawData) {
  return List<Map<String, dynamic>>.from(rawData).map((row) {
    return SesiHasil(
      id: row['id'] as String,
      level: (row['level'] as num).toInt(),
      skor: (row['skor'] as num).toInt(),
      totalSoal: (row['total_soal'] as num).toInt(),
      skorSkala100: (row['skor_skala100'] as num).toInt(),
      bintang: (row['bintang'] as num).toInt(),
      tanggal: DateTime.parse(row['created_at'] as String),
      detailSoal: (row['detail_soal'] as List)
          .map((e) => HasilSoal.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }).toList();
}
