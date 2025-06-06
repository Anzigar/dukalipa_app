import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lumina/app/router/app_router.dart';
import 'package:provider/provider.dart';
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

// Add Airbnb color constant
const Color airbnbRed = Color(0xFFFF385C);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style for MKBHD-inspired look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.mkbhdDarkGrey,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
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
          ],
          child: Consumer2<ThemeProvider, LanguageProvider>(
            builder: (context, themeProvider, languageProvider, _) {
              return MaterialApp.router( 
                title: AppConstants.appName,
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  useMaterial3: true,
                  brightness: Brightness.light,
                  scaffoldBackgroundColor: Colors.white,
                  primaryColor: airbnbRed,
                  colorScheme: const ColorScheme.light(
                    primary: airbnbRed,
                    secondary: airbnbRed,
                  ),
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    iconTheme: IconThemeData(color: Colors.black87),
                    titleTextStyle: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  floatingActionButtonTheme: const FloatingActionButtonThemeData(
                    backgroundColor: airbnbRed,
                    foregroundColor: Colors.white,
                    elevation: 4,
                  ),
                  inputDecorationTheme: const InputDecorationTheme(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  cardTheme: CardThemeData(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    shadowColor: Colors.black.withOpacity(0.05),
                  ),
                  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                    backgroundColor: Colors.white,
                    selectedItemColor: airbnbRed,
                    unselectedItemColor: Colors.black54,
                    showUnselectedLabels: true,
                    type: BottomNavigationBarType.fixed,
                  ),
                  pageTransitionsTheme: const PageTransitionsTheme(
                    builders: {
                      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                    },
                  ),
                  splashColor: airbnbRed.withOpacity(0.08),
                  highlightColor: airbnbRed.withOpacity(0.04),
                  dividerColor: Colors.grey.shade200,
                  iconTheme: const IconThemeData(color: airbnbRed),
                  textTheme: ThemeData.light().textTheme.apply(
                        fontFamily: 'Montserrat',
                        bodyColor: Colors.black87,
                        displayColor: Colors.black87,
                      ),
                ),
                darkTheme: ThemeData.dark().copyWith(
                  primaryColor: airbnbRed,
                  colorScheme: const ColorScheme.dark(
                    primary: airbnbRed,
                    secondary: airbnbRed,
                  ),
                  floatingActionButtonTheme: const FloatingActionButtonThemeData(
                    backgroundColor: airbnbRed,
                    foregroundColor: Colors.white,
                  ),
                  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                    backgroundColor: Colors.black,
                    selectedItemColor: airbnbRed,
                    unselectedItemColor: Colors.white70,
                  ),
                  cardTheme: CardThemeData(
                    color: Colors.grey[900],
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    shadowColor: Colors.black.withOpacity(0.1),
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: Colors.grey[900],
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  dividerColor: Colors.grey.shade800,
                  iconTheme: const IconThemeData(color: airbnbRed),
                  textTheme: ThemeData.dark().textTheme.apply(
                        fontFamily: 'Montserrat',
                        bodyColor: Colors.white,
                        displayColor: Colors.white,
                      ),
                ),
                themeMode: themeProvider.themeMode,
                routerConfig: appRouter,
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
                  
                  return childWidget;
                },
              );
            },
          ),
        );
      },
    );
  }
}
