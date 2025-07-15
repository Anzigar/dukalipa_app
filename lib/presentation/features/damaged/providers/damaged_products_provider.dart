import 'package:flutter/foundation.dart';
import '../../../../data/services/damaged_products_service.dart';

class DamagedProductsProvider with ChangeNotifier {
  final DamagedProductsService _damagedProductsService;

  DamagedProductsProvider(this._damagedProductsService);

  List<DamagedProductModel> _damagedProducts = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<DamagedProductModel> get damagedProducts => _damagedProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load damaged products
  Future<void> loadDamagedProducts({
    bool refresh = false,
    String? status,
    String? damageType,
    String? severity,
  }) async {
    if (refresh) {
      _damagedProducts.clear();
    }

    _setLoading(true);
    _clearError();

    try {
      // For now, we'll get individual damage reports
      // In a real implementation, the service would return a list directly
      // Since the current service structure is unclear, we'll keep the list empty
      // and populate it when individual reports are fetched
      
      if (refresh) {
        _damagedProducts = [];
      }
    } catch (e) {
      _setError('Failed to load damaged products: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get a specific damage report by ID
  Future<DamagedProductModel?> getDamageReport(String damageId) async {
    try {
      final response = await _damagedProductsService.getDamageReport(damageId);
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        _setError(response.message ?? 'Failed to load damage report');
        return null;
      }
    } catch (e) {
      _setError('Failed to load damage report: $e');
      return null;
    }
  }

  /// Report a new damaged product
  Future<bool> reportDamagedProduct({
    required String productId,
    required String productName,
    required int quantity,
    required double originalPrice,
    required double estimatedLoss,
    required String damageType,
    required String severity,
    required String description,
    String? location,
    required String discoveredBy,
    List<String>? images,
    InsuranceClaimInfo? insuranceClaim,
    String? actionTaken,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _damagedProductsService.reportDamagedProduct(
        productId: productId,
        productName: productName,
        quantity: quantity,
        originalPrice: originalPrice,
        estimatedLoss: estimatedLoss,
        damageType: damageType,
        severity: severity,
        description: description,
        location: location,
        discoveredBy: discoveredBy,
        images: images,
        insuranceClaim: insuranceClaim,
        actionTaken: actionTaken,
      );

      if (response.success && response.data != null) {
        // Add the new damaged product to the beginning of the list
        _damagedProducts.insert(0, response.data!);
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to report damaged product');
        return false;
      }
    } catch (e) {
      _setError('Failed to report damaged product: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update a damage report
  Future<bool> updateDamageReport(
    String damageId, {
    int? quantity,
    double? estimatedLoss,
    String? damageType,
    String? severity,
    String? description,
    String? location,
    List<String>? images,
    String? status,
    InsuranceClaimInfo? insuranceClaim,
    String? actionTaken,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _damagedProductsService.updateDamageReport(
        damageId,
        quantity: quantity,
        estimatedLoss: estimatedLoss,
        damageType: damageType,
        severity: severity,
        description: description,
        location: location,
        images: images,
        status: status,
        insuranceClaim: insuranceClaim,
        actionTaken: actionTaken,
      );

      if (response.success && response.data != null) {
        // Update the product in the list
        final index = _damagedProducts.indexWhere((product) => product.id == damageId);
        if (index != -1) {
          _damagedProducts[index] = response.data!;
          notifyListeners();
        }
        return true;
      } else {
        _setError(response.message ?? 'Failed to update damage report');
        return false;
      }
    } catch (e) {
      _setError('Failed to update damage report: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Search damaged products by name/description
  Future<void> searchDamagedProducts(String query) async {
    // For now, we'll filter locally. In the future, this could be moved to the API
    if (query.isEmpty) {
      loadDamagedProducts(refresh: true);
      return;
    }

    final filteredProducts = _damagedProducts.where((product) {
      return product.productName.toLowerCase().contains(query.toLowerCase()) ||
          product.description.toLowerCase().contains(query.toLowerCase());
    }).toList();

    _damagedProducts = filteredProducts;
    notifyListeners();
  }

  /// Get damaged products analytics
  Future<Map<String, dynamic>?> getDamageAnalytics() async {
    try {
      final response = await _damagedProductsService.getDamageAnalytics();

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
    _damagedProducts.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
