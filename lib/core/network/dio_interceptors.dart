import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';

/// Logging utility for Appwrite operations  
class AppwriteLogger {
  static void logRequest({
    required String operation,
    required String collection,
    Map<String, dynamic>? data,
  }) {
    if (kDebugMode) {
      print('🔵 [APPWRITE REQUEST] $operation - Collection: $collection');
      if (data != null) {
        print('📝 Data: $data');
      }
    }
  }

  static void logResponse({
    required String operation,
    required String collection,
    dynamic response,
    bool? success,
  }) {
    if (kDebugMode) {
      print('🟢 [APPWRITE RESPONSE] $operation - Collection: $collection');
      if (success != null) {
        print('📊 Success: $success');
      }
      if (response != null) {
        print('📄 Response type: ${response.runtimeType}');
      }
    }
  }

  static void logError({
    required String operation,
    required String collection,
    required dynamic error,
  }) {
    if (kDebugMode) {
      print('🔴 [APPWRITE ERROR] $operation - Collection: $collection');
      print('❌ Error: ${error.toString()}');
    }
  }
}

/// Wrapper class for Appwrite operations with logging
class AppwriteClient {
  final Client _client;
  final Databases _databases;
  final Storage _storage;
  final Account _account;

  AppwriteClient({
    required String endpoint,
    required String projectId,
  }) : _client = Client()
    ..setEndpoint(endpoint)
    ..setProject(projectId),
    _databases = Databases(Client()..setEndpoint(endpoint)..setProject(projectId)),
    _storage = Storage(Client()..setEndpoint(endpoint)..setProject(projectId)),
    _account = Account(Client()..setEndpoint(endpoint)..setProject(projectId));

  // Getters for direct access if needed
  Client get client => _client;
  Databases get databases => _databases;
  Storage get storage => _storage;
  Account get account => _account;

  /// Set session for authenticated requests
  void setSession(String session) {
    _client.setJWT(session);
  }

  /// Clear session
  void clearSession() {
    _client.setJWT('');
  }

  /// Execute database operation with logging
  Future<T> executeWithLogging<T>({
    required String operation,
    required String collection,
    required Future<T> Function() action,
    Map<String, dynamic>? data,
  }) async {
    AppwriteLogger.logRequest(
      operation: operation,
      collection: collection,
      data: data,
    );

    try {
      final result = await action();
      AppwriteLogger.logResponse(
        operation: operation,
        collection: collection,
        response: result,
        success: true,
      );
      return result;
    } catch (error) {
      AppwriteLogger.logError(
        operation: operation,
        collection: collection,
        error: error,
      );
      rethrow;
    }
  }
}