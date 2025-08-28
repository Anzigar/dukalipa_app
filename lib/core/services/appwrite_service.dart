import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../../config/environment.dart';
import '../../data/models/user_profile.dart';

class AppwriteService {
  static final AppwriteService _instance = AppwriteService._internal();
  factory AppwriteService() => _instance;
  AppwriteService._internal();

  late Client _client;
  late Account _account;
  late Databases _databases;
  late Storage _storage;

  static const String _databaseId = 'shop_management_db';
  static const String _usersCollectionId = 'users';
  static const String _productsCollectionId = 'products';
  static const String _salesCollectionId = 'sales';
  static const String _productImagesBucketId = 'product_images';

  void initialize() {
    _client = Client();
    _client
        .setEndpoint(Environment.appwritePublicEndpoint)
        .setProject(Environment.appwriteProjectId)
        .setSelfSigned(status: true);

    _account = Account(_client);
    _databases = Databases(_client);
    _storage = Storage(_client);
  }

  // Email/Password Authentication
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String shopName,
  }) async {
    try {
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      // Create user profile in database
      await _createUserProfile(
        userId: user.$id,
        email: email,
        name: name,
        shopName: shopName,
      );

      // Create session if not already exists
      try {
        await _account.createEmailSession(
          email: email,
          password: password,
        );
      } catch (e) {
        // If session already exists, that's fine for signup
        if (!e.toString().contains('user_session_already_exists')) {
          rethrow;
        }
      }

      return user;
    } catch (e) {
      if (kDebugMode) {
        print('Signup error: $e');
      }
      rethrow;
    }
  }

  Future<Session?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Check if user already has an active session
      final existingUser = await getCurrentUser();
      if (existingUser != null) {
        // User already has active session, return current session
        final sessions = await _account.listSessions();
        return sessions.sessions.isNotEmpty ? sessions.sessions.first : null;
      }

      // Create new session if no active session
      final session = await _account.createEmailSession(
        email: email,
        password: password,
      );
      return session;
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      rethrow;
    }
  }

  // Google Sign-In
  Future<Session?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null) {
        throw Exception('Failed to get Google access token');
      }

      // Use Appwrite OAuth2 session creation for Google
      try {
        await _account.createOAuth2Session(
          provider: 'google',
          success: '${Environment.appwritePublicEndpoint}/auth/oauth2/success',
          failure: '${Environment.appwritePublicEndpoint}/auth/oauth2/failure',
        );

        // Get the created session
        final sessions = await _account.listSessions();
        final session = sessions.sessions.isNotEmpty ? sessions.sessions.first : null;

        if (session != null) {
          // Create or update user profile after successful authentication
          final user = await getCurrentUser();
          if (user != null) {
            await _createUserProfile(
              userId: user.$id,
              email: googleUser.email,
              name: googleUser.displayName ?? user.name,
              shopName: '', // Will be set by user later
            );
          }
        }

        return session;
      } catch (e) {
        if (kDebugMode) {
          print('Appwrite OAuth2 session creation failed: $e');
          print('Falling back to manual Google auth handling');
        }
        
        // Fallback: Return null and handle Google auth in the UI layer
        return null;
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('Google sign-in error: $e');
      }
      rethrow;
    }
  }


  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      return await _account.get();
    } catch (e) {
      if (kDebugMode) {
        print('Get current user error: $e');
      }
      return null;
    }
  }

  // Get current session
  Future<Session?> getCurrentSession() async {
    try {
      final user = await getCurrentUser();
      if (user == null) return null;
      
      final sessions = await _account.listSessions();
      return sessions.sessions.isNotEmpty ? sessions.sessions.first : null;
    } catch (e) {
      if (kDebugMode) {
        print('Get current session error: $e');
      }
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: $e');
      }
      rethrow;
    }
  }

  // Password reset
  Future<void> resetPassword({required String email}) async {
    try {
      await _account.createRecovery(
        email: email,
        url: 'your-app://reset-password',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Password reset error: $e');
      }
      rethrow;
    }
  }

  // Update password
  Future<void> updatePassword({
    required String newPassword,
    String? oldPassword,
  }) async {
    try {
      await _account.updatePassword(
        password: newPassword,
        oldPassword: oldPassword,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Update password error: $e');
      }
      rethrow;
    }
  }

  // Database operations for user profiles
  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String name,
    required String shopName,
  }) async {
    try {
      await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: _usersCollectionId,
        documentId: userId,
        data: {
          'user_id': userId,
          'email': email,
          'name': name,
          'shop_name': shopName,
          'phone': '',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Create user profile error: $e');
      }
      rethrow;
    }
  }


  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final document = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: _usersCollectionId,
        documentId: userId,
      );

      return UserProfile(
        id: document.data['user_id'] ?? '',
        name: document.data['name'] ?? '',
        email: document.data['email'] ?? '',
        phone: document.data['phone'] ?? '',
        shopName: document.data['shop_name'] ?? '',
        shopAddress: document.data['shop_address'] ?? '',
        shopPhone: document.data['shop_phone'] ?? '',
        createdAt: DateTime.parse(document.data['created_at'] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(document.data['updated_at'] ?? DateTime.now().toIso8601String()),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Get user profile error: $e');
      }
      return null;
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _usersCollectionId,
        documentId: userId,
        data: {
          ...data,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Update user profile error: $e');
      }
      rethrow;
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final user = await getCurrentUser();
      return user != null;
    } catch (e) {
      return false;
    }
  }

  // Getters for service instances (for use in other services)
  Client get client => _client;
  Account get account => _account;
  Databases get databases => _databases;
  Storage get storage => _storage;

  // Database and collection IDs getters
  String get databaseId => _databaseId;
  String get usersCollectionId => _usersCollectionId;
  String get productsCollectionId => _productsCollectionId;
  String get salesCollectionId => _salesCollectionId;
  String get productImagesBucketId => _productImagesBucketId;
}