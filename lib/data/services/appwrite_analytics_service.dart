import 'package:appwrite/appwrite.dart';
import '../../core/services/appwrite_service.dart';
import '../models/analytics_model.dart';

/// Service for handling analytics and dashboard metrics using Appwrite backend
class AppwriteAnalyticsService {
  final Databases _databases;
  final String _databaseId = 'shop_management_db';

  AppwriteAnalyticsService() : _databases = AppwriteService().databases;

  /// Get complete analytics data for dashboard
  Future<AnalyticsModel> getAnalytics({
    String? startDate,
    String? endDate,
    String? period = 'month',
  }) async {
    try {
      // Get all data concurrently
      final futures = await Future.wait([
        getDashboardMetrics(startDate: startDate, endDate: endDate),
        getSalesChart(startDate: startDate, endDate: endDate, period: period ?? 'day'),
        getCategoryBreakdown(startDate: startDate, endDate: endDate),
        getTopProducts(startDate: startDate, endDate: endDate, limit: 5),
      ]);

      return AnalyticsModel(
        dashboard: futures[0] as DashboardMetrics,
        salesChart: futures[1] as List<SalesChartData>,
        categoryBreakdown: futures[2] as List<CategoryAnalytics>,
        topProducts: futures[3] as List<ProductPerformance>,
      );
    } catch (e) {
      throw Exception('Failed to fetch analytics: ${e.toString()}');
    }
  }

  /// Get dashboard metrics only
  Future<DashboardMetrics> getDashboardMetrics({
    String? startDate,
    String? endDate,
  }) async {
    try {
      // Get all needed data from different collections
      final futures = await Future.wait([
        _getTotalRevenue(startDate: startDate, endDate: endDate),
        _getTodayRevenue(),
        _getTotalProducts(),
        _getLowStockCount(),
        _getTotalSales(startDate: startDate, endDate: endDate),
        _getTodaySales(),
        _calculateProfit(startDate: startDate, endDate: endDate),
      ]);

      final totalRevenue = futures[0] as double;
      final todayRevenue = futures[1] as double;
      final totalProducts = futures[2] as int;
      final lowStockItems = futures[3] as int;
      final totalSales = futures[4] as int;
      final todaySales = futures[5] as int;
      final profitData = futures[6] as Map<String, double>;

      return DashboardMetrics(
        totalRevenue: totalRevenue,
        todayRevenue: todayRevenue,
        totalProducts: totalProducts,
        lowStockItems: lowStockItems,
        totalSales: totalSales,
        todaySales: todaySales,
        totalProfit: profitData['profit'] ?? 0.0,
        profitMargin: profitData['margin'] ?? 0.0,
      );
    } catch (e) {
      throw Exception('Failed to fetch dashboard metrics: ${e.toString()}');
    }
  }

  /// Get sales chart data for specific period
  Future<List<SalesChartData>> getSalesChart({
    String? startDate,
    String? endDate,
    String period = 'day',
  }) async {
    try {
      // Calculate date range
      final end = endDate != null ? DateTime.parse(endDate) : DateTime.now();
      final start = startDate != null ? DateTime.parse(startDate) : end.subtract(Duration(days: 7));

      List<String> queries = [
        Query.greaterThanEqual('\$createdAt', start.toIso8601String()),
        Query.lessThanEqual('\$createdAt', end.toIso8601String()),
        Query.orderDesc('\$createdAt'),
      ];

      final salesDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'sales',
        queries: queries,
      );

      // Group sales by date
      Map<String, Map<String, dynamic>> salesByDate = {};
      
      for (var sale in salesDocs.documents) {
        final saleDate = DateTime.parse(sale.data['\$createdAt']).toIso8601String().split('T')[0];
        final revenue = (sale.data['total_amount'] ?? 0).toDouble();
        final profit = (sale.data['profit'] ?? 0).toDouble();

        if (salesByDate.containsKey(saleDate)) {
          salesByDate[saleDate]!['revenue'] += revenue;
          salesByDate[saleDate]!['profit'] += profit;
          salesByDate[saleDate]!['count'] += 1;
        } else {
          salesByDate[saleDate] = {
            'revenue': revenue,
            'profit': profit,
            'count': 1,
          };
        }
      }

      // Convert to chart data
      List<SalesChartData> chartData = [];
      for (var entry in salesByDate.entries) {
        chartData.add(SalesChartData(
          date: entry.key,
          revenue: entry.value['revenue'],
          salesCount: entry.value['count'],
          profit: entry.value['profit'],
        ));
      }

      // Sort by date
      chartData.sort((a, b) => a.date.compareTo(b.date));
      
      return chartData;
    } catch (e) {
      throw Exception('Failed to fetch sales chart data: ${e.toString()}');
    }
  }

  /// Get category breakdown analytics
  Future<List<CategoryAnalytics>> getCategoryBreakdown({
    String? startDate,
    String? endDate,
  }) async {
    try {
      List<String> queries = [];
      
      if (startDate != null) {
        queries.add(Query.greaterThanEqual('\$createdAt', DateTime.parse(startDate).toIso8601String()));
      }
      if (endDate != null) {
        queries.add(Query.lessThanEqual('\$createdAt', DateTime.parse(endDate).toIso8601String()));
      }

      final salesDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'sales',
        queries: queries,
      );

      // Get category breakdown from sales
      Map<String, Map<String, dynamic>> categoryStats = {};
      double totalRevenue = 0;

      for (var sale in salesDocs.documents) {
        final items = sale.data['items'] as List? ?? [];
        
        for (var item in items) {
          final category = item['category'] ?? 'Other';
          final revenue = (item['total_price'] ?? 0).toDouble();
          final quantity = item['quantity'] ?? 0;
          
          totalRevenue += revenue;

          if (categoryStats.containsKey(category)) {
            categoryStats[category]!['revenue'] += revenue;
            categoryStats[category]!['salesCount'] += quantity;
            categoryStats[category]!['productCount'] += 1;
          } else {
            categoryStats[category] = {
              'revenue': revenue,
              'salesCount': quantity,
              'productCount': 1,
            };
          }
        }
      }

      // Convert to category analytics
      List<CategoryAnalytics> analytics = [];
      for (var entry in categoryStats.entries) {
        final percentage = totalRevenue > 0 ? (entry.value['revenue'] / totalRevenue) * 100 : 0;
        
        analytics.add(CategoryAnalytics(
          category: entry.key,
          productCount: entry.value['productCount'],
          revenue: entry.value['revenue'],
          percentage: percentage,
          salesCount: entry.value['salesCount'],
        ));
      }

      // Sort by revenue descending
      analytics.sort((a, b) => b.revenue.compareTo(a.revenue));
      
      return analytics;
    } catch (e) {
      throw Exception('Failed to fetch category breakdown: ${e.toString()}');
    }
  }

  /// Get top performing products
  Future<List<ProductPerformance>> getTopProducts({
    String? startDate,
    String? endDate,
    int limit = 10,
  }) async {
    try {
      List<String> queries = [];
      
      if (startDate != null) {
        queries.add(Query.greaterThanEqual('\$createdAt', DateTime.parse(startDate).toIso8601String()));
      }
      if (endDate != null) {
        queries.add(Query.lessThanEqual('\$createdAt', DateTime.parse(endDate).toIso8601String()));
      }

      final salesDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'sales',
        queries: queries,
      );

      // Track product performance
      Map<String, Map<String, dynamic>> productStats = {};

      for (var sale in salesDocs.documents) {
        final items = sale.data['items'] as List? ?? [];
        
        for (var item in items) {
          final productId = item['product_id'] ?? '';
          final productName = item['product_name'] ?? 'Unknown Product';
          final revenue = (item['total_price'] ?? 0).toDouble();
          final profit = ((item['selling_price'] ?? 0) - (item['cost_price'] ?? 0)) * (item['quantity'] ?? 1).toDouble();
          final quantity = item['quantity'] ?? 0;

          if (productStats.containsKey(productId)) {
            productStats[productId]!['revenue'] += revenue;
            productStats[productId]!['profit'] += profit;
            productStats[productId]!['salesCount'] += quantity;
          } else {
            productStats[productId] = {
              'productName': productName,
              'revenue': revenue,
              'profit': profit,
              'salesCount': quantity,
              'stockLevel': 0, // Will be updated below
            };
          }
        }
      }

      // Get current stock levels for products
      for (var productId in productStats.keys) {
        try {
          final productDoc = await _databases.getDocument(
            databaseId: _databaseId,
            collectionId: 'products',
            documentId: productId,
          );
          productStats[productId]!['stockLevel'] = productDoc.data['stock_quantity'] ?? 0;
        } catch (e) {
          // Product might not exist anymore, keep stock as 0
        }
      }

      // Convert to product performance list
      List<ProductPerformance> performance = [];
      for (var entry in productStats.entries) {
        performance.add(ProductPerformance(
          productId: entry.key,
          productName: entry.value['productName'],
          salesCount: entry.value['salesCount'],
          revenue: entry.value['revenue'],
          profit: entry.value['profit'],
          stockLevel: entry.value['stockLevel'],
        ));
      }

      // Sort by revenue descending and limit
      performance.sort((a, b) => b.revenue.compareTo(a.revenue));
      
      return performance.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to fetch top products: ${e.toString()}');
    }
  }

  /// Get low stock alert count
  Future<int> getLowStockCount() async {
    return await _getLowStockCount();
  }

  /// Get revenue summary for specific period
  Future<Map<String, double>> getRevenueSummary({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final totalRevenue = await _getTotalRevenue(startDate: startDate, endDate: endDate);
      final profitData = await _calculateProfit(startDate: startDate, endDate: endDate);
      
      return {
        'total_revenue': totalRevenue,
        'total_profit': profitData['profit'] ?? 0.0,
        'total_cost': totalRevenue - (profitData['profit'] ?? 0.0),
        'profit_margin': profitData['margin'] ?? 0.0,
      };
    } catch (e) {
      throw Exception('Failed to fetch revenue summary: ${e.toString()}');
    }
  }

  /// Get total products count
  Future<int> getTotalProductsCount() async {
    return await _getTotalProducts();
  }

  /// Get total stock quantity (sum of all product quantities)
  Future<int> getTotalStockQuantity() async {
    try {
      final productsDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'products',
        queries: [Query.limit(1000)], // Get all products
      );

      int totalQuantity = 0;
      for (var product in productsDocs.documents) {
        totalQuantity += (product.data['stock_quantity'] ?? 0) as int;
      }

      return totalQuantity;
    } catch (e) {
      throw Exception('Failed to fetch total stock quantity: ${e.toString()}');
    }
  }

  /// Get total stock value
  Future<double> getTotalStockValue() async {
    try {
      final productsDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'products',
        queries: [Query.limit(1000)], // Get all products
      );

      double totalValue = 0.0;
      for (var product in productsDocs.documents) {
        final quantity = (product.data['stock_quantity'] ?? 0) as int;
        final costPrice = (product.data['cost_price'] ?? 0).toDouble();
        totalValue += quantity * costPrice;
      }

      return totalValue;
    } catch (e) {
      throw Exception('Failed to fetch total stock value: ${e.toString()}');
    }
  }

  /// Get inventory summary with counts and values
  Future<Map<String, dynamic>> getInventorySummary() async {
    try {
      final futures = await Future.wait([
        getTotalProductsCount(),
        getTotalStockValue(),
        getLowStockCount(),
        _getOutOfStockCount(),
      ]);

      return {
        'total_products': futures[0],
        'total_stock_value': futures[1],
        'low_stock_count': futures[2],
        'out_of_stock_count': futures[3],
      };
    } catch (e) {
      throw Exception('Failed to fetch inventory summary: ${e.toString()}');
    }
  }

  // Private helper methods

  Future<double> _getTotalRevenue({String? startDate, String? endDate}) async {
    try {
      List<String> queries = [];
      
      if (startDate != null) {
        queries.add(Query.greaterThanEqual('\$createdAt', DateTime.parse(startDate).toIso8601String()));
      }
      if (endDate != null) {
        queries.add(Query.lessThanEqual('\$createdAt', DateTime.parse(endDate).toIso8601String()));
      }

      final salesDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'sales',
        queries: queries,
      );

      double totalRevenue = 0.0;
      for (var sale in salesDocs.documents) {
        totalRevenue += (sale.data['total_amount'] ?? 0).toDouble();
      }

      return totalRevenue;
    } catch (e) {
      return 0.0;
    }
  }

  Future<double> _getTodayRevenue() async {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(Duration(days: 1));

    return await _getTotalRevenue(
      startDate: todayStart.toIso8601String(),
      endDate: todayEnd.toIso8601String(),
    );
  }

  Future<int> _getTotalProducts() async {
    try {
      final productsDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'products',
        queries: [Query.limit(1)], // Just get count
      );

      return productsDocs.total;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getLowStockCount() async {
    try {
      // Get products where stock_quantity <= low_stock_threshold
      final productsDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'products',
        queries: [Query.limit(1000)], // Get all to check stock levels
      );

      int lowStockCount = 0;
      for (var product in productsDocs.documents) {
        final currentStock = (product.data['stock_quantity'] ?? 0) as int;
        final lowStockThreshold = (product.data['low_stock_threshold'] ?? 5) as int;
        
        if (currentStock <= lowStockThreshold) {
          lowStockCount++;
        }
      }

      return lowStockCount;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getTotalSales({String? startDate, String? endDate}) async {
    try {
      List<String> queries = [];
      
      if (startDate != null) {
        queries.add(Query.greaterThanEqual('\$createdAt', DateTime.parse(startDate).toIso8601String()));
      }
      if (endDate != null) {
        queries.add(Query.lessThanEqual('\$createdAt', DateTime.parse(endDate).toIso8601String()));
      }

      final salesDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'sales',
        queries: queries,
      );

      return salesDocs.total;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getTodaySales() async {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(Duration(days: 1));

    return await _getTotalSales(
      startDate: todayStart.toIso8601String(),
      endDate: todayEnd.toIso8601String(),
    );
  }

  Future<Map<String, double>> _calculateProfit({String? startDate, String? endDate}) async {
    try {
      List<String> queries = [];
      
      if (startDate != null) {
        queries.add(Query.greaterThanEqual('\$createdAt', DateTime.parse(startDate).toIso8601String()));
      }
      if (endDate != null) {
        queries.add(Query.lessThanEqual('\$createdAt', DateTime.parse(endDate).toIso8601String()));
      }

      final salesDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'sales',
        queries: queries,
      );

      double totalRevenue = 0.0;
      double totalCost = 0.0;

      for (var sale in salesDocs.documents) {
        final items = sale.data['items'] as List? ?? [];
        
        for (var item in items) {
          final revenue = (item['total_price'] ?? 0).toDouble();
          final cost = (item['cost_price'] ?? 0).toDouble() * (item['quantity'] ?? 1);
          
          totalRevenue += revenue;
          totalCost += cost;
        }
      }

      final profit = totalRevenue - totalCost;
      final margin = totalRevenue > 0 ? (profit / totalRevenue) * 100 : 0.0;

      return {
        'profit': profit,
        'margin': margin,
      };
    } catch (e) {
      return {
        'profit': 0.0,
        'margin': 0.0,
      };
    }
  }

  Future<int> _getOutOfStockCount() async {
    try {
      final productsDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'products',
        queries: [
          Query.equal('stock_quantity', 0),
          Query.limit(1000),
        ],
      );

      return productsDocs.total;
    } catch (e) {
      return 0;
    }
  }
}