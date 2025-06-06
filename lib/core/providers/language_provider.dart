import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_constants.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en', '');
  
  Locale get locale => _locale;
  
  LanguageProvider() {
    _loadLanguage();
  }
  
  Future<void> _loadLanguage() async {
    try {
      // Use SharedPreferences directly since LocalStorageService doesn't have getString for arbitrary keys
      final prefs = await SharedPreferences.getInstance();
      final String? savedLanguage = prefs.getString(AppConstants.languageKey);
      
      if (savedLanguage != null && savedLanguage.isNotEmpty) {
        _locale = Locale(savedLanguage, '');
      } else {
        // Save default language if none is set
        await prefs.setString(AppConstants.languageKey, _locale.languageCode);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading language preference: $e');
      // Continue with default locale
    }
  }
  
  Future<void> setLocale(Locale locale) async {
    if (_locale.languageCode == locale.languageCode) return;
    
    try {
      _locale = locale;
      // Use SharedPreferences directly
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.languageKey, locale.languageCode);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving language preference: $e');
      // Revert to previous locale if saving fails
      _locale = const Locale('en', '');
      notifyListeners();
    }
  }
}
