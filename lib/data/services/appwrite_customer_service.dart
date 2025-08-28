import 'package:appwrite/appwrite.dart';
import '../../core/services/appwrite_service.dart';
import '../../presentation/features/clients/models/customer_model.dart';

/// Service for handling customer operations using Appwrite backend
class AppwriteCustomerService {
  final Databases _databases;
  final String _databaseId = 'shop_management_db';

  AppwriteCustomerService() : _databases = AppwriteService().databases;

  /// Get all customers with optional filtering
  Future<List<CustomerModel>> getCustomers({
    String? search,
    DateTime? startDate,
    DateTime? endDate,
    int? page,
    int? pageSize,
  }) async {
    try {
      List<String> queries = [];

      // Add search functionality
      if (search != null && search.isNotEmpty) {
        queries.add(Query.search('name', search));
      }

      // Add date filters
      if (startDate != null) {
        queries.add(Query.greaterThanEqual('\$createdAt', startDate.toIso8601String()));
      }

      if (endDate != null) {
        queries.add(Query.lessThanEqual('\$createdAt', endDate.toIso8601String()));
      }

      // Add pagination
      if (pageSize != null) {
        queries.add(Query.limit(pageSize));
      }

      if (page != null && pageSize != null) {
        queries.add(Query.offset((page - 1) * pageSize));
      }

      // Order by creation date (newest first)
      queries.add(Query.orderDesc('\$createdAt'));

      final customerDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'customers',
        queries: queries,
      );

      return customerDocs.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['id'] = doc.$id;
        return CustomerModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch customers: ${e.toString()}');
    }
  }

  /// Get a specific customer by ID
  Future<CustomerModel> getCustomerById(String customerId) async {
    try {
      final customerDoc = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: 'customers',
        documentId: customerId,
      );

      final data = Map<String, dynamic>.from(customerDoc.data);
      data['id'] = customerDoc.$id;
      return CustomerModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch customer: ${e.toString()}');
    }
  }

  /// Create a new customer
  Future<CustomerModel> createCustomer(Map<String, dynamic> customerData) async {
    try {
      // Generate unique ID
      final customerId = ID.unique();

      // Prepare the data for Appwrite
      final processedData = Map<String, dynamic>.from(customerData);
      
      // Add timestamp
      processedData['\$createdAt'] = DateTime.now().toIso8601String();
      processedData['\$updatedAt'] = DateTime.now().toIso8601String();

      // Create the document
      final createdDoc = await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: 'customers',
        documentId: customerId,
        data: processedData,
      );

      final data = Map<String, dynamic>.from(createdDoc.data);
      data['id'] = createdDoc.$id;
      return CustomerModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create customer: ${e.toString()}');
    }
  }

  /// Update an existing customer
  Future<CustomerModel> updateCustomer(String customerId, Map<String, dynamic> customerData) async {
    try {
      // Prepare the data for update
      final processedData = Map<String, dynamic>.from(customerData);
      processedData['\$updatedAt'] = DateTime.now().toIso8601String();

      final updatedDoc = await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: 'customers',
        documentId: customerId,
        data: processedData,
      );

      final data = Map<String, dynamic>.from(updatedDoc.data);
      data['id'] = updatedDoc.$id;
      return CustomerModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update customer: ${e.toString()}');
    }
  }

  /// Delete a customer
  Future<void> deleteCustomer(String customerId) async {
    try {
      await _databases.deleteDocument(
        databaseId: _databaseId,
        collectionId: 'customers',
        documentId: customerId,
      );
    } catch (e) {
      throw Exception('Failed to delete customer: ${e.toString()}');
    }
  }

  /// Search customers by name, phone, or email
  Future<List<CustomerModel>> searchCustomers(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      // Try multiple search approaches
      List<String> queries = [
        Query.search('name', query),
        Query.orderDesc('\$createdAt'),
        Query.limit(20),
      ];

      final customerDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'customers',
        queries: queries,
      );

      var customers = customerDocs.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['id'] = doc.$id;
        return CustomerModel.fromJson(data);
      }).toList();

      // Also search by phone number if the query looks like a phone number
      if (RegExp(r'^[0-9+\-\s()]*$').hasMatch(query)) {
        final phoneQueries = [
          Query.search('phone_number', query),
          Query.orderDesc('\$createdAt'),
          Query.limit(10),
        ];

        final phoneResults = await _databases.listDocuments(
          databaseId: _databaseId,
          collectionId: 'customers',
          queries: phoneQueries,
        );

        final phoneCustomers = phoneResults.documents.map((doc) {
          final data = Map<String, dynamic>.from(doc.data);
          data['id'] = doc.$id;
          return CustomerModel.fromJson(data);
        }).toList();

        // Merge results and remove duplicates
        for (var customer in phoneCustomers) {
          if (!customers.any((c) => c.id == customer.id)) {
            customers.add(customer);
          }
        }
      }

      return customers;
    } catch (e) {
      throw Exception('Failed to search customers: ${e.toString()}');
    }
  }

  /// Get customer purchase statistics
  Future<Map<String, dynamic>> getCustomerStatistics(String customerId) async {
    try {
      // Get all sales for this customer
      final salesDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'sales',
        queries: [
          Query.equal('customer_id', customerId),
          Query.orderDesc('\$createdAt'),
        ],
      );

      double totalPurchases = 0.0;
      int purchaseCount = salesDocs.total;
      DateTime? lastPurchaseDate;

      if (salesDocs.documents.isNotEmpty) {
        // Calculate totals
        for (var sale in salesDocs.documents) {
          totalPurchases += (sale.data['total_amount'] ?? 0).toDouble();
        }

        // Get last purchase date
        lastPurchaseDate = DateTime.parse(salesDocs.documents.first.data['\$createdAt']);
      }

      return {
        'total_purchases': totalPurchases,
        'purchase_count': purchaseCount,
        'last_purchase_date': lastPurchaseDate?.toIso8601String(),
        'average_purchase_value': purchaseCount > 0 ? totalPurchases / purchaseCount : 0.0,
      };
    } catch (e) {
      throw Exception('Failed to fetch customer statistics: ${e.toString()}');
    }
  }

  /// Get recent customers (last N customers)
  Future<List<CustomerModel>> getRecentCustomers({int limit = 10}) async {
    try {
      final customerDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'customers',
        queries: [
          Query.orderDesc('\$createdAt'),
          Query.limit(limit),
        ],
      );

      return customerDocs.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['id'] = doc.$id;
        return CustomerModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch recent customers: ${e.toString()}');
    }
  }

  /// Get top customers by purchase value
  Future<List<CustomerModel>> getTopCustomers({int limit = 10}) async {
    try {
      // This is a simplified version - in a real scenario, you'd want to
      // pre-calculate these stats or use a more efficient approach
      final customers = await getCustomers(pageSize: 100);
      
      // Get purchase statistics for each customer
      List<Map<String, dynamic>> customerStats = [];
      
      for (var customer in customers) {
        try {
          final stats = await getCustomerStatistics(customer.id);
          customerStats.add({
            'customer': customer,
            'total_purchases': stats['total_purchases'] as double,
          });
        } catch (e) {
          // Skip customer if stats fail
          customerStats.add({
            'customer': customer,
            'total_purchases': 0.0,
          });
        }
      }

      // Sort by total purchases and limit
      customerStats.sort((a, b) => 
        (b['total_purchases'] as double).compareTo(a['total_purchases'] as double));

      return customerStats
          .take(limit)
          .map((item) => item['customer'] as CustomerModel)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch top customers: ${e.toString()}');
    }
  }

  /// Helper method to format date for API
  static String formatDateForApi(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }
}