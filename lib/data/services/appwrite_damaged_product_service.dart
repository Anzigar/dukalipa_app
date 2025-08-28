import 'package:appwrite/appwrite.dart';
import '../../core/services/appwrite_service.dart';
import '../../presentation/features/damaged/models/damaged_product_model.dart';

/// Service for handling damaged products operations using Appwrite backend
class AppwriteDamagedProductService {
  final Databases _databases;
  final String _databaseId = 'shop_management_db';

  AppwriteDamagedProductService() : _databases = AppwriteService().databases;

  /// Report a new damaged product
  Future<DamagedProductModel> reportDamagedProduct({
    required String productId,
    required String productName,
    required int quantity,
    required double pricePerUnit,
    required String reason,
    String? notes,
    String? imageUrl,
  }) async {
    try {
      final damagedProductId = ID.unique();

      final damagedProductData = {
        'product_id': productId,
        'product_name': productName,
        'image_url': imageUrl,
        'quantity': quantity,
        'price_per_unit': pricePerUnit,
        'reason': reason,
        'reported_date': DateTime.now().toIso8601String(),
        'notes': notes,
        '\$createdAt': DateTime.now().toIso8601String(),
        '\$updatedAt': DateTime.now().toIso8601String(),
      };

      final createdDoc = await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: 'damaged_products',
        documentId: damagedProductId,
        data: damagedProductData,
      );

      final resultData = Map<String, dynamic>.from(createdDoc.data);
      resultData['id'] = createdDoc.$id;
      return DamagedProductModel.fromJson(resultData);
    } catch (e) {
      throw Exception('Failed to report damaged product: ${e.toString()}');
    }
  }

  /// Get all damaged products with pagination and filtering
  Future<List<DamagedProductModel>> getDamagedProducts({
    int page = 1,
    int limit = 20,
    String? productName,
    String? reason,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      List<String> queries = [];

      // Add search functionality
      if (productName != null && productName.isNotEmpty) {
        queries.add(Query.search('product_name', productName));
      }

      // Add reason filter
      if (reason != null && reason.isNotEmpty) {
        queries.add(Query.equal('reason', reason));
      }

      // Add date filters
      if (startDate != null) {
        queries.add(Query.greaterThanEqual('reported_date', startDate.toIso8601String()));
      }

      if (endDate != null) {
        queries.add(Query.lessThanEqual('reported_date', endDate.toIso8601String()));
      }

      // Add pagination and ordering
      queries.add(Query.orderDesc('reported_date'));
      queries.add(Query.limit(limit));
      
      if (page > 1) {
        queries.add(Query.offset((page - 1) * limit));
      }

      final damagedProductDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'damaged_products',
        queries: queries,
      );

      return damagedProductDocs.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['id'] = doc.$id;
        return DamagedProductModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch damaged products: ${e.toString()}');
    }
  }

  /// Get a specific damage report by ID
  Future<DamagedProductModel> getDamageReport(String damageId) async {
    try {
      final damagedProductDoc = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: 'damaged_products',
        documentId: damageId,
      );

      final data = Map<String, dynamic>.from(damagedProductDoc.data);
      data['id'] = damagedProductDoc.$id;

      return DamagedProductModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch damage report: ${e.toString()}');
    }
  }

  /// Update a damage report
  Future<DamagedProductModel> updateDamageReport(
    String damageId, {
    int? quantity,
    double? pricePerUnit,
    String? reason,
    String? notes,
    String? imageUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (quantity != null) updateData['quantity'] = quantity;
      if (pricePerUnit != null) updateData['price_per_unit'] = pricePerUnit;
      if (reason != null) updateData['reason'] = reason;
      if (notes != null) updateData['notes'] = notes;
      if (imageUrl != null) updateData['image_url'] = imageUrl;

      updateData['\$updatedAt'] = DateTime.now().toIso8601String();

      await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: 'damaged_products',
        documentId: damageId,
        data: updateData,
      );

      return await getDamageReport(damageId);
    } catch (e) {
      throw Exception('Failed to update damage report: ${e.toString()}');
    }
  }

  /// Delete a damage report
  Future<void> deleteDamageReport(String damageId) async {
    try {
      await _databases.deleteDocument(
        databaseId: _databaseId,
        collectionId: 'damaged_products',
        documentId: damageId,
      );
    } catch (e) {
      throw Exception('Failed to delete damage report: ${e.toString()}');
    }
  }

  /// Get damage analytics
  Future<Map<String, dynamic>> getDamageAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      List<String> queries = [];

      // Add date filters
      if (startDate != null) {
        queries.add(Query.greaterThanEqual('reported_date', startDate.toIso8601String()));
      }

      if (endDate != null) {
        queries.add(Query.lessThanEqual('reported_date', endDate.toIso8601String()));
      }

      queries.add(Query.limit(1000));

      final damagedProductDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'damaged_products',
        queries: queries,
      );

      // Calculate analytics
      double totalLoss = 0;
      Map<String, int> reasonCount = {};
      Map<String, double> reasonLoss = {};

      for (var doc in damagedProductDocs.documents) {
        final quantity = (doc.data['quantity'] ?? 0) as int;
        final pricePerUnit = (doc.data['price_per_unit'] ?? 0).toDouble();
        final reason = doc.data['reason'] as String? ?? 'Unknown';
        
        final itemLoss = quantity * pricePerUnit;
        totalLoss += itemLoss;

        reasonCount[reason] = (reasonCount[reason] ?? 0) + 1;
        reasonLoss[reason] = (reasonLoss[reason] ?? 0) + itemLoss;
      }

      return {
        'total_damaged_items': damagedProductDocs.total,
        'total_financial_loss': totalLoss,
        'average_loss_per_incident': damagedProductDocs.total > 0 ? totalLoss / damagedProductDocs.total : 0.0,
        'damage_reasons': reasonCount,
        'loss_by_reason': reasonLoss,
      };
    } catch (e) {
      throw Exception('Failed to fetch damage analytics: ${e.toString()}');
    }
  }

  /// Get damaged products by reason
  Future<List<DamagedProductModel>> getDamagedProductsByReason(String reason) async {
    try {
      final damagedProductDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'damaged_products',
        queries: [
          Query.equal('reason', reason),
          Query.orderDesc('reported_date'),
          Query.limit(50),
        ],
      );

      return damagedProductDocs.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['id'] = doc.$id;
        return DamagedProductModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch damaged products by reason: ${e.toString()}');
    }
  }

  /// Get recent damaged products
  Future<List<DamagedProductModel>> getRecentDamagedProducts({int limit = 10}) async {
    try {
      final damagedProductDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'damaged_products',
        queries: [
          Query.orderDesc('reported_date'),
          Query.limit(limit),
        ],
      );

      return damagedProductDocs.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['id'] = doc.$id;
        return DamagedProductModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch recent damaged products: ${e.toString()}');
    }
  }

  /// Get damaged products summary
  Future<Map<String, dynamic>> getDamagesSummary() async {
    try {
      final damagedProductDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'damaged_products',
        queries: [
          Query.limit(1000),
        ],
      );

      double totalLoss = 0;
      int totalQuantity = 0;

      for (var doc in damagedProductDocs.documents) {
        final quantity = (doc.data['quantity'] ?? 0) as int;
        final pricePerUnit = (doc.data['price_per_unit'] ?? 0).toDouble();
        
        totalQuantity += quantity;
        totalLoss += (quantity * pricePerUnit);
      }

      return {
        'total_reports': damagedProductDocs.total,
        'total_damaged_quantity': totalQuantity,
        'total_financial_loss': totalLoss,
      };
    } catch (e) {
      throw Exception('Failed to fetch damages summary: ${e.toString()}');
    }
  }
}