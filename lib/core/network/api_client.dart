import 'dart:io';
import 'dart:math'; // Add this import for Random
import 'package:dio/dio.dart';

/// A simplified API client for testing and development
class ApiClient {
  final Dio _dio;
  final Random _random = Random();

  ApiClient({Dio? dio}) : _dio = dio ?? Dio();

  /// Performs a GET request
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to perform GET request: $e');
    }
  }

  /// Performs a POST request
  Future<Map<String, dynamic>> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to perform POST request: $e');
    }
  }

  /// Performs a PUT request
  Future<Map<String, dynamic>> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to perform PUT request: $e');
    }
  }

  /// Performs a PATCH request
  Future<Map<String, dynamic>> patch(String path, {dynamic data}) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to perform PATCH request: $e');
    }
  }

  /// Performs a DELETE request
  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to perform DELETE request: $e');
    }
  }

  /// Uploads a file
  Future<Map<String, dynamic>> uploadFile(String path, File file, {String fieldName = 'file'}) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(file.path),
      });

      final response = await _dio.post(
        path,
        data: formData,
      );

      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  dynamic _processResponse(Response response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return response.data;
    } else {
      throw Exception('Error occurred: ${response.statusCode}');
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please check your internet connection.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final errorMessage = error.response?.data?['message'] ?? error.message;

        if (statusCode == 401) {
          return Exception('Authentication error. Please log in again.');
        } else if (statusCode == 403) {
          return Exception('You don\'t have permission to access this resource.');
        } else if (statusCode == 404) {
          return Exception('Resource not found.');
        } else {
          return Exception('Server error: $errorMessage');
        }

      case DioExceptionType.cancel:
        return Exception('Request was cancelled');

      case DioExceptionType.connectionError:
        return Exception('Connection error. Please check your internet connection.');

      case DioExceptionType.badCertificate:
        return Exception('Bad certificate. Please check your connection security.');

      case DioExceptionType.unknown:
      default:
        return Exception(error.message ?? 'An unexpected error occurred');
    }
  }

  // For mock implementation until backend is ready
  Future<dynamic> getMockData(String path, {Map<String, dynamic>? queryParameters}) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Return mock data based on path
    switch (path) {
      case '/products':
        return _getMockProducts(queryParameters);
      case '/sales':
        if (path.contains('statistics')) {
          return _getMockSalesStatistics(queryParameters);
        }
        return _getMockSales(queryParameters);
      case '/categories':
        return {'data': _getMockCategories()};
      case '/suppliers':
        return {'data': _getMockSuppliers()};
      case '/expenses':
        if (path.contains('statistics')) {
          return _getMockExpenseStatistics(queryParameters);
        }
        return _getMockExpenses(queryParameters);
      case '/auth':
        if (path.contains('/me')) {
          return _getMockUser();
        }
        return _getMockUser();
      default:
        return {'data': []};
    }
  }

  // Helper methods to generate mock data
  Map<String, dynamic> _getMockProducts(Map<String, dynamic>? queryParameters) {
    final List<Map<String, dynamic>> products = List.generate(
      10,
      (index) => {
        'id': 'prod-$index',
        'name': 'Product ${index + 1}',
        'description': 'This is a mock product description',
        'category': _getRandomCategory(),
        'purchasePrice': (50.0 + _random.nextDouble() * 200),
        'sellingPrice': (100.0 + _random.nextDouble() * 300),
        'quantity': _random.nextInt(100),
        'lowStockThreshold': 10,
        'imageUrl': null,
        'metadata': {
          'supplier': _getRandomSupplier(),
          'unit': _getRandomUnit(),
        }
      },
    );

    return {'data': products};
  }

  Map<String, dynamic> _getMockSales(Map<String, dynamic>? queryParameters) {
    final List<Map<String, dynamic>> sales = List.generate(
      8,
      (index) => {
        'id': 'sale-$index',
        'date': DateTime.now().subtract(Duration(days: _random.nextInt(30))).toIso8601String(),
        'totalAmount': (1000.0 + _random.nextDouble() * 5000),
        'status': _getRandomStatus(),
        'customerName': _random.nextBool() ? 'Customer ${index + 1}' : null,
        'items': List.generate(
          _random.nextInt(5) + 1,
          (itemIndex) => {
            'productId': 'prod-${_random.nextInt(10)}',
            'productName': 'Product ${_random.nextInt(10) + 1}',
            'quantity': _random.nextInt(5) + 1,
            'unitPrice': (100.0 + _random.nextDouble() * 300),
          },
        ),
      },
    );

    return {'data': sales};
  }

  Map<String, dynamic> _getMockExpenses(Map<String, dynamic>? queryParameters) {
    final List<Map<String, dynamic>> expenses = List.generate(
      8,
      (index) => {
        'id': 'exp-$index',
        'amount': (100.0 + _random.nextDouble() * 1000),
        'description': 'Expense ${index + 1}',
        'category': _getRandomExpenseCategory(),
        'date': DateTime.now().subtract(Duration(days: _random.nextInt(30))).toIso8601String(),
        'paymentMethod': _getRandomPaymentMethod(),
        'receiptUrl': _random.nextBool() ? 'https://example.com/receipts/receipt-$index.jpg' : null,
      },
    );

    return {'data': expenses};
  }

  Map<String, dynamic> _getMockSalesStatistics(Map<String, dynamic>? queryParameters) {
    return {
      'totalAmount': 15000 + _random.nextDouble() * 15000,
      'totalCount': 45 + _random.nextInt(30),
      'averageAmount': 800 + _random.nextDouble() * 400,
      'byCategory': [
        {'category': 'Electronics', 'amount': 8500, 'count': 12},
        {'category': 'Clothing', 'amount': 6200, 'count': 18},
        {'category': 'Food', 'amount': 3800, 'count': 8},
      ],
      'byDate': List.generate(
        7,
        (index) => {
          'date': DateTime.now().subtract(Duration(days: 6 - index)).toIso8601String().split('T')[0],
          'amount': 1000 + _random.nextDouble() * 3000,
          'count': 2 + _random.nextInt(8),
        },
      ),
    };
  }

  Map<String, dynamic> _getMockExpenseStatistics(Map<String, dynamic>? queryParameters) {
    return {
      'totalAmount': 5000 + _random.nextDouble() * 10000,
      'categories': [
        {'name': 'Rent', 'amount': 2000.0},
        {'name': 'Supplies', 'amount': 1500.0},
        {'name': 'Utilities', 'amount': 800.0},
        {'name': 'Salaries', 'amount': 4500.0},
      ],
      'monthly': [
        {'month': 'Jan', 'amount': 3200.0},
        {'month': 'Feb', 'amount': 2800.0},
        {'month': 'Mar', 'amount': 3500.0},
        {'month': 'Apr', 'amount': 2900.0},
      ]
    };
  }

  List<Map<String, dynamic>> _getMockCategories() {
    return [
      {'name': 'Electronics'},
      {'name': 'Clothing'},
      {'name': 'Food'},
      {'name': 'Beverages'},
      {'name': 'Stationery'},
    ];
  }

  List<Map<String, dynamic>> _getMockSuppliers() {
    return [
      {'name': 'Local Supplier'},
      {'name': 'International Distributor'},
      {'name': 'Wholesale Market'},
      {'name': 'Direct Factory'},
      {'name': 'Online Store'},
    ];
  }

  Map<String, dynamic> _getMockUser() {
    return {
      'id': 'user-123',
      'name': 'Shop Owner',
      'email': 'owner@example.com',
      'phoneNumber': '+255712345678',
      'shopName': 'My Awesome Shop',
      'profileImage': null,
    };
  }

  String _getRandomCategory() {
    final categories = ['Electronics', 'Clothing', 'Food', 'Beverages', 'Stationery'];
    return categories[_random.nextInt(categories.length)];
  }

  String _getRandomSupplier() {
    final suppliers = [
      'Local Supplier',
      'International Distributor',
      'Wholesale Market',
      'Direct Factory',
      'Online Store'
    ];
    return suppliers[_random.nextInt(suppliers.length)];
  }

  String _getRandomUnit() {
    final units = ['pcs', 'kg', 'liters', 'boxes', 'pairs'];
    return units[_random.nextInt(units.length)];
  }

  String _getRandomStatus() {
    final statuses = ['completed', 'pending', 'cancelled'];
    return statuses[_random.nextInt(statuses.length)];
  }

  String _getRandomExpenseCategory() {
    final categories = ['Rent', 'Utilities', 'Salaries', 'Supplies', 'Marketing', 'Miscellaneous'];
    return categories[_random.nextInt(categories.length)];
  }

  String _getRandomPaymentMethod() {
    final methods = ['Cash', 'Bank Transfer', 'Mobile Money', 'Credit Card'];
    return methods[_random.nextInt(methods.length)];
  }
}
