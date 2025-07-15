import 'package:flutter/material.dart';

/// Main theme class for the application
class AppTheme {
  // MKBHD Red color scheme (using Meta blue palette)
  static const Color mkbhdRed = Color(0xFF1877F2); // Meta blue
  static const Color mkbhdDarkRed = Color(0xFF166FE5); // Meta dark blue
  static const Color mkbhdLightRed = Color(0xFF42A5F5); // Meta light blue
  
  // MKBHD Grey color scheme (using Meta greys)
  static const Color mkbhdDarkGrey = Color(0xFF1C1E21); // Meta dark grey
  static const Color mkbhdGrey = Color(0xFF65676B); // Meta medium grey
  static const Color mkbhdLightGrey = Color(0xFFB0B3B8); // Meta light grey
  
  // Meta-style background colors
  static const Color metaLightBackground = Color(0xFFF0F2F5); // Meta light background
  static const Color metaDarkBackground = Color(0xFF18191A); // Meta dark background
  static const Color metaLightSurface = Color(0xFFFFFFFF); // Meta white
  static const Color metaDarkSurface = Color(0xFF242526); // Meta dark surface
  static const Color metaLightCardColor = Color(0xFFFFFFFF); // Meta white
  static const Color metaDarkCardColor = Color(0xFF3A3B3C); // Meta dark card
  
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

  // Add Meta-style colors to the existing AppTheme class
  static const Color airbnbRed = Color(0xFF1877F2); // Meta blue (keeping airbnb name)
  static const Color airbnbDarkGrey = Color(0xFF1C1E21); // Meta dark grey
  static const Color airbnbLightGrey = Color(0xFF65676B); // Meta medium grey
  static const Color airbnbBlue = Color(0xFF42A5F5); // Meta accent blue
  static const Color airbnbLightBg = Color(0xFFF0F2F5); // Meta light background
  
  /// Get the light theme
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: mkbhdRed,
      colorScheme: const ColorScheme.light(
        primary: mkbhdRed,
        onPrimary: Colors.white,
        secondary: mkbhdDarkRed,
        onSecondary: Colors.white,
        surface: metaLightSurface,
        onSurface: mkbhdDarkGrey,
        background: metaLightBackground,
        onBackground: mkbhdDarkGrey,
        error: Color(0xFFE74C3C),
        onError: Colors.white,
        outline: mkbhdLightGrey,
        surfaceVariant: Color(0xFFF5F5F5),
        onSurfaceVariant: mkbhdGrey,
      ),
      scaffoldBackgroundColor: metaLightBackground,
      cardColor: metaLightCardColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: metaLightSurface,
        elevation: elevationXSmall,
        centerTitle: false,
        foregroundColor: mkbhdDarkGrey,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        iconTheme: IconThemeData(color: mkbhdDarkGrey),
        titleTextStyle: TextStyle(
          color: mkbhdDarkGrey,
          fontWeight: FontWeight.w600,
          fontSize: fontSizeXLarge,
        ),
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
        elevation: elevationNone,
        color: metaLightCardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadiusLarge),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade100,
        selectedColor: mkbhdRed.withOpacity(0.2),
        labelStyle: const TextStyle(color: mkbhdDarkGrey),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadiusLarge),
        ),
      ),
      dividerTheme: const DividerThemeData(
        thickness: 0.5,
        space: 1,
        color: mkbhdLightGrey,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: metaLightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(cornerRadiusXLarge)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: metaLightSurface,
        indicatorColor: mkbhdRed.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: fontSizeSmall),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: metaLightSurface,
        selectedItemColor: mkbhdRed,
        unselectedItemColor: mkbhdGrey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: elevationSmall,
      ),
      iconTheme: const IconThemeData(color: mkbhdGrey),
      primaryIconTheme: const IconThemeData(color: Colors.white),
    );
  }

  /// Get the dark theme
  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: mkbhdRed,
      colorScheme: const ColorScheme.dark(
        primary: mkbhdRed,
        onPrimary: Colors.white,
        secondary: mkbhdLightRed,
        onSecondary: Colors.white,
        surface: metaDarkSurface,
        onSurface: Colors.white,
        background: metaDarkBackground,
        onBackground: Colors.white,
        error: Color(0xFFE74C3C),
        onError: Colors.white,
        outline: mkbhdGrey,
        surfaceVariant: Color(0xFF2A2B2C),
        onSurfaceVariant: mkbhdLightGrey,
      ),
      scaffoldBackgroundColor: metaDarkBackground,
      cardColor: metaDarkCardColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: metaDarkSurface,
        elevation: elevationNone,
        centerTitle: false,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: fontSizeXLarge,
        ),
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
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadiusLarge),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: metaDarkCardColor,
        selectedColor: mkbhdRed.withOpacity(0.3),
        labelStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadiusLarge),
        ),
      ),
      dividerTheme: const DividerThemeData(
        thickness: 0.5,
        space: 1,
        color: mkbhdGrey,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: metaDarkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(cornerRadiusXLarge)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: metaDarkSurface,
        indicatorColor: mkbhdRed.withOpacity(0.3),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: fontSizeSmall, color: Colors.white),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: metaDarkSurface,
        selectedItemColor: mkbhdRed,
        unselectedItemColor: mkbhdLightGrey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: elevationSmall,
      ),
      iconTheme: const IconThemeData(color: mkbhdLightGrey),
      primaryIconTheme: const IconThemeData(color: Colors.white),
    );
  }

  // Meta-style text theme
  static TextTheme _buildTextTheme([bool isDark = false]) {
    final baseColor = isDark ? Colors.white : mkbhdDarkGrey;
    
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: fontSizeHeadline,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      titleLarge: TextStyle(
        fontSize: fontSizeXLarge,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      bodyLarge: TextStyle(
        fontSize: fontSizeMedium,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
    );
  }

  // Meta-style input decoration
  static InputDecorationTheme _buildInputDecorationTheme(bool isDark) {
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? metaDarkCardColor : Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cornerRadiusLarge),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cornerRadiusLarge),
        borderSide: BorderSide(
          color: isDark ? mkbhdGrey.withOpacity(0.3) : mkbhdLightGrey.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cornerRadiusLarge),
        borderSide: const BorderSide(color: mkbhdRed, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cornerRadiusLarge),
        borderSide: const BorderSide(color: Color(0xFFE74C3C), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cornerRadiusLarge),
        borderSide: const BorderSide(color: Color(0xFFE74C3C), width: 1.5),
      ),
      hintStyle: TextStyle(
        color: isDark ? mkbhdLightGrey : mkbhdGrey,
        fontSize: fontSizeMedium,
      ),
      labelStyle: TextStyle(
        color: isDark ? mkbhdLightGrey : mkbhdGrey,
        fontSize: fontSizeMedium,
      ),
    );
  }

  // Meta-style button themes
  static ElevatedButtonThemeData _buildElevatedButtonTheme(bool isDark) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: mkbhdRed,
        foregroundColor: Colors.white,
        elevation: elevationNone,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: spacingLarge, vertical: spacingMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadiusLarge),
        ),
        textStyle: const TextStyle(
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.w600,
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.1)),
      ),
    );
  }
  
  static OutlinedButtonThemeData _buildOutlinedButtonTheme(bool isDark) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: mkbhdRed,
        side: const BorderSide(color: mkbhdRed, width: 1.5),
        backgroundColor: Colors.transparent,
        elevation: elevationNone,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: spacingLarge, vertical: spacingMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadiusLarge),
        ),
        textStyle: const TextStyle(
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.w600,
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.all(mkbhdRed.withOpacity(0.1)),
      ),
    );
  }
  
  static TextButtonThemeData _buildTextButtonTheme(bool isDark) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: mkbhdRed,
        backgroundColor: Colors.transparent,
        elevation: elevationNone,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: spacingMedium, vertical: spacingSmall),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadiusMedium),
        ),
        textStyle: const TextStyle(
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.w500,
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.all(mkbhdRed.withOpacity(0.1)),
      ),
    );
  }
}
