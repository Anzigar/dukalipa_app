import 'package:flutter/foundation.dart';
import '../../../../data/services/returns_service.dart';

class ReturnsProvider with ChangeNotifier {
  final ReturnsService _returnsService;

  ReturnsProvider(this._returnsService);

  List<ReturnModel> _returns = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ReturnModel> get returns => _returns;
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
      // For now we'll get empty returns since the service returns SalesListResponse
      // which doesn't have a proper returns structure
      // In a real implementation, this would be properly mapped
      _returns = [];
    } catch (e) {
      _setError('Failed to load returns: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get a specific return by ID
  Future<ReturnModel?> getReturn(String returnId) async {
    try {
      final response = await _returnsService.getReturn(returnId);
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        _setError(response.message ?? 'Failed to load return');
        return null;
      }
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
    required List<ReturnItemCreateRequest> items,
    required String refundMethod,
    required String reason,
    String? processedBy,
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _returnsService.createReturn(
        originalSaleId: originalSaleId,
        customerName: customerName,
        customerPhone: customerPhone,
        items: items,
        refundMethod: refundMethod,
        reason: reason,
        processedBy: processedBy,
        notes: notes,
      );

      if (response.success && response.data != null) {
        // Add the new return to the beginning of the list
        _returns.insert(0, response.data!);
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to create return');
        return false;
      }
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
      final response = await _returnsService.updateReturn(
        returnId,
        status: status,
        processedBy: processedBy,
        notes: notes,
      );

      if (response.success && response.data != null) {
        // Update the return in the list
        final index = _returns.indexWhere((returnItem) => returnItem.id == returnId);
        if (index != -1) {
          _returns[index] = response.data!;
          notifyListeners();
        }
        return true;
      } else {
        _setError(response.message ?? 'Failed to update return');
        return false;
      }
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
      return returnItem.customerName.toLowerCase().contains(query.toLowerCase()) ||
          returnItem.originalSaleId.toLowerCase().contains(query.toLowerCase());
    }).toList();

    _returns = filteredReturns;
    notifyListeners();
  }

  /// Get returns analytics
  Future<Map<String, dynamic>?> getReturnsAnalytics() async {
    try {
      final response = await _returnsService.getReturnsAnalytics();

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        _setError(response.message ?? 'Failed to load analytics');
        return null;
      }
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
