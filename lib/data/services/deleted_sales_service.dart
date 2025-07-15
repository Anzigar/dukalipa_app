import 'package:dio/dio.dart';
import '../../data/models/api_models.dart';
import '../../data/services/sales_service.dart';
import '../../presentation/features/sales/models/sale_model.dart';

class DeletedSalesService {
  late final Dio _dio;

  DeletedSalesService() {
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

  /// Get all deleted sales with pagination
  Future<ApiResponse<SalesListResponse>> getDeletedSales({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      final response = await _dio.get('/sales/deleted/', queryParameters: queryParams);
      
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

  /// Restore a deleted sale back to active sales
  Future<ApiResponse<void>> restoreDeletedSale(String deletedSaleId) async {
    try {
      final response = await _dio.post('/sales/deleted/$deletedSaleId/restore');
      
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
}

class DeletedSaleModel {
  final String id;
  final String originalSaleId;
  final SaleModel saleData;
  final String reason;
  final String deletedBy;
  final DateTime deletedAt;
  final String? notes;
  final bool canRestore;

  const DeletedSaleModel({
    required this.id,
    required this.originalSaleId,
    required this.saleData,
    required this.reason,
    required this.deletedBy,
    required this.deletedAt,
    this.notes,
    required this.canRestore,
  });

  factory DeletedSaleModel.fromJson(Map<String, dynamic> json) {
    return DeletedSaleModel(
      id: json['id'] ?? '',
      originalSaleId: json['original_sale_id'] ?? '',
      saleData: SaleModel.fromJson(json['sale_data'] ?? {}),
      reason: json['reason'] ?? '',
      deletedBy: json['deleted_by'] ?? '',
      deletedAt: json['deleted_at'] != null 
          ? DateTime.parse(json['deleted_at'] as String)
          : DateTime.now(),
      notes: json['notes'],
      canRestore: json['can_restore'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'original_sale_id': originalSaleId,
    'sale_data': saleData.toJson(),
    'reason': reason,
    'deleted_by': deletedBy,
    'deleted_at': deletedAt.toIso8601String(),
    'notes': notes,
    'can_restore': canRestore,
  };
}
