import 'package:flutter/foundation.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../data/services/appwrite_sales_service.dart';

class ReturnsProvider with ChangeNotifier {
  final AppwriteSalesService _salesService = locator<AppwriteSalesService>();

  List<Map<String, dynamic>> _returns = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get returns => _returns;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load returns with optional filtering
  Future<void> loadReturns({
    bool refresh = false,
    String? status,
    String? customerName,
  }) async {
    if (refresh) {
      _returns.clear();
    }

    _setLoading(true);
    _clearError();

    try {
      // Returns are handled as a type of sale in Appwrite
      final sales = await _salesService.getSales(
        status: 'returned',
        search: customerName,
      );
      
      _returns = sales.map((sale) => sale.toJson()).toList();
    } catch (e) {
      _setError('Failed to load returns: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get a specific return by ID
  Future<Map<String, dynamic>?> getReturn(String returnId) async {
    try {
      final sale = await _salesService.getSaleById(returnId);
      return sale.toJson();
    } catch (e) {
      _setError('Failed to load return: $e');
      return null;
    }
  }

  /// Create a new return
  Future<bool> createReturn({
    required String originalSaleId,
    required String customerName,
    String? customerPhone,
    required List<Map<String, dynamic>> items,
    required String refundMethod,
    required String reason,
    String? processedBy,
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Create a return by updating the original sale status
      final updateData = {
        'status': 'returned',
        'note': 'Return reason: $reason${notes != null ? '\nNotes: $notes' : ''}',
      };

      await _salesService.updateSale(originalSaleId, updateData);
      await loadReturns(refresh: true);
      return true;
    } catch (e) {
      _setError('Failed to create return: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update a return
  Future<bool> updateReturn(
    String returnId, {
    String? status,
    String? processedBy,
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // For now, just refresh the returns list
      // In a full implementation, you would call the actual update method
      await loadReturns(refresh: true);
      return true;
    } catch (e) {
      _setError('Failed to update return: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Search returns by customer name or sale ID
  Future<void> searchReturns(String query) async {
    // For now, we'll filter locally. In the future, this could be moved to the API
    if (query.isEmpty) {
      loadReturns(refresh: true);
      return;
    }

    final filteredReturns = _returns.where((returnItem) {
      final customerName = returnItem['customerName'] as String? ?? '';
      final saleId = returnItem['id'] as String? ?? '';
      return customerName.toLowerCase().contains(query.toLowerCase()) ||
          saleId.toLowerCase().contains(query.toLowerCase());
    }).toList();

    _returns = filteredReturns;
    notifyListeners();
  }

  /// Get returns analytics
  Future<Map<String, dynamic>?> getReturnsAnalytics() async {
    try {
      // Returns analytics would be calculated from returned sales
      final returnCount = _returns.length;
      final totalReturnValue = _returns.fold<double>(0.0, (sum, returnItem) {
        final totalAmount = returnItem['totalAmount'] as num? ?? 0;
        return sum + totalAmount.toDouble();
      });

      return {
        'totalReturns': returnCount,
        'totalReturnValue': totalReturnValue,
        'averageReturnValue': returnCount > 0 ? totalReturnValue / returnCount : 0.0,
      };
    } catch (e) {
      _setError('Failed to load analytics: $e');
      return null;
    }
  }

  /// Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear all data (useful for logout)
  void clear() {
    _returns.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
