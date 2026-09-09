import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _isDarkMode = false;
  String _language = 'id';

  bool get isDarkMode => _isDarkMode;
  String get language => _language;

  void loadSettingsFromPrefs(SharedPreferences prefs) {
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _language   = prefs.getString('language') ?? 'id';
  }
  
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _language   = prefs.getString('language') ?? 'id';
    notifyListeners();
  }

  // Ganti Tema
  void toggleTheme(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  // Ganti Bahasa
  void changeLanguage(String langCode) async {
    _language = langCode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);
  }
}
