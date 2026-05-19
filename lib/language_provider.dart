import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale? _locale;
  Locale? get locale => _locale;

  LanguageProvider() {
    _loadLanguage();
  }

  // تحميل اللغة المحفوظة أو استخدام لغة النظام
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language_code');
    if (languageCode != null && languageCode != 'system') {
      _locale = Locale(languageCode);
    } else {
      _locale = null; // null تعني اتباع لغة النظام
    }
    notifyListeners();
  }

  // تغيير اللغة وحفظها
  Future<void> changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    if (languageCode == 'system') {
      _locale = null;
      await prefs.remove('language_code');
    } else {
      _locale = Locale(languageCode);
      await prefs.setString('language_code', languageCode);
    }
    notifyListeners();
  }
}
