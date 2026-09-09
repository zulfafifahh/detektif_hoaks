import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════
// AUDIT FIX — Manajemen Lifecycle BGM & Pemisahan SFX/BGM Player
// ═══════════════════════════════════════════════════════════════════════════
//
// ROOT CAUSE LAMA:
//   • Satu AudioPlayer (_player) dipakai untuk SEMUA suara.
//     → playCorrect() memanggil _player.stop() → BGM ikut berhenti saat
//       pindah soal kuis.
//   • Tidak ada mekanisme pause/resume saat app masuk background.
//     → BGM tetap berbunyi ketika app di-minimize.
//   • AudioPlayer dibuat sebagai static field biasa — dispose-nya tidak
//     dikelola → memory leak potensial.
//
// SOLUSI:
//   • AudioService sebagai Singleton (instance tunggal seumur app).
//   • _bgmPlayer : khusus BGM, ReleaseMode.loop, TIDAK pernah di-stop oleh SFX.
//   • _sfxPlayer : khusus SFX one-shot (correct, wrong, win, lose, timeout).
//   • Lifecycle dijembatani oleh onAppLifecycleChanged() yang dipanggil dari
//     WidgetsBindingObserver di MyApp (main.dart).
//   • SoundManager static API dipertahankan untuk backward-compatibility:
//     quiz_screen.dart, result_screen.dart, dll. TIDAK perlu diubah.
//
// CARA MENAMBAH BGM:
//   1. Tambahkan file audio/BGM.mp3 ke folder assets/audio/
//   2. Panggil AudioService.instance.startBgm() di HomeScreen.initState()
//   3. Panggil AudioService.instance.stopBgm() saat keluar ke WelcomeScreen
// ═══════════════════════════════════════════════════════════════════════════

class AudioService {
  // ── Singleton ─────────────────────────────────────────────────────────────
  AudioService._internal();
  static final AudioService instance = AudioService._internal();

  // ── Players ───────────────────────────────────────────────────────────────
  // Dua AudioPlayer terpisah agar BGM tidak terganggu oleh SFX
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  // ── State ─────────────────────────────────────────────────────────────────
  bool _bgmEnabled = true;   // bisa diubah via setBgmEnabled()
  bool _sfxEnabled = true;   // bisa diubah via setSfxEnabled()
  bool _isAppActive = true;  // false ketika app di background
  String? _currentBgmPath;   // path asset BGM yang sedang aktif

  // ── Init — dipanggil sekali di main() sebelum runApp ─────────────────────
  Future<void> init() async {
    // BGM: loop tanpa batas, tidak auto-release
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    // SFX: release setelah selesai (hemat resource)
    await _sfxPlayer.setReleaseMode(ReleaseMode.release);
  }

  // ── BGM API ───────────────────────────────────────────────────────────────

  /// Mulai putar BGM. Aman dipanggil berkali-kali (idempotent).
  Future<void> startBgm([String assetPath = 'audio/BGM.mp3']) async {
    _currentBgmPath = assetPath;
    if (!_bgmEnabled || !_isAppActive) return;
    try {
      await _bgmPlayer.play(AssetSource(assetPath));
    } catch (e) {
      // File belum ada → silent fail, tidak crash app
      debugPrint('[AudioService] BGM file tidak ditemukan: $assetPath');
    }
  }

  /// Pause BGM — dipanggil saat app ke background.
  Future<void> pauseBgm() async {
    try {
      await _bgmPlayer.pause();
    } catch (_) {}
  }

  /// Resume BGM — dipanggil saat app kembali ke foreground.
  Future<void> resumeBgm() async {
    if (!_bgmEnabled || !_isAppActive) return;
    try {
      // Jika player sudah ada audio yang di-pause, lanjutkan
      await _bgmPlayer.resume();
    } catch (_) {}
  }

  /// Stop total BGM (misalnya saat logout atau layar khusus).
  Future<void> stopBgm() async {
    try {
      await _bgmPlayer.stop();
    } catch (_) {}
  }

  void setBgmEnabled(bool enabled) {
    _bgmEnabled = enabled;
    if (!enabled) {
      stopBgm();
    } else if (_isAppActive && _currentBgmPath != null) {
      startBgm(_currentBgmPath!);
    }
  }

  // ── Lifecycle Hook — dipanggil dari WidgetsBindingObserver di MyApp ───────

  void onAppLifecycleChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // App masuk background → pause BGM seketika
        _isAppActive = false;
        pauseBgm();
        break;
      case AppLifecycleState.resumed:
        // App kembali ke foreground → resume BGM
        _isAppActive = true;
        resumeBgm();
        break;
      case AppLifecycleState.detached:
        // App akan ditutup → stop total
        _isAppActive = false;
        stopBgm();
        break;
    }
  }

  // ── SFX API ───────────────────────────────────────────────────────────────
  // Menggunakan _sfxPlayer TERPISAH dari _bgmPlayer.
  // BGM TIDAK akan berhenti ketika SFX diputar.

  Future<void> _playSfx(String assetPath) async {
    if (!_sfxEnabled) return;
    try {
      // Stop SFX sebelumnya (bukan BGM!) sebelum putar yang baru
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('[AudioService] SFX error ($assetPath): $e');
    }
  }

  Future<void> playCorrect() => _playSfx('audio/True.mp3');
  Future<void> playWrong()   => _playSfx('audio/False.mp3');
  Future<void> playWin()     => _playSfx('audio/Winner.mp3');
  Future<void> playLose()    => _playSfx('audio/Lose.mp3');
  Future<void> playTimeOut() => _playSfx('audio/Over.mp3');

  void setSfxEnabled(bool enabled) => _sfxEnabled = enabled;

  // ── Dispose — dipanggil dari MyApp.dispose() ──────────────────────────────
  Future<void> disposeAll() async {
    await _bgmPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BACKWARD-COMPATIBLE STATIC API
// ═══════════════════════════════════════════════════════════════════════════
// Semua file yang memanggil SoundManager.playCorrect() dll. TIDAK perlu
// diubah. Static method di sini hanya mendelegasikan ke AudioService.

class SoundManager {
  SoundManager._(); // tidak boleh diinstansiasi

  // ── BGM ───────────────────────────────────────────────────────────────────
  /// Mulai BGM. Dipanggil di HomeScreen.initState() setelah login.
  /// [assetPath] default: 'audio/BGM.mp3' — sesuaikan jika nama file berbeda.
  static Future<void> startBgm([String assetPath = 'audio/BGM.mp3']) =>
      AudioService.instance.startBgm(assetPath);

  /// Stop BGM total. Dipanggil di ResultScreen sebelum navigasi keluar.
  static Future<void> stopBgm() => AudioService.instance.stopBgm();

  /// Pause BGM sementara (tanpa reset posisi).
  static Future<void> pauseBgm() => AudioService.instance.pauseBgm();

  /// Resume BGM yang di-pause.
  static Future<void> resumeBgm() => AudioService.instance.resumeBgm();

  // ── SFX ───────────────────────────────────────────────────────────────────
  static Future<void> playCorrect()  => AudioService.instance.playCorrect();
  static Future<void> playWrong()    => AudioService.instance.playWrong();
  static Future<void> playWin()      => AudioService.instance.playWin();
  static Future<void> playLose()     => AudioService.instance.playLose();
  static Future<void> playTimeOut()  => AudioService.instance.playTimeOut();
}