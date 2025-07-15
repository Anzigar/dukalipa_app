import 'dart:async';
import '../models/sale_model.dart';

abstract class SalesRepository {
  Future<List<SaleModel>> getSales({
    String? search,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? page,
    int? pageSize,
  });

  Future<SaleModel?> getSaleById(String saleId);
  Future<SaleModel> createSale(SaleModel sale);
  Future<SaleModel> updateSale(SaleModel sale);
  Future<void> deleteSale(String saleId);
  Future<double> getTotalRevenue({DateTime? startDate, DateTime? endDate});
  Future<int> getSalesCount({DateTime? startDate, DateTime? endDate});
  Future<Map<String, dynamic>> getSalesStats({DateTime? startDate, DateTime? endDate});
}

class SalesRepositoryImpl implements SalesRepository {
  final List<SaleModel> _sales = [];
  int _nextId = 1;

  @override
  Future<SaleModel> createSale(SaleModel sale) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final newSale = sale.copyWith(
      id: sale.id.isEmpty ? _nextId.toString() : sale.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    _sales.add(newSale);
    _nextId++;
    
    return newSale;
  }

  @override
  Future<List<SaleModel>> getSales({
    String? search,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? page,
    int? pageSize,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    List<SaleModel> filteredSales = List.from(_sales);
    
    if (search != null && search.isNotEmpty) {
      final searchLower = search.toLowerCase();
      filteredSales = filteredSales.where((sale) =>
        sale.id.toLowerCase().contains(searchLower) ||
        (sale.customerName?.toLowerCase().contains(searchLower) ?? false) ||
        (sale.customerPhone?.toLowerCase().contains(searchLower) ?? false)
      ).toList();
    }
    
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      filteredSales = filteredSales.where((sale) =>
        sale.status.toLowerCase() == status.toLowerCase()
      ).toList();
    }
    
    if (startDate != null) {
      filteredSales = filteredSales.where((sale) =>
        sale.dateTime.isAfter(startDate) || sale.dateTime.isAtSameMomentAs(startDate)
      ).toList();
    }
    
    if (endDate != null) {
      filteredSales = filteredSales.where((sale) =>
        sale.dateTime.isBefore(endDate.add(const Duration(days: 1)))
      ).toList();
    }
    
    filteredSales.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    
    if (page != null && pageSize != null) {
      final startIndex = (page - 1) * pageSize;
      final endIndex = startIndex + pageSize;
      
      if (startIndex < filteredSales.length) {
        filteredSales = filteredSales.sublist(
          startIndex,
          endIndex > filteredSales.length ? filteredSales.length : endIndex,
        );
      } else {
        filteredSales = [];
      }
    }
    
    return filteredSales;
  }

  @override
  Future<SaleModel?> getSaleById(String saleId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    try {
      return _sales.firstWhere((sale) => sale.id == saleId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<SaleModel> updateSale(SaleModel sale) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final index = _sales.indexWhere((s) => s.id == sale.id);
    if (index == -1) {
      throw Exception('Sale not found');
    }
    
    final updatedSale = sale.copyWith(updatedAt: DateTime.now());
    _sales[index] = updatedSale;
    
    return updatedSale;
  }

  @override
  Future<void> deleteSale(String saleId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _sales.indexWhere((sale) => sale.id == saleId);
    if (index == -1) {
      throw Exception('Sale not found');
    }
    
    _sales.removeAt(index);
  }

  @override
  Future<Map<String, dynamic>> getSalesStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    List<SaleModel> salesInRange = _sales;
    
    if (startDate != null) {
      salesInRange = salesInRange.where((sale) =>
        sale.dateTime.isAfter(startDate) || sale.dateTime.isAtSameMomentAs(startDate)
      ).toList();
    }
    
    if (endDate != null) {
      salesInRange = salesInRange.where((sale) =>
        sale.dateTime.isBefore(endDate.add(const Duration(days: 1)))
      ).toList();
    }
    
    final totalSales = salesInRange.length;
    final totalRevenue = salesInRange.fold<double>(
      0.0, (sum, sale) => sum + sale.totalAmount
    );
    final averageSaleValue = totalSales > 0 ? totalRevenue / totalSales : 0.0;
    
    final completedSales = salesInRange.where((sale) => sale.isCompleted).length;
    final pendingSales = salesInRange.where((sale) => sale.isPending).length;
    final cancelledSales = salesInRange.where((sale) => sale.isCancelled).length;
    
    return {
      'totalSales': totalSales,
      'totalRevenue': totalRevenue,
      'averageSaleValue': averageSaleValue,
      'completedSales': completedSales,
      'pendingSales': pendingSales,
      'cancelledSales': cancelledSales,
    };
  }

  @override
  Future<double> getTotalRevenue({DateTime? startDate, DateTime? endDate}) async {
    final stats = await getSalesStats(startDate: startDate, endDate: endDate);
    return stats['totalRevenue'] as double;
  }

  @override
  Future<int> getSalesCount({DateTime? startDate, DateTime? endDate}) async {
    final stats = await getSalesStats(startDate: startDate, endDate: endDate);
    return stats['totalSales'] as int;
  }
}
