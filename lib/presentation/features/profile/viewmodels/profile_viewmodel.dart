import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../data/models/user_profile.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthProvider _authProvider;
  
  bool _isLoading = false;
  String? _errorMessage;
  UserProfile? _userProfile;

  ProfileViewModel(this._authProvider);

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserProfile? get userProfile => _userProfile;

  // Load current user profile data
  Future<void> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get current user profile from auth provider
      _userProfile = _authProvider.userProfile;
      
      if (_userProfile == null) {
        // If no profile in auth provider, try to fetch from API
        // TODO: Implement API call to fetch user profile
        // For now, create a default profile if user is authenticated
        if (_authProvider.isAuthenticated) {
          _userProfile = UserProfile(
            id: '1',
            name: 'Demo User',
            email: 'demo@example.com',
            phone: '+1234567890',
            shopName: 'Demo Shop',
            shopAddress: '123 Demo Street',
            shopPhone: '+1987654321',
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
            updatedAt: DateTime.now(),
          );
          
          // Update auth provider with this profile
          await _authProvider.updateUserProfile(_userProfile!);
        } else {
          throw Exception('User not authenticated');
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      await _authProvider.logout();
      _userProfile = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
