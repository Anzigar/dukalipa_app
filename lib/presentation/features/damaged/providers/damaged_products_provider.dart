import 'package:flutter/foundation.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../data/services/appwrite_damaged_product_service.dart';

class DamagedProductsProvider with ChangeNotifier {
  final AppwriteDamagedProductService _damagedProductsService = locator<AppwriteDamagedProductService>();

  List<Map<String, dynamic>> _damagedProducts = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get damagedProducts => _damagedProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load damaged products
  Future<void> loadDamagedProducts({
    bool refresh = false,
    String? productName,
    String? reason,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (refresh) {
      _damagedProducts.clear();
    }

    _setLoading(true);
    _clearError();

    try {
      final products = await _damagedProductsService.getDamagedProducts(
        productName: productName,
        reason: reason,
        startDate: startDate,
        endDate: endDate,
      );
      
      _damagedProducts = products.map((item) => item.toJson()).toList();
    } catch (e) {
      _setError('Failed to load damaged products: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get a specific damage report by ID
  Future<Map<String, dynamic>?> getDamageReport(String damageId) async {
    try {
      final product = await _damagedProductsService.getDamageReport(damageId);
      return product.toJson();
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
    required double pricePerUnit,
    required String reason,
    String? notes,
    String? imageUrl,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _damagedProductsService.reportDamagedProduct(
        productId: productId,
        productName: productName,
        quantity: quantity,
        pricePerUnit: pricePerUnit,
        reason: reason,
        notes: notes,
        imageUrl: imageUrl,
      );

      await loadDamagedProducts(refresh: true);
      return true;
    } catch (e) {
      _setError('Failed to report damaged product: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a damage report
  Future<bool> deleteDamageReport(String damageId) async {
    _setLoading(true);
    _clearError();

    try {
      await _damagedProductsService.deleteDamageReport(damageId);
      await loadDamagedProducts(refresh: true);
      return true;
    } catch (e) {
      _setError('Failed to delete damage report: $e');
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
      final productName = product['productName'] as String? ?? '';
      final description = product['description'] as String? ?? '';
      return productName.toLowerCase().contains(query.toLowerCase()) ||
          description.toLowerCase().contains(query.toLowerCase());
    }).toList();

    _damagedProducts = filteredProducts;
    notifyListeners();
  }

  /// Get damaged products analytics
  Future<Map<String, dynamic>?> getDamageAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final analytics = await _damagedProductsService.getDamageAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
      return analytics;
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
