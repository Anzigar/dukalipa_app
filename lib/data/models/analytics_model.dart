/// Analytics data model for dashboard metrics
class AnalyticsModel {
  final DashboardMetrics dashboard;
  final List<SalesChartData> salesChart;
  final List<CategoryAnalytics> categoryBreakdown;
  final List<ProductPerformance> topProducts;

  const AnalyticsModel({
    required this.dashboard,
    required this.salesChart,
    required this.categoryBreakdown,
    required this.topProducts,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      dashboard: DashboardMetrics.fromJson(json['dashboard'] ?? {}),
      salesChart: (json['sales_chart'] as List?)
          ?.map((e) => SalesChartData.fromJson(e))
          .toList() ?? [],
      categoryBreakdown: (json['category_breakdown'] as List?)
          ?.map((e) => CategoryAnalytics.fromJson(e))
          .toList() ?? [],
      topProducts: (json['top_products'] as List?)
          ?.map((e) => ProductPerformance.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dashboard': dashboard.toJson(),
      'sales_chart': salesChart.map((e) => e.toJson()).toList(),
      'category_breakdown': categoryBreakdown.map((e) => e.toJson()).toList(),
      'top_products': topProducts.map((e) => e.toJson()).toList(),
    };
  }
}

/// Dashboard metrics for key performance indicators
class DashboardMetrics {
  final double totalRevenue;
  final double todayRevenue;
  final int totalProducts;
  final int lowStockItems;
  final int totalSales;
  final int todaySales;
  final double totalProfit;
  final double profitMargin;

  const DashboardMetrics({
    required this.totalRevenue,
    required this.todayRevenue,
    required this.totalProducts,
    required this.lowStockItems,
    required this.totalSales,
    required this.todaySales,
    required this.totalProfit,
    required this.profitMargin,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      todayRevenue: (json['today_revenue'] ?? 0).toDouble(),
      totalProducts: json['total_products'] ?? 0,
      lowStockItems: json['low_stock_items'] ?? 0,
      totalSales: json['total_sales'] ?? 0,
      todaySales: json['today_sales'] ?? 0,
      totalProfit: (json['total_profit'] ?? 0).toDouble(),
      profitMargin: (json['profit_margin'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_revenue': totalRevenue,
      'today_revenue': todayRevenue,
      'total_products': totalProducts,
      'low_stock_items': lowStockItems,
      'total_sales': totalSales,
      'today_sales': todaySales,
      'total_profit': totalProfit,
      'profit_margin': profitMargin,
    };
  }
}

/// Sales chart data for trend visualization
class SalesChartData {
  final String date;
  final double revenue;
  final int salesCount;
  final double profit;

  const SalesChartData({
    required this.date,
    required this.revenue,
    required this.salesCount,
    required this.profit,
  });

  factory SalesChartData.fromJson(Map<String, dynamic> json) {
    return SalesChartData(
      date: json['date'] ?? '',
      revenue: (json['revenue'] ?? 0).toDouble(),
      salesCount: json['sales_count'] ?? 0,
      profit: (json['profit'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'revenue': revenue,
      'sales_count': salesCount,
      'profit': profit,
    };
  }
}

/// Category analytics for breakdown by product categories
class CategoryAnalytics {
  final String category;
  final int productCount;
  final double revenue;
  final double percentage;
  final int salesCount;

  const CategoryAnalytics({
    required this.category,
    required this.productCount,
    required this.revenue,
    required this.percentage,
    required this.salesCount,
  });

  factory CategoryAnalytics.fromJson(Map<String, dynamic> json) {
    return CategoryAnalytics(
      category: json['category'] ?? '',
      productCount: json['product_count'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
      salesCount: json['sales_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'product_count': productCount,
      'revenue': revenue,
      'percentage': percentage,
      'sales_count': salesCount,
    };
  }
}

/// Product performance metrics
class ProductPerformance {
  final String productId;
  final String productName;
  final int salesCount;
  final double revenue;
  final double profit;
  final int stockLevel;

  const ProductPerformance({
    required this.productId,
    required this.productName,
    required this.salesCount,
    required this.revenue,
    required this.profit,
    required this.stockLevel,
  });

  factory ProductPerformance.fromJson(Map<String, dynamic> json) {
    return ProductPerformance(
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      salesCount: json['sales_count'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
      profit: (json['profit'] ?? 0).toDouble(),
      stockLevel: json['stock_level'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'sales_count': salesCount,
      'revenue': revenue,
      'profit': profit,
      'stock_level': stockLevel,
    };
  }
}
