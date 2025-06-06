import 'package:shared_preferences/shared_preferences.dart';

abstract class StorageService {
  Future<String?> getString(String key);
  Future<bool> setString(String key, String value);
  
  Future<bool?> getBool(String key);
  Future<bool> setBool(String key, bool value);
  
  Future<int?> getInt(String key);
  Future<bool> setInt(String key, int value);
  
  Future<double?> getDouble(String key);
  Future<bool> setDouble(String key, double value);
  
  Future<bool> remove(String key);
  Future<bool> clear();
}

class SharedPreferencesService implements StorageService {
  final SharedPreferences _prefs;
  
  SharedPreferencesService(this._prefs);
  
  @override
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }
  
  @override
  Future<bool> setString(String key, String value) async {
    return _prefs.setString(key, value);
  }
  
  @override
  Future<bool?> getBool(String key) async {
    return _prefs.getBool(key);
  }
  
  @override
  Future<bool> setBool(String key, bool value) async {
    return _prefs.setBool(key, value);
  }
  
  @override
  Future<int?> getInt(String key) async {
    return _prefs.getInt(key);
  }
  
  @override
  Future<bool> setInt(String key, int value) async {
    return _prefs.setInt(key, value);
  }
  
  @override
  Future<double?> getDouble(String key) async {
    return _prefs.getDouble(key);
  }
  
  @override
  Future<bool> setDouble(String key, double value) async {
    return _prefs.setDouble(key, value);
  }
  
  @override
  Future<bool> remove(String key) async {
    return _prefs.remove(key);
  }
  
  @override
  Future<bool> clear() async {
    return _prefs.clear();
  }
}
