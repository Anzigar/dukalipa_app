import 'dart:io';
import '../models/product_model.dart';
import '../../../../data/services/appwrite_inventory_service.dart';

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
  final AppwriteInventoryService _appwriteService;

  InventoryRepositoryImpl() 
      : _appwriteService = AppwriteInventoryService();

  @override
  Future<List<ProductModel>> getProducts({
    String? search,
    String? category,
    String? supplier,
    int? page,
    int? pageSize,
  }) async {
    try {
      return await _appwriteService.getProducts(
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
      return await _appwriteService.getProductById(productId);
    } catch (e) {
      throw Exception('Failed to get product: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> createProduct(ProductModel product, {File? imageFile}) async {
    try {
      final productData = {
        'name': product.name,
        'description': product.description,
        'barcode': product.barcode,
        'selling_price': product.sellingPrice,
        'cost_price': product.costPrice,
        'stock_quantity': product.quantity,
        'low_stock_threshold': product.lowStockThreshold,
        'reorder_level': product.reorderLevel,
        'category': product.category,
        'supplier': product.supplier,
        'product_metadata': product.metadata,
        'device_entries': product.deviceEntries?.map((e) => e.toJson()).toList(),
      };
      
      return await _appwriteService.createProduct(productData, imageFile: imageFile);
    } catch (e) {
      throw Exception('Failed to create product: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product, {File? imageFile}) async {
    try {
      final productData = {
        'name': product.name,
        'description': product.description,
        'barcode': product.barcode,
        'selling_price': product.sellingPrice,
        'cost_price': product.costPrice,
        'stock_quantity': product.quantity,
        'low_stock_threshold': product.lowStockThreshold,
        'reorder_level': product.reorderLevel,
        'category': product.category,
        'supplier': product.supplier,
        'product_metadata': product.metadata,
        'device_entries': product.deviceEntries?.map((e) => e.toJson()).toList(),
      };
      
      return await _appwriteService.updateProduct(product.id, productData, imageFile: imageFile);
    } catch (e) {
      throw Exception('Failed to update product: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await _appwriteService.deleteProduct(productId);
    } catch (e) {
      throw Exception('Failed to delete product: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      return await _appwriteService.getCategories();
    } catch (e) {
      throw Exception('Failed to get categories: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getSuppliers() async {
    try {
      return await _appwriteService.getSuppliers();
    } catch (e) {
      throw Exception('Failed to get suppliers: ${e.toString()}');
    }
  }

  @override
  Future<int> getLowStockCount() async {
    try {
      final lowStockProducts = await _appwriteService.getLowStockProducts();
      return lowStockProducts.length;
    } catch (e) {
      throw Exception('Failed to get low stock count: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    try {
      return await _appwriteService.getProductByBarcode(barcode);
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
      };
      return await _appwriteService.updateProductStock(productId, stockData);
    } catch (e) {
      throw Exception('Failed to update product stock: ${e.toString()}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDeviceEntries(String productId) async {
    try {
      return await _appwriteService.getDeviceEntries(productId);
    } catch (e) {
      throw Exception('Failed to get device entries: ${e.toString()}');
    }
  }

  @override
  Future<void> addDeviceEntries(String productId, Map<String, dynamic> entriesData) async {
    try {
      await _appwriteService.addDeviceEntries(productId, entriesData);
    } catch (e) {
      throw Exception('Failed to add device entries: ${e.toString()}');
    }
  }
}
