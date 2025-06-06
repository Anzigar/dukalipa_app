import 'package:flutter/material.dart';

/// Main theme class for the application
class AppTheme {
  // MKBHD Red color scheme
  static const Color mkbhdRed = Color(0xFFE01D1D);
  static const Color mkbhdDarkRed = Color(0xFFBF0000);
  static const Color mkbhdLightRed = Color(0xFFFF6B6B);
  
  // MKBHD Grey color scheme
  static const Color mkbhdDarkGrey = Color(0xFF333333);
  static const Color mkbhdGrey = Color(0xFF666666);
  static const Color mkbhdLightGrey = Color(0xFF9E9E9E);
  
  // Meta-style background colors
  static const Color metaLightBackground = Color(0xFFF5F5F5);
  static const Color metaDarkBackground = Color(0xFF18191A);
  static const Color metaLightSurface = Colors.white;
  static const Color metaDarkSurface = Color(0xFF242526);
  static const Color metaLightCardColor = Colors.white;
  static const Color metaDarkCardColor = Color(0xFF3A3B3C);
  
  // Meta-style rounded corner radiuses
  static const double cornerRadiusSmall = 8.0;
  static const double cornerRadiusMedium = 12.0;
  static const double cornerRadiusLarge = 16.0;
  static const double cornerRadiusXLarge = 20.0;
  
  // Meta-style elevations
  static const double elevationNone = 0.0;
  static const double elevationXSmall = 1.0;
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;
  
  // Meta-style spacing
  static const double spacingXXSmall = 2.0;
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;
  
  // Meta-style font sizes
  static const double fontSizeXSmall = 10.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeXXLarge = 20.0;
  static const double fontSizeTitle = 24.0;
  static const double fontSizeHeadline = 28.0;

  // Add Airbnb-style colors to the existing AppTheme class
  static const Color airbnbRed = Color(0xFFFF5A5F);
  static const Color airbnbDarkGrey = Color(0xFF484848);
  static const Color airbnbLightGrey = Color(0xFF767676);
  static const Color airbnbBlue = Color(0xFF428BFF);
  static const Color airbnbLightBg = Color(0xFFF7F7F7);
  
  /// Get the light theme
  static ThemeData getLightTheme() {
    return ThemeData(
      primaryColor: mkbhdRed,
      colorScheme: ColorScheme.light(
        primary: mkbhdRed,
        onPrimary: Colors.white,
        secondary: mkbhdDarkRed,
        onSecondary: Colors.white,
        surface: metaLightSurface,
        error: Colors.red.shade700,
      ),
      scaffoldBackgroundColor: metaLightBackground,
      cardColor: metaLightCardColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: metaLightSurface,
        elevation: elevationXSmall,
        centerTitle: false,
        foregroundColor: mkbhdDarkGrey,
      ),
      textTheme: _buildTextTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(false),
      elevatedButtonTheme: _buildElevatedButtonTheme(false),
      outlinedButtonTheme: _buildOutlinedButtonTheme(false),
      textButtonTheme: _buildTextButtonTheme(false),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: mkbhdRed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(cornerRadiusLarge)),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: elevationSmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadiusMedium),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadiusLarge),
        ),
      ),
      dividerTheme: const DividerThemeData(
        thickness: 0.5,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(cornerRadiusXLarge),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: mkbhdRed.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: fontSizeSmall,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }

  /// Get the dark theme
  static ThemeData getDarkTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: mkbhdRed,
      colorScheme: ColorScheme.dark(
        primary: mkbhdRed,
        onPrimary: Colors.white,
        secondary: mkbhdLightRed,
        onSecondary: Colors.white,
        surface: metaDarkSurface,
        error: Colors.red.shade300,
      ),
      scaffoldBackgroundColor: metaDarkBackground,
      cardColor: metaDarkCardColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: metaDarkSurface,
        elevation: elevationNone,
        centerTitle: false,
        foregroundColor: Colors.white,
      ),
      textTheme: _buildTextTheme(true),
      inputDecorationTheme: _buildInputDecorationTheme(true),
      elevatedButtonTheme: _buildElevatedButtonTheme(true),
      outlinedButtonTheme: _buildOutlinedButtonTheme(true),
      textButtonTheme: _buildTextButtonTheme(true),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: mkbhdRed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(cornerRadiusLarge)),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: elevationNone,
        color: metaDarkCardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadiusMedium),
          side: const BorderSide(color: Color(0xFF444444), width: 1.0),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadiusLarge),
        ),
      ),
      dividerTheme: const DividerThemeData(
        thickness: 0.5,
        space: 1,
        color: Color(0xFF444444),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: metaDarkCardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(cornerRadiusXLarge),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: metaDarkSurface,
        indicatorColor: mkbhdRed.withOpacity(0.3),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: fontSizeSmall,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }

  // Meta-style text theme with slightly reduced letter spacing
  static TextTheme _buildTextTheme([bool isDark = false]) {
    return TextTheme(
      displayLarge: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 32,
        letterSpacing: -0.6,
        color: isDark ? Colors.white : mkbhdDarkGrey,
      ),
      displayMedium: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 28,
        letterSpacing: -0.5,
        color: isDark ? Colors.white : mkbhdDarkGrey,
      ),
      displaySmall: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 24,
        letterSpacing: -0.5,
        color: isDark ? Colors.white : mkbhdDarkGrey,
      ),
      headlineLarge: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 22,
        letterSpacing: -0.3,
        color: isDark ? Colors.white : mkbhdDarkGrey,
      ),
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        letterSpacing: -0.3,
        color: isDark ? Colors.white : mkbhdDarkGrey,
      ),
      headlineSmall: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        letterSpacing: -0.2,
        color: isDark ? Colors.white : mkbhdDarkGrey,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        letterSpacing: -0.2,
        color: isDark ? Colors.white : mkbhdDarkGrey,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        letterSpacing: -0.1,
        color: isDark ? Colors.white : mkbhdDarkGrey,
      ),
      titleSmall: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 12,
        letterSpacing: 0,
        color: isDark ? Colors.white70 : mkbhdGrey,
      ),
      bodyLarge: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        letterSpacing: 0,
        color: isDark ? Colors.white : mkbhdDarkGrey,
      ),
      bodyMedium: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        letterSpacing: 0,
        color: isDark ? Colors.white : mkbhdDarkGrey,
      ),
      bodySmall: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        letterSpacing: 0,
        color: isDark ? Colors.white70 : mkbhdGrey,
      ),
      labelLarge: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        letterSpacing: 0,
        color: isDark ? Colors.white : mkbhdDarkGrey,
      ),
      labelMedium: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 12,
        letterSpacing: 0,
        color: isDark ? Colors.white70 : mkbhdGrey,
      ),
      labelSmall: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 10,
        letterSpacing: 0,
        color: isDark ? Colors.white60 : mkbhdLightGrey,
      ),
    );
  }

  // Meta-style input decoration with more rounded corners
  static InputDecorationTheme _buildInputDecorationTheme(bool isDark) {
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? metaDarkCardColor : Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cornerRadiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cornerRadiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cornerRadiusMedium),
        borderSide: const BorderSide(color: mkbhdRed, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cornerRadiusMedium),
        borderSide: BorderSide(color: isDark ? Colors.red[300]! : Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cornerRadiusMedium),
        borderSide: BorderSide(color: isDark ? Colors.red[300]! : Colors.red, width: 1.5),
      ),
      labelStyle: TextStyle(
        color: isDark ? Colors.white70 : mkbhdGrey,
      ),
      hintStyle: TextStyle(
        color: isDark ? Colors.white38 : Colors.grey.shade400,
      ),
    );
  }

  // Meta-style button theme with more rounded corners
  static ElevatedButtonThemeData _buildElevatedButtonTheme(bool isDark) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: mkbhdRed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadiusMedium),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: -0.2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        elevation: 2,
      ),
    );
  }
  
  // Meta-style outlined button theme
  static OutlinedButtonThemeData _buildOutlinedButtonTheme(bool isDark) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: mkbhdRed,
        side: const BorderSide(color: mkbhdRed),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadiusMedium),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: -0.2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    );
  }
  
  // Meta-style text button theme
  static TextButtonThemeData _buildTextButtonTheme(bool isDark) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: mkbhdRed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadiusMedium),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: -0.2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }
}
