
import '../../../../core/network/api_client.dart';
import '../../../../data/services/local_storage_service.dart';
import '../../profile/models/user_profile.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Future<String> login({required String email, required String password});
  Future<String> signup({
    required String name, 
    required String email, 
    required String password, 
    required String shopName,
  });
  Future<void> logout();
  Future<UserProfile?> getUserProfile();
  Future<String?> getToken();
}

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final LocalStorageService _storageService;
  
  AuthRepositoryImpl(this._apiClient, this._storageService);
  
  @override
  Future<String> login({required String email, required String password}) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      
      final token = response['token'];
      final userData = response['user'];
      
      // Store token
      await _storageService.setToken(token);
      
      // Store user profile
      final userModel = UserModel.fromJson(userData);
      final userProfile = _convertToUserProfile(userModel);
      await _storageService.setUserProfile(userProfile);
      
      return token;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<String> signup({
    required String name, 
    required String email, 
    required String password, 
    required String shopName,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'shop_name': shopName,
        },
      );
      
      final token = response['token'];
      final userData = response['user'];
      
      // Store token
      await _storageService.setToken(token);
      
      // Store user profile
      final userModel = UserModel.fromJson(userData);
      final userProfile = _convertToUserProfile(userModel);
      await _storageService.setUserProfile(userProfile);
      
      return token;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      await _storageService.clearTokens();
      await _storageService.clearUserData();
    }
  }
  
  @override
  Future<UserProfile?> getUserProfile() async {
    try {
      // Check for stored user profile first
      final userProfile = await _storageService.getUserProfile();
      if (userProfile != null) {
        return userProfile;
      }
      
      // If no profile stored, fetch from API
      final token = await _storageService.getToken();
      if (token == null) {
        return null;
      }
      
      final response = await _apiClient.get('/auth/me');
      final userModel = UserModel.fromJson(response);
      final newProfile = _convertToUserProfile(userModel);
      
      // Cache the profile
      await _storageService.setUserProfile(newProfile);
      
      return newProfile;
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<String?> getToken() async {
    return _storageService.getToken();
  }
  
  // Helper method to convert UserModel to UserProfile
  UserProfile _convertToUserProfile(UserModel model) {
    return UserProfile(
      id: model.id,
      name: model.name,
      email: model.email,
      phone: model.phoneNumber,
      shopName: model.shopName,
      avatarUrl: model.profileImage,
      createdAt: DateTime.now(), // Since we don't have this in UserModel
    );
  }
  
  String _handleError(dynamic error) {
    if (error is Exception) {
      return 'An unexpected error occurred';
    }
    return error.toString();
  }
}
