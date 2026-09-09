import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/content_model.dart';

final supabase = Supabase.instance.client;

class SupabaseService {

  static Future<AuthResponse> signUp({
  required String email,
  required String password,
  required String nama,
  required String avatar,
}) async {
  // Langkah 1: Daftarkan ke Supabase Auth
  final res = await supabase.auth.signUp(
    email: email,
    password: password,
    data: {'nama': nama, 'avatar': avatar},
  );

  // Langkah 2: Jika berhasil dan session ada (email confirm OFF),
  // langsung INSERT ke tabel profil.
  // Jika session null (email confirm ON), trigger DB yang handle ini.
  final uid = res.user?.id;
  if (uid != null && res.session != null) {
    // upsert agar aman jika trigger DB sudah membuat baris duluan
    await supabase.from('profil').upsert({
      'id':     uid,
      'nama':   nama,
      'avatar': avatar,
      'skor':   0,
    });
  }

  return res;
}

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async => supabase.auth.signOut();

  static User? get currentUser => supabase.auth.currentUser;
  static bool get isLoggedIn   => currentUser != null;

  static Future<Map<String, dynamic>?> getProfil() async {
    final uid = currentUser?.id;
    if (uid == null) return null;
    return await supabase
        .from('profil')
        .select()
        .eq('id', uid)
        .maybeSingle();
  }

  static Future<void> updateProfil({String? nama, String? avatar}) async {
    final uid = currentUser?.id;
    if (uid == null) return;
    final Map<String, dynamic> updates = {};
    if (nama   != null) updates['nama']   = nama;
    if (avatar != null) updates['avatar'] = avatar;
    if (updates.isNotEmpty) {
      await supabase.from('profil').update(updates).eq('id', uid);
    }
  }

  static Future<void> tambahSkorProfil(int tambahan) async {
    final uid = currentUser?.id;
    if (uid == null) return;
    await supabase.rpc(
      'tambah_skor',
      params: {'p_user_id': uid, 'p_tambahan': tambahan},
    );
  }

  static Future<List<Map<String, dynamic>>> getAllProgress() async {
    final uid = currentUser?.id;
    if (uid == null) return [];
    final data = await supabase
        .from('progress_level')
        .select()
        .eq('user_id', uid)
        .order('level');
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<void> updateProgress({
    required int level,
    int?  bintang,
    bool? materiDibaca,
  }) async {
    final uid = currentUser?.id;
    if (uid == null) return;
    final Map<String, dynamic> updates = {
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (bintang      != null) updates['bintang']       = bintang;
    if (materiDibaca != null) updates['materi_dibaca'] = materiDibaca;

    await supabase
        .from('progress_level')
        .update(updates)
        .eq('user_id', uid)
        .eq('level', level);
  }

  static Future<void> bukaLevelBerikutnya(int levelSebelumnya) async {
    final uid = currentUser?.id;
    if (uid == null) return;
    final nextLevel = levelSebelumnya + 1;
    await supabase
        .from('progress_level')
        .update({
          'bintang':    0,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', uid)
        .eq('level', nextLevel)
        .eq('bintang', -1);
  }

  // ── FIX 1 + FIX 2: getSoalByLevel ────────────────────────────────────────
  static Future<List<Soal>> getSoalByLevel(int level) async {
    final data = await supabase
        .from('soal')
        .select('soal_id_level, teks, gambar, opsi, jawaban_benar')
        .eq('level', level);

    final list = List<Map<String, dynamic>>.from(data);

    // FIX 1: Seed eksplisit berbasis microsecond → urutan PASTI berbeda
    // setiap sesi, menyelesaikan masalah soal tidak teracak di real device.
    list.shuffle(Random(DateTime.now().microsecondsSinceEpoch));

    // FIX 2: (as num).toInt() menggantikan (as int) agar aman di AOT mode.
    return list
        .map((row) => Soal(
              id:          (row['soal_id_level'] as num).toInt(),
              text:         row['teks']          as String,
              image:       (row['gambar']        as String?) ?? '',
              options:      List<String>.from(row['opsi'] as List),
              answerIndex: (row['jawaban_benar'] as num).toInt(),
            ))
        .toList();
  }

  static Future<void> simpanSesi(SesiHasil sesi) async {
    final uid = currentUser?.id;
    if (uid == null) return;
    await supabase.from('sesi_hasil').insert({
      'user_id':      uid,
      'level':        sesi.level,
      'skor':         sesi.skor,
      'total_soal':   sesi.totalSoal,
      'skor_skala100':sesi.skorSkala100,
      'bintang':      sesi.bintang,
      'detail_soal':  sesi.detailSoal.map((s) => s.toJson()).toList(),
    });
  }

  static Future<List<dynamic>> getRiwayatRaw() async {
    final uid = currentUser?.id;
    if (uid == null) return [];
    return await supabase
        .from('sesi_hasil')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .limit(50);
  }

  static Future<List<SesiHasil>> getRiwayat({int? level}) async {
    final uid = currentUser?.id;
    if (uid == null) return [];

    final query = supabase
        .from('sesi_hasil')
        .select()
        .eq('user_id', uid);

    final data = level != null
        ? await query
            .eq('level', level)
            .order('created_at', ascending: false)
            .limit(50)
        : await query
            .order('created_at', ascending: false)
            .limit(50);

    return _parseSesiList(data);
  }

  // ── FIX 3: _parseSesiList — semua cast int → (as num).toInt() ─────────────
  static List<SesiHasil> _parseSesiList(List<dynamic> data) {
    return List<Map<String, dynamic>>.from(data).map((row) {
      return SesiHasil(
        id:           row['id']            as String,
        level:        (row['level']         as num).toInt(),
        skor:         (row['skor']          as num).toInt(),
        totalSoal:    (row['total_soal']    as num).toInt(),
        skorSkala100: (row['skor_skala100'] as num).toInt(),
        bintang:      (row['bintang']       as num).toInt(),
        tanggal:       DateTime.parse(row['created_at'] as String),
        detailSoal:   (row['detail_soal'] as List)
            .map((e) => HasilSoal.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }).toList();
  }

  static Future<void> hapusSemuaSesi() async {
    final uid = currentUser?.id;
    if (uid == null) return;
    await supabase.from('sesi_hasil').delete().eq('user_id', uid);
  }

  static Future<void> updateAvatarColors({
    String? hairColorHex,
    String? bgColorHex,
  }) async {
    final uid = currentUser?.id;
    if (uid == null) return;
    final Map<String, dynamic> updates = {};
    if (hairColorHex != null) updates['avatar_hair_color'] = hairColorHex;
    if (bgColorHex != null) updates['avatar_bg_color'] = bgColorHex;
    if (updates.isNotEmpty) {
      await supabase.from('profil').update(updates).eq('id', uid);
    }
  }

  // ── FITUR LEADERBOARD ────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getLeaderboard({
    int limit = 100,
  }) async {
    final data = await supabase
        .from('profil')
        .select('id, nama, avatar, avatar_hair_color, avatar_bg_color, skor_total')
        .order('skor_total', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(data);
  }
}