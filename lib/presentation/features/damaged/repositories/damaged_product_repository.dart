import 'dart:async';

import '../../../../core/network/api_client.dart';
import '../models/damaged_product_model.dart';

abstract class DamagedProductRepository {
  Future<List<DamagedProductModel>> getDamagedProducts({
    String? search,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<DamagedProductModel> getDamagedProductById(String id);
  
  Future<DamagedProductModel> reportDamagedProduct({
    required String productId,
    required String productName,
    required int quantity,
    required double pricePerUnit,
    required String reason,
    String? notes,
  });
  
  Future<void> deleteDamagedProductReport(String id);
}

class DamagedProductRepositoryImpl implements DamagedProductRepository {
  final ApiClient _apiClient;

  DamagedProductRepositoryImpl(this._apiClient);

  @override
  Future<List<DamagedProductModel>> getDamagedProducts({
    String? search,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (startDate != null) {
        queryParams['start_date'] = formatDateForApi(startDate);
      }
      
      if (endDate != null) {
        queryParams['end_date'] = formatDateForApi(endDate);
      }

      final response = await _apiClient.get('/damaged-products', queryParameters: queryParams);
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => DamagedProductModel.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<DamagedProductModel> getDamagedProductById(String id) async {
    try {
      final response = await _apiClient.get('/damaged-products/$id');
      return DamagedProductModel.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<DamagedProductModel> reportDamagedProduct({
    required String productId,
    required String productName,
    required int quantity,
    required double pricePerUnit,
    required String reason,
    String? notes,
  }) async {
    try {
      final data = {
        'product_id': productId,
        'product_name': productName,
        'quantity': quantity,
        'price_per_unit': pricePerUnit,
        'reason': reason,
        'reported_date': DateTime.now().toIso8601String(),
      };
      
      if (notes != null) {
        data['notes'] = notes;
      }
      
      final response = await _apiClient.post('/damaged-products', data: data);
      return DamagedProductModel.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteDamagedProductReport(String id) async {
    try {
      await _apiClient.delete('/damaged-products/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Helper function to handle errors
  Exception _handleError(dynamic error) {
    if (error is TimeoutException) {
      return Exception('Connection timed out. Please check your internet connection.');
    }
    return Exception('Failed to perform operation: $error');
  }

  // Helper function to format date for API
  String formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
