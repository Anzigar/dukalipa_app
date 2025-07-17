# Analytics Consumption Guide

This guide shows where and how to consume analytics data in different features of your Flutter application using the AnalyticsProvider and AnalyticsRepository.

## Current Analytics Implementation

### AnalyticsProvider Location
- **File**: `lib/presentation/features/home/providers/analytics_provider.dart`
- **Repository**: `lib/presentation/features/home/repositories/analytics_repository.dart`
- **Service**: `lib/data/services/analytics_service.dart`

### Available Analytics Data

#### Inventory Analytics
- `totalProductsCount` - Number of unique products
- `totalStockQuantity` - Sum of all product quantities
- `totalStockValue` - Total value of all inventory
- `inventorySummary` - Complete inventory summary with low stock, out of stock counts

#### Sales Analytics
- `salesChart` - Sales data over time
- `revenueSummary` - Revenue breakdown and profits
- `topProducts` - Best performing products
- `dashboardMetrics` - Key business metrics

#### Business Analytics
- `categoryBreakdown` - Performance by product category
- `lowStockCount` - Number of products with low stock

## Where to Consume Analytics

### 1. Home Screen (✅ Already Implemented)
**Location**: `lib/presentation/features/home/screens/home_screen.dart`

```dart
Consumer<AnalyticsProvider>(
  builder: (context, analyticsProvider, _) {
    return _buildMetaStyleStatCard(
      'Products', 
      '${analyticsProvider.totalStockQuantity}', 
      'total stock'
    );
  },
),
```

**Usage**: 
- Dashboard overview cards
- Revenue summary
- Quick metrics display

### 2. Business Analytics Screen (🔄 Needs Integration)
**Location**: `lib/presentation/features/business/screens/business_analytics_screen.dart`

**What to Add**:
```dart
// Add to imports
import '../../home/providers/analytics_provider.dart';
import 'package:provider/provider.dart';

// In build method, wrap with Consumer
Consumer<AnalyticsProvider>(
  builder: (context, analyticsProvider, _) {
    return Column(
      children: [
        _buildRevenueChart(analyticsProvider.salesChart),
        _buildCategoryBreakdown(analyticsProvider.categoryBreakdown),
        _buildTopProducts(analyticsProvider.topProducts),
      ],
    );
  },
)
```

### 3. Inventory Screen (🔄 Needs Integration)
**Location**: `lib/presentation/features/inventory/screens/inventory_screen.dart`

**What to Add**:
```dart
// Add to existing InventorySummaryWidget
Consumer<AnalyticsProvider>(
  builder: (context, analyticsProvider, _) {
    return InventorySummaryWidget(
      totalProducts: analyticsProvider.totalProductsCount,
      totalValue: analyticsProvider.totalStockValue,
      lowStockCount: analyticsProvider.inventorySummary['low_stock_count'] ?? 0,
      outOfStockCount: analyticsProvider.inventorySummary['out_of_stock_count'] ?? 0,
    );
  },
)
```

### 4. Sales Screen (🔄 Needs Integration)
**Location**: `lib/presentation/features/sales/screens/sales_screen.dart`

**What to Add**:
```dart
// Add sales analytics summary header
Consumer<AnalyticsProvider>(
  builder: (context, analyticsProvider, _) {
    return SalesAnalyticsHeader(
      todayRevenue: analyticsProvider.dashboardMetrics?.todayRevenue ?? 0,
      todaySales: analyticsProvider.dashboardMetrics?.todaySales ?? 0,
      totalRevenue: analyticsProvider.dashboardMetrics?.totalRevenue ?? 0,
    );
  },
)
```

### 5. Business Hub Screen (🔄 Needs Integration)
**Location**: `lib/presentation/features/business/screens/business_hub_screen.dart`

**What to Add**:
```dart
// Business overview cards
Consumer<AnalyticsProvider>(
  builder: (context, analyticsProvider, _) {
    return BusinessOverviewGrid(
      totalProducts: analyticsProvider.totalProductsCount,
      totalStockValue: analyticsProvider.totalStockValue,
      lowStockItems: analyticsProvider.inventorySummary['low_stock_count'] ?? 0,
      profitMargin: analyticsProvider.dashboardMetrics?.profitMargin ?? 0,
    );
  },
)
```

## API Endpoints Being Consumed

The analytics system consumes these API endpoints via Dio:

### Base URL: `http://127.0.0.1:8000/api/v1`

#### Analytics Endpoints
- `GET /analytics` - Complete analytics data
- `GET /analytics/dashboard` - Dashboard metrics only
- `GET /analytics/sales/chart` - Sales chart data
- `GET /analytics/categories/breakdown` - Category performance
- `GET /analytics/products/top` - Top performing products
- `GET /analytics/revenue/summary` - Revenue breakdown

#### Inventory Analytics Endpoints
- `GET /analytics/products/total/` - Total products count
- `GET /analytics/products/stock-quantity/` - Total stock quantity
- `GET /analytics/products/stock-value/` - Total stock value
- `GET /analytics/inventory/summary/` - Complete inventory summary

## Implementation Steps

### Step 1: Register AnalyticsProvider in App
```dart
// In main.dart or app.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) => AnalyticsProvider(
        AnalyticsRepositoryImpl(),
      ),
    ),
    // ... other providers
  ],
  child: MyApp(),
)
```

### Step 2: Load Analytics Data
```dart
// In initState of screens that need analytics
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final analyticsProvider = Provider.of<AnalyticsProvider>(context, listen: false);
    analyticsProvider.loadAnalytics();
    analyticsProvider.loadInventorySummary();
  });
}
```

### Step 3: Handle Loading States
```dart
Consumer<AnalyticsProvider>(
  builder: (context, analyticsProvider, _) {
    if (analyticsProvider.isLoadingAnalytics) {
      return const AnalyticsShimmer();
    }
    
    if (analyticsProvider.hasError) {
      return AnalyticsErrorWidget(
        error: analyticsProvider.analyticsError,
        onRetry: () => analyticsProvider.loadAnalytics(forceRefresh: true),
      );
    }
    
    return AnalyticsContent(data: analyticsProvider);
  },
)
```

### Step 4: Implement Refresh Functionality
```dart
Future<void> _refreshAnalytics() async {
  final analyticsProvider = Provider.of<AnalyticsProvider>(context, listen: false);
  await analyticsProvider.refreshAll();
}

// In build method
RefreshIndicator(
  onRefresh: _refreshAnalytics,
  child: analyticsContent,
)
```

## Error Handling

The analytics system includes comprehensive error handling:

1. **Fallback Data**: When API fails, fallback data is provided
2. **Error States**: UI shows appropriate error messages
3. **Retry Mechanism**: Users can retry failed requests
4. **Offline Support**: Cached data is used when offline

## Performance Considerations

1. **Lazy Loading**: Analytics data is loaded only when needed
2. **Caching**: Data is cached to avoid repeated API calls
3. **Shimmer Loading**: Provides smooth loading experience
4. **Background Refresh**: Data refreshes automatically every 5 minutes

## Testing Analytics Integration

1. **Unit Tests**: Test analytics provider methods
2. **Widget Tests**: Test UI with different analytics states
3. **Integration Tests**: Test complete analytics flow
4. **API Tests**: Test analytics service with mock data

## Next Steps

1. ✅ **Home Screen** - Already consuming analytics
2. 🔄 **Business Analytics** - Add comprehensive analytics dashboard
3. 🔄 **Inventory Screen** - Add inventory analytics summary
4. 🔄 **Sales Screen** - Add sales performance metrics
5. 🔄 **Business Hub** - Add business overview cards

Each feature should follow the Consumer pattern and handle loading/error states appropriately.
