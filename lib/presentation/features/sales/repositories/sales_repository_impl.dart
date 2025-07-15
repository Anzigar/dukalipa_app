import 'dart:async';

import 'package:dio/dio.dart';
import '../models/sale_model.dart';
import 'sales_repository.dart';

class SalesRepositoryImpl implements SalesRepository {
  final Dio _dio;

  SalesRepositoryImpl() : _dio = Dio(BaseOptions(
    baseUrl: 'http://127.0.0.1:8000/api/v1',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  @override
  Future<List<SaleModel>> getSales({
    String? search,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? page,
    int? pageSize,
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

      if (page != null) {
        queryParams['page'] = page;
      }

      if (pageSize != null) {
        queryParams['pageSize'] = pageSize;
      }

      final response = await _dio.get('/sales', queryParameters: queryParams);
      final List<dynamic> salesJson = response.data['data'] ?? [];
      return salesJson.map((json) => SaleModel.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<SaleModel?> getSaleById(String saleId) async {
    try {
      final response = await _dio.get('/sales/$saleId');
      return SaleModel.fromJson(response.data['data']);
    } catch (e) {
      // Return null if sale not found instead of throwing
      return null;
    }
  }

  @override
  Future<SaleModel> createSale(SaleModel sale) async {
    try {
      final data = sale.toJson();
      final response = await _dio.post('/sales', data: data);
      return SaleModel.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<SaleModel> updateSale(SaleModel sale) async {
    try {
      final data = sale.toJson();
      final response = await _dio.patch('/sales/${sale.id}', data: data);
      return SaleModel.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteSale(String saleId) async {
    try {
      await _dio.delete('/sales/$saleId');
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<double> getTotalRevenue({DateTime? startDate, DateTime? endDate}) async {
    try {
      final stats = await getSalesStats(startDate: startDate, endDate: endDate);
      return stats['totalRevenue'] as double;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<int> getSalesCount({DateTime? startDate, DateTime? endDate}) async {
    try {
      final stats = await getSalesStats(startDate: startDate, endDate: endDate);
      return stats['totalSales'] as int;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getSalesStats({
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
      
      final response = await _dio.get('/sales/statistics', queryParameters: queryParams);
      return response.data['data'] ?? <String, dynamic>{};
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Helper methods
  String formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      return Exception('Failed to process sales operation: ${error.message}');
    }
    if (error is Exception) {
      return Exception('Failed to process sales operation: ${error.toString()}');
    }
    return Exception('Failed to process sales operation: $error');
  }
}