import 'package:flutter/foundation.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../data/services/appwrite_sales_service.dart';
import '../models/sale_model.dart';

class SalesProvider extends ChangeNotifier {
  final AppwriteSalesService _salesService = locator<AppwriteSalesService>();

  // State management
  List<SaleModel> _sales = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _salesAnalytics;

  // Getters
  List<SaleModel> get sales => _sales;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get salesAnalytics => _salesAnalytics;

  // Sales operations
  Future<bool> createSale({
    required String customerName,
    String? customerPhone,
    required List<Map<String, dynamic>> items,
    double discount = 0.0,
    required String paymentMethod,
    String? note,
    String? createdBy,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final saleData = {
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'items': items,
        'discount': discount,
        'payment_method': paymentMethod,
        'note': note,
        'created_by': createdBy,
        'status': 'completed',
        'total_amount': items.fold<double>(0.0, (sum, item) {
          final quantity = item['quantity'] as num? ?? 0;
          final price = item['price'] as num? ?? 0;
          return sum + (quantity * price);
        }) - discount,
      };

      await _salesService.createSale(saleData);
      await loadSales(); // Refresh sales list
      return true;
    } catch (e) {
      _setError('An unexpected error occurred: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadSales({
    bool refresh = false,
    String? search,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final sales = await _salesService.getSales(
        search: search,
        status: status,
        startDate: startDate,
        endDate: endDate,
      );

      _sales = sales;
      notifyListeners();
    } catch (e) {
      _setError('An unexpected error occurred: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<SaleModel?> getSaleDetails(String saleId) async {
    try {
      final sale = await _salesService.getSaleById(saleId);
      return sale;
    } catch (e) {
      _setError('An unexpected error occurred: $e');
      return null;
    }
  }

  Future<bool> updateSale(
    String saleId, {
    String? customerName,
    String? customerPhone,
    List<Map<String, dynamic>>? items,
    double? discount,
    String? status,
    String? paymentMethod,
    String? note,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final updateData = <String, dynamic>{};
      if (customerName != null) updateData['customer_name'] = customerName;
      if (customerPhone != null) updateData['customer_phone'] = customerPhone;
      if (items != null) updateData['items'] = items;
      if (discount != null) updateData['discount'] = discount;
      if (status != null) updateData['status'] = status;
      if (paymentMethod != null) updateData['payment_method'] = paymentMethod;
      if (note != null) updateData['note'] = note;

      await _salesService.updateSale(saleId, updateData);
      await loadSales(); // Refresh sales list
      return true;
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

      await _salesService.deleteSale(saleId);
      await loadSales(); // Refresh sales list
      return true;
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
      final analytics = await _salesService.getSalesStatistics(
        startDate: startDate,
        endDate: endDate,
      );

      _salesAnalytics = analytics;
      notifyListeners();
    } catch (e) {
      _setError('An unexpected error occurred: $e');
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
    _salesAnalytics = null;
    _clearError();
    notifyListeners();
  }

  // Convenience getters for UI
  bool get hasSales => _sales.isNotEmpty;
  bool get hasError => _errorMessage != null;

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
