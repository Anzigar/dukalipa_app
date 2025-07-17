import 'package:dio/dio.dart';
import '../models/analytics_model.dart';

/// Service for handling analytics and dashboard metrics API operations
class AnalyticsService {
  late final Dio _dio;

  AnalyticsService() {
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

  /// Get complete analytics data for dashboard
  Future<AnalyticsModel> getAnalytics({
    String? startDate,
    String? endDate,
    String? period = 'month', // day, week, month, year
  }) async {
    try {
      final response = await _dio.get(
        '/analytics',
        queryParameters: {
          'period': period,
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
        },
      );

      if (response.data['data'] != null) {
        return AnalyticsModel.fromJson(response.data['data']);
      } else {
        // Return empty analytics if no data
        return const AnalyticsModel(
          dashboard: DashboardMetrics(
            totalRevenue: 0,
            todayRevenue: 0,
            totalProducts: 0,
            lowStockItems: 0,
            totalSales: 0,
            todaySales: 0,
            totalProfit: 0,
            profitMargin: 0,
          ),
          salesChart: [],
          categoryBreakdown: [],
          topProducts: [],
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch analytics: ${e.response?.data ?? e.message}');
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
      final response = await _dio.get(
        '/analytics/dashboard',
        queryParameters: {
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
        },
      );

      if (response.data['data'] != null) {
        return DashboardMetrics.fromJson(response.data['data']);
      } else {
        return const DashboardMetrics(
          totalRevenue: 0,
          todayRevenue: 0,
          totalProducts: 0,
          lowStockItems: 0,
          totalSales: 0,
          todaySales: 0,
          totalProfit: 0,
          profitMargin: 0,
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch dashboard metrics: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Failed to fetch dashboard metrics: ${e.toString()}');
    }
  }

  /// Get sales chart data for specific period
  Future<List<SalesChartData>> getSalesChart({
    String? startDate,
    String? endDate,
    String period = 'day', // day, week, month
  }) async {
    try {
      final response = await _dio.get(
        '/analytics/sales-chart',
        queryParameters: {
          'period': period,
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
        },
      );

      if (response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((json) => SalesChartData.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch sales chart data: ${e.response?.data ?? e.message}');
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
      final response = await _dio.get(
        '/analytics/categories',
        queryParameters: {
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
        },
      );

      if (response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((json) => CategoryAnalytics.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch category breakdown: ${e.response?.data ?? e.message}');
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
      final response = await _dio.get(
        '/analytics/top-products',
        queryParameters: {
          'limit': limit,
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
        },
      );

      if (response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((json) => ProductPerformance.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch top products: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Failed to fetch top products: ${e.toString()}');
    }
  }

  /// Get low stock alert count
  Future<int> getLowStockCount() async {
    try {
      final response = await _dio.get('/analytics/low-stock-count');
      
      if (response.data['data'] != null) {
        return response.data['data']['count'] ?? 0;
      } else {
        return 0;
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch low stock count: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Failed to fetch low stock count: ${e.toString()}');
    }
  }

  /// Get revenue summary for specific period
  Future<Map<String, double>> getRevenueSummary({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _dio.get(
        '/analytics/revenue-summary',
        queryParameters: {
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
        },
      );

      if (response.data['data'] != null) {
        final data = response.data['data'] as Map<String, dynamic>;
        return {
          'total_revenue': (data['total_revenue'] ?? 0).toDouble(),
          'total_profit': (data['total_profit'] ?? 0).toDouble(),
          'total_cost': (data['total_cost'] ?? 0).toDouble(),
          'profit_margin': (data['profit_margin'] ?? 0).toDouble(),
        };
      } else {
        return {
          'total_revenue': 0.0,
          'total_profit': 0.0,
          'total_cost': 0.0,
          'profit_margin': 0.0,
        };
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch revenue summary: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Failed to fetch revenue summary: ${e.toString()}');
    }
  }

  /// Get total products count
  Future<int> getTotalProductsCount() async {
    try {
      final response = await _dio.get('/analytics/products/total/');
      
      if (response.data['data'] != null) {
        return response.data['data']['total'] ?? 0;
      } else {
        return response.data['total'] ?? 0;
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch total products count: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Failed to fetch total products count: ${e.toString()}');
    }
  }

  /// Get total stock quantity (sum of all product quantities)
  Future<int> getTotalStockQuantity() async {
    try {
      final response = await _dio.get('/analytics/products/stock-quantity/');
      
      if (response.data['data'] != null) {
        return response.data['data']['total_quantity'] ?? 0;
      } else {
        return response.data['total_quantity'] ?? 0;
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch total stock quantity: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Failed to fetch total stock quantity: ${e.toString()}');
    }
  }

  /// Get total stock value
  Future<double> getTotalStockValue() async {
    try {
      final response = await _dio.get('/analytics/products/stock-value/');
      
      if (response.data['data'] != null) {
        return (response.data['data']['total_value'] ?? 0.0).toDouble();
      } else {
        return (response.data['total_value'] ?? 0.0).toDouble();
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch total stock value: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Failed to fetch total stock value: ${e.toString()}');
    }
  }

  /// Get inventory summary with counts and values
  Future<Map<String, dynamic>> getInventorySummary() async {
    try {
      final response = await _dio.get('/analytics/inventory/summary/');
      
      if (response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        return response.data as Map<String, dynamic>;
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch inventory summary: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Failed to fetch inventory summary: ${e.toString()}');
    }
  }
}
