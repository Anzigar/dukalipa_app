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
