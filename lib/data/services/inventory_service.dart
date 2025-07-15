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

    // Add error handling interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        debugPrint('API Error: ${error.message}');
        handler.next(error);
      },
    ));
  }

  /// Get all products with optional filters
  Future<List<ProductModel>> getProducts({
    String? search,
    String? category,
    String? supplier,
    int? page,
    int? pageSize,
    bool? lowStock,
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
        queryParams['limit'] = pageSize; // Use 'limit' instead of 'page_size'
      }
      if (lowStock != null && lowStock) {
        queryParams['low_stock'] = true;
      }

      final response = await _dio.get('/products/', queryParameters: queryParams);
      
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
      final response = await _dio.get('/products/$productId/');
      
      // Handle the backend response structure
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('data')) {
          return ProductModel.fromJson(responseData['data']);
        }
        return ProductModel.fromJson(responseData);
      }
      
      throw Exception('Invalid response format');
    } on DioException catch (e) {
      debugPrint('Error fetching product $productId: $e');
      if (e.response?.statusCode == 404) {
        throw Exception('Product not found');
      }
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error fetching product $productId: $e');
      rethrow;
    }
  }

  /// Get a specific product by barcode
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    try {
      final response = await _dio.get('/products/barcode/$barcode/');
      
      // Handle the backend response structure
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('data')) {
          return ProductModel.fromJson(responseData['data']);
        }
        return ProductModel.fromJson(responseData);
      }
      
      return null;
    } on DioException catch (e) {
      debugPrint('Error fetching product by barcode $barcode: $e');
      if (e.response?.statusCode == 404) {
        return null; // Product not found
      }
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error fetching product by barcode $barcode: $e');
      return null;
    }
  }

  /// Create a new product
  Future<ProductModel> createProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _dio.post('/products/', data: productData);
      
      // Handle the backend response structure
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('data')) {
          return ProductModel.fromJson(responseData['data']);
        }
        return ProductModel.fromJson(responseData);
      }
      
      throw Exception('Invalid response format');
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
      final response = await _dio.put('/products/$productId/', data: productData);
      
      // Handle the backend response structure
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('data')) {
          return ProductModel.fromJson(responseData['data']);
        }
        return ProductModel.fromJson(responseData);
      }
      
      throw Exception('Invalid response format');
    } on DioException catch (e) {
      debugPrint('Error updating product $productId: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error updating product $productId: $e');
      rethrow;
    }
  }

  /// Update product stock
  Future<ProductModel> updateProductStock(String productId, Map<String, dynamic> stockData) async {
    try {
      final response = await _dio.patch('/products/$productId/stock/', data: stockData);
      
      // Handle the backend response structure
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('data')) {
          return ProductModel.fromJson(responseData['data']);
        }
        return ProductModel.fromJson(responseData);
      }
      
      throw Exception('Invalid response format');
    } on DioException catch (e) {
      debugPrint('Error updating product stock $productId: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error updating product stock $productId: $e');
      rethrow;
    }
  }

  /// Delete a product
  Future<void> deleteProduct(String productId) async {
    try {
      await _dio.delete('/products/$productId/');
    } on DioException catch (e) {
      debugPrint('Error deleting product $productId: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error deleting product $productId: $e');
      rethrow;
    }
  }

  /// Get device entries for a product
  Future<List<Map<String, dynamic>>> getDeviceEntries(String productId) async {
    try {
      final response = await _dio.get('/products/$productId/device-entries/');
      
      // Handle the backend response structure
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('data') && responseData['data'] is List) {
          return List<Map<String, dynamic>>.from(responseData['data']);
        }
      } else if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      
      return [];
    } on DioException catch (e) {
      debugPrint('Error fetching device entries for product $productId: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error fetching device entries for product $productId: $e');
      rethrow;
    }
  }

  /// Add device entries for a product
  Future<void> addDeviceEntries(String productId, Map<String, dynamic> entriesData) async {
    try {
      await _dio.post('/products/$productId/device-entries/', data: entriesData);
    } on DioException catch (e) {
      debugPrint('Error adding device entries for product $productId: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error adding device entries for product $productId: $e');
      rethrow;
    }
  }

  /// Get all categories
  Future<List<String>> getCategories() async {
    try {
      final response = await _dio.get('/categories/');
      
      // Handle the backend response structure
      List<String> categories = [];
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('data') && responseData['data'] is List) {
          categories = List<String>.from(responseData['data']);
        }
      } else if (response.data is List) {
        categories = List<String>.from(response.data);
      }
      
      return categories;
    } on DioException catch (e) {
      debugPrint('Error fetching categories: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      rethrow;
    }
  }

  /// Get all suppliers
  Future<List<String>> getSuppliers() async {
    try {
      final response = await _dio.get('/business/suppliers/');
      
      // Handle the backend response structure
      List<String> suppliers = [];
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final supplierList = responseData['data'] as List;
          suppliers = supplierList.map((supplier) => supplier['name']?.toString() ?? '').where((name) => name.isNotEmpty).toList();
        }
      } else if (response.data is List) {
        final supplierList = response.data as List;
        suppliers = supplierList.map((supplier) => supplier['name']?.toString() ?? '').where((name) => name.isNotEmpty).toList();
      }
      
      return suppliers;
    } on DioException catch (e) {
      debugPrint('Error fetching suppliers: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error fetching suppliers: $e');
      rethrow;
    }
  }

  /// Get low stock products
  Future<List<ProductModel>> getLowStockProducts() async {
    try {
      final response = await _dio.get('/analytics/products/low-stock/');
      
      // Handle the backend response structure
      List<dynamic> products = [];
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('data') && responseData['data'] is List) {
          products = responseData['data'];
        }
      } else if (response.data is List) {
        products = response.data;
      }
      
      return products.map((item) => ProductModel.fromJson(item)).toList();
    } on DioException catch (e) {
      debugPrint('Error fetching low stock products: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error fetching low stock products: $e');
      rethrow;
    }
  }

  /// Bulk create products
  Future<List<ProductModel>> bulkCreateProducts(Map<String, dynamic> bulkData) async {
    try {
      final response = await _dio.post('/products/bulk-create/', data: bulkData);
      
      // Handle the backend response structure
      List<dynamic> products = [];
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('data') && responseData['data'] is List) {
          products = responseData['data'];
        }
      } else if (response.data is List) {
        products = response.data;
      }
      
      return products.map((item) => ProductModel.fromJson(item)).toList();
    } on DioException catch (e) {
      debugPrint('Error bulk creating products: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error bulk creating products: $e');
      rethrow;
    }
  }

  /// Update a specific device entry
  Future<void> updateDeviceEntry(String entryId, Map<String, dynamic> entryData) async {
    try {
      await _dio.put('/products/device-entries/$entryId/', data: entryData);
    } on DioException catch (e) {
      debugPrint('Error updating device entry $entryId: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error updating device entry $entryId: $e');
      rethrow;
    }
  }

  /// Delete a specific device entry
  Future<void> deleteDeviceEntry(String entryId) async {
    try {
      await _dio.delete('/products/device-entries/$entryId/');
    } on DioException catch (e) {
      debugPrint('Error deleting device entry $entryId: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error deleting device entry $entryId: $e');
      rethrow;
    }
  }

  /// Bulk add serial numbers for a product
  Future<void> bulkAddSerialNumbers(String productId, Map<String, dynamic> serialData) async {
    try {
      await _dio.post('/products/$productId/bulk-serial-numbers/', data: serialData);
    } on DioException catch (e) {
      debugPrint('Error bulk adding serial numbers for product $productId: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error bulk adding serial numbers for product $productId: $e');
      rethrow;
    }
  }

  /// Get all serial numbers
  Future<List<Map<String, dynamic>>> getSerialNumbers({
    String? productId,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (productId != null) queryParams['product_id'] = productId;
      if (status != null) queryParams['status'] = status;

      final response = await _dio.get('/products/serial-numbers/', queryParameters: queryParams);
      
      // Handle the backend response structure
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('data') && responseData['data'] is List) {
          return List<Map<String, dynamic>>.from(responseData['data']);
        }
      } else if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      
      return [];
    } on DioException catch (e) {
      debugPrint('Error fetching serial numbers: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error fetching serial numbers: $e');
      rethrow;
    }
  }

  /// Get category requirements for a specific category
  Future<Map<String, dynamic>> getCategoryRequirements(String category) async {
    try {
      final response = await _dio.get('/products/categories/$category/requirements/');
      
      // Handle the backend response structure
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('data')) {
          return responseData['data'] as Map<String, dynamic>;
        }
        return responseData;
      }
      
      return {};
    } on DioException catch (e) {
      debugPrint('Error fetching category requirements for $category: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error fetching category requirements for $category: $e');
      rethrow;
    }
  }

  /// Get total products count
  Future<int> getTotalProductsCount() async {
    try {
      final response = await _dio.get('/analytics/products/total/');
      
      // Handle the backend response structure
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('data')) {
          return responseData['data']['total'] ?? 0;
        }
        return responseData['total'] ?? 0;
      }
      
      return 0;
    } on DioException catch (e) {
      debugPrint('Error fetching total products count: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error fetching total products count: $e');
      rethrow;
    }
  }

  /// Get total stock value
  Future<double> getTotalStockValue() async {
    try {
      final response = await _dio.get('/analytics/products/stock-value/');
      
      // Handle the backend response structure
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('data')) {
          return (responseData['data']['total_value'] ?? 0.0).toDouble();
        }
        return (responseData['total_value'] ?? 0.0).toDouble();
      }
      
      return 0.0;
    } on DioException catch (e) {
      debugPrint('Error fetching total stock value: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error fetching total stock value: $e');
      rethrow;
    }
  }

  /// Get inventory summary with counts and values
  Future<Map<String, dynamic>> getInventorySummary() async {
    try {
      final response = await _dio.get('/analytics/inventory/summary/');
      
      // Handle the backend response structure
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('data')) {
          return responseData['data'] as Map<String, dynamic>;
        }
        return responseData;
      }
      
      return {
        'total_products': 0,
        'total_stock_value': 0.0,
        'low_stock_count': 0,
        'out_of_stock_count': 0,
      };
    } on DioException catch (e) {
      debugPrint('Error fetching inventory summary: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error fetching inventory summary: $e');
      rethrow;
    }
  }

  /// Get damaged products
  Future<List<Map<String, dynamic>>> getDamagedProducts() async {
    try {
      final response = await _dio.get('/damaged-products/');
      
      // Handle the backend response structure
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('data') && responseData['data'] is List) {
          return List<Map<String, dynamic>>.from(responseData['data']);
        }
      } else if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      
      return [];
    } on DioException catch (e) {
      debugPrint('Error fetching damaged products: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error fetching damaged products: $e');
      rethrow;
    }
  }

  /// Create a damaged product record
  Future<Map<String, dynamic>> createDamagedProduct(Map<String, dynamic> damageData) async {
    try {
      final response = await _dio.post('/damaged-products/', data: damageData);
      
      // Handle the backend response structure
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('data')) {
          return responseData['data'] as Map<String, dynamic>;
        }
        return responseData;
      }
      
      return {};
    } on DioException catch (e) {
      debugPrint('Error creating damaged product record: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error creating damaged product record: $e');
      rethrow;
    }
  }

  /// Update a damaged product record
  Future<Map<String, dynamic>> updateDamagedProduct(String damageId, Map<String, dynamic> damageData) async {
    try {
      final response = await _dio.put('/damaged-products/$damageId/', data: damageData);
      
      // Handle the backend response structure
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('data')) {
          return responseData['data'] as Map<String, dynamic>;
        }
        return responseData;
      }
      
      return {};
    } on DioException catch (e) {
      debugPrint('Error updating damaged product record $damageId: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error updating damaged product record $damageId: $e');
      rethrow;
    }
  }

  /// Delete a damaged product record
  Future<void> deleteDamagedProduct(String damageId) async {
    try {
      await _dio.delete('/damaged-products/$damageId/');
    } on DioException catch (e) {
      debugPrint('Error deleting damaged product record $damageId: $e');
      throw Exception('Server error (${e.response?.statusCode}): ${e.response?.data}');
    } catch (e) {
      debugPrint('Error deleting damaged product record $damageId: $e');
      rethrow;
    }
  }
}
