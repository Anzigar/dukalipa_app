import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app/router/app_router.dart'; // This exports the core router
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/language_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/localization/app_localizations.dart';
import 'core/utils/app_constants.dart';
import 'presentation/features/auth/repositories/auth_repository.dart';
import 'presentation/features/notifications/repositories/notification_repository.dart';
import 'presentation/features/inventory/repositories/inventory_repository.dart';
import 'presentation/features/inventory/providers/inventory_provider.dart';
import 'presentation/features/home/repositories/analytics_repository.dart';
import 'presentation/features/home/providers/analytics_provider.dart';
import 'presentation/features/damaged/providers/damaged_products_provider.dart';
import 'presentation/features/returns/providers/returns_provider.dart';
import 'presentation/features/expenses/providers/expenses_provider.dart';

// Add Airbnb color constant
const Color airbnbRed = AppTheme.mkbhdLightRed;

/// Widget to update system UI overlay style based on theme
class SystemUIController extends StatelessWidget {
  final Widget child;
  final bool isDarkMode;

  const SystemUIController({
    Key? key,
    required this.child,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Update system UI overlay style based on theme
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDarkMode 
            ? AppTheme.metaDarkBackground 
            : AppTheme.metaLightBackground,
        systemNavigationBarIconBrightness: isDarkMode 
            ? Brightness.light 
            : Brightness.dark,
      ),
    );
    
    return child;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize service locator
  await setupServiceLocator();
  
  // Run app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Design size based on iPhone X dimensions
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => LanguageProvider()),
            // Fix: Use service locator to get AuthRepository dependency
            ChangeNotifierProvider(
              create: (_) => AuthProvider(locator<AuthRepository>()),
            ),
            // Fix: Use service locator to get NotificationRepository dependency
            ChangeNotifierProvider(
              create: (_) => NotificationProvider(locator<NotificationRepository>()),
            ),
            // Add inventory provider
            ChangeNotifierProvider(
              create: (_) => InventoryProvider(locator<InventoryRepository>()),
            ),
            // Add analytics provider
            ChangeNotifierProvider(
              create: (_) => AnalyticsProvider(locator<AnalyticsRepository>()),
            ),
            // Add damaged products provider
            ChangeNotifierProvider(
              create: (_) => locator<DamagedProductsProvider>(),
            ),
            // Add returns provider
            ChangeNotifierProvider(
              create: (_) => locator<ReturnsProvider>(),
            ),
            // Add expenses provider
            ChangeNotifierProvider(
              create: (_) => locator<ExpensesProvider>(),
            ),
          ],
          child: Consumer2<ThemeProvider, LanguageProvider>(
            builder: (context, themeProvider, languageProvider, _) {
              final isDarkMode = themeProvider.themeMode == ThemeMode.dark ||
                  (themeProvider.themeMode == ThemeMode.system &&
                      MediaQuery.platformBrightnessOf(context) == Brightness.dark);

              return SystemUIController(
                isDarkMode: isDarkMode,
                child: MaterialApp.router( 
                  title: AppConstants.appName,
                  debugShowCheckedModeBanner: false,
                  routerConfig: AppRouter.router, // Use AppRouter.router for routing configuration
                  theme: AppTheme.getLightTheme().copyWith(
                    textTheme: AppTheme.getLightTheme().textTheme.apply(
                      fontFamily: 'Montserrat',
                    ),
                    pageTransitionsTheme: const PageTransitionsTheme(
                      builders: {
                        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                      },
                    ),
                  ),
                  darkTheme: AppTheme.getDarkTheme().copyWith(
                    textTheme: AppTheme.getDarkTheme().textTheme.apply(
                      fontFamily: 'Montserrat',
                    ),
                    pageTransitionsTheme: const PageTransitionsTheme(
                      builders: {
                        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                      },
                    ),
                  ),
                  themeMode: themeProvider.themeMode,
                locale: languageProvider.locale,
                supportedLocales: const [
                  Locale('en', ''),
                  Locale('sw', ''),
                ],
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                // Add image caching and error handling configuration
                builder: (context, child) {
                  // Make sure child is never null
                  Widget childWidget = child ?? const SizedBox();
                  
                  // Configure error handling for all network images
                  // This adds a global fallback for all NetworkImage instances
                  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                    // Only customize network image errors
                    if (errorDetails.exception is NetworkImageLoadException) {
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Icon(
                            Icons.broken_image, // Using valid icon from Material library
                            color: Colors.grey[500],
                          ),
                        ),
                      );
                    }
                    // For other errors, use default error widget
                    return ErrorWidget(errorDetails.exception);
                  };
                  
                  // Initialize ScreenUtil for responsive design
                  return ScreenUtilInit(
                    designSize: const Size(375, 812), // iPhone 12 design size
                    minTextAdapt: true,
                    splitScreenMode: true,
                    builder: (context, child) {
                      return childWidget;
                    },
                  );
                },
              ),
            );
          },
        ),
        );
      },
    );
  }
}
