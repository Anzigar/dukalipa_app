import 'dart:async';
import '../../../../core/network/api_client.dart';
import '../models/client_model.dart';
import 'client_repository.dart';

class ClientRepositoryImpl implements ClientRepository {
  final ApiClient _apiClient;

  ClientRepositoryImpl(this._apiClient);

  @override
  Future<List<ClientModel>> getAllClients() async {
    try {
      final response = await _apiClient.get('/clients');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((item) => ClientModel.fromJson(item)).toList();
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
      
      final response = await _apiClient.get('/clients', queryParameters: queryParams);
      final List<dynamic> data = response['data'] ?? [];
      return data.map((item) => ClientModel.fromJson(item)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ClientModel> getClientById(String id) async {
    try {
      final response = await _apiClient.get('/clients/$id');
      return ClientModel.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ClientModel> createClient(ClientModel client) async {
    try {
      final response = await _apiClient.post('/clients', data: client.toJson());
      return ClientModel.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ClientModel> updateClient(ClientModel client) async {
    try {
      final response = await _apiClient.put('/clients/${client.id}', data: client.toJson());
      return ClientModel.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteClient(String id) async {
    try {
      await _apiClient.delete('/clients/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<ClientModel>> searchClients(String query) async {
    try {
      final response = await _apiClient.get('/clients/search', queryParameters: {
        'query': query,
      });
      final List<dynamic> data = response['data'] ?? [];
      return data.map((item) => ClientModel.fromJson(item)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is TimeoutException) {
      return Exception('Connection timed out. Please check your internet connection and try again.');
    }
    // Add more specific error handling as needed
    return Exception('Failed to perform client operation: ${error.toString()}');
  }
}
