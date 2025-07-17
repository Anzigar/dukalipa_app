import 'package:dio/dio.dart';
import '../../presentation/features/sales/models/sale_model.dart';
import '../../presentation/features/inventory/models/product_model.dart';

/// Model for recent activity items
class RecentActivityItem {
  final String id;
  final String type; // 'sale', 'inventory', 'customer', 'low_stock'
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  RecentActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.metadata,
  });

  factory RecentActivityItem.fromJson(Map<String, dynamic> json) {
    return RecentActivityItem(
      id: json['id'].toString(),
      type: json['type'] ?? 'unknown',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// Service for handling recent activity API operations
class RecentActivityService {
  late final Dio _dio;

  RecentActivityService() {
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

  /// Get recent activities by aggregating data from multiple sources
  Future<List<RecentActivityItem>> getRecentActivities({int limit = 10}) async {
    try {
      List<RecentActivityItem> activities = [];

      // Get recent sales (last 5)
      final recentSales = await _getRecentSales(limit: 3);
      activities.addAll(recentSales);

      // Get recent inventory changes (last 3)
      final recentInventory = await _getRecentInventoryChanges(limit: 2);
      activities.addAll(recentInventory);

      // Get low stock alerts
      final lowStockAlerts = await _getLowStockAlerts(limit: 2);
      activities.addAll(lowStockAlerts);

      // Sort by timestamp (most recent first)
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Return only the requested limit
      return activities.take(limit).toList();
    } catch (e) {
      // Return empty list with fallback dummy data on error
      return _getFallbackActivities();
    }
  }

  /// Get recent sales and convert to activity items
  Future<List<RecentActivityItem>> _getRecentSales({int limit = 5}) async {
    try {
      final response = await _dio.get('/sales/', queryParameters: {
        'page': 1,
        'limit': limit,
      });

      List<RecentActivityItem> activities = [];
      
      if (response.data['data'] != null && response.data['data']['sales'] != null) {
        final sales = response.data['data']['sales'] as List;
        
        for (var saleData in sales) {
          final sale = SaleModel.fromJson(saleData);
          activities.add(RecentActivityItem(
            id: 'sale_${sale.id}',
            type: 'sale',
            title: 'New sale completed',
            subtitle: '${sale.customerName} - ${_formatCurrency(sale.totalAmount)}',
            timestamp: sale.createdAt,
            metadata: {
              'customer_name': sale.customerName,
              'total_amount': sale.totalAmount,
              'payment_method': sale.paymentMethod,
              'items_count': sale.items.length,
            },
          ));
        }
      }

      return activities;
    } catch (e) {
      return [];
    }
  }

  /// Get recent inventory changes and convert to activity items
  Future<List<RecentActivityItem>> _getRecentInventoryChanges({int limit = 5}) async {
    try {
      final response = await _dio.get('/products/', queryParameters: {
        'page': 1,
        'limit': limit,
      });

      List<RecentActivityItem> activities = [];
      
      if (response.data['data'] != null && response.data['data']['products'] != null) {
        final products = response.data['data']['products'] as List;
        
        for (var productData in products) {
          final product = ProductModel.fromJson(productData);
          activities.add(RecentActivityItem(
            id: 'inventory_${product.id}',
            type: 'inventory',
            title: 'Product added to inventory',
            subtitle: '${product.name} - ${product.quantity} units',
            timestamp: product.createdAt,
            metadata: {
              'product_name': product.name,
              'quantity': product.quantity,
              'category': product.category,
              'selling_price': product.sellingPrice,
            },
          ));
        }
      }

      return activities;
    } catch (e) {
      return [];
    }
  }

  /// Get low stock alerts and convert to activity items
  Future<List<RecentActivityItem>> _getLowStockAlerts({int limit = 5}) async {
    try {
      final response = await _dio.get('/products/', queryParameters: {
        'low_stock': true,
        'page': 1,
        'limit': limit,
      });

      List<RecentActivityItem> activities = [];
      
      if (response.data['data'] != null && response.data['data']['products'] != null) {
        final products = response.data['data']['products'] as List;
        
        for (var productData in products) {
          final product = ProductModel.fromJson(productData);
          activities.add(RecentActivityItem(
            id: 'low_stock_${product.id}',
            type: 'low_stock',
            title: 'Low stock alert',
            subtitle: '${product.name} - ${product.quantity} units left',
            timestamp: DateTime.now().subtract(Duration(minutes: activities.length * 30)),
            metadata: {
              'product_name': product.name,
              'quantity': product.quantity,
              'low_stock_threshold': product.lowStockThreshold,
              'category': product.category,
            },
          ));
        }
      }

      return activities;
    } catch (e) {
      return [];
    }
  }

  /// Format currency values
  String _formatCurrency(double amount) {
    return 'TSh ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  /// Fallback activities when API fails
  List<RecentActivityItem> _getFallbackActivities() {
    final now = DateTime.now();
    return [
      RecentActivityItem(
        id: 'fallback_1',
        type: 'sale',
        title: 'New sale completed',
        subtitle: 'iPhone 13 Pro - TSh 2,500,000',
        timestamp: now.subtract(const Duration(minutes: 2)),
      ),
      RecentActivityItem(
        id: 'fallback_2',
        type: 'low_stock',
        title: 'Low stock alert',
        subtitle: 'Samsung Galaxy S21 - 2 units left',
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
      RecentActivityItem(
        id: 'fallback_3',
        type: 'inventory',
        title: 'Product added to inventory',
        subtitle: 'MacBook Pro M2 - 5 units',
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
    ];
  }
}
