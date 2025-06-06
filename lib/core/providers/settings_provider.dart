import 'package:flutter/material.dart';

import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService;
  
  // Theme
  ThemeMode _themeMode = ThemeMode.system;
  
  // Language
  Locale _locale = const Locale('en');
  
  // Notifications
  bool _salesNotificationsEnabled = true;
  bool _lowStockNotificationsEnabled = true;
  bool _expenseNotificationsEnabled = true;
  
  // Security
  bool _biometricAuthEnabled = false;
  
  SettingsProvider(this._storageService) {
    _loadSettings();
  }
  
  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get salesNotificationsEnabled => _salesNotificationsEnabled;
  bool get lowStockNotificationsEnabled => _lowStockNotificationsEnabled;
  bool get expenseNotificationsEnabled => _expenseNotificationsEnabled;
  bool get biometricAuthEnabled => _biometricAuthEnabled;
  
  Future<void> _loadSettings() async {
    // Load theme
    final themeModeString = await _storageService.getString('theme_mode');
    if (themeModeString != null) {
      switch (themeModeString) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
    }
    
    // Load language
    final languageCode = await _storageService.getString('language_code');
    if (languageCode != null) {
      _locale = Locale(languageCode);
    }
    
    // Load notifications settings
    _salesNotificationsEnabled = await _storageService.getBool('sales_notifications') ?? true;
    _lowStockNotificationsEnabled = await _storageService.getBool('low_stock_notifications') ?? true;
    _expenseNotificationsEnabled = await _storageService.getBool('expense_notifications') ?? true;
    
    // Load security settings
    _biometricAuthEnabled = await _storageService.getBool('biometric_auth') ?? false;
    
    notifyListeners();
  }
  
  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    
    String themeModeString;
    switch (themeMode) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      default:
        themeModeString = 'system';
    }
    
    await _storageService.setString('theme_mode', themeModeString);
    notifyListeners();
  }
  
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _storageService.setString('language_code', locale.languageCode);
    notifyListeners();
  }
  
  Future<void> setSalesNotifications(bool enabled) async {
    _salesNotificationsEnabled = enabled;
    await _storageService.setBool('sales_notifications', enabled);
    notifyListeners();
  }
  
  Future<void> setLowStockNotifications(bool enabled) async {
    _lowStockNotificationsEnabled = enabled;
    await _storageService.setBool('low_stock_notifications', enabled);
    notifyListeners();
  }
  
  Future<void> setExpenseNotifications(bool enabled) async {
    _expenseNotificationsEnabled = enabled;
    await _storageService.setBool('expense_notifications', enabled);
    notifyListeners();
  }
  
  Future<void> setBiometricAuth(bool enabled) async {
    _biometricAuthEnabled = enabled;
    await _storageService.setBool('biometric_auth', enabled);
    notifyListeners();
  }
}
