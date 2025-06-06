import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../data/services/local_storage_service.dart';
import '../utils/app_constants.dart';

/// Interceptor for logging API requests and responses
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('REQUEST[${options.method}] => PATH: ${options.path}');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    return super.onError(err, handler);
  }
}

/// Interceptor for adding authentication token to requests
class AuthInterceptor extends Interceptor {
  final LocalStorageService _localStorageService;
  // Lock to prevent multiple concurrent refresh token requests
  final _refreshTokenLock = Lock();

  AuthInterceptor(this._localStorageService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _localStorageService.getToken();
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only attempt token refresh for 401 errors on non-auth endpoints
    if (err.response?.statusCode == 401 && 
        !err.requestOptions.path.contains('/auth/refresh') && 
        !err.requestOptions.path.contains('/auth/login')) {
      try {
        // Use lock to prevent multiple refresh token requests
        return await _refreshTokenLock.synchronized(() async {
          // Double-check if token is still expired (might have been refreshed by another request)
          final token = await _localStorageService.getToken();
          if (token != null) {
            // Check if current token is different from the one used in the failed request
            final usedToken = err.requestOptions.headers['Authorization']?.replaceFirst('Bearer ', '');
            if (token != usedToken) {
              // Token has already been refreshed by another request, retry with the new token
              return _retryRequest(err, handler, token);
            }
          }

          final refreshToken = await _localStorageService.getRefreshToken();
          
          if (refreshToken == null) {
            // No refresh token available, logout user
            await _localStorageService.clearTokens();
            return super.onError(err, handler);
          }
          
          // Create a separate Dio instance for token refresh to avoid interceptor loops
          final tokenDio = Dio(BaseOptions(
            baseUrl: AppConstants.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ));
          
          final response = await tokenDio.post(
            AppConstants.refreshTokenEndpoint,
            data: {'refresh_token': refreshToken},
            options: Options(
              validateStatus: (status) => status != null && status < 500,
              contentType: Headers.jsonContentType,
              followRedirects: false,
            ),
          );
          
          if (response.statusCode == 200 && response.data['access_token'] != null) {
            final newToken = response.data['access_token'];
            // Also save the new refresh token if provided
            if (response.data['refresh_token'] != null) {
              await _localStorageService.setRefreshToken(response.data['refresh_token']);
            }
            
            await _localStorageService.setToken(newToken);
            return _retryRequest(err, handler, newToken);
          } else {
            // Refresh token is invalid or expired, logout user
            await _localStorageService.clearTokens();
          }
        });
      } catch (e) {
        if (kDebugMode) {
          print('Token refresh error: $e');
        }
        // Clear tokens on refresh error
        await _localStorageService.clearTokens();
      }
    }
    
    return super.onError(err, handler);
  }

  Future<void> _retryRequest(
    DioException err, 
    ErrorInterceptorHandler handler,
    String newToken
  ) async {
    final requestOptions = err.requestOptions;
    
    // Update the Authorization header with the new token
    requestOptions.headers['Authorization'] = 'Bearer $newToken';
    
    // Create a new request with all the original parameters
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
      contentType: requestOptions.contentType,
      responseType: requestOptions.responseType,
      validateStatus: requestOptions.validateStatus,
      receiveTimeout: requestOptions.receiveTimeout,
      sendTimeout: requestOptions.sendTimeout,
      extra: requestOptions.extra,
    );
    
    try {
      // Create a new Dio instance without interceptors to avoid loops
      final dio = Dio();
      final response = await dio.request<dynamic>(
        requestOptions.path,
        options: options,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        cancelToken: requestOptions.cancelToken,
        onSendProgress: requestOptions.onSendProgress,
        onReceiveProgress: requestOptions.onReceiveProgress,
      );
      
      handler.resolve(response);
    } on DioException catch (e) {
      handler.reject(e);
    }
  }
}

/// A simple lock implementation for synchronizing async operations
class Lock {
  bool _locked = false;
  Future<void>? _completer;

  Future<T> synchronized<T>(Future<T> Function() fn) async {
    if (_locked) {
      // Wait for the previous operation to complete
      await _completer;
    }

    _locked = true;
    _completer = Future<void>(() async {
      try {
        await fn();
      } finally {
        _locked = false;
      }
    });

    try {
      return await fn();
    } finally {
      _locked = false;
    }
  }
}
