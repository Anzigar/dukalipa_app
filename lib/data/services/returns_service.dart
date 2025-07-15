import 'package:dio/dio.dart';
import '../../data/models/api_models.dart';
import '../../data/services/sales_service.dart';

class ReturnsService {
  late final Dio _dio;

  ReturnsService() {
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

  /// Process a new product return
  Future<ApiResponse<ReturnModel>> createReturn({
    required String originalSaleId,
    required String customerName,
    String? customerPhone,
    required List<ReturnItemCreateRequest> items,
    required String refundMethod,
    required String reason,
    String? processedBy,
    String? notes,
  }) async {
    try {
      final requestData = {
        'original_sale_id': originalSaleId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'items': items.map((item) => item.toJson()).toList(),
        'refund_method': refundMethod,
        'reason': reason,
        'processed_by': processedBy,
        'notes': notes,
      };

      final response = await _dio.post('/returns/', data: requestData);
      
      final returnData = response.data['data'];
      return ApiResponse<ReturnModel>(
        success: true,
        data: ReturnModel.fromJson(returnData),
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return ApiResponse<ReturnModel>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      return ApiResponse<ReturnModel>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Get all returns with pagination and filtering
  Future<ApiResponse<SalesListResponse>> getReturns({
    int page = 1,
    int limit = 20,
    String? status,
    String? customerName,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (status != null) queryParams['status'] = status;
      if (customerName != null) queryParams['customer_name'] = customerName;

      final response = await _dio.get('/returns/', queryParameters: queryParams);
      
      return ApiResponse<SalesListResponse>(
        success: true,
        data: SalesListResponse.fromJson(response.data),
      );
    } on DioException catch (e) {
      return ApiResponse<SalesListResponse>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      return ApiResponse<SalesListResponse>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Get a specific return by ID
  Future<ApiResponse<ReturnModel>> getReturn(String returnId) async {
    try {
      final response = await _dio.get('/returns/$returnId');
      
      final returnData = response.data['data'];
      return ApiResponse<ReturnModel>(
        success: true,
        data: ReturnModel.fromJson(returnData),
      );
    } on DioException catch (e) {
      return ApiResponse<ReturnModel>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      return ApiResponse<ReturnModel>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Update a return status or details
  Future<ApiResponse<ReturnModel>> updateReturn(
    String returnId, {
    String? status,
    String? processedBy,
    String? notes,
  }) async {
    try {
      final requestData = <String, dynamic>{};
      
      if (status != null) requestData['status'] = status;
      if (processedBy != null) requestData['processed_by'] = processedBy;
      if (notes != null) requestData['notes'] = notes;

      final response = await _dio.put('/returns/$returnId', data: requestData);
      
      final returnData = response.data['data'];
      return ApiResponse<ReturnModel>(
        success: true,
        data: ReturnModel.fromJson(returnData),
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return ApiResponse<ReturnModel>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      return ApiResponse<ReturnModel>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Get returns analytics
  Future<ApiResponse<Map<String, dynamic>>> getReturnsAnalytics() async {
    try {
      final response = await _dio.get('/returns/analytics/summary');
      
      return ApiResponse<Map<String, dynamic>>(
        success: true,
        data: response.data['data'],
      );
    } on DioException catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }
}

// Helper classes for returns
class ReturnItemCreateRequest {
  final String productId;
  final int quantity;
  final double returnPrice;
  final String reason;

  const ReturnItemCreateRequest({
    required this.productId,
    required this.quantity,
    required this.returnPrice,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'quantity': quantity,
    'return_price': returnPrice,
    'reason': reason,
  };
}

class ReturnModel {
  final String id;
  final String originalSaleId;
  final String customerName;
  final String? customerPhone;
  final List<ReturnItemModel> items;
  final double totalAmount;
  final String refundMethod;
  final String status;
  final String reason;
  final DateTime dateTime;
  final String? processedBy;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReturnModel({
    required this.id,
    required this.originalSaleId,
    required this.customerName,
    this.customerPhone,
    required this.items,
    required this.totalAmount,
    required this.refundMethod,
    required this.status,
    required this.reason,
    required this.dateTime,
    this.processedBy,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReturnModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return ReturnModel(
      id: json['id'] ?? '',
      originalSaleId: json['original_sale_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'],
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => ReturnItemModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      refundMethod: json['refund_method'] ?? '',
      status: json['status'] ?? 'pending',
      reason: json['reason'] ?? '',
      dateTime: json['date_time'] != null 
          ? DateTime.parse(json['date_time'] as String)
          : now,
      processedBy: json['processed_by'],
      notes: json['notes'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : now,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : now,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'original_sale_id': originalSaleId,
    'customer_name': customerName,
    'customer_phone': customerPhone,
    'items': items.map((item) => item.toJson()).toList(),
    'total_amount': totalAmount,
    'refund_method': refundMethod,
    'status': status,
    'reason': reason,
    'date_time': dateTime.toIso8601String(),
    'processed_by': processedBy,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

class ReturnItemModel {
  final String productId;
  final String productName;
  final int quantity;
  final double originalPrice;
  final double returnPrice;
  final double total;
  final String reason;

  const ReturnItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.originalPrice,
    required this.returnPrice,
    required this.total,
    required this.reason,
  });

  factory ReturnItemModel.fromJson(Map<String, dynamic> json) {
    return ReturnItemModel(
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      originalPrice: (json['original_price'] ?? 0).toDouble(),
      returnPrice: (json['return_price'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      reason: json['reason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'product_name': productName,
    'quantity': quantity,
    'original_price': originalPrice,
    'return_price': returnPrice,
    'total': total,
    'reason': reason,
  };
}
