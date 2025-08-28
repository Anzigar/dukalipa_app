import 'package:appwrite/appwrite.dart';
import '../../core/services/appwrite_service.dart';
import '../../presentation/features/suppliers/models/supplier_model.dart';

/// Service for handling supplier operations using Appwrite backend
class AppwriteSupplierService {
  final Databases _databases;
  final String _databaseId = 'shop_management_db';

  AppwriteSupplierService() : _databases = AppwriteService().databases;

  /// Get all suppliers with optional filtering
  Future<List<SupplierModel>> getSuppliers({
    String? search,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      List<String> queries = [];

      // Add search functionality
      if (search != null && search.isNotEmpty) {
        queries.add(Query.search('name', search));
      }

      // Add date filters
      if (startDate != null) {
        queries.add(Query.greaterThanEqual('created_at', startDate.toIso8601String()));
      }

      if (endDate != null) {
        queries.add(Query.lessThanEqual('created_at', endDate.toIso8601String()));
      }

      // Order by creation date (newest first)
      queries.add(Query.orderDesc('\$createdAt'));
      queries.add(Query.limit(100));

      final supplierDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'suppliers',
        queries: queries,
      );

      return supplierDocs.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['id'] = doc.$id;
        return SupplierModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch suppliers: ${e.toString()}');
    }
  }

  /// Get a specific supplier by ID
  Future<SupplierModel> getSupplierById(String supplierId) async {
    try {
      final supplierDoc = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: 'suppliers',
        documentId: supplierId,
      );

      final data = Map<String, dynamic>.from(supplierDoc.data);
      data['id'] = supplierDoc.$id;

      return SupplierModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch supplier: ${e.toString()}');
    }
  }

  /// Create a new supplier
  Future<SupplierModel> createSupplier(SupplierModel supplier) async {
    try {
      final supplierId = ID.unique();
      final now = DateTime.now();

      // Prepare supplier data
      final supplierData = {
        'name': supplier.name,
        'contact_name': supplier.contactName,
        'phone_number': supplier.phoneNumber,
        'email': supplier.email,
        'address': supplier.address,
        'total_orders': supplier.totalOrders,
        'order_count': supplier.orderCount,
        'last_order_date': supplier.lastOrderDate.toIso8601String(),
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      // Create the supplier document
      await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: 'suppliers',
        documentId: supplierId,
        data: supplierData,
      );

      // Get the created supplier
      return await getSupplierById(supplierId);
    } catch (e) {
      throw Exception('Failed to create supplier: ${e.toString()}');
    }
  }

  /// Update an existing supplier
  Future<SupplierModel> updateSupplier(SupplierModel supplier) async {
    try {
      final updateData = {
        'name': supplier.name,
        'contact_name': supplier.contactName,
        'phone_number': supplier.phoneNumber,
        'email': supplier.email,
        'address': supplier.address,
        'total_orders': supplier.totalOrders,
        'order_count': supplier.orderCount,
        'last_order_date': supplier.lastOrderDate.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: 'suppliers',
        documentId: supplier.id,
        data: updateData,
      );

      return await getSupplierById(supplier.id);
    } catch (e) {
      throw Exception('Failed to update supplier: ${e.toString()}');
    }
  }

  /// Delete a supplier
  Future<void> deleteSupplier(String supplierId) async {
    try {
      await _databases.deleteDocument(
        databaseId: _databaseId,
        collectionId: 'suppliers',
        documentId: supplierId,
      );
    } catch (e) {
      throw Exception('Failed to delete supplier: ${e.toString()}');
    }
  }

  /// Search suppliers by name or contact name
  Future<List<SupplierModel>> searchSuppliers(String query) async {
    try {
      final supplierDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'suppliers',
        queries: [
          Query.search('name', query),
          Query.limit(50),
        ],
      );

      List<SupplierModel> suppliers = supplierDocs.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['id'] = doc.$id;
        return SupplierModel.fromJson(data);
      }).toList();

      // Also search by contact name if no results by name
      if (suppliers.isEmpty) {
        final contactResults = await _databases.listDocuments(
          databaseId: _databaseId,
          collectionId: 'suppliers',
          queries: [
            Query.search('contact_name', query),
            Query.limit(50),
          ],
        );

        suppliers = contactResults.documents.map((doc) {
          final data = Map<String, dynamic>.from(doc.data);
          data['id'] = doc.$id;
          return SupplierModel.fromJson(data);
        }).toList();
      }

      return suppliers;
    } catch (e) {
      throw Exception('Failed to search suppliers: ${e.toString()}');
    }
  }

  /// Get supplier statistics
  Future<Map<String, dynamic>> getSupplierStatistics() async {
    try {
      // Get all suppliers for statistics
      final allSuppliers = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'suppliers',
      );

      double totalOrders = 0;
      int totalOrderCount = 0;
      SupplierModel? topSupplier;
      double topSupplierOrders = 0;

      for (var doc in allSuppliers.documents) {
        final data = Map<String, dynamic>.from(doc.data);
        data['id'] = doc.$id;
        final supplier = SupplierModel.fromJson(data);
        
        totalOrders += supplier.totalOrders;
        totalOrderCount += supplier.orderCount;
        
        if (supplier.totalOrders > topSupplierOrders) {
          topSupplierOrders = supplier.totalOrders;
          topSupplier = supplier;
        }
      }

      return {
        'total_suppliers': allSuppliers.total,
        'total_orders_value': totalOrders,
        'total_order_count': totalOrderCount,
        'average_order_value': totalOrderCount > 0 ? totalOrders / totalOrderCount : 0,
        'top_supplier': topSupplier?.toJson(),
      };
    } catch (e) {
      throw Exception('Failed to fetch supplier statistics: ${e.toString()}');
    }
  }

  /// Get top suppliers by total orders
  Future<List<SupplierModel>> getTopSuppliers({int limit = 10}) async {
    try {
      final supplierDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'suppliers',
        queries: [
          Query.orderDesc('total_orders'),
          Query.limit(limit),
        ],
      );

      return supplierDocs.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['id'] = doc.$id;
        return SupplierModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch top suppliers: ${e.toString()}');
    }
  }

  /// Update supplier order statistics (when a new order is placed)
  Future<void> updateSupplierOrderStats(String supplierId, double orderAmount) async {
    try {
      // Get current supplier data
      final supplier = await getSupplierById(supplierId);
      
      // Update statistics
      await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: 'suppliers',
        documentId: supplierId,
        data: {
          'total_orders': supplier.totalOrders + orderAmount,
          'order_count': supplier.orderCount + 1,
          'last_order_date': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to update supplier order statistics: ${e.toString()}');
    }
  }
}