import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/app_initialization_service.dart';
import '../../../common/widgets/shimmer_loading.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    
    // Use post-frame callback to prevent setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize the app and check for existing sessions
      await AppInitializationService.initialize(context);
      
      // Wait minimum 3 seconds for smooth UX
      await Future.delayed(const Duration(seconds: 3));
      
      if (mounted && !_isNavigating) {
        await _navigateToNextScreen();
      }
    } catch (e) {
      debugPrint('App initialization error: $e');
      // Wait minimum time and navigate to login as fallback
      await Future.delayed(const Duration(seconds: 3));
      if (mounted && !_isNavigating) {
        _navigateToLogin();
      }
    }
  }

  Future<void> _navigateToNextScreen() async {
    // Prevent multiple navigation attempts
    if (_isNavigating) return;
    
    setState(() {
      _isNavigating = true;
    });

    try {
      // Wait a bit for any initialization to complete
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Always navigate to home page regardless of authentication status
      debugPrint('Navigating to home page');
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      debugPrint('Error during navigation: $e');
      // Still navigate to home page even if there's an error
      if (mounted) {
        context.go('/home');
      }
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appName = l10n?.appName ?? 'Dukalipa';
    final shopManagement = l10n?.shopManagement ?? 'Shop Management';

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo with shimmer effect
              ShimmerLoading(
                child: Container(
                  width: size.width * 0.3,
                  height: size.width * 0.3,
                  decoration: BoxDecoration(
                    color: AppTheme.mkbhdRed,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      'D',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // App Name with shimmer effect
              ShimmerLoading(
                child: Text(
                  appName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // App subtitle
              Text(
                shopManagement,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 48),
              // Shimmer loading animation
              SizedBox(
                width: 120,
                height: 120,
                child: ShimmerLoading(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.mkbhdRed.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Icon(
                          Icons.store,
                          color: AppTheme.mkbhdRed,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Shimmer loading text
              ShimmerLoading(
                child: Container(
                  width: 100,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
