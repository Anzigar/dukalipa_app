import 'package:appwrite/appwrite.dart';
import '../../core/services/appwrite_service.dart';
import '../../presentation/features/sales/models/sale_model.dart';

/// Service for handling sales operations using Appwrite backend
class AppwriteSalesService {
  final Databases _databases;
  final String _databaseId = 'shop_management_db';

  AppwriteSalesService() : _databases = AppwriteService().databases;

  /// Get all sales with optional filtering and pagination
  Future<List<SaleModel>> getSales({
    String? search,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? page,
    int? pageSize,
  }) async {
    try {
      List<String> queries = [];

      // Add filters
      if (status != null && status.isNotEmpty) {
        queries.add(Query.equal('status', status));
      }

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

      // Add search functionality
      if (search != null && search.isNotEmpty) {
        queries.add(Query.search('customer_name', search));
      }

      // Order by creation date (newest first)
      queries.add(Query.orderDesc('\$createdAt'));

      final salesDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'sales',
        queries: queries,
      );

      return salesDocs.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['id'] = doc.$id;
        return SaleModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch sales: ${e.toString()}');
    }
  }

  /// Get a specific sale by ID
  Future<SaleModel> getSaleById(String saleId) async {
    try {
      final saleDoc = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: 'sales',
        documentId: saleId,
      );

      final data = Map<String, dynamic>.from(saleDoc.data);
      data['id'] = saleDoc.$id;
      return SaleModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch sale: ${e.toString()}');
    }
  }

  /// Create a new sale
  Future<SaleModel> createSale(Map<String, dynamic> saleData) async {
    try {
      // Generate unique ID
      final saleId = ID.unique();

      // Prepare the data for Appwrite
      final processedData = Map<String, dynamic>.from(saleData);
      
      // Add timestamp
      processedData['\$createdAt'] = DateTime.now().toIso8601String();
      processedData['\$updatedAt'] = DateTime.now().toIso8601String();

      // Create the document
      final createdDoc = await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: 'sales',
        documentId: saleId,
        data: processedData,
      );

      return SaleModel.fromJson({
        'id': createdDoc.$id,
        ...createdDoc.data,
      });
    } catch (e) {
      throw Exception('Failed to create sale: ${e.toString()}');
    }
  }

  /// Update an existing sale
  Future<SaleModel> updateSale(String saleId, Map<String, dynamic> saleData) async {
    try {
      // Prepare the data for update
      final processedData = Map<String, dynamic>.from(saleData);
      processedData['\$updatedAt'] = DateTime.now().toIso8601String();

      final updatedDoc = await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: 'sales',
        documentId: saleId,
        data: processedData,
      );

      return SaleModel.fromJson({
        'id': updatedDoc.$id,
        ...updatedDoc.data,
      });
    } catch (e) {
      throw Exception('Failed to update sale: ${e.toString()}');
    }
  }

  /// Delete a sale
  Future<void> deleteSale(String saleId) async {
    try {
      await _databases.deleteDocument(
        databaseId: _databaseId,
        collectionId: 'sales',
        documentId: saleId,
      );
    } catch (e) {
      throw Exception('Failed to delete sale: ${e.toString()}');
    }
  }

  /// Get sales statistics
  Future<Map<String, dynamic>> getSalesStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      List<String> queries = [];

      if (startDate != null) {
        queries.add(Query.greaterThanEqual('\$createdAt', startDate.toIso8601String()));
      }

      if (endDate != null) {
        queries.add(Query.lessThanEqual('\$createdAt', endDate.toIso8601String()));
      }

      final salesDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'sales',
        queries: queries,
      );

      double totalRevenue = 0;
      double totalProfit = 0;
      int totalQuantity = 0;
      Map<String, int> statusCounts = {};

      for (var sale in salesDocs.documents) {
        final saleData = sale.data;
        
        totalRevenue += (saleData['total_amount'] ?? 0).toDouble();
        totalProfit += (saleData['profit'] ?? 0).toDouble();
        
        final items = saleData['items'] as List? ?? [];
        for (var item in items) {
          totalQuantity += (item['quantity'] ?? 0) as int;
        }

        final status = saleData['status'] ?? 'completed';
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }

      return {
        'total_sales': salesDocs.total,
        'total_revenue': totalRevenue,
        'total_profit': totalProfit,
        'total_quantity': totalQuantity,
        'status_counts': statusCounts,
        'average_sale_value': salesDocs.total > 0 ? totalRevenue / salesDocs.total : 0,
      };
    } catch (e) {
      throw Exception('Failed to fetch sales statistics: ${e.toString()}');
    }
  }

  /// Get recent sales (last N sales)
  Future<List<SaleModel>> getRecentSales({int limit = 10}) async {
    try {
      final salesDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'sales',
        queries: [
          Query.orderDesc('\$createdAt'),
          Query.limit(limit),
        ],
      );

      return salesDocs.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['id'] = doc.$id;
        return SaleModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch recent sales: ${e.toString()}');
    }
  }

  /// Get sales by customer
  Future<List<SaleModel>> getSalesByCustomer(String customerId) async {
    try {
      final salesDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'sales',
        queries: [
          Query.equal('customer_id', customerId),
          Query.orderDesc('\$createdAt'),
        ],
      );

      return salesDocs.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['id'] = doc.$id;
        return SaleModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch customer sales: ${e.toString()}');
    }
  }

  /// Get sales by date range
  Future<List<SaleModel>> getSalesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final salesDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'sales',
        queries: [
          Query.greaterThanEqual('\$createdAt', startDate.toIso8601String()),
          Query.lessThanEqual('\$createdAt', endDate.toIso8601String()),
          Query.orderDesc('\$createdAt'),
        ],
      );

      return salesDocs.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['id'] = doc.$id;
        return SaleModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch sales by date range: ${e.toString()}');
    }
  }

  /// Update sale status
  Future<SaleModel> updateSaleStatus(String saleId, String status) async {
    try {
      final updatedDoc = await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: 'sales',
        documentId: saleId,
        data: {
          'status': status,
          '\$updatedAt': DateTime.now().toIso8601String(),
        },
      );

      return SaleModel.fromJson({
        'id': updatedDoc.$id,
        ...updatedDoc.data,
      });
    } catch (e) {
      throw Exception('Failed to update sale status: ${e.toString()}');
    }
  }

  /// Get top customers by purchase value
  Future<List<Map<String, dynamic>>> getTopCustomers({int limit = 10}) async {
    try {
      final salesDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'sales',
        queries: [Query.limit(1000)], // Get all sales to calculate customer totals
      );

      // Group by customer and calculate totals
      Map<String, Map<String, dynamic>> customerTotals = {};

      for (var sale in salesDocs.documents) {
        final customerId = sale.data['customer_id'] as String? ?? '';
        final customerName = sale.data['customer_name'] as String? ?? 'Unknown';
        final totalAmount = (sale.data['total_amount'] ?? 0).toDouble();

        if (customerTotals.containsKey(customerId)) {
          customerTotals[customerId]!['total_amount'] += totalAmount;
          customerTotals[customerId]!['purchase_count'] += 1;
        } else {
          customerTotals[customerId] = {
            'customer_id': customerId,
            'customer_name': customerName,
            'total_amount': totalAmount,
            'purchase_count': 1,
          };
        }
      }

      // Sort by total amount and limit
      var sortedCustomers = customerTotals.values.toList();
      sortedCustomers.sort((a, b) => b['total_amount'].compareTo(a['total_amount']));

      return sortedCustomers.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to fetch top customers: ${e.toString()}');
    }
  }

  /// Helper method to format date for API
  static String formatDateForApi(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }
}