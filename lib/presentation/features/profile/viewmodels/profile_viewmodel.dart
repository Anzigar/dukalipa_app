import 'package:flutter/material.dart';
import '../../../../core/providers/auth_provider.dart';

class ProfileViewModel with ChangeNotifier {
  final AuthProvider _authProvider;
  bool _isLoading = false;

  ProfileViewModel(this._authProvider);

  bool get isLoading => _isLoading;
  
  // Getter for user profile from auth provider
  get userProfile => _authProvider.userProfile;

  Future<void> loadUserProfile() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _authProvider.fetchUserProfile();
    } catch (e) {
      rethrow; // Let the UI handle error messaging
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> logout() async {
    await _authProvider.logout();
  }
  
  String getInitials(String name) {
    if (name.isEmpty) return '';
    
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    } else if (nameParts.length == 1 && nameParts[0].isNotEmpty) {
      return nameParts[0][0];
    }
    
    return '';
  }
}
