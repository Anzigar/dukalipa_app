import 'package:flutter/foundation.dart';
import '../../presentation/features/auth/repositories/auth_repository.dart';
import '../../presentation/features/profile/models/user_profile.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  // States
  bool _isLoading = false;
  String? _error;
  String? _token;
  UserProfile? _userProfile;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get token => _token;
  UserProfile? get userProfile => _userProfile ?? _devUserProfile; // Fallback to dev profile
  bool get isLoggedIn => _token != null;
  
  // Development mode user profile
  final UserProfile _devUserProfile = UserProfile(
    id: 'dev-user-123',
    name: 'Dev User',
    email: 'dev@example.com',
    phone: '+255123456789',
    shopName: 'Dukalipa Dev Shop',
    createdAt: DateTime.now(),
  );
  
  AuthProvider(this._authRepository) {
    // In development mode, uncomment this to bypass authentication
    _token = 'dev-token';
    
    // For production, use this
    // _loadToken();
  }
  
  Future<void> _loadToken() async {
    _token = await _authRepository.getToken();
    if (_token != null) {
      await fetchUserProfile();
    }
    notifyListeners();
  }
  
  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _clearError();
    
    try {
      final token = await _authRepository.login(email: email, password: password);
      _token = token;
      
      // Fetch user profile after successful login
      await fetchUserProfile();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
  
  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required String shopName,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final token = await _authRepository.signup(
        name: name,
        email: email,
        password: password,
        shopName: shopName,
      );
      
      _token = token;
      
      // Fetch user profile after successful signup
      await fetchUserProfile();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
  
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _authRepository.logout();
      _token = null;
      _userProfile = null;
    } catch (e) {
      // Even if logout fails from server, clear local data
      _token = null;
      _userProfile = null;
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> fetchUserProfile() async {
    if (_token == null) return;
    
    _setLoading(true);
    try {
      final profile = await _authRepository.getUserProfile();
      _userProfile = profile;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
