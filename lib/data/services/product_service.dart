import 'dart:io';
import 'package:dio/dio.dart';
import '../models/api_models.dart';
import '../../presentation/features/inventory/models/product_model.dart';

/// Service for handling all product-related API operations
class ProductService {
  late final Dio _dio;

  ProductService() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }

  /// Get all products with optional filtering and pagination
  Future<List<ProductModel>> getProducts({
    String? search,
    String? category,
    String? supplier,
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      final response = await _dio.get(
        '/products/',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (category != null && category.isNotEmpty) 'category': category,
          if (supplier != null && supplier.isNotEmpty) 'supplier': supplier,
        },
      );

      // Handle response as a list directly
      List<dynamic> productList = [];
      
      if (response.data is List) {
        productList = response.data as List;
      } else if (response.data is Map<String, dynamic>) {
        if (response.data['results'] is List) {
          productList = response.data['results'] as List;
        } else if (response.data['data'] is List) {
          productList = response.data['data'] as List;
        }
      }

      final products = <ProductModel>[];
      for (final item in productList) {
        if (item is Map<String, dynamic>) {
          products.add(ProductModel.fromJson(item));
        }
      }
      return products;
    } on DioException catch (e) {
      throw Exception('Failed to fetch products: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Failed to fetch products: ${e.toString()}');
    }
  }

  /// Get a single product by ID
  Future<ProductModel> getProductById(String productId) async {
    try {
      final response = await _dio.get('/products/$productId/');
      
      if (response.data is Map<String, dynamic>) {
        return ProductModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Product not found');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch product: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Failed to fetch product: ${e.toString()}');
    }
  }

  /// Create a new product
  Future<ProductModel> createProduct(
    ProductRequest productRequest, {
    File? imageFile,
  }) async {
    try {
      // For now, create product without image upload functionality
      // TODO: Implement proper file upload with Dio when needed
      final response = await _dio.post(
        '/products/',
        data: productRequest.toJson(),
      );

      if (response.data is Map<String, dynamic>) {
        return ProductModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      throw Exception('Failed to create product: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Failed to create product: ${e.toString()}');
    }
  }

  /// Update an existing product
  Future<ProductModel> updateProduct(
    String productId,
    ProductRequest productRequest, {
    File? imageFile,
  }) async {
    try {
      // For now, update product without image upload functionality
      // TODO: Implement proper file upload with Dio when needed
      final response = await _dio.patch(
        '/products/$productId/',
        data: productRequest.toJson(),
      );

      if (response.data is Map<String, dynamic>) {
        return ProductModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      throw Exception('Failed to update product: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Failed to update product: ${e.toString()}');
    }
  }

  /// Delete a product
  Future<void> deleteProduct(String productId) async {
    try {
      await _dio.delete('/products/$productId/');
    } on DioException catch (e) {
      throw Exception('Failed to delete product: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Failed to delete product: ${e.toString()}');
    }
  }

  /// Get all product categories (hardcoded as per requirements)
  Future<List<String>> getCategories() async {
    try {
      // Return predefined categories as specified in requirements
      return ['Electronics', 'Accessories', 'Phones'];
    } catch (e) {
      throw Exception('Failed to fetch categories: ${e.toString()}');
    }
  }

  /// Get all suppliers
  Future<List<String>> getSuppliers() async {
    try {
      // For now, return a basic list of suppliers
      // This can be enhanced to fetch from an actual suppliers endpoint if available
      return [
        'Local Supplier',
        'International Distributor',
        'Wholesale Market',
        'Direct Factory',
        'Online Store'
      ];
    } catch (e) {
      throw Exception('Failed to fetch suppliers: ${e.toString()}');
    }
  }

  /// Get products with low stock
  Future<List<ProductModel>> getLowStockProducts() async {
    try {
      final response = await _dio.get('/analytics/products/low-stock/');
      
      if (response.data is List) {
        final products = <ProductModel>[];
        for (final item in response.data as List) {
          if (item is Map<String, dynamic>) {
            products.add(ProductModel.fromJson(item));
          }
        }
        return products;
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to fetch low stock products: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Failed to fetch low stock products: ${e.toString()}');
    }
  }

  /// Search products by barcode
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    try {
      // Since there's no specific barcode endpoint, search through all products
      final products = await getProducts(search: barcode);
      for (final product in products) {
        if (product.barcode == barcode) {
          return product;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update product stock quantity
  Future<ProductModel> updateProductStock(String productId, int quantity) async {
    try {
      final response = await _dio.patch(
        '/products/$productId/stock/',
        data: {'quantity': quantity},
      );

      if (response.data is Map<String, dynamic>) {
        return ProductModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      throw Exception('Failed to update product stock: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Failed to update product stock: ${e.toString()}');
    }
  }
}

