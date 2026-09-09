import 'package:flutter/material.dart';

abstract final class AppColors {
  // App
  static const primary = Color(0xFF1A237E);
  static const primaryDark = Color(0xFF0D1B4B);
  static const primaryMid = Color(0xFF283593);
  static const accent = Color(0xFF3949AB);
  static const amber = Color(0xFFFBC02D);

  static const correct = Color(0xFF2E7D32);
  static const correctDark = Color(0xFF1B5E20);
  static const wrong = Color(0xFFFF5252);
  static const wrongDark = Color(0xFFC62828);

  // Statistik result
  static const statBenar = Color(0xFF69F0AE);
  static const statSalah = Color(0xFFFF5252);
  static const statSkip = Color(0xFFFFD740);

  // Kartu review jawaban
  static const reviewCorrectBg = Color(0xFFE8F5E9);
  static const reviewCorrectText = Color(0xFF1B5E20);
  static const reviewCorrectBdr = Color(0xFF81C784);
  static const reviewWrongBg = Color(0xFFFFEBEE);
  static const reviewWrongText = Color(0xFF7F0000);
  static const reviewWrongBdr = Color(0xFFEF9A9A);

  // Node level map
  static const nodeLocked = Color(0xFF455A64);
  static const nodeLockedShadow = Color(0xFF263238);
  static const nodeLockedBorder = Color(0xFF546E7A);
  static const nodeDone = Color(0xFF2E7D32);
  static const nodeDoneShadow = Color(0xFF1B5E20);
  static const nodeDoneBorder = Color(0xFF81C784);
  static const nodeActive = Color(0xFFF57F17);
  static const nodeActiveShadow = Color(0xFFE65100);
  static const nodeActiveBorder = Color(0xFFFFD54F);
}
