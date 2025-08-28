import 'package:appwrite/appwrite.dart';
import '../../core/services/appwrite_service.dart';
import '../../presentation/features/clients/models/client_model.dart';

/// Service for handling client operations using Appwrite backend
class AppwriteClientService {
  final Databases _databases;
  final String _databaseId = 'shop_management_db';

  AppwriteClientService() : _databases = AppwriteService().databases;

  /// Get all clients with optional filtering
  Future<List<ClientModel>> getClients({
    String? search,
    String? supplier,
    int? page,
    int? limit,
  }) async {
    try {
      List<String> queries = [];

      // Add search functionality
      if (search != null && search.isNotEmpty) {
        queries.add(Query.search('name', search));
      }

      // Add pagination
      if (limit != null) {
        queries.add(Query.limit(limit));
      }

      if (page != null && limit != null) {
        queries.add(Query.offset((page - 1) * limit));
      }

      // Order by creation date (newest first)
      queries.add(Query.orderDesc('\$createdAt'));

      final clientDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'clients',
        queries: queries.isNotEmpty ? queries : [Query.limit(100)],
      );

      return clientDocs.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['id'] = doc.$id;
        return ClientModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch clients: ${e.toString()}');
    }
  }

  /// Get all clients (simple method)
  Future<List<ClientModel>> getAllClients() async {
    return await getClients();
  }

  /// Get a specific client by ID
  Future<ClientModel> getClientById(String clientId) async {
    try {
      final clientDoc = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: 'clients',
        documentId: clientId,
      );

      final data = Map<String, dynamic>.from(clientDoc.data);
      data['id'] = clientDoc.$id;

      return ClientModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch client: ${e.toString()}');
    }
  }

  /// Create a new client
  Future<ClientModel> createClient(ClientModel client) async {
    try {
      final clientId = ID.unique();
      final now = DateTime.now();

      // Prepare client data
      final clientData = {
        'name': client.name,
        'phone_number': client.phoneNumber,
        'email': client.email,
        'address': client.address,
        'total_purchases': client.totalPurchases,
        'purchase_count': client.purchaseCount,
        'profile_image_url': client.profileImageUrl,
        'last_purchase_date': client.lastPurchaseDate?.toIso8601String(),
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      // Create the client document
      await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: 'clients',
        documentId: clientId,
        data: clientData,
      );

      // Get the created client
      return await getClientById(clientId);
    } catch (e) {
      throw Exception('Failed to create client: ${e.toString()}');
    }
  }

  /// Update an existing client
  Future<ClientModel> updateClient(ClientModel client) async {
    try {
      final updateData = {
        'name': client.name,
        'phone_number': client.phoneNumber,
        'email': client.email,
        'address': client.address,
        'total_purchases': client.totalPurchases,
        'purchase_count': client.purchaseCount,
        'profile_image_url': client.profileImageUrl,
        'last_purchase_date': client.lastPurchaseDate?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: 'clients',
        documentId: client.id,
        data: updateData,
      );

      return await getClientById(client.id);
    } catch (e) {
      throw Exception('Failed to update client: ${e.toString()}');
    }
  }

  /// Delete a client
  Future<void> deleteClient(String clientId) async {
    try {
      await _databases.deleteDocument(
        databaseId: _databaseId,
        collectionId: 'clients',
        documentId: clientId,
      );
    } catch (e) {
      throw Exception('Failed to delete client: ${e.toString()}');
    }
  }

  /// Search clients by name or phone number
  Future<List<ClientModel>> searchClients(String query) async {
    try {
      final clientDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'clients',
        queries: [
          Query.search('name', query),
          Query.limit(50),
        ],
      );

      List<ClientModel> clients = clientDocs.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['id'] = doc.$id;
        return ClientModel.fromJson(data);
      }).toList();

      // Also search by phone number if no results by name
      if (clients.isEmpty) {
        final phoneResults = await _databases.listDocuments(
          databaseId: _databaseId,
          collectionId: 'clients',
          queries: [
            Query.search('phone_number', query),
            Query.limit(50),
          ],
        );

        clients = phoneResults.documents.map((doc) {
          final data = Map<String, dynamic>.from(doc.data);
          data['id'] = doc.$id;
          return ClientModel.fromJson(data);
        }).toList();
      }

      return clients;
    } catch (e) {
      throw Exception('Failed to search clients: ${e.toString()}');
    }
  }

  /// Get client statistics
  Future<Map<String, dynamic>> getClientStatistics() async {
    try {
      // Get all clients for statistics
      final allClients = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'clients',
      );

      double totalRevenue = 0;
      int totalPurchases = 0;
      ClientModel? topClient;
      double topClientRevenue = 0;

      for (var doc in allClients.documents) {
        final data = Map<String, dynamic>.from(doc.data);
        data['id'] = doc.$id;
        final client = ClientModel.fromJson(data);
        
        totalRevenue += client.totalPurchases;
        totalPurchases += client.purchaseCount;
        
        if (client.totalPurchases > topClientRevenue) {
          topClientRevenue = client.totalPurchases;
          topClient = client;
        }
      }

      return {
        'total_clients': allClients.total,
        'total_revenue': totalRevenue,
        'total_purchases': totalPurchases,
        'average_purchase_value': totalPurchases > 0 ? totalRevenue / totalPurchases : 0,
        'top_client': topClient?.toJson(),
      };
    } catch (e) {
      throw Exception('Failed to fetch client statistics: ${e.toString()}');
    }
  }

  /// Get top clients by total purchases
  Future<List<ClientModel>> getTopClients({int limit = 10}) async {
    try {
      final clientDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'clients',
        queries: [
          Query.orderDesc('total_purchases'),
          Query.limit(limit),
        ],
      );

      return clientDocs.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['id'] = doc.$id;
        return ClientModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch top clients: ${e.toString()}');
    }
  }
}