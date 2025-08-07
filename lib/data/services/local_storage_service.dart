import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/app_constants.dart';
import '../models/user_profile.dart';

abstract class LocalStorageService {
  Future<String?> getToken();
  Future<String?> getRefreshToken();
  Future<void> setToken(String token);
  Future<void> setRefreshToken(String refreshToken);
  Future<void> clearToken();
  Future<void> clearTokens();
  Future<void> setUserProfile(UserProfile profile);
  Future<UserProfile?> getUserProfile();
  Future<void> clearUserData();
}

class LocalStorageServiceImpl implements LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageServiceImpl(this._prefs);

  @override
  Future<String?> getToken() async {
    return _prefs.getString(AppConstants.tokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _prefs.getString(AppConstants.refreshTokenKey);
  }

  @override
  Future<void> setToken(String token) async {
    await _prefs.setString(AppConstants.tokenKey, token);
  }

  @override
  Future<void> setRefreshToken(String refreshToken) async {
    await _prefs.setString(AppConstants.refreshTokenKey, refreshToken);
  }

  @override
  Future<void> clearToken() async {
    await _prefs.remove(AppConstants.tokenKey);
  }
  
  @override
  Future<void> clearTokens() async {
    await _prefs.remove(AppConstants.tokenKey);
    await _prefs.remove(AppConstants.refreshTokenKey);
  }

  @override
  Future<void> setUserProfile(UserProfile profile) async {
    final json = jsonEncode(profile.toJson());
    await _prefs.setString(AppConstants.userKey, json);
  }

  @override
  Future<UserProfile?> getUserProfile() async {
    final json = _prefs.getString(AppConstants.userKey);
    if (json == null) return null;
    
    try {
      return UserProfile.fromJson(jsonDecode(json));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearUserData() async {
    await clearTokens();
    await _prefs.remove(AppConstants.userKey);
  }
}
