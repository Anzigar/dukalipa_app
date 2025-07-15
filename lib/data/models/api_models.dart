/// API response wrapper for consistent response handling
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error(String error, {int? statusCode}) {
    return ApiResponse(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      message: json['message'],
      error: json['error'],
      statusCode: json['status_code'],
    );
  }

  Map<String, dynamic> toJson(dynamic Function(T) toJsonT) {
    return {
      'success': success,
      'data': data != null ? toJsonT(data as T) : null,
      'message': message,
      'error': error,
      'status_code': statusCode,
    };
  }
}

/// Paginated API response for list endpoints
class PaginatedResponse<T> {
  final List<T> data;
  final bool hasNextPage;
  final bool hasPrevPage;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;

  const PaginatedResponse({
    required this.data,
    required this.hasNextPage,
    required this.hasPrevPage,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return PaginatedResponse(
      data: (json['data'] as List?)?.map(fromJsonT).toList() ?? [],
      hasNextPage: json['has_next_page'] ?? false,
      hasPrevPage: json['has_prev_page'] ?? false,
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
      totalItems: json['total_items'] ?? 0,
      pageSize: json['page_size'] ?? 10,
    );
  }

  Map<String, dynamic> toJson(dynamic Function(T) toJsonT) {
    return {
      'data': data.map(toJsonT).toList(),
      'has_next_page': hasNextPage,
      'has_prev_page': hasPrevPage,
      'current_page': currentPage,
      'total_pages': totalPages,
      'total_items': totalItems,
      'page_size': pageSize,
    };
  }
}

/// Create/Update product request model
class ProductRequest {
  final String name;
  final String? description;
  final String? barcode;
  final double sellingPrice;
  final double costPrice;
  final int quantity;
  final int lowStockThreshold;
  final int? reorderLevel;
  final String? category;
  final String? supplier;
  final Map<String, dynamic>? metadata;

  const ProductRequest({
    required this.name,
    this.description,
    this.barcode,
    required this.sellingPrice,
    required this.costPrice,
    required this.quantity,
    required this.lowStockThreshold,
    this.reorderLevel,
    this.category,
    this.supplier,
    this.metadata,
  });

  factory ProductRequest.fromJson(Map<String, dynamic> json) {
    return ProductRequest(
      name: json['name'] ?? '',
      description: json['description'],
      barcode: json['barcode'],
      sellingPrice: (json['selling_price'] ?? 0).toDouble(),
      costPrice: (json['cost_price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      lowStockThreshold: json['low_stock_threshold'] ?? 0,
      reorderLevel: json['reorder_level'],
      category: json['category'],
      supplier: json['supplier'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'barcode': barcode,
      'selling_price': sellingPrice,
      'cost_price': costPrice,
      'quantity': quantity,
      'low_stock_threshold': lowStockThreshold,
      'reorder_level': reorderLevel,
      'category': category,
      'supplier': supplier,
      'product_metadata': metadata,
    };
  }
}
