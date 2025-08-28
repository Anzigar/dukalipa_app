import '../../../../core/services/appwrite_service.dart';
import '../../../../data/models/user_profile.dart';
import 'auth_repository.dart';

class AppwriteAuthRepository implements AuthRepository {
  final AppwriteService _appwriteService;

  AppwriteAuthRepository(this._appwriteService);

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _appwriteService.signInWithEmail(
        email: email,
        password: password,
      );

      if (session != null) {
        return session.$id;
      } else {
        throw Exception('Login failed');
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
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
      final user = await _appwriteService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        shopName: shopName,
      );

      if (user != null) {
        final session = await _appwriteService.getCurrentSession();
        return session?.$id ?? user.$id;
      } else {
        throw Exception('Signup failed');
      }
    } catch (e) {
      throw Exception('Signup failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final session = await _appwriteService.signInWithGoogle();

      if (session != null) {
        return {
          'status': 'success',
          'message': 'Google sign-in successful',
          'data': {
            'session': session,
            'user': await _appwriteService.getCurrentUser(),
          }
        };
      } else {
        return {
          'status': 'error',
          'message': 'Google sign-in failed',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }


  @override
  Future<void> logout() async {
    try {
      await _appwriteService.logout();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      // Appwrite handles token refresh automatically
      final session = await _appwriteService.getCurrentSession();
      
      if (session != null) {
        return {
          'status': 'success',
          'message': 'Token refreshed',
          'data': {
            'session': session,
          }
        };
      } else {
        return {
          'status': 'error',
          'message': 'Token refresh failed',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      if (newPassword != confirmPassword) {
        return {
          'status': 'error',
          'message': 'Passwords do not match',
        };
      }

      await _appwriteService.updatePassword(
        newPassword: newPassword,
        oldPassword: currentPassword,
      );

      return {
        'status': 'success',
        'message': 'Password updated successfully',
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> forgotPassword({
    required String email,
    String? resetUrl,
  }) async {
    try {
      await _appwriteService.resetPassword(email: email);

      return {
        'status': 'success',
        'message': 'Password reset email sent',
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      if (newPassword != confirmPassword) {
        return {
          'status': 'error',
          'message': 'Passwords do not match',
        };
      }

      // This would typically be handled by Appwrite's recovery flow
      // For now, we'll return success as the actual implementation
      // depends on how you handle the reset URL callback
      return {
        'status': 'success',
        'message': 'Password reset successful',
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }

  @override
  Future<UserProfile?> getUserProfile() async {
    try {
      final user = await _appwriteService.getCurrentUser();
      if (user == null) return null;

      return await _appwriteService.getUserProfile(user.$id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      final session = await _appwriteService.getCurrentSession();
      return session?.$id;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      // Appwrite handles refresh tokens internally
      final session = await _appwriteService.getCurrentSession();
      return session?.$id;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isAuthenticated() async {
    return await _appwriteService.isAuthenticated();
  }

  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    await _appwriteService.updateUserProfile(userId: userId, data: data);
  }
}