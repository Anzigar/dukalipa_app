import 'dart:async';
import '../../../../data/services/appwrite_deleted_item_service.dart';
import '../models/deleted_item_model.dart';

abstract class DeletedItemRepository {
  Future<List<DeletedItemModel>> getDeletedItems({
    String? search,
    String? itemType,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<DeletedItemModel> getDeletedItemById(String id);
  
  Future<void> restoreItem(String id);
  
  Future<void> permanentlyDeleteItem(String id);
}

class DeletedItemRepositoryImpl implements DeletedItemRepository {
  final AppwriteDeletedItemService _deletedItemService;

  DeletedItemRepositoryImpl() : _deletedItemService = AppwriteDeletedItemService();

  @override
  Future<List<DeletedItemModel>> getDeletedItems({
    String? search,
    String? itemType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _deletedItemService.getDeletedItems(
        search: search,
        itemType: itemType,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to fetch deleted items: ${e.toString()}');
    }
  }

  @override
  Future<DeletedItemModel> getDeletedItemById(String id) async {
    try {
      return await _deletedItemService.getDeletedItemById(id);
    } catch (e) {
      throw Exception('Failed to fetch deleted item: ${e.toString()}');
    }
  }

  @override
  Future<void> restoreItem(String id) async {
    try {
      await _deletedItemService.restoreItem(id);
    } catch (e) {
      throw Exception('Failed to restore item: ${e.toString()}');
    }
  }

  @override
  Future<void> permanentlyDeleteItem(String id) async {
    try {
      await _deletedItemService.permanentlyDeleteItem(id);
    } catch (e) {
      throw Exception('Failed to permanently delete item: ${e.toString()}');
    }
  }

}
