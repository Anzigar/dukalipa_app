import 'dart:async';
import '../../../../core/network/api_client.dart';
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
  final ApiClient _apiClient;

  DeletedItemRepositoryImpl(this._apiClient);

  @override
  Future<List<DeletedItemModel>> getDeletedItems({
    String? search,
    String? itemType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (itemType != null && itemType.isNotEmpty) {
        queryParams['item_type'] = itemType;
      }
      
      if (startDate != null) {
        queryParams['start_date'] = formatDateForApi(startDate);
      }
      
      if (endDate != null) {
        queryParams['end_date'] = formatDateForApi(endDate);
      }

      final response = await _apiClient.get('/deleted-items', queryParameters: queryParams);
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => DeletedItemModel.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<DeletedItemModel> getDeletedItemById(String id) async {
    try {
      final response = await _apiClient.get('/deleted-items/$id');
      return DeletedItemModel.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> restoreItem(String id) async {
    try {
      await _apiClient.post('/deleted-items/$id/restore');
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> permanentlyDeleteItem(String id) async {
    try {
      await _apiClient.delete('/deleted-items/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Helper function to handle errors
  Exception _handleError(dynamic error) {
    // Add specific error handling logic here
    return Exception('Failed to perform operation: ${error.toString()}');
  }

  // Helper function to format date for API
  String formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
