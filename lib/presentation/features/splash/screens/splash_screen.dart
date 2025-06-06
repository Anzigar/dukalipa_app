import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _animationController;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    
    // Set up animation controller for the Lottie animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    
    // Play the animation
    _animationController.forward();
    
    // Set a 5-second timer before navigating to the next screen
    _timer = Timer(const Duration(seconds: 5), () {
      if (mounted && !_isNavigating) {
        _navigateToNextScreen();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextScreen() async {
    // Prevent multiple navigation attempts
    if (_isNavigating) return;
    
    setState(() {
      _isNavigating = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final bool isLoggedIn = authProvider.isLoggedIn;

      if (isLoggedIn) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    } catch (e) {
      debugPrint('Error during navigation: $e');
      // If AuthProvider isn't available, go to login as a fallback
      if (mounted) {
        context.go('/login');
      }
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
              // App logo
              Container(
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
              const SizedBox(height: 24),
              // App Name
              Text(
                appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
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
              // Lottie animation from assets/animations folder
              SizedBox(
                width: 100,
                height: 100,
                child: Lottie.asset(
                  'assets/animations/loader2.json',
                  controller: _animationController,
                  fit: BoxFit.contain,
                  onLoaded: (composition) {
                    // Adjust animation controller duration to match the composition
                    _animationController.duration = composition.duration;
                    _animationController.forward();
                  },
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Lottie error: $error');
                    // Fallback to a basic loading indicator if Lottie fails
                    return const CircularProgressIndicator(
                      color: AppTheme.mkbhdRed,
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Loading text
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
