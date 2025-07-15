import 'package:flutter/foundation.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../data/models/user_profile.dart';

class EditProfileViewModel extends ChangeNotifier {
  final AuthProvider _authProvider;
  
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  UserProfile? _userProfile;

  EditProfileViewModel(this._authProvider);

  // Getters
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  UserProfile? get userProfile => _userProfile;

  // Load current user profile data
  Future<void> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get current user profile from auth provider or API
      final presentationProfile = _authProvider.userProfile;
      if (presentationProfile != null) {
        // Ensure proper type assignment - presentationProfile is already UserProfile?
        _userProfile = presentationProfile;
      } else {
        _userProfile = null;
      }
      
      if (_userProfile == null) {
        // Fetch from API if not available
        // TODO: Implement API call to fetch user profile
        throw Exception('User profile not found');
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save updated profile
  Future<bool> saveProfile({
    required String name,
    required String email,
    required String phone,
    String? shopName,
    String? shopAddress,
    String? shopPhone,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate required fields
      if (name.trim().isEmpty || email.trim().isEmpty) {
        throw Exception('Name and email are required');
      }

      // Email validation
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim())) {
        throw Exception('Please enter a valid email address');
      }

      // Create updated profile
      final updatedProfile = UserProfile(
        id: _userProfile?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim().isEmpty ? null : phone.trim(),
        shopName: shopName?.trim().isEmpty == true ? null : shopName?.trim(),
        shopAddress: shopAddress?.trim().isEmpty == true ? null : shopAddress?.trim(),
        shopPhone: shopPhone?.trim().isEmpty == true ? null : shopPhone?.trim(),
        createdAt: _userProfile?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // TODO: Implement API call to update profile
      // await _profileService.updateProfile(updatedProfile);
      
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Update local profile
      _userProfile = updatedProfile;
      
      // Update auth provider with new profile
      await _authProvider.updateUserProfile(updatedProfile);
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSaving = false;
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
