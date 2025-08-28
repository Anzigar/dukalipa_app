import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_constants.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  ThemeProvider() {
    _loadTheme();
  }
  
  Future<void> _loadTheme() async {
    // Use SharedPreferences directly
    final prefs = await SharedPreferences.getInstance();
    final String? savedTheme = prefs.getString(AppConstants.themeKey);
    
    if (savedTheme == null) return;
    
    switch (savedTheme) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
        break;
    }
    
    notifyListeners();
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      default:
        value = 'system';
        break;
    }
    
    // Use SharedPreferences directly
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.themeKey, value);
    notifyListeners();
  }

  /// Set theme mode with animated transition
  Future<void> setThemeModeAnimated(ThemeMode mode) async {
    return setThemeMode(mode);
  }
}
