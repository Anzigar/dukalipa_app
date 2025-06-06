import 'dart:math';
import 'package:flutter/foundation.dart';

/// A mock implementation of ApiClient for testing and development
class ApiClient {
  final Random _random = Random();
  
  /// Simulates a GET request
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (kDebugMode) {
      print('MockAPI GET: $path, Query: $queryParameters');
    }
    
    // Simulate different responses based on path
    if (path.startsWith('/products')) {
      return _getMockProducts(queryParameters);
    } else if (path.startsWith('/sales')) {
      return _getMockSales(queryParameters);
    } else if (path.startsWith('/categories')) {
      return {'data': _getMockCategories()};
    }
    
    // Default empty response
    return {'data': []};
  }

  /// Simulates a POST request
  Future<Map<String, dynamic>> post(String path, {dynamic data}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (kDebugMode) {
      print('MockAPI POST: $path, Data: $data');
    }
    
    // Return the same data with an added id
    if (data is Map) {
      final result = Map<String, dynamic>.from(data);
      result['id'] = 'mock-${_random.nextInt(10000)}';
      return {'data': result};
    }
    
    return {'data': data};
  }

  /// Simulates a PUT request
  Future<Map<String, dynamic>> put(String path, {dynamic data}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (kDebugMode) {
      print('MockAPI PUT: $path, Data: $data');
    }
    
    // Just return the data as if updated
    return {'data': data};
  }

  /// Simulates a PATCH request
  Future<Map<String, dynamic>> patch(String path, {dynamic data}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (kDebugMode) {
      print('MockAPI PATCH: $path, Data: $data');
    }
    
    // Just return the data as if updated
    return {'data': data};
  }

  /// Simulates a DELETE request
  Future<Map<String, dynamic>> delete(String path) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (kDebugMode) {
      print('MockAPI DELETE: $path');
    }
    
    // Return success response
    return {'success': true};
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
        'purchasePrice': (50.0 + _random.nextDouble() * 200).toStringAsFixed(2),
        'sellingPrice': (100.0 + _random.nextDouble() * 300).toStringAsFixed(2),
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
        'totalAmount': (1000.0 + _random.nextDouble() * 5000).toStringAsFixed(2),
        'status': _getRandomStatus(),
        'customerName': _random.nextBool() ? 'Customer ${index + 1}' : null,
        'items': List.generate(
          _random.nextInt(5) + 1,
          (itemIndex) => {
            'productId': 'prod-${_random.nextInt(10)}',
            'productName': 'Product ${_random.nextInt(10) + 1}',
            'quantity': _random.nextInt(5) + 1,
            'unitPrice': (100.0 + _random.nextDouble() * 300).toStringAsFixed(2),
          },
        ),
      },
    );
    
    return {'data': sales};
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
}
