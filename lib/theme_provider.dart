import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // Light Mode Colors
  static const Color lightBackground = Color(0xFFF8F8F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF424242);
  static const Color lightSecondaryText = Color(0xFF9E9E9E);
  static const Color lightBorder = Color(0xFFE5E5E5);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0D0D0D);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkText = Color(0xFFF5F5F5);
  static const Color darkSecondaryText = Color(0xFF9E9E9E);
  static const Color darkBorder = Color(0xFF2C2C2C);
  static const Color darkCard = Color(0xFF1E1E1E);

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('dark_mode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }

  // Get colors based on current theme
  Color get backgroundColor => _isDarkMode ? darkBackground : lightBackground;
  Color get surfaceColor => _isDarkMode ? darkSurface : lightSurface;
  Color get textColor => _isDarkMode ? darkText : lightText;
  Color get secondaryTextColor => _isDarkMode ? darkSecondaryText : lightSecondaryText;
  Color get borderColor => _isDarkMode ? darkBorder : lightBorder;
  Color get cardColor => _isDarkMode ? darkCard : lightCard;
  
  // Navigation bar specific
  Color get navBarBackground => _isDarkMode ? darkSurface : lightSurface;
  Color get navBarSelectedColor => _isDarkMode ? Colors.white : lightText;
  Color get navBarUnselectedColor => _isDarkMode ? Colors.white54 : lightSecondaryText;
}
