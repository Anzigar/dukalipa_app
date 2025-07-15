# API Integration Guide

This document outlines how the new API services integrate with the existing UI/UX without affecting the current user experience.

## Services Implemented

### 1. SalesService (`lib/data/services/sales_service.dart`)
Handles all sales-related operations:
- `createSale()` - Create new sales transactions
- `getSales()` - Fetch sales with pagination and filtering
- `getSale(id)` - Get specific sale details
- `updateSale(id)` - Update existing sales
- `deleteSale(id)` - Soft delete sales (moves to deleted_sales)
- `getSalesAnalytics()` - Get sales analytics and summaries

### 2. ReturnsService (`lib/data/services/returns_service.dart`)
Manages product returns and refunds:
- `createReturn()` - Process new returns
- `getReturns()` - List all returns with filtering
- `getReturn(id)` - Get specific return details
- `updateReturn(id)` - Update return status/details
- `getReturnsAnalytics()` - Get returns analytics

### 3. DeletedSalesService (`lib/data/services/deleted_sales_service.dart`)
Handles soft-deleted sales:
- `getDeletedSales()` - List deleted sales
- `restoreDeletedSale(id)` - Restore deleted sales

### 4. DamagedProductsService (`lib/data/services/damaged_products_service.dart`)
Tracks damaged inventory:
- `reportDamagedProduct()` - Report new damage
- `getDamagedProducts()` - List damaged products
- `getDamageReport(id)` - Get damage details
- `updateDamageReport(id)` - Update damage reports
- `getDamageAnalytics()` - Get damage analytics

### 5. ExpensesService (`lib/data/services/expenses_service.dart`)
Manages business expenses:
- `createExpense()` - Record new expenses
- `getExpenses()` - List expenses with filtering
- `getExpense(id)` - Get expense details
- `updateExpense(id)` - Update expense records
- `deleteExpense(id)` - Delete expenses
- `getExpenseCategories()` - Get available categories
- `getExpenseSummary()` - Get expense analytics

## API Endpoints Consumed

All services connect to the backend API at `http://127.0.0.1:8000` with these endpoints:

### Sales Endpoints
- `POST /api/v1/sales/` - Create sale
- `GET /api/v1/sales/` - List sales (with pagination/filtering)
- `GET /api/v1/sales/{id}` - Get sale details
- `PUT /api/v1/sales/{id}` - Update sale
- `DELETE /api/v1/sales/{id}` - Delete sale (soft delete)
- `GET /api/v1/sales/analytics/summary` - Sales analytics

### Returns Endpoints
- `POST /api/v1/returns/` - Create return
- `GET /api/v1/returns/` - List returns
- `GET /api/v1/returns/{id}` - Get return details
- `PUT /api/v1/returns/{id}` - Update return
- `GET /api/v1/returns/analytics/summary` - Returns analytics

### Deleted Sales Endpoints
- `GET /api/v1/sales/deleted/` - List deleted sales
- `POST /api/v1/sales/deleted/{id}/restore` - Restore deleted sale

### Damaged Products Endpoints
- `POST /api/v1/damaged-products/` - Report damage
- `GET /api/v1/damaged-products/` - List damaged products
- `GET /api/v1/damaged-products/{id}` - Get damage details
- `PUT /api/v1/damaged-products/{id}` - Update damage report
- `GET /api/v1/damaged-products/analytics/summary` - Damage analytics

### Expenses Endpoints
- `POST /api/v1/expenses/` - Create expense
- `GET /api/v1/expenses/` - List expenses
- `GET /api/v1/expenses/{id}` - Get expense details
- `PUT /api/v1/expenses/{id}` - Update expense
- `DELETE /api/v1/expenses/{id}` - Delete expense
- `GET /api/v1/expenses/categories/list` - Get categories
- `GET /api/v1/expenses/summary/analytics` - Expense analytics

## Integration with Existing UI

### Service Locator Registration
All services are registered in `lib/core/di/service_locator.dart`:
```dart
locator.registerLazySingleton<SalesService>(() => SalesService(locator<ApiClient>()));
locator.registerLazySingleton<ReturnsService>(() => ReturnsService(locator<ApiClient>()));
locator.registerLazySingleton<DeletedSalesService>(() => DeletedSalesService(locator<ApiClient>()));
locator.registerLazySingleton<DamagedProductsService>(() => DamagedProductsService(locator<ApiClient>()));
locator.registerLazySingleton<ExpensesService>(() => ExpensesService(locator<ApiClient>()));
```

### Usage in Existing Screens
The services can be injected into existing providers/repositories without changing the UI:

```dart
// In providers
class SalesProvider extends ChangeNotifier {
  final SalesService _salesService = locator<SalesService>();
  
  Future<void> createSale(SaleData saleData) async {
    final response = await _salesService.createSale(
      customerName: saleData.customerName,
      items: saleData.items.map((item) => SaleItemCreateRequest(
        productId: item.productId,
        quantity: item.quantity,
        price: item.price,
      )).toList(),
      paymentMethod: saleData.paymentMethod,
    );
    
    if (response.success && response.data != null) {
      // Update UI state
      notifyListeners();
    }
  }
}
```

### Model Compatibility
All models are designed to work with the existing `SaleModel` and `SaleItemModel`:
- Backend API fields use snake_case (e.g., `customer_name`, `product_id`)
- Frontend models use camelCase (e.g., `customerName`, `productId`)
- JSON serialization handles the conversion automatically

### Error Handling
All services return `ApiResponse<T>` objects with consistent error handling:
```dart
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  
  // Handle both success and error cases uniformly
}
```

### Pagination Support
List endpoints support pagination with `PaginationInfo`:
```dart
class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
}
```

## Benefits

1. **No UI Changes Required**: Existing screens continue to work unchanged
2. **Real API Integration**: Replaces mock data with actual backend calls
3. **Consistent Error Handling**: Uniform error responses across all services
4. **Type Safety**: Strong typing with Dart models
5. **Extensible**: Easy to add new endpoints or modify existing ones
6. **Testable**: Services can be easily mocked for testing

## Next Steps

1. Update existing providers to use these services instead of mock data
2. Add error handling in UI screens to display API errors
3. Implement loading states using the service responses
4. Add offline support with local caching if needed
5. Add authentication headers when user authentication is implemented

The implementation maintains the existing UI/UX while providing robust backend integration that follows Flutter best practices and API design standards.
