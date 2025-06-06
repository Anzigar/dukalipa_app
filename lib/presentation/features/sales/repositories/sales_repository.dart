import 'dart:async';

import '../../../../core/network/api_client.dart';
import '../models/sale_model.dart';
import '../models/sale_item_model.dart';

abstract class SalesRepository {
  /// Fetches a list of sales with optional filtering
  Future<List<SaleModel>> getSales({
    String? search,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  });

  /// Fetches a specific sale by ID
  Future<SaleModel> getSaleById(String id);

  /// Creates a new sale
  Future<SaleModel> createSale({
    required List<SaleItemModel> items,
    String? customerName,
    String? customerPhone,
    double discount = 0,
    String? paymentMethod,
    String? note,
  });

  /// Updates an existing sale
  Future<SaleModel> updateSale({
    required String id,
    String? status,
    String? paymentMethod,
    String? note,
  });

  /// Deletes a sale
  Future<void> deleteSale(String id);

  /// Gets sales statistics
  Future<Map<String, dynamic>> getSalesStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });
}

class SalesRepositoryImpl implements SalesRepository {
  final ApiClient _apiClient;

  SalesRepositoryImpl(this._apiClient);

  @override
  Future<List<SaleModel>> getSales({
    String? search,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (startDate != null) {
        queryParams['startDate'] = formatDateForApi(startDate);
      }

      if (endDate != null) {
        queryParams['endDate'] = formatDateForApi(endDate);
      }

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _apiClient.get('/sales', queryParameters: queryParams);
      final List<dynamic> salesJson = response['data'] ?? [];
      return salesJson.map((json) => SaleModel.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<SaleModel> getSaleById(String id) async {
    try {
      final response = await _apiClient.get('/sales/$id');
      return SaleModel.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<SaleModel> createSale({
    required List<SaleItemModel> items,
    String? customerName,
    String? customerPhone,
    double discount = 0,
    String? paymentMethod,
    String? note,
  }) async {
    try {
      final data = {
        'items': items.map((item) => item.toJson()).toList(),
        'discount': discount,
      };
      
      if (customerName != null) data['customerName'] = customerName;
      if (customerPhone != null) data['customerPhone'] = customerPhone;
      if (paymentMethod != null) data['paymentMethod'] = paymentMethod;
      if (note != null) data['note'] = note;
      
      final response = await _apiClient.post('/sales', data: data);
      return SaleModel.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<SaleModel> updateSale({
    required String id,
    String? status,
    String? paymentMethod,
    String? note,
  }) async {
    try {
      final data = <String, dynamic>{};
      
      if (status != null) data['status'] = status;
      if (paymentMethod != null) data['paymentMethod'] = paymentMethod;
      if (note != null) data['note'] = note;
      
      final response = await _apiClient.patch('/sales/$id', data: data);
      return SaleModel.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteSale(String id) async {
    try {
      await _apiClient.delete('/sales/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getSalesStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (startDate != null) {
        queryParams['startDate'] = formatDateForApi(startDate);
      }
      
      if (endDate != null) {
        queryParams['endDate'] = formatDateForApi(endDate);
      }
      
      final response = await _apiClient.get('/sales/statistics', queryParameters: queryParams);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Helper function to handle errors
  Exception _handleError(dynamic error) {
    if (error is TimeoutException) {
      return Exception('Connection timed out. Please check your internet connection and try again.');
    }
    // Add more specific error handling as needed
    return Exception('Failed to perform operation: ${error.toString()}');
  }

  // Helper function to format date for API
  String formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
