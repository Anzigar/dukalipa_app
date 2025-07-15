class AppConstants {
  // App info
  static const String appName = 'Dukalipa';
  static const String appVersion = '1.0.0';
  
  // API endpoints
  static const String baseUrl = "http://127.0.0.1:8000"; // Updated to match the OpenAPI documentation
  static const String refreshTokenEndpoint = "/auth/refresh-token";
  
  // Shared preferences keys
  static const String tokenKey = "auth_token";
  static const String refreshTokenKey = "refresh_token";
  static const String userKey = "user_data";
  static const String languageKey = "language";
  static const String themeKey = 'theme';
  
  // Pagination defaults
  static const int defaultPageSize = 10;
  
  // Low stock threshold (default)
  static const int defaultLowStockThreshold = 5;
  
  // Animation durations
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 400);
  static const Duration longDuration = Duration(milliseconds: 800);
  
  // Misc
  static const int connectTimeout = 15000; // 15 seconds
  static const int receiveTimeout = 15000; // 15 seconds
}
