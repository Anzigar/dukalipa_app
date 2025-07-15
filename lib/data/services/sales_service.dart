import 'package:dio/dio.dart';
import '../../data/models/api_models.dart';
import '../../presentation/features/sales/models/sale_model.dart';

class SalesService {
  late final Dio _dio;

  SalesService() {
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

  /// Create a new sale
  Future<ApiResponse<SaleModel>> createSale({
    required String customerName,
    String? customerPhone,
    required List<SaleItemCreateRequest> items,
    double discount = 0.0,
    required String paymentMethod,
    String? note,
    String? createdBy,
  }) async {
    try {
      final requestData = {
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'items': items.map((item) => item.toJson()).toList(),
        'discount': discount,
        'payment_method': paymentMethod,
        'note': note,
        'created_by': createdBy,
      };

      final response = await _dio.post('/sales/', data: requestData);
      
      final saleData = response.data['data'];
      return ApiResponse<SaleModel>(
        success: true,
        data: SaleModel.fromJson(saleData),
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return ApiResponse<SaleModel>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      return ApiResponse<SaleModel>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Get all sales with pagination and filtering
  Future<ApiResponse<SalesListResponse>> getSales({
    int page = 1,
    int limit = 20,
    String? customerName,
    String? status,
    String? paymentMethod,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (customerName != null) queryParams['customer_name'] = customerName;
      if (status != null) queryParams['status'] = status;
      if (paymentMethod != null) queryParams['payment_method'] = paymentMethod;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await _dio.get('/sales/', queryParameters: queryParams);
      
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

  /// Get a specific sale by ID
  Future<ApiResponse<SaleModel>> getSale(String saleId) async {
    try {
      final response = await _dio.get('/sales/$saleId');
      
      final saleData = response.data['data'];
      return ApiResponse<SaleModel>(
        success: true,
        data: SaleModel.fromJson(saleData),
      );
    } on DioException catch (e) {
      return ApiResponse<SaleModel>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      return ApiResponse<SaleModel>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Update a sale
  Future<ApiResponse<SaleModel>> updateSale(
    String saleId, {
    String? customerName,
    String? customerPhone,
    List<SaleItemCreateRequest>? items,
    double? discount,
    String? status,
    String? paymentMethod,
    String? note,
  }) async {
    try {
      final requestData = <String, dynamic>{};
      
      if (customerName != null) requestData['customer_name'] = customerName;
      if (customerPhone != null) requestData['customer_phone'] = customerPhone;
      if (items != null) requestData['items'] = items.map((item) => item.toJson()).toList();
      if (discount != null) requestData['discount'] = discount;
      if (status != null) requestData['status'] = status;
      if (paymentMethod != null) requestData['payment_method'] = paymentMethod;
      if (note != null) requestData['note'] = note;

      final response = await _dio.put('/sales/$saleId', data: requestData);
      
      final saleData = response.data['data'];
      return ApiResponse<SaleModel>(
        success: true,
        data: SaleModel.fromJson(saleData),
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return ApiResponse<SaleModel>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      return ApiResponse<SaleModel>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Delete a sale (soft delete)
  Future<ApiResponse<void>> deleteSale(
    String saleId, {
    required String reason,
    required String deletedBy,
  }) async {
    try {
      final queryParams = {
        'reason': reason,
        'deleted_by': deletedBy,
      };

      final response = await _dio.delete('/sales/$saleId', queryParameters: queryParams);
      
      return ApiResponse<void>(
        success: true,
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return ApiResponse<void>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Get sales analytics
  Future<ApiResponse<Map<String, dynamic>>> getSalesAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await _dio.get('/sales/analytics/summary', queryParameters: queryParams);
      
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

// Helper classes for API requests
class SaleItemCreateRequest {
  final String productId;
  final int quantity;
  final double price;

  const SaleItemCreateRequest({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'quantity': quantity,
    'price': price,
  };
}

class SalesListResponse {
  final String status;
  final SalesData data;

  const SalesListResponse({
    required this.status,
    required this.data,
  });

  factory SalesListResponse.fromJson(Map<String, dynamic> json) {
    return SalesListResponse(
      status: json['status'] ?? 'success',
      data: SalesData.fromJson(json['data']),
    );
  }
}

class SalesData {
  final List<SaleModel> sales;
  final PaginationInfo? pagination;
  final Map<String, dynamic>? summary;

  const SalesData({
    required this.sales,
    this.pagination,
    this.summary,
  });

  factory SalesData.fromJson(Map<String, dynamic> json) {
    return SalesData(
      sales: (json['sales'] as List<dynamic>?)
          ?.map((sale) => SaleModel.fromJson(sale as Map<String, dynamic>))
          .toList() ?? [],
      pagination: json['pagination'] != null 
          ? PaginationInfo.fromJson(json['pagination'])
          : null,
      summary: json['summary'] as Map<String, dynamic>?,
    );
  }
}

class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}
