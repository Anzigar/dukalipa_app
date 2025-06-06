import '../../../../core/network/api_client.dart';
import '../models/client_model.dart';

abstract class ClientRepository {
  /// Search for clients by name or phone number
  Future<List<ClientModel>> searchClients(String query);
  
  /// Get a client by ID
  Future<ClientModel> getClientById(String id);
  
  /// Create a new client
  Future<ClientModel> createClient(ClientModel client);
  
  /// Update an existing client
  Future<ClientModel> updateClient(ClientModel client);
  
  /// Get all clients
  Future<List<ClientModel>> getAllClients();
  
  /// Get clients with optional filters
  Future<List<ClientModel>> getClients({
    String? search,
    String? supplier,
    int? page,
    int? limit,
  });
}

class ClientRepositoryImpl implements ClientRepository {
  final ApiClient _apiClient;
  
  ClientRepositoryImpl(this._apiClient);
  
  @override
  Future<List<ClientModel>> searchClients(String query) async {
    try {
      final response = await _apiClient.get(
        '/clients',
        queryParameters: {'search': query},
      );
      
      final List<dynamic> data = response['data'] ?? [];
      return data.map((item) => ClientModel.fromJson(item)).toList();
    } catch (e) {
      // Return an empty list for now to avoid breaking the UI
      // In production, you might want to throw an error or handle differently
      return [];
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
      final response = await _apiClient.post(
        '/clients',
        data: client.toJson(),
      );
      return ClientModel.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<ClientModel> updateClient(ClientModel client) async {
    try {
      final response = await _apiClient.put(
        '/clients/${client.id}',
        data: client.toJson(),
      );
      return ClientModel.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
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
        queryParams['page'] = page.toString();
      }
      
      if (limit != null) {
        queryParams['limit'] = limit.toString();
      }
      
      final response = await _apiClient.get('/clients', queryParameters: queryParams);
      final List<dynamic> clientsJson = response['data'];
      return clientsJson.map((json) => ClientModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get clients: ${e.toString()}');
    }
  }
  
  Exception _handleError(dynamic error) {
    // Basic error handling
    return Exception('Failed to perform client operation: ${error.toString()}');
  }
}
