import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

/// A simplified API client using Dio for HTTP requests
class ApiClient {
  final String baseUrl;
  final Dio _dio;

  ApiClient({
    this.baseUrl = 'http://127.0.0.1:8000/api/v1',
    Map<String, String>? defaultHeaders,
  }) : _dio = Dio() {
    // Configure Dio instance
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = defaultHeaders ?? {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add interceptors for logging and error handling
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('[DIO] $obj'),
    ));
  }

  /// Performs a GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Performs a POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Performs a PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Performs a PATCH request
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Performs a DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Uploads a file
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    File file, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        ...?additionalData,
      });

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  dynamic _handleResponse(Response response) {
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      if (response.data == null) {
        return {'data': null};
      }

      // Dio automatically handles JSON parsing
      return response.data;
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'HTTP ${response.statusCode}: ${response.statusMessage}',
      );
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Connection timed out. Please check your internet connection and try again.');

        case DioExceptionType.connectionError:
          return Exception('No internet connection. Please check your network and try again.');

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data?.toString() ?? error.message;
          return Exception('Server error ($statusCode): $message');

        case DioExceptionType.cancel:
          return Exception('Request was cancelled.');

        case DioExceptionType.unknown:
        default:
          return Exception('An unexpected error occurred: ${error.message}');
      }
    }

    return Exception('An unexpected error occurred: ${error.toString()}');
  }

  /// Dispose the Dio instance
  void dispose() {
    _dio.close();
  }
}
