import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../presentation/features/inventory/models/product_model.dart';

class InventoryService {
  late final Dio _dio;
  final String _baseUrl = 'http://127.0.0.1:8000/api/v1';

  InventoryService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for logging and error handling
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('[DIO] $obj'),
      ));
    }
  }

  /// Get all products with optional filters
  Future<List<ProductModel>> getProducts({
    String? search,
    String? category,
    String? supplier,
    int? page,
    int? pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (supplier != null && supplier.isNotEmpty) {
        queryParams['supplier'] = supplier;
      }
      if (page != null) {
        queryParams['page'] = page;
      }
      if (pageSize != null) {
        queryParams['page_size'] = pageSize;
      }

      final response = await _dio.get('/products', queryParameters: queryParams);
      
      // Handle the backend response structure: {status, message, data: {products: [], pagination: {}}}
      List<dynamic> products = [];
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
          final data = responseData['data'] as Map<String, dynamic>;
          products = data['products'] ?? [];
        } else if (responseData.containsKey('results')) {
          // Fallback for different response structures
          products = responseData['results'] ?? [];
        } else if (responseData.containsKey('data') && responseData['data'] is List) {
          products = responseData['data'] ?? [];
        }
      } else if (response.data is List) {
        products = response.data;
      }
      
      debugPrint('Products API Response: ${products.length} products found');
      return products.map((item) => ProductModel.fromJson(item)).toList();
    } on DioException catch (e) {
      debugPrint('Error fetching products: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error fetching products: $e');
      rethrow;
    }
  }

  /// Get a specific product by ID
  Future<ProductModel> getProductById(String productId) async {
    try {
      // Since the backend doesn't support filtering by ID directly,
      // we'll get all products and filter on the client side
      final response = await _dio.get('/products');
      
      // Handle the backend response structure: {status, message, data: {products: [], pagination: {}}}
      List<dynamic> products = [];
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
          final data = responseData['data'] as Map<String, dynamic>;
          products = data['products'] ?? [];
        }
      }
      
      // Filter by ID on the client side
      final matchingProducts = products.where((product) => product['id'] == productId).toList();
      
      if (matchingProducts.isEmpty) {
        throw Exception('Product not found');
      }
      
      return ProductModel.fromJson(matchingProducts.first);
    } on DioException catch (e) {
      debugPrint('Error fetching product $productId: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error fetching product $productId: $e');
      rethrow;
    }
  }

  /// Get a specific product by barcode
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    try {
      final response = await _dio.get('/products', queryParameters: {
        'barcode': barcode,
      });
      
      // Handle the backend response structure: {status, message, data: {products: [], pagination: {}}}
      List<dynamic> products = [];
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
          final data = responseData['data'] as Map<String, dynamic>;
          products = data['products'] ?? [];
        }
      }
      
      if (products.isNotEmpty) {
        return ProductModel.fromJson(products.first);
      } else {
        return null;
      }
    } on DioException catch (e) {
      debugPrint('Error fetching product by barcode $barcode: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error fetching product by barcode $barcode: $e');
      rethrow;
    }
  }

  /// Create a new product
  Future<ProductModel> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _dio.post('/products', data: productData);
      return ProductModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Error creating product: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error creating product: $e');
      rethrow;
    }
  }

  /// Update an existing product
  Future<ProductModel> updateProduct(String productId, Map<String, dynamic> productData) async {
    try {
      final response = await _dio.put('/products/$productId', data: productData);
      return ProductModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Error updating product $productId: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error updating product $productId: $e');
      rethrow;
    }
  }

  /// Delete a product
  Future<void> deleteProduct(String productId) async {
    try {
      await _dio.delete('/products/$productId');
    } on DioException catch (e) {
      debugPrint('Error deleting product $productId: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error deleting product $productId: $e');
      rethrow;
    }
  }

  /// Get product categories
  Future<List<String>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      
      // Handle the backend response structure: {status, message, data: {categories: []}}
      List<dynamic> categories = [];
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
          final data = responseData['data'] as Map<String, dynamic>;
          categories = data['categories'] ?? [];
        } else if (responseData.containsKey('data') && responseData['data'] is List) {
          categories = responseData['data'] ?? [];
        }
      } else if (response.data is List) {
        categories = response.data;
      }
      
      debugPrint('Categories API Response: ${categories.length} categories found');
      return categories.map((item) => item.toString()).toList();
    } on DioException catch (e) {
      debugPrint('Error fetching categories: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      rethrow;
    }
  }

  /// Get product suppliers
  Future<List<String>> getSuppliers() async {
    try {
      final response = await _dio.get('/suppliers');
      
      // Handle the backend response structure: {status, message, data: {suppliers: []}}
      List<dynamic> suppliers = [];
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
          final data = responseData['data'] as Map<String, dynamic>;
          suppliers = data['suppliers'] ?? [];
        } else if (responseData.containsKey('data') && responseData['data'] is List) {
          suppliers = responseData['data'] ?? [];
        }
      } else if (response.data is List) {
        suppliers = response.data;
      }
      
      debugPrint('Suppliers API Response: ${suppliers.length} suppliers found');
      return suppliers.map((item) => item.toString()).toList();
    } on DioException catch (e) {
      debugPrint('Error fetching suppliers: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error fetching suppliers: $e');
      rethrow;
    }
  }

  /// Get inventory summary/analytics
  Future<Map<String, dynamic>> getInventorySummary() async {
    try {
      final response = await _dio.get('/inventory/summary');
      return response.data is Map<String, dynamic> ? response.data : {'data': response.data};
    } catch (e) {
      debugPrint('Error fetching inventory summary: $e');
      rethrow;
    }
  }

  /// Get low stock products
  Future<List<ProductModel>> getLowStockProducts() async {
    try {
      final response = await _dio.get('/products', queryParameters: {
        'low_stock': true,
      });
      
      final List<dynamic> data = response.data is Map<String, dynamic> 
          ? (response.data['results'] ?? response.data['data'] ?? [])
          : response.data ?? [];
      
      return data.map((item) => ProductModel.fromJson(item)).toList();
    } on DioException catch (e) {
      debugPrint('Error fetching low stock products: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error fetching low stock products: $e');
      rethrow;
    }
  }

  /// Get out of stock products
  Future<List<ProductModel>> getOutOfStockProducts() async {
    try {
      final response = await _dio.get('/products', queryParameters: {
        'out_of_stock': true,
      });
      
      final List<dynamic> data = response.data is Map<String, dynamic> 
          ? (response.data['results'] ?? response.data['data'] ?? [])
          : response.data ?? [];
      
      return data.map((item) => ProductModel.fromJson(item)).toList();
    } on DioException catch (e) {
      debugPrint('Error fetching out of stock products: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error fetching out of stock products: $e');
      rethrow;
    }
  }

  /// Update product stock quantity
  Future<ProductModel> updateProductStock(String productId, int newQuantity) async {
    try {
      final response = await _dio.patch('/products/$productId/stock', data: {
        'quantity': newQuantity,
      });
      return ProductModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Error updating product stock for $productId: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error updating product stock for $productId: $e');
      rethrow;
    }
  }

  /// Bulk update product quantities
  Future<List<ProductModel>> bulkUpdateStock(List<Map<String, dynamic>> updates) async {
    try {
      final response = await _dio.post('/products/bulk-update-stock', data: {
        'updates': updates,
      });
      
      final List<dynamic> data = response.data is List ? response.data : (response.data['data'] ?? []);
      return data.map((item) => ProductModel.fromJson(item)).toList();
    } on DioException catch (e) {
      debugPrint('Error bulk updating stock: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error bulk updating stock: $e');
      rethrow;
    }
  }
}
