import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Service for initializing the app and checking authentication status
class AppInitializationService {
  static Future<void> initialize(BuildContext context) async {
    try {
      // Get the auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Check authentication status and restore session if valid
      await authProvider.checkAuthStatus();
      
      // Additional initialization tasks can be added here
      // - Initialize notifications
      // - Check app version
      // - Load user preferences
      // - Initialize analytics
      
    } catch (e) {
      // Handle initialization errors
      debugPrint('App initialization error: $e');
    }
  }

  /// Check if user should be automatically logged in
  static Future<bool> shouldAutoLogin(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Check if user has stored session and it's valid
      final hasStoredSession = await authProvider.hasStoredSession();
      if (!hasStoredSession) return false;
      
      // Let checkAuthStatus handle the validation and restoration
      await authProvider.checkAuthStatus();
      
      return authProvider.isAuthenticated;
    } catch (e) {
      debugPrint('Auto login check error: $e');
      return false;
    }
  }
}
