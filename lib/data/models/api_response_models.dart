/// Standard response wrapper for all API responses
class StandardResponse {
  final String status;
  final String? message;
  final dynamic data;

  StandardResponse({
    required this.status,
    this.message,
    this.data,
  });

  factory StandardResponse.fromJson(Map<String, dynamic> json) {
    return StandardResponse(
      status: json['status'] as String,
      message: json['message'] as String?,
      data: json['data'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
    };
  }
}

/// Product response model
class ProductResponse {
  final String name;
  final String? description;
  final String sku;
  final String? barcode;
  final String? category;
  final String? supplier;
  final double costPrice;
  final double sellingPrice;
  final int stockQuantity;
  final int lowStockThreshold;
  final String? unitOfMeasure;
  final double? weight;
  final String? dimensions;
  final DateTime? expiryDate;
  final String? batchNumber;
  final String? location;
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductResponse({
    required this.name,
    this.description,
    required this.sku,
    this.barcode,
    this.category,
    this.supplier,
    required this.costPrice,
    required this.sellingPrice,
    required this.stockQuantity,
    required this.lowStockThreshold,
    this.unitOfMeasure,
    this.weight,
    this.dimensions,
    this.expiryDate,
    this.batchNumber,
    this.location,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      name: json['name'] as String,
      description: json['description'] as String?,
      sku: json['sku'] as String,
      barcode: json['barcode'] as String?,
      category: json['category'] as String?,
      supplier: json['supplier'] as String?,
      costPrice: (json['cost_price'] as num).toDouble(),
      sellingPrice: (json['selling_price'] as num).toDouble(),
      stockQuantity: json['stock_quantity'] as int,
      lowStockThreshold: json['low_stock_threshold'] as int,
      unitOfMeasure: json['unit_of_measure'] as String?,
      weight: json['weight'] as double?,
      dimensions: json['dimensions'] as String?,
      expiryDate: json['expiry_date'] != null ? DateTime.parse(json['expiry_date']) : null,
      batchNumber: json['batch_number'] as String?,
      location: json['location'] as String?,
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'sku': sku,
      'barcode': barcode,
      'category': category,
      'supplier': supplier,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'stock_quantity': stockQuantity,
      'low_stock_threshold': lowStockThreshold,
      'unit_of_measure': unitOfMeasure,
      'weight': weight,
      'dimensions': dimensions,
      'expiry_date': expiryDate?.toIso8601String(),
      'batch_number': batchNumber,
      'location': location,
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Sales list response model
class SalesListResponse {
  final String status;
  final Map<String, dynamic> data;

  SalesListResponse({
    required this.status,
    required this.data,
  });

  factory SalesListResponse.fromJson(Map<String, dynamic> json) {
    return SalesListResponse(
      status: json['status'] as String,
      data: json['data'] as Map<String, dynamic>,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data,
    };
  }
}

/// Expenses list response model
class ExpensesListResponse {
  final String status;
  final Map<String, dynamic> data;

  ExpensesListResponse({
    required this.status,
    required this.data,
  });

  factory ExpensesListResponse.fromJson(Map<String, dynamic> json) {
    return ExpensesListResponse(
      status: json['status'] as String,
      data: json['data'] as Map<String, dynamic>,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data,
    };
  }
}

/// Damaged products list response model
class DamagedProductsListResponse {
  final String status;
  final Map<String, dynamic> data;

  DamagedProductsListResponse({
    required this.status,
    required this.data,
  });

  factory DamagedProductsListResponse.fromJson(Map<String, dynamic> json) {
    return DamagedProductsListResponse(
      status: json['status'] as String,
      data: json['data'] as Map<String, dynamic>,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data,
    };
  }
}

/// Deleted sales list response model
class DeletedSalesListResponse {
  final String status;
  final Map<String, dynamic> data;

  DeletedSalesListResponse({
    required this.status,
    required this.data,
  });

  factory DeletedSalesListResponse.fromJson(Map<String, dynamic> json) {
    return DeletedSalesListResponse(
      status: json['status'] as String,
      data: json['data'] as Map<String, dynamic>,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data,
    };
  }
}

/// Deleted sale item response model
class DeletedSaleItemResponse {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final double total;

  DeletedSaleItemResponse({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory DeletedSaleItemResponse.fromJson(Map<String, dynamic> json) {
    return DeletedSaleItemResponse(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }
}

/// Deleted sale response model
class DeletedSaleResponse {
  final String id;
  final String originalSaleId;
  final String customerName;
  final String? customerPhone;
  final List<DeletedSaleItemResponse> items;
  final double totalAmount;
  final double discount;
  final String paymentMethod;
  final String reason;
  final String deletedBy;
  final DateTime deletedAt;
  final DateTime originalDate;

  DeletedSaleResponse({
    required this.id,
    required this.originalSaleId,
    required this.customerName,
    this.customerPhone,
    required this.items,
    required this.totalAmount,
    required this.discount,
    required this.paymentMethod,
    required this.reason,
    required this.deletedBy,
    required this.deletedAt,
    required this.originalDate,
  });

  factory DeletedSaleResponse.fromJson(Map<String, dynamic> json) {
    return DeletedSaleResponse(
      id: json['id'] as String,
      originalSaleId: json['original_sale_id'] as String,
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String?,
      items: (json['items'] as List).map((e) => DeletedSaleItemResponse.fromJson(e)).toList(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
      reason: json['reason'] as String,
      deletedBy: json['deleted_by'] as String,
      deletedAt: DateTime.parse(json['deleted_at'] as String),
      originalDate: DateTime.parse(json['original_date'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'original_sale_id': originalSaleId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'items': items.map((e) => e.toJson()).toList(),
      'total_amount': totalAmount,
      'discount': discount,
      'payment_method': paymentMethod,
      'reason': reason,
      'deleted_by': deletedBy,
      'deleted_at': deletedAt.toIso8601String(),
      'original_date': originalDate.toIso8601String(),
    };
  }
}

/// HTTP validation error detail model
class ValidationError {
  final List<dynamic> loc;
  final String msg;
  final String type;

  ValidationError({
    required this.loc,
    required this.msg,
    required this.type,
  });

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      loc: json['loc'] as List<dynamic>,
      msg: json['msg'] as String,
      type: json['type'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'loc': loc,
      'msg': msg,
      'type': type,
    };
  }
}

/// HTTP validation error response model
class HTTPValidationError {
  final List<ValidationError> detail;

  HTTPValidationError({
    required this.detail,
  });

  factory HTTPValidationError.fromJson(Map<String, dynamic> json) {
    return HTTPValidationError(
      detail: (json['detail'] as List).map((e) => ValidationError.fromJson(e)).toList(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'detail': detail.map((e) => e.toJson()).toList(),
    };
  }
}

/// Paginated response model
class PaginatedResponse<T> {
  final List<T> results;
  final int count;
  final String? next;
  final String? previous;

  PaginatedResponse({
    required this.results,
    required this.count,
    this.next,
    this.previous,
  });

  factory PaginatedResponse.fromJson(Map<String, dynamic> json, T Function(dynamic json) fromJsonT) {
    return PaginatedResponse<T>(
      results: (json['results'] as List).map((e) => fromJsonT(e)).toList(),
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
    );
  }
  
  Map<String, dynamic> toJson(dynamic Function(T value) toJsonT) {
    return {
      'results': results.map((e) => toJsonT(e)).toList(),
      'count': count,
      'next': next,
      'previous': previous,
    };
  }
}

/// API endpoint response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  final dynamic errors;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.errors,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic json) fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      message: json['message'] as String?,
      statusCode: json['status_code'] as int?,
      errors: json['errors'],
    );
  }
  
  Map<String, dynamic> toJson(dynamic Function(T value) toJsonT) {
    return {
      'success': success,
      'data': data != null ? toJsonT(data as T) : null,
      'message': message,
      'status_code': statusCode,
      'errors': errors,
    };
  }
}

/// Generic list response model
class ListResponse<T> {
  final String status;
  final List<T> data;
  final int? total;
  final int? page;
  final int? pageSize;
  final int? totalPages;

  ListResponse({
    required this.status,
    required this.data,
    this.total,
    this.page,
    this.pageSize,
    this.totalPages,
  });

  factory ListResponse.fromJson(Map<String, dynamic> json, T Function(dynamic json) fromJsonT) {
    return ListResponse<T>(
      status: json['status'] as String,
      data: (json['data'] as List).map((e) => fromJsonT(e)).toList(),
      total: json['total'] as int?,
      page: json['page'] as int?,
      pageSize: json['page_size'] as int?,
      totalPages: json['total_pages'] as int?,
    );
  }
  
  Map<String, dynamic> toJson(dynamic Function(T value) toJsonT) {
    return {
      'status': status,
      'data': data.map((e) => toJsonT(e)).toList(),
      'total': total,
      'page': page,
      'page_size': pageSize,
      'total_pages': totalPages,
    };
  }
}

/// Analytics response model
class AnalyticsResponse {
  final String status;
  final Map<String, dynamic> data;

  AnalyticsResponse({
    required this.status,
    required this.data,
  });

  factory AnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return AnalyticsResponse(
      status: json['status'] as String,
      data: json['data'] as Map<String, dynamic>,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data,
    };
  }
}

/// Dashboard data response model
class DashboardResponse {
  final String status;
  final Map<String, dynamic> data;

  DashboardResponse({
    required this.status,
    required this.data,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      status: json['status'] as String,
      data: json['data'] as Map<String, dynamic>,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data,
    };
  }
}
