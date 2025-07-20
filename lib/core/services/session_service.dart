import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/user_profile.dart';

/// Service for managing secure user sessions with long-term authentication
class SessionService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      sharedPreferencesName: 'dukalipa_secure_prefs',
      preferencesKeyPrefix: 'dukalipa_',
    ),
    iOptions: IOSOptions(
      groupId: 'group.com.dukalipa.dukalipa-app',
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Storage keys
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserProfile = 'user_profile';
  static const String _keyLoginTime = 'login_time';
  static const String _keyRememberMe = 'remember_me';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyAutoLoginEnabled = 'auto_login_enabled';

  // Session configuration
  static const Duration _sessionDuration = Duration(days: 30); // 30 days like most apps
  static const Duration _refreshTokenDuration = Duration(days: 90); // 3 months
  static const Duration _extendedSessionDuration = Duration(days: 365); // 1 year for "Remember Me"

  /// Safe wrapper for secure storage reads with iOS entitlement error handling
  Future<String?> _safeRead(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      // Handle iOS Keychain entitlement errors gracefully in development
      if (e.toString().contains('-34018') || e.toString().contains('entitlement')) {
        // iOS Keychain access error - return null to indicate no stored value
        return null;
      }
      // Re-throw other errors
      rethrow;
    }
  }

  /// Save authentication tokens and user data
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required UserProfile userProfile,
    bool rememberMe = false,
    bool enableAutoLogin = true,
  }) async {
    final loginTime = DateTime.now().millisecondsSinceEpoch.toString();
    
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
      _storage.write(key: _keyUserProfile, value: jsonEncode(userProfile.toJson())),
      _storage.write(key: _keyLoginTime, value: loginTime),
      _storage.write(key: _keyRememberMe, value: rememberMe.toString()),
      _storage.write(key: _keyAutoLoginEnabled, value: enableAutoLogin.toString()),
    ]);
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    return await _safeRead(_keyAccessToken);
  }

  /// Get stored refresh token
  Future<String?> getRefreshToken() async {
    return await _safeRead(_keyRefreshToken);
  }

  /// Get stored user profile
  Future<UserProfile?> getUserProfile() async {
    try {
      final profileJson = await _safeRead(_keyUserProfile);
      if (profileJson != null) {
        return UserProfile.fromJson(jsonDecode(profileJson));
      }
    } catch (e) {
      print('Error retrieving user profile: $e');
    }
    return null;
  }

  /// Check if session is valid based on login time and remember me preference
  Future<bool> isSessionValid() async {
    try {
      final loginTimeStr = await _safeRead(_keyLoginTime);
      final rememberMeStr = await _safeRead(_keyRememberMe);
      final accessToken = await getAccessToken();

      if (loginTimeStr == null || accessToken == null) {
        return false;
      }

      final loginTime = DateTime.fromMillisecondsSinceEpoch(int.parse(loginTimeStr));
      final rememberMe = rememberMeStr?.toLowerCase() == 'true';
      final now = DateTime.now();

      // Determine session duration based on "Remember Me" preference
      final maxSessionDuration = rememberMe ? _extendedSessionDuration : _sessionDuration;
      
      // Check if session has expired
      final sessionExpired = now.difference(loginTime) > maxSessionDuration;
      
      return !sessionExpired;
    } catch (e) {
      // Handle iOS Keychain entitlement errors gracefully in development
      if (e.toString().contains('-34018') || e.toString().contains('entitlement')) {
        // iOS Keychain access error - this is expected in development mode
        // Return false to trigger normal login flow
        return false;
      }
      print('Error checking session validity: $e');
      return false;
    }
  }

  /// Check if auto-login is enabled
  Future<bool> isAutoLoginEnabled() async {
    final autoLoginStr = await _safeRead(_keyAutoLoginEnabled);
    return autoLoginStr?.toLowerCase() == 'true';
  }

  /// Check if biometric authentication is enabled
  Future<bool> isBiometricEnabled() async {
    final biometricStr = await _safeRead(_keyBiometricEnabled);
    return biometricStr?.toLowerCase() == 'true';
  }

  /// Enable/disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _keyBiometricEnabled, value: enabled.toString());
  }

  /// Update access token (for token refresh)
  Future<void> updateAccessToken(String newAccessToken) async {
    await _storage.write(key: _keyAccessToken, value: newAccessToken);
  }

  /// Update user profile
  Future<void> updateUserProfile(UserProfile userProfile) async {
    await _storage.write(key: _keyUserProfile, value: jsonEncode(userProfile.toJson()));
  }

  /// Extend session (update login time)
  Future<void> extendSession() async {
    final newLoginTime = DateTime.now().millisecondsSinceEpoch.toString();
    await _storage.write(key: _keyLoginTime, value: newLoginTime);
  }

    /// Check if refresh token is still valid
  Future<bool> isRefreshTokenValid() async {
    try {
      final loginTimeStr = await _safeRead(_keyLoginTime);
      final refreshToken = await getRefreshToken();

      if (loginTimeStr == null || refreshToken == null) {
        return false;
      }

      final loginTime = DateTime.fromMillisecondsSinceEpoch(int.parse(loginTimeStr));
      final now = DateTime.now();
      
      // Refresh token has a longer lifespan
      final refreshExpired = now.difference(loginTime) > _refreshTokenDuration;
      
      return !refreshExpired;
    } catch (e) {
      // Handle iOS Keychain entitlement errors gracefully
      if (e.toString().contains('-34018') || e.toString().contains('entitlement')) {
        return false;
      }
      print('Error checking refresh token validity: $e');
      return false;
    }
  }

  /// Get session info for debugging/display
  Future<Map<String, dynamic>> getSessionInfo() async {
    try {
      final loginTimeStr = await _safeRead(_keyLoginTime);
      final rememberMe = await _safeRead(_keyRememberMe);
      final autoLogin = await _safeRead(_keyAutoLoginEnabled);
      final biometric = await _safeRead(_keyBiometricEnabled);
      final hasAccessToken = await getAccessToken() != null;
      final hasRefreshToken = await getRefreshToken() != null;

      DateTime? loginTime;
      if (loginTimeStr != null) {
        loginTime = DateTime.fromMillisecondsSinceEpoch(int.parse(loginTimeStr));
      }

      return {
        'hasAccessToken': hasAccessToken,
        'hasRefreshToken': hasRefreshToken,
        'loginTime': loginTime?.toIso8601String(),
        'rememberMe': rememberMe == 'true',
        'autoLoginEnabled': autoLogin == 'true',
        'biometricEnabled': biometric == 'true',
        'sessionValid': await isSessionValid(),
        'refreshTokenValid': await isRefreshTokenValid(),
      };
    } catch (e) {
      print('Error getting session info: $e');
      return {};
    }
  }

  /// Clear all session data (logout)
  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyUserProfile),
      _storage.delete(key: _keyLoginTime),
      _storage.delete(key: _keyRememberMe),
      // Keep biometric and auto-login preferences
    ]);
  }

  /// Clear all data including preferences (complete reset)
  Future<void> clearAllData() async {
    await _storage.deleteAll();
  }

  /// Check if user has an existing session (even if expired)
  Future<bool> hasStoredSession() async {
    final accessToken = await getAccessToken();
    final userProfile = await getUserProfile();
    return accessToken != null && userProfile != null;
  }

  /// Get remaining session time
  Future<Duration?> getRemainingSessionTime() async {
    try {
      final loginTimeStr = await _safeRead(_keyLoginTime);
      final rememberMeStr = await _safeRead(_keyRememberMe);

      if (loginTimeStr == null) return null;

      final loginTime = DateTime.fromMillisecondsSinceEpoch(int.parse(loginTimeStr));
      final rememberMe = rememberMeStr?.toLowerCase() == 'true';
      final maxSessionDuration = rememberMe ? _extendedSessionDuration : _sessionDuration;
      
      final expiryTime = loginTime.add(maxSessionDuration);
      final now = DateTime.now();
      
      if (expiryTime.isAfter(now)) {
        return expiryTime.difference(now);
      } else {
        return Duration.zero;
      }
    } catch (e) {
      print('Error calculating remaining session time: $e');
      return null;
    }
  }
}
