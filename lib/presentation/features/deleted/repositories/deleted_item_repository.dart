import 'dart:async';
import 'package:dio/dio.dart';
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
  late final Dio _dio;

  DeletedItemRepositoryImpl() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api/v1',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }

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

      final response = await _dio.get('/deleted-items', queryParameters: queryParams);
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => DeletedItemModel.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<DeletedItemModel> getDeletedItemById(String id) async {
    try {
      final response = await _dio.get('/deleted-items/$id');
      return DeletedItemModel.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> restoreItem(String id) async {
    try {
      await _dio.post('/deleted-items/$id/restore');
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> permanentlyDeleteItem(String id) async {
    try {
      await _dio.delete('/deleted-items/$id');
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
