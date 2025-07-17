import 'package:flutter/foundation.dart';
import '../../../../data/models/analytics_model.dart';
import '../repositories/analytics_repository.dart';

class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsRepository _analyticsRepository;

  AnalyticsProvider(this._analyticsRepository);

  // Analytics data
  AnalyticsModel? _analytics;
  DashboardMetrics? _dashboardMetrics;
  List<SalesChartData> _salesChart = [];
  List<CategoryAnalytics> _categoryBreakdown = [];
  List<ProductPerformance> _topProducts = [];
  Map<String, double> _revenueSummary = {};

  // Inventory data
  int _totalProductsCount = 0;
  int _totalStockQuantity = 0;
  double _totalStockValue = 0.0;
  Map<String, dynamic> _inventorySummary = {};

  // Loading states
  bool _isLoadingAnalytics = false;
  bool _isLoadingDashboard = false;
  bool _isLoadingSalesChart = false;
  bool _isLoadingInventory = false;

  // Error states
  String? _analyticsError;
  String? _dashboardError;
  String? _salesChartError;
  String? _inventoryError;

  // Getters
  AnalyticsModel? get analytics => _analytics;
  DashboardMetrics? get dashboardMetrics => _dashboardMetrics;
  List<SalesChartData> get salesChart => _salesChart;
  List<CategoryAnalytics> get categoryBreakdown => _categoryBreakdown;
  List<ProductPerformance> get topProducts => _topProducts;
  Map<String, double> get revenueSummary => _revenueSummary;

  // Inventory getters
  int get totalProductsCount => _totalProductsCount;
  int get totalStockQuantity => _totalStockQuantity;
  double get totalStockValue => _totalStockValue;
  Map<String, dynamic> get inventorySummary => _inventorySummary;

  bool get isLoadingAnalytics => _isLoadingAnalytics;
  bool get isLoadingDashboard => _isLoadingDashboard;
  bool get isLoadingSalesChart => _isLoadingSalesChart;
  bool get isLoadingInventory => _isLoadingInventory;

  String? get analyticsError => _analyticsError;
  String? get dashboardError => _dashboardError;
  String? get salesChartError => _salesChartError;
  String? get inventoryError => _inventoryError;

  // Computed properties
  bool get hasData => _dashboardMetrics != null;
  bool get hasError => _analyticsError != null || _dashboardError != null;

  /// Load complete analytics data
  Future<void> loadAnalytics({
    String? startDate,
    String? endDate,
    String? period = 'month',
    bool forceRefresh = false,
  }) async {
    if (_isLoadingAnalytics && !forceRefresh) return;

    _isLoadingAnalytics = true;
    _analyticsError = null;
    notifyListeners();

    try {
      final analytics = await _analyticsRepository.getAnalytics(
        startDate: startDate,
        endDate: endDate,
        period: period,
      );

      _analytics = analytics;
      _dashboardMetrics = analytics.dashboard;
      _salesChart = analytics.salesChart;
      _categoryBreakdown = analytics.categoryBreakdown;
      _topProducts = analytics.topProducts;
      
      _analyticsError = null;
    } catch (e) {
      _analyticsError = e.toString();
      if (kDebugMode) {
        print('Analytics loading error: $e');
      }
    } finally {
      _isLoadingAnalytics = false;
      notifyListeners();
    }
  }

  /// Load dashboard metrics only
  Future<void> loadDashboardMetrics({
    String? startDate,
    String? endDate,
    bool forceRefresh = false,
  }) async {
    if (_isLoadingDashboard && !forceRefresh) return;

    _isLoadingDashboard = true;
    _dashboardError = null;
    notifyListeners();

    try {
      final metrics = await _analyticsRepository.getDashboardMetrics(
        startDate: startDate,
        endDate: endDate,
      );

      _dashboardMetrics = metrics;
      _dashboardError = null;
    } catch (e) {
      _dashboardError = e.toString();
      if (kDebugMode) {
        print('Dashboard metrics loading error: $e');
      }
    } finally {
      _isLoadingDashboard = false;
      notifyListeners();
    }
  }

  /// Load sales chart data
  Future<void> loadSalesChart({
    String? startDate,
    String? endDate,
    String period = 'day',
    bool forceRefresh = false,
  }) async {
    if (_isLoadingSalesChart && !forceRefresh) return;

    _isLoadingSalesChart = true;
    _salesChartError = null;
    notifyListeners();

    try {
      final chartData = await _analyticsRepository.getSalesChart(
        startDate: startDate,
        endDate: endDate,
        period: period,
      );

      _salesChart = chartData;
      _salesChartError = null;
    } catch (e) {
      _salesChartError = e.toString();
      if (kDebugMode) {
        print('Sales chart loading error: $e');
      }
    } finally {
      _isLoadingSalesChart = false;
      notifyListeners();
    }
  }

  /// Load category breakdown
  Future<void> loadCategoryBreakdown({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final categories = await _analyticsRepository.getCategoryBreakdown(
        startDate: startDate,
        endDate: endDate,
      );

      _categoryBreakdown = categories;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Category breakdown loading error: $e');
      }
    }
  }

  /// Load top performing products
  Future<void> loadTopProducts({
    String? startDate,
    String? endDate,
    int limit = 5,
  }) async {
    try {
      final products = await _analyticsRepository.getTopProducts(
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );

      _topProducts = products;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Top products loading error: $e');
      }
    }
  }

  /// Load revenue summary
  Future<void> loadRevenueSummary({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final summary = await _analyticsRepository.getRevenueSummary(
        startDate: startDate,
        endDate: endDate,
      );

      _revenueSummary = summary;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Revenue summary loading error: $e');
      }
    }
  }

  /// Load inventory summary data
  Future<void> loadInventorySummary() async {
    if (_isLoadingInventory) return;

    _isLoadingInventory = true;
    _inventoryError = null;
    notifyListeners();

    try {
      final summary = await _analyticsRepository.getInventorySummary();
      final productsCount = await _analyticsRepository.getTotalProductsCount();
      final stockQuantity = await _analyticsRepository.getTotalStockQuantity();
      final stockValue = await _analyticsRepository.getTotalStockValue();

      _inventorySummary = summary;
      _totalProductsCount = productsCount;
      _totalStockQuantity = stockQuantity;
      _totalStockValue = stockValue;
      _inventoryError = null;
    } catch (e) {
      _inventoryError = e.toString();
      if (kDebugMode) {
        print('Inventory summary loading error: $e');
      }
    } finally {
      _isLoadingInventory = false;
      notifyListeners();
    }
  }

  /// Load total products count only
  Future<void> loadTotalProductsCount() async {
    try {
      final count = await _analyticsRepository.getTotalProductsCount();
      _totalProductsCount = count;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Total products count loading error: $e');
      }
    }
  }

  /// Load total stock quantity only
  Future<void> loadTotalStockQuantity() async {
    try {
      final quantity = await _analyticsRepository.getTotalStockQuantity();
      _totalStockQuantity = quantity;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Total stock quantity loading error: $e');
      }
    }
  }

  /// Load total stock value only
  Future<void> loadTotalStockValue() async {
    try {
      final value = await _analyticsRepository.getTotalStockValue();
      _totalStockValue = value;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Total stock value loading error: $e');
      }
    }
  }

  /// Refresh all data
  Future<void> refreshAll({
    String? startDate,
    String? endDate,
  }) async {
    await Future.wait([
      loadAnalytics(
        startDate: startDate,
        endDate: endDate,
        forceRefresh: true,
      ),
      loadRevenueSummary(
        startDate: startDate,
        endDate: endDate,
      ),
      loadInventorySummary(),
    ]);
  }

  /// Clear all data and errors
  void clearData() {
    _analytics = null;
    _dashboardMetrics = null;
    _salesChart = [];
    _categoryBreakdown = [];
    _topProducts = [];
    _revenueSummary = {};
    
    // Clear inventory data
    _totalProductsCount = 0;
    _totalStockQuantity = 0;
    _totalStockValue = 0.0;
    _inventorySummary = {};
    
    _analyticsError = null;
    _dashboardError = null;
    _salesChartError = null;
    _inventoryError = null;
    
    notifyListeners();
  }

  /// Get formatted revenue text
  String getFormattedRevenue(double revenue) {
    if (revenue >= 1000000) {
      return '${(revenue / 1000000).toStringAsFixed(1)}M';
    } else if (revenue >= 1000) {
      return '${(revenue / 1000).toStringAsFixed(1)}K';
    } else {
      return revenue.toStringAsFixed(0);
    }
  }

  /// Get formatted currency with TSh prefix
  String getFormattedCurrency(double amount) {
    if (amount >= 1000000) {
      return 'TSh ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'TSh ${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return 'TSh ${amount.toStringAsFixed(0)}';
    }
  }

  /// Get revenue growth percentage (mock calculation)
  double getRevenueGrowth() {
    if (_dashboardMetrics != null) {
      // Mock calculation - in real app this would compare with previous period
      return (_dashboardMetrics!.todayRevenue / _dashboardMetrics!.totalRevenue * 365 * 100);
    }
    return 0.0;
  }
}
