import 'dart:async';
import 'package:dio/dio.dart';
import '../models/client_model.dart';
import 'client_repository.dart';

class ClientRepositoryImpl implements ClientRepository {
  late final Dio _dio;

  ClientRepositoryImpl() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }

  @override
  Future<List<ClientModel>> getAllClients() async {
    try {
      final response = await _dio.get('/clients');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((item) => ClientModel.fromJson(item)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<ClientModel>> getClients({
    String? search,
    String? supplier,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (supplier != null && supplier.isNotEmpty) {
        queryParams['supplier'] = supplier;
      }
      
      if (page != null) {
        queryParams['page'] = page;
      }
      
      if (limit != null) {
        queryParams['limit'] = limit;
      }
      
      final response = await _dio.get('/clients', queryParameters: queryParams);
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((item) => ClientModel.fromJson(item)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ClientModel> getClientById(String id) async {
    try {
      final response = await _dio.get('/clients/$id');
      return ClientModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ClientModel> createClient(ClientModel client) async {
    try {
      final response = await _dio.post('/clients', data: client.toJson());
      return ClientModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ClientModel> updateClient(ClientModel client) async {
    try {
      final response = await _dio.put('/clients/${client.id}', data: client.toJson());
      return ClientModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteClient(String id) async {
    try {
      await _dio.delete('/clients/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<ClientModel>> searchClients(String query) async {
    try {
      final response = await _dio.get('/clients/search', queryParameters: {
        'query': query,
      });
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((item) => ClientModel.fromJson(item)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout) {
        return Exception('Connection timed out. Please check your internet connection and try again.');
      }
      if (error.response?.statusCode == 404) {
        return Exception('Client not found.');
      }
      if (error.response?.statusCode == 401) {
        return Exception('Authentication required. Please login again.');
      }
      if (error.response?.statusCode == 403) {
        return Exception('Access denied.');
      }
      return Exception('Network error: ${error.response?.data ?? error.message}');
    }
    if (error is TimeoutException) {
      return Exception('Connection timed out. Please check your internet connection and try again.');
    }
    // Add more specific error handling as needed
    return Exception('Failed to perform client operation: ${error.toString()}');
  }
}
