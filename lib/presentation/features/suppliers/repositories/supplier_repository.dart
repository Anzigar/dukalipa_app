import 'dart:async';
import '../../../../core/network/api_client.dart';
import '../models/supplier_model.dart';

abstract class SupplierRepository {
  Future<List<SupplierModel>> getSuppliers({
    String? search,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<SupplierModel> getSupplierById(String id);
  
  Future<SupplierModel> createSupplier(SupplierModel supplier);
  
  Future<SupplierModel> updateSupplier(SupplierModel supplier);
  
  Future<void> deleteSupplier(String id);
}

class SupplierRepositoryImpl implements SupplierRepository {
  final ApiClient _apiClient;

  SupplierRepositoryImpl(this._apiClient);

  @override
  Future<List<SupplierModel>> getSuppliers({
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

      final response = await _apiClient.get('/suppliers', queryParameters: queryParams);
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => SupplierModel.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<SupplierModel> getSupplierById(String id) async {
    try {
      final response = await _apiClient.get('/suppliers/$id');
      return SupplierModel.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<SupplierModel> createSupplier(SupplierModel supplier) async {
    try {
      final response = await _apiClient.post(
        '/suppliers',
        data: supplier.toJson(),
      );
      return SupplierModel.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<SupplierModel> updateSupplier(SupplierModel supplier) async {
    try {
      final response = await _apiClient.put(
        '/suppliers/${supplier.id}',
        data: supplier.toJson(),
      );
      return SupplierModel.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteSupplier(String id) async {
    try {
      await _apiClient.delete('/suppliers/$id');
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
