import '../../../../data/services/appwrite_damaged_product_service.dart';
import '../models/damaged_product_model.dart';

abstract class DamagedProductRepository {
  Future<List<DamagedProductModel>> getDamagedProducts({
    String? productName,
    String? reason,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<DamagedProductModel> getDamageReport(String id);
  
  Future<DamagedProductModel> reportDamagedProduct({
    required String productId,
    required String productName,
    required int quantity,
    required double pricePerUnit,
    required String reason,
    String? notes,
    String? imageUrl,
  });
  
  Future<DamagedProductModel> updateDamageReport(
    String id, {
    int? quantity,
    double? pricePerUnit,
    String? reason,
    String? notes,
    String? imageUrl,
  });
  
  Future<void> deleteDamageReport(String id);
  
  Future<Map<String, dynamic>> getDamageAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<List<DamagedProductModel>> getRecentDamagedProducts({int limit = 10});
}

class DamagedProductRepositoryImpl implements DamagedProductRepository {
  final AppwriteDamagedProductService _damagedProductService;
  
  DamagedProductRepositoryImpl() : _damagedProductService = AppwriteDamagedProductService();
  
  @override
  Future<List<DamagedProductModel>> getDamagedProducts({
    String? productName,
    String? reason,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _damagedProductService.getDamagedProducts(
        productName: productName,
        reason: reason,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to fetch damaged products: ${e.toString()}');
    }
  }
  
  @override
  Future<DamagedProductModel> getDamageReport(String id) async {
    try {
      return await _damagedProductService.getDamageReport(id);
    } catch (e) {
      throw Exception('Failed to fetch damage report: ${e.toString()}');
    }
  }
  
  @override
  Future<DamagedProductModel> reportDamagedProduct({
    required String productId,
    required String productName,
    required int quantity,
    required double pricePerUnit,
    required String reason,
    String? notes,
    String? imageUrl,
  }) async {
    try {
      return await _damagedProductService.reportDamagedProduct(
        productId: productId,
        productName: productName,
        quantity: quantity,
        pricePerUnit: pricePerUnit,
        reason: reason,
        notes: notes,
        imageUrl: imageUrl,
      );
    } catch (e) {
      throw Exception('Failed to report damaged product: ${e.toString()}');
    }
  }
  
  @override
  Future<DamagedProductModel> updateDamageReport(
    String id, {
    int? quantity,
    double? pricePerUnit,
    String? reason,
    String? notes,
    String? imageUrl,
  }) async {
    try {
      return await _damagedProductService.updateDamageReport(
        id,
        quantity: quantity,
        pricePerUnit: pricePerUnit,
        reason: reason,
        notes: notes,
        imageUrl: imageUrl,
      );
    } catch (e) {
      throw Exception('Failed to update damage report: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteDamageReport(String id) async {
    try {
      await _damagedProductService.deleteDamageReport(id);
    } catch (e) {
      throw Exception('Failed to delete damage report: ${e.toString()}');
    }
  }
  
  @override
  Future<Map<String, dynamic>> getDamageAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _damagedProductService.getDamageAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to fetch damage analytics: ${e.toString()}');
    }
  }
  
  @override
  Future<List<DamagedProductModel>> getRecentDamagedProducts({int limit = 10}) async {
    try {
      return await _damagedProductService.getRecentDamagedProducts(limit: limit);
    } catch (e) {
      throw Exception('Failed to fetch recent damaged products: ${e.toString()}');
    }
  }
}