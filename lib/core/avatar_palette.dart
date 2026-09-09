import 'package:flutter/material.dart';

/// Palet warna untuk kustomisasi avatar (warna rambut & background profil).
/// Disimpan sebagai hex string di database agar ringan dan mudah divalidasi.
abstract final class AvatarPalette {
  static const String defaultHairHex = '#2D2013';
  static const String defaultBgHex = '#FBC02D';
  static const Color defaultSkinColor = Color(0xFFFFD7B0);

  static const List<MapEntry<String, Color>> hairColors = [
    MapEntry('#2D2013', Color(0xFF2D2013)), // Hitam
    MapEntry('#4E342E', Color(0xFF4E342E)), // Coklat Tua
    MapEntry('#7B4B2A', Color(0xFF7B4B2A)), // Coklat
    MapEntry('#C99A5B', Color(0xFFC99A5B)), // Pirang
    MapEntry('#A63A2E', Color(0xFFA63A2E)), // Merah Bata
    MapEntry('#B0BEC5', Color(0xFFB0BEC5)), // Silver
    MapEntry('#5C6BC0', Color(0xFF5C6BC0)), // Biru
    MapEntry('#EC407A', Color(0xFFEC407A)), // Pink
  ];

  static const List<MapEntry<String, Color>> bgColors = [
    MapEntry('#FBC02D', Color(0xFFFBC02D)), // Amber (default)
    MapEntry('#26A69A', Color(0xFF26A69A)), // Teal
    MapEntry('#7E57C2', Color(0xFF7E57C2)), // Ungu
    MapEntry('#FF7043', Color(0xFFFF7043)), // Coral
    MapEntry('#29B6F6', Color(0xFF29B6F6)), // Biru Langit
    MapEntry('#66BB6A', Color(0xFF66BB6A)), // Hijau Mint
    MapEntry('#F06292', Color(0xFFF06292)), // Pink
    MapEntry('#607D8B', Color(0xFF607D8B)), // Slate
  ];

  /// Ubah hex string ("#RRGGBB") menjadi Color. Jatuh ke [fallback] jika
  /// null/kosong/format tidak valid, agar avatar tidak pernah gagal render.
  static Color hexToColor(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    final h = hex.replaceAll('#', '').trim();
    if (h.length != 6) return fallback;
    final value = int.tryParse('FF$h', radix: 16);
    return value != null ? Color(value) : fallback;
  }
}
