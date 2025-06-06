import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  Map<String, String> _localizedStrings = {};
  
  Future<bool> load() async {
    try {
      String jsonString = await rootBundle.loadString('assets/i18n/${locale.languageCode}.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      
      _localizedStrings = {};
      
      jsonMap.forEach((key, value) {
        if (value is String) {
          _localizedStrings[key] = value;
        } else if (value is Map) {
          _flattenMap(key, value as Map<String, dynamic>);
        }
      });
      
      return true;
    } catch (e) {
      print("Failed to load language file: $e");
      // Fallback to empty strings to avoid crashes
      return false;
    }
  }
  
  void _flattenMap(String prefix, Map<String, dynamic> map) {
    map.forEach((key, value) {
      if (value is String) {
        _localizedStrings['$prefix.$key'] = value;
      } else if (value is Map) {
        _flattenMap('$prefix.$key', value as Map<String, dynamic>);
      }
    });
  }
  
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
  
  // Common translations
  String get appName => translate('appName');
  String get shopManagement => translate('shopManagement');
  
  // Auth translations
  String get login => translate('auth.login');
  String get signup => translate('auth.signup');
  String get email => translate('auth.email');
  String get password => translate('auth.password');
  String get forgotPassword => translate('auth.forgotPassword');
  
  // Dashboard/Home
  String get dashboard => translate('dashboard');
  String get summary => translate('home.summary');
  
  // Inventory/Products
  String get inventory => translate('inventory.title');
  String get products => translate('inventory.products');
  String get addProduct => translate('inventory.addProduct');
  String get search => translate('common.search');
  String get all => translate('common.all');
  
  // Sales
  String get sales => translate('sales.title');
  String get addSale => translate('sales.addSale');
  
  // Expenses
  String get expenses => translate('expenses.title');
  String get addExpense => translate('expenses.addExpense');
  
  // Notifications
  String get notifications => translate('notifications.title');
  String get markAllAsRead => translate('notifications.markAllAsRead');
  String get noNotifications => translate('notifications.noNotifications');
  String get deleteNotification => translate('notifications.delete');
  String get deleteConfirmation => translate('notifications.deleteConfirmation');
  
  // Settings
  String get settings => translate('settings.title');
  String get theme => translate('settings.theme');
  String get language => translate('settings.language');
  
  // Common actions
  String get retry => translate('common.retry');
  String get refresh => translate('common.refresh');
  String get cancel => translate('common.cancel');
  String get delete => translate('common.delete');
  String get save => translate('common.save');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['en', 'sw'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension TranslateX on String {
  String tr(BuildContext context) {
    return AppLocalizations.of(context)!.translate(this);
  }
}
