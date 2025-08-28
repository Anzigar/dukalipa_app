import 'package:appwrite/appwrite.dart';
import '../../core/services/appwrite_service.dart';
import '../../presentation/features/deleted/models/deleted_item_model.dart';

/// Service for handling deleted items operations using Appwrite backend
class AppwriteDeletedItemService {
  final Databases _databases;
  final String _databaseId = 'shop_management_db';

  AppwriteDeletedItemService() : _databases = AppwriteService().databases;

  /// Get all deleted items with optional filtering
  Future<List<DeletedItemModel>> getDeletedItems({
    String? search,
    String? itemType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      List<String> queries = [];

      // Add search functionality
      if (search != null && search.isNotEmpty) {
        queries.add(Query.search('item_name', search));
      }

      // Add item type filter
      if (itemType != null && itemType.isNotEmpty) {
        queries.add(Query.equal('item_type', itemType));
      }

      // Add date filters
      if (startDate != null) {
        queries.add(Query.greaterThanEqual('deleted_at', startDate.toIso8601String()));
      }

      if (endDate != null) {
        queries.add(Query.lessThanEqual('deleted_at', endDate.toIso8601String()));
      }

      // Order by deletion date (newest first)
      queries.add(Query.orderDesc('deleted_at'));
      queries.add(Query.limit(100));

      final deletedItemDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'deleted_items',
        queries: queries,
      );

      return deletedItemDocs.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['id'] = doc.$id;
        return DeletedItemModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch deleted items: ${e.toString()}');
    }
  }

  /// Get a specific deleted item by ID
  Future<DeletedItemModel> getDeletedItemById(String id) async {
    try {
      final deletedItemDoc = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: 'deleted_items',
        documentId: id,
      );

      final data = Map<String, dynamic>.from(deletedItemDoc.data);
      data['id'] = deletedItemDoc.$id;

      return DeletedItemModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch deleted item: ${e.toString()}');
    }
  }

  /// Record a deleted item
  Future<DeletedItemModel> recordDeletedItem({
    required String itemId,
    required String itemName,
    required String itemType,
    required String deletedBy,
    bool isRecoverable = true,
  }) async {
    try {
      final deletedItemId = ID.unique();

      final deletedItemData = {
        'item_id': itemId,
        'item_name': itemName,
        'item_type': itemType,
        'deleted_by': deletedBy,
        'deleted_at': DateTime.now().toIso8601String(),
        'is_recoverable': isRecoverable,
        '\$createdAt': DateTime.now().toIso8601String(),
        '\$updatedAt': DateTime.now().toIso8601String(),
      };

      final createdDoc = await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: 'deleted_items',
        documentId: deletedItemId,
        data: deletedItemData,
      );

      final resultData = Map<String, dynamic>.from(createdDoc.data);
      resultData['id'] = createdDoc.$id;
      return DeletedItemModel.fromJson(resultData);
    } catch (e) {
      throw Exception('Failed to record deleted item: ${e.toString()}');
    }
  }

  /// Restore a deleted item
  Future<void> restoreItem(String id) async {
    try {
      // Here you would typically restore the original item to its collection
      // This is a complex operation that depends on the item type
      // For now, we'll just mark it as not recoverable and add a note
      
      await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: 'deleted_items',
        documentId: id,
        data: {
          'is_recoverable': false,
          'restored_at': DateTime.now().toIso8601String(),
          '\$updatedAt': DateTime.now().toIso8601String(),
        },
      );

      // TODO: Implement actual restoration logic based on item type
      // This would involve:
      // 1. Recreating the item in its original collection
      // 2. Updating any references to the item
      // 3. Removing it from deleted_items or marking as restored
      
    } catch (e) {
      throw Exception('Failed to restore item: ${e.toString()}');
    }
  }

  /// Permanently delete an item from the deleted items collection
  Future<void> permanentlyDeleteItem(String id) async {
    try {
      await _databases.deleteDocument(
        databaseId: _databaseId,
        collectionId: 'deleted_items',
        documentId: id,
      );
    } catch (e) {
      throw Exception('Failed to permanently delete item: ${e.toString()}');
    }
  }

  /// Get deleted items statistics
  Future<Map<String, dynamic>> getDeletedItemsStatistics() async {
    try {
      // Get all deleted items
      final allDeletedItems = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'deleted_items',
        queries: [
          Query.limit(1000),
        ],
      );

      // Count by item type
      Map<String, int> typeCount = {};
      int recoverableCount = 0;
      
      for (var doc in allDeletedItems.documents) {
        final itemType = doc.data['item_type'] as String? ?? 'unknown';
        final isRecoverable = doc.data['is_recoverable'] as bool? ?? false;
        
        typeCount[itemType] = (typeCount[itemType] ?? 0) + 1;
        if (isRecoverable) recoverableCount++;
      }

      return {
        'total_count': allDeletedItems.total,
        'recoverable_count': recoverableCount,
        'permanent_count': allDeletedItems.total - recoverableCount,
        'type_breakdown': typeCount,
      };
    } catch (e) {
      throw Exception('Failed to fetch deleted items statistics: ${e.toString()}');
    }
  }

  /// Get deleted items by type
  Future<List<DeletedItemModel>> getDeletedItemsByType(String itemType) async {
    try {
      final deletedItemDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'deleted_items',
        queries: [
          Query.equal('item_type', itemType),
          Query.orderDesc('deleted_at'),
          Query.limit(50),
        ],
      );

      return deletedItemDocs.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['id'] = doc.$id;
        return DeletedItemModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch deleted items by type: ${e.toString()}');
    }
  }

  /// Clean up old deleted items (older than specified days)
  Future<int> cleanupOldDeletedItems({int olderThanDays = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));
      
      final oldDeletedItems = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'deleted_items',
        queries: [
          Query.lessThan('deleted_at', cutoffDate.toIso8601String()),
          Query.equal('is_recoverable', false), // Only delete non-recoverable items
          Query.limit(100),
        ],
      );

      int deletedCount = 0;
      for (var doc in oldDeletedItems.documents) {
        await _databases.deleteDocument(
          databaseId: _databaseId,
          collectionId: 'deleted_items',
          documentId: doc.$id,
        );
        deletedCount++;
      }

      return deletedCount;
    } catch (e) {
      throw Exception('Failed to cleanup old deleted items: ${e.toString()}');
    }
  }
}