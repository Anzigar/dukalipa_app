import 'package:flutter/foundation.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../data/services/sales_service.dart';
import '../../../../data/services/returns_service.dart';
import '../../../../data/services/deleted_sales_service.dart';
import '../models/sale_model.dart';

class SalesProvider extends ChangeNotifier {
  final SalesService _salesService = locator<SalesService>();
  final ReturnsService _returnsService = locator<ReturnsService>();
  final DeletedSalesService _deletedSalesService = locator<DeletedSalesService>();

  // State management
  List<SaleModel> _sales = [];
  List<ReturnModel> _returns = [];
  List<DeletedSaleModel> _deletedSales = [];
  bool _isLoading = false;
  String? _errorMessage;
  PaginationInfo? _salesPagination;
  Map<String, dynamic>? _salesAnalytics;

  // Getters
  List<SaleModel> get sales => _sales;
  List<ReturnModel> get returns => _returns;
  List<DeletedSaleModel> get deletedSales => _deletedSales;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PaginationInfo? get salesPagination => _salesPagination;
  Map<String, dynamic>? get salesAnalytics => _salesAnalytics;

  // Sales operations
  Future<bool> createSale({
    required String customerName,
    String? customerPhone,
    required List<SaleItemModel> items,
    double discount = 0.0,
    required String paymentMethod,
    String? note,
    String? createdBy,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _salesService.createSale(
        customerName: customerName,
        customerPhone: customerPhone,
        items: items.map((item) => SaleItemCreateRequest(
          productId: item.productId,
          quantity: item.quantity,
          price: item.price,
        )).toList(),
        discount: discount,
        paymentMethod: paymentMethod,
        note: note,
        createdBy: createdBy,
      );

      if (response.success && response.data != null) {
        _sales.insert(0, response.data!);
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to create sale');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadSales({
    int page = 1,
    int limit = 20,
    String? customerName,
    String? status,
    String? paymentMethod,
    DateTime? startDate,
    DateTime? endDate,
    bool append = false,
  }) async {
    try {
      if (!append) _setLoading(true);
      _clearError();

      final response = await _salesService.getSales(
        page: page,
        limit: limit,
        customerName: customerName,
        status: status,
        paymentMethod: paymentMethod,
        startDate: startDate,
        endDate: endDate,
      );

      if (response.success && response.data != null) {
        final salesData = response.data!.data;
        
        if (append) {
          _sales.addAll(salesData.sales);
        } else {
          _sales = salesData.sales;
        }
        
        _salesPagination = salesData.pagination;
        notifyListeners();
      } else {
        _setError(response.message ?? 'Failed to load sales');
      }
    } catch (e) {
      _setError('An unexpected error occurred: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<SaleModel?> getSaleDetails(String saleId) async {
    try {
      final response = await _salesService.getSale(saleId);
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        _setError(response.message ?? 'Failed to load sale details');
        return null;
      }
    } catch (e) {
      _setError('An unexpected error occurred: $e');
      return null;
    }
  }

  Future<bool> updateSale(
    String saleId, {
    String? customerName,
    String? customerPhone,
    List<SaleItemModel>? items,
    double? discount,
    String? status,
    String? paymentMethod,
    String? note,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _salesService.updateSale(
        saleId,
        customerName: customerName,
        customerPhone: customerPhone,
        items: items?.map((item) => SaleItemCreateRequest(
          productId: item.productId,
          quantity: item.quantity,
          price: item.price,
        )).toList(),
        discount: discount,
        status: status,
        paymentMethod: paymentMethod,
        note: note,
      );

      if (response.success && response.data != null) {
        final index = _sales.indexWhere((sale) => sale.id == saleId);
        if (index != -1) {
          _sales[index] = response.data!;
          notifyListeners();
        }
        return true;
      } else {
        _setError(response.message ?? 'Failed to update sale');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteSale(
    String saleId, {
    required String reason,
    required String deletedBy,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _salesService.deleteSale(
        saleId,
        reason: reason,
        deletedBy: deletedBy,
      );

      if (response.success) {
        _sales.removeWhere((sale) => sale.id == saleId);
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to delete sale');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadSalesAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _salesService.getSalesAnalytics(
        startDate: startDate,
        endDate: endDate,
      );

      if (response.success && response.data != null) {
        _salesAnalytics = response.data!;
        notifyListeners();
      } else {
        _setError(response.message ?? 'Failed to load analytics');
      }
    } catch (e) {
      _setError('An unexpected error occurred: $e');
    }
  }

  // Returns operations
  Future<bool> createReturn({
    required String originalSaleId,
    required String customerName,
    String? customerPhone,
    required List<ReturnItemModel> items,
    required String refundMethod,
    required String reason,
    String? processedBy,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _returnsService.createReturn(
        originalSaleId: originalSaleId,
        customerName: customerName,
        customerPhone: customerPhone,
        items: items.map((item) => ReturnItemCreateRequest(
          productId: item.productId,
          quantity: item.quantity,
          returnPrice: item.returnPrice,
          reason: item.reason,
        )).toList(),
        refundMethod: refundMethod,
        reason: reason,
        processedBy: processedBy,
        notes: notes,
      );

      if (response.success && response.data != null) {
        _returns.insert(0, response.data!);
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to create return');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadReturns({
    int page = 1,
    int limit = 20,
    String? status,
    String? customerName,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _returnsService.getReturns(
        page: page,
        limit: limit,
        status: status,
        customerName: customerName,
      );

      if (response.success && response.data != null) {
        // Note: Returns service reuses SalesListResponse, you may want to create a specific ReturnsListResponse
        _returns = response.data!.data.sales.map((sale) => ReturnModel(
          id: sale.id,
          originalSaleId: sale.id, // This should be mapped properly based on actual API response
          customerName: sale.customerName ?? '',
          customerPhone: sale.customerPhone,
          items: sale.items.map((item) => ReturnItemModel(
            productId: item.productId,
            productName: item.productName,
            quantity: item.quantity,
            originalPrice: item.price,
            returnPrice: item.price,
            total: item.total,
            reason: 'Customer request', // Default reason
          )).toList(),
          totalAmount: sale.totalAmount,
          refundMethod: sale.paymentMethod ?? 'cash',
          status: sale.status,
          reason: 'Customer return',
          dateTime: sale.dateTime,
          notes: sale.note,
          createdAt: sale.createdAt,
          updatedAt: sale.updatedAt,
        )).toList();
        
        notifyListeners();
      } else {
        _setError(response.message ?? 'Failed to load returns');
      }
    } catch (e) {
      _setError('An unexpected error occurred: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Deleted sales operations
  Future<void> loadDeletedSales({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _deletedSalesService.getDeletedSales(
        page: page,
        limit: limit,
      );

      if (response.success && response.data != null) {
        // Note: This would need proper mapping based on actual API response structure
        _deletedSales = response.data!.data.sales.map((sale) => DeletedSaleModel(
          id: '${sale.id}_deleted',
          originalSaleId: sale.id,
          saleData: sale,
          reason: 'Unknown', // This should come from API
          deletedBy: 'Unknown', // This should come from API
          deletedAt: DateTime.now(), // This should come from API
          canRestore: true,
        )).toList();
        
        notifyListeners();
      } else {
        _setError(response.message ?? 'Failed to load deleted sales');
      }
    } catch (e) {
      _setError('An unexpected error occurred: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> restoreDeletedSale(String deletedSaleId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _deletedSalesService.restoreDeletedSale(deletedSaleId);

      if (response.success) {
        _deletedSales.removeWhere((sale) => sale.id == deletedSaleId);
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to restore sale');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  void clearSales() {
    _sales.clear();
    _returns.clear();
    _deletedSales.clear();
    _salesAnalytics = null;
    _salesPagination = null;
    _clearError();
    notifyListeners();
  }

  // Convenience getters for UI
  bool get hasSales => _sales.isNotEmpty;
  bool get hasReturns => _returns.isNotEmpty;
  bool get hasDeletedSales => _deletedSales.isNotEmpty;
  bool get hasError => _errorMessage != null;
  bool get canLoadMoreSales => _salesPagination != null && 
      _salesPagination!.page < _salesPagination!.totalPages;

  // Filter methods for UI
  List<SaleModel> getSalesByStatus(String status) {
    return _sales.where((sale) => sale.status.toLowerCase() == status.toLowerCase()).toList();
  }

  List<SaleModel> getSalesByPaymentMethod(String paymentMethod) {
    return _sales.where((sale) => sale.paymentMethod?.toLowerCase() == paymentMethod.toLowerCase()).toList();
  }

  List<SaleModel> getTodaysSales() {
    final today = DateTime.now();
    return _sales.where((sale) => 
        sale.dateTime.year == today.year &&
        sale.dateTime.month == today.month &&
        sale.dateTime.day == today.day
    ).toList();
  }
}
