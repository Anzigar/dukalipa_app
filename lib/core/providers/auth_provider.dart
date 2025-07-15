import 'package:flutter/foundation.dart';
import 'package:dukalipa_app/presentation/features/auth/repositories/auth_repository.dart';
import '../../data/models/user_profile.dart';
import '../services/session_service.dart';

class AuthProvider extends ChangeNotifier {
  UserProfile? _userProfile;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  final SessionService _sessionService = SessionService();

  AuthProvider(AuthRepository authRepository);

  // Getters
  UserProfile? get userProfile => _userProfile;
  UserProfile? get user => _userProfile; // Add this getter for compatibility
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoggedIn => _isAuthenticated; // Add this getter for compatibility
  bool get isLoading => _isLoading;

  // Update user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    _userProfile = profile;
    // Save updated profile to secure storage
    await _sessionService.updateUserProfile(profile);
    notifyListeners();
  }

  // Login method with persistent session
  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual login logic with API
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      // Mock user profile for testing
      _userProfile = UserProfile(
        id: '1',
        name: 'John Doe',
        email: email,
        phone: '+1234567890',
        shopName: 'Demo Shop',
        shopAddress: '123 Main St, City',
        shopPhone: '+1987654321',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      );
      
      _isAuthenticated = true;
      
      // Save session with long-term authentication
      await _sessionService.saveSession(
        accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        userProfile: _userProfile!,
        rememberMe: rememberMe,
        enableAutoLogin: true,
      );
      
      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout method with session cleanup
  Future<void> logout() async {
    _userProfile = null;
    _isAuthenticated = false;
    // Clear stored session
    await _sessionService.clearSession();
    notifyListeners();
  }

  // Check authentication status and restore session
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if valid session exists
      final isSessionValid = await _sessionService.isSessionValid();
      final isAutoLoginEnabled = await _sessionService.isAutoLoginEnabled();
      
      if (isSessionValid && isAutoLoginEnabled) {
        // Restore user profile from session
        _userProfile = await _sessionService.getUserProfile();
        _isAuthenticated = _userProfile != null;
        
        if (_isAuthenticated) {
          // Extend session on successful auto-login
          await _sessionService.extendSession();
        }
      } else {
        // Session expired or invalid
        _isAuthenticated = false;
        _userProfile = null;
        
        // Check if refresh token is valid for silent refresh
        final isRefreshValid = await _sessionService.isRefreshTokenValid();
        if (isRefreshValid) {
          // TODO: Implement token refresh logic
          // await _refreshToken();
        }
      }
    } catch (e) {
      // Log the error for debugging
      if (kDebugMode) {
        print('Error checking session validity: $e');
      }
      _isAuthenticated = false;
      _userProfile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get user profile
  Future<void> getUserProfile() async {
    // TODO: Implement logic to fetch and update user profile
    // Example:
    // _userProfile = await apiService.fetchUserProfile();
    // notifyListeners();
  }

  // Sign up with persistent session
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String shopName,
    bool rememberMe = false,
    // Add other fields as needed
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual signup logic with API
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      // Mock user profile for testing
      _userProfile = UserProfile(
        id: '1',
        name: name.trim(),
        email: email.trim(),
        phone: '', // Add phone if needed
        shopName: shopName.trim(),
        shopAddress: '', // Add shopAddress if needed
        shopPhone: '', // Add shopPhone if needed
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _isAuthenticated = true;
      
      // Save session with long-term authentication
      await _sessionService.saveSession(
        accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        userProfile: _userProfile!,
        rememberMe: rememberMe,
        enableAutoLogin: true,
      );
      
      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh authentication token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _sessionService.getRefreshToken();
      if (refreshToken == null || !await _sessionService.isRefreshTokenValid()) {
        return false;
      }

      // TODO: Implement actual token refresh with API
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
      
      // Mock new access token
      final newAccessToken = 'refreshed_access_token_${DateTime.now().millisecondsSinceEpoch}';
      await _sessionService.updateAccessToken(newAccessToken);
      
      // Extend session
      await _sessionService.extendSession();
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get session information for debugging
  Future<Map<String, dynamic>> getSessionInfo() async {
    return await _sessionService.getSessionInfo();
  }

  // Check if user has any stored session
  Future<bool> hasStoredSession() async {
    try {
      return await _sessionService.hasStoredSession();
    } catch (e) {
      if (kDebugMode) {
        print('Error checking stored session: $e');
      }
      return false;
    }
  }

  // Initialize auth provider - call this on app startup
  Future<void> initialize() async {
    await checkAuthStatus();
  }

  // Enable/disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    await _sessionService.setBiometricEnabled(enabled);
  }

  // Check if biometric is enabled
  Future<bool> isBiometricEnabled() async {
    return await _sessionService.isBiometricEnabled();
  }

  // Get session validity status
  Future<bool> isSessionValid() async {
    try {
      return await _sessionService.isSessionValid();
    } catch (e) {
      if (kDebugMode) {
        print('Error checking session validity: $e');
      }
      return false;
    }
  }

  // Check if auto-login is enabled
  Future<bool> isAutoLoginEnabled() async {
    try {
      return await _sessionService.isAutoLoginEnabled();
    } catch (e) {
      if (kDebugMode) {
        print('Error checking auto-login status: $e');
      }
      return false;
    }
  }

  // Force session restoration (for testing)
  Future<bool> restoreSession() async {
    try {
      await checkAuthStatus();
      return _isAuthenticated;
    } catch (e) {
      if (kDebugMode) {
        print('Error restoring session: $e');
      }
      return false;
    }
  }
}
