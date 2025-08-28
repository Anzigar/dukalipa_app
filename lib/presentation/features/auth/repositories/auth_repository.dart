import '../../../../data/models/user_profile.dart';

abstract class AuthRepository {
  Future<String> login({
    required String email,
    required String password,
  });

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