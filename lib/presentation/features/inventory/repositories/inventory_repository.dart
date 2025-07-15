import 'dart:io';
import '../models/product_model.dart';
import '../../../../data/services/inventory_service.dart';

abstract class InventoryRepository {
  Future<List<ProductModel>> getProducts({
    String? search,
    String? category,
    String? supplier,
    int? page,
    int? pageSize,
  });

  Future<ProductModel> getProductById(String productId);
  Future<ProductModel> createProduct(ProductModel product, {File? imageFile});
  Future<ProductModel> updateProduct(ProductModel product, {File? imageFile});
  Future<void> deleteProduct(String productId);
  Future<List<String>> getCategories();
  Future<List<String>> getSuppliers();
  Future<int> getLowStockCount();
  Future<ProductModel?> getProductByBarcode(String barcode);
  Future<ProductModel> updateProductStock(String productId, int newQuantity, {String? reason});
  Future<List<Map<String, dynamic>>> getDeviceEntries(String productId);
  Future<void> addDeviceEntries(String productId, Map<String, dynamic> entriesData);
}

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryService _inventoryService;

  InventoryRepositoryImpl() 
      : _inventoryService = InventoryService();

  @override
  Future<List<ProductModel>> getProducts({
    String? search,
    String? category,
    String? supplier,
    int? page,
    int? pageSize,
  }) async {
    try {
      return await _inventoryService.getProducts(
        search: search,
        category: category,
        supplier: supplier,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      throw Exception('Failed to get products: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> getProductById(String productId) async {
    try {
      return await _inventoryService.getProductById(productId);
    } catch (e) {
      throw Exception('Failed to get product: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> createProduct(ProductModel product, {File? imageFile}) async {
    try {
      return await _inventoryService.createProduct(product.toJson());
    } catch (e) {
      throw Exception('Failed to create product: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product, {File? imageFile}) async {
    try {
      return await _inventoryService.updateProduct(product.id, product.toJson());
    } catch (e) {
      throw Exception('Failed to update product: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await _inventoryService.deleteProduct(productId);
    } catch (e) {
      throw Exception('Failed to delete product: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      return await _inventoryService.getCategories();
    } catch (e) {
      throw Exception('Failed to get categories: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getSuppliers() async {
    try {
      return await _inventoryService.getSuppliers();
    } catch (e) {
      throw Exception('Failed to get suppliers: ${e.toString()}');
    }
  }

  @override
  Future<int> getLowStockCount() async {
    try {
      final lowStockProducts = await _inventoryService.getLowStockProducts();
      return lowStockProducts.length;
    } catch (e) {
      throw Exception('Failed to get low stock count: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    try {
      return await _inventoryService.getProductByBarcode(barcode);
    } catch (e) {
      // Return null if product not found or API fails
      return null;
    }
  }

  @override
  Future<ProductModel> updateProductStock(String productId, int newQuantity, {String? reason}) async {
    try {
      final stockData = {
        'quantity': newQuantity,
        'adjustment_type': reason ?? 'manual_update',
        'notes': reason ?? 'Stock updated via app',
      };
      return await _inventoryService.updateProductStock(productId, stockData);
    } catch (e) {
      throw Exception('Failed to update product stock: ${e.toString()}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDeviceEntries(String productId) async {
    try {
      return await _inventoryService.getDeviceEntries(productId);
    } catch (e) {
      throw Exception('Failed to get device entries: ${e.toString()}');
    }
  }

  @override
  Future<void> addDeviceEntries(String productId, Map<String, dynamic> entriesData) async {
    try {
      await _inventoryService.addDeviceEntries(productId, entriesData);
    } catch (e) {
      throw Exception('Failed to add device entries: ${e.toString()}');
    }
  }
}
