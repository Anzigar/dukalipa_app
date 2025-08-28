import 'dart:async';
import '../../../../data/services/appwrite_client_service.dart';
import '../models/client_model.dart';
import 'client_repository.dart';

class ClientRepositoryImpl implements ClientRepository {
  final AppwriteClientService _clientService;

  ClientRepositoryImpl() : _clientService = AppwriteClientService();

  @override
  Future<List<ClientModel>> getAllClients() async {
    try {
      return await _clientService.getAllClients();
    } catch (e) {
      throw Exception('Failed to fetch clients: ${e.toString()}');
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
      return await _clientService.getClients(
        search: search,
        supplier: supplier,
        page: page,
        limit: limit,
      );
    } catch (e) {
      throw Exception('Failed to fetch clients: ${e.toString()}');
    }
  }

  @override
  Future<ClientModel> getClientById(String id) async {
    try {
      return await _clientService.getClientById(id);
    } catch (e) {
      throw Exception('Failed to fetch client: ${e.toString()}');
    }
  }

  @override
  Future<ClientModel> createClient(ClientModel client) async {
    try {
      return await _clientService.createClient(client);
    } catch (e) {
      throw Exception('Failed to create client: ${e.toString()}');
    }
  }

  @override
  Future<ClientModel> updateClient(ClientModel client) async {
    try {
      return await _clientService.updateClient(client);
    } catch (e) {
      throw Exception('Failed to update client: ${e.toString()}');
    }
  }

  Future<void> deleteClient(String id) async {
    try {
      await _clientService.deleteClient(id);
    } catch (e) {
      throw Exception('Failed to delete client: ${e.toString()}');
    }
  }

  @override
  Future<List<ClientModel>> searchClients(String query) async {
    try {
      return await _clientService.searchClients(query);
    } catch (e) {
      throw Exception('Failed to search clients: ${e.toString()}');
    }
  }

}
