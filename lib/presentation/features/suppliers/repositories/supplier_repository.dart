import 'dart:async';
import 'package:dio/dio.dart';
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
  late final Dio _dio;

  SupplierRepositoryImpl() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api/v1',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }

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

      final response = await _dio.get('/suppliers', queryParameters: queryParams);
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => SupplierModel.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<SupplierModel> getSupplierById(String id) async {
    try {
      final response = await _dio.get('/suppliers/$id');
      return SupplierModel.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<SupplierModel> createSupplier(SupplierModel supplier) async {
    try {
      final response = await _dio.post(
        '/suppliers',
        data: supplier.toJson(),
      );
      return SupplierModel.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<SupplierModel> updateSupplier(SupplierModel supplier) async {
    try {
      final response = await _dio.put(
        '/suppliers/${supplier.id}',
        data: supplier.toJson(),
      );
      return SupplierModel.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteSupplier(String id) async {
    try {
      await _dio.delete('/suppliers/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Helper function to handle errors
  Exception _handleError(dynamic e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return Exception('Network error. Please check your internet connection.');
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          if (statusCode == 404) {
            return Exception('Supplier not found.');
          }
          if (statusCode == 401 || statusCode == 403) {
            return Exception('Authentication error. Please login again.');
          }
          return Exception('Server error: ${e.response?.statusMessage}');
        default:
          return Exception('An error occurred: ${e.message}');
      }
    }
    
    return Exception('An error occurred: ${e.toString()}');
  }

  // Helper function to format date for API
  String formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
