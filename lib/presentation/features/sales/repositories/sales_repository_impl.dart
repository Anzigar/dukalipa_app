import 'dart:async';
import '../../../../data/services/appwrite_sales_service.dart';
import '../models/sale_model.dart';
import 'sales_repository.dart';

class SalesRepositoryImpl implements SalesRepository {
  final AppwriteSalesService _salesService;

  SalesRepositoryImpl() : _salesService = AppwriteSalesService();

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
      return await _salesService.getSales(
        search: search,
        status: status,
        startDate: startDate,
        endDate: endDate,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<SaleModel?> getSaleById(String saleId) async {
    try {
      return await _salesService.getSaleById(saleId);
    } catch (e) {
      // Return null if sale not found instead of throwing
      return null;
    }
  }

  @override
  Future<SaleModel> createSale(SaleModel sale) async {
    try {
      final data = sale.toJson();
      return await _salesService.createSale(data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<SaleModel> updateSale(SaleModel sale) async {
    try {
      final data = sale.toJson();
      return await _salesService.updateSale(sale.id, data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteSale(String saleId) async {
    try {
      await _salesService.deleteSale(saleId);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<double> getTotalRevenue({DateTime? startDate, DateTime? endDate}) async {
    try {
      final stats = await getSalesStats(startDate: startDate, endDate: endDate);
      return stats['total_revenue'] as double;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<int> getSalesCount({DateTime? startDate, DateTime? endDate}) async {
    try {
      final stats = await getSalesStats(startDate: startDate, endDate: endDate);
      return stats['total_sales'] as int;
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
      return await _salesService.getSalesStatistics(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Helper methods
  String formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Exception _handleError(dynamic error) {
    if (error is Exception) {
      return Exception('Failed to process sales operation: ${error.toString()}');
    }
    return Exception('Failed to process sales operation: $error');
  }
}