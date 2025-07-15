import 'package:dio/dio.dart';
import '../../data/models/api_models.dart';
import '../../data/services/sales_service.dart';

class DamagedProductsService {
  late final Dio _dio;

  DamagedProductsService() {
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

  /// Report a new damaged product
  Future<ApiResponse<DamagedProductModel>> reportDamagedProduct({
    required String productId,
    required String productName,
    required int quantity,
    required double originalPrice,
    required double estimatedLoss,
    required String damageType,
    required String severity,
    required String description,
    String? location,
    required String discoveredBy,
    List<String>? images,
    InsuranceClaimInfo? insuranceClaim,
    String? actionTaken,
  }) async {
    try {
      final requestData = {
        'product_id': productId,
        'product_name': productName,
        'quantity': quantity,
        'original_price': originalPrice,
        'estimated_loss': estimatedLoss,
        'damage_type': damageType,
        'severity': severity,
        'description': description,
        'location': location,
        'discovered_by': discoveredBy,
        'images': images,
        'insurance_claim': insuranceClaim?.toJson(),
        'action_taken': actionTaken,
      };

      final response = await _dio.post('/damaged-products/', data: requestData);
      
      final damageData = response.data['data'];
      return ApiResponse<DamagedProductModel>(
        success: true,
        data: DamagedProductModel.fromJson(damageData),
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return ApiResponse<DamagedProductModel>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      return ApiResponse<DamagedProductModel>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Get all damaged products with pagination and filtering
  Future<ApiResponse<SalesListResponse>> getDamagedProducts({
    int page = 1,
    int limit = 20,
    String? status,
    String? damageType,
    String? severity,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (status != null) queryParams['status'] = status;
      if (damageType != null) queryParams['damage_type'] = damageType;
      if (severity != null) queryParams['severity'] = severity;

      final response = await _dio.get('/damaged-products/', queryParameters: queryParams);
      
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

  /// Get a specific damage report by ID
  Future<ApiResponse<DamagedProductModel>> getDamageReport(String damageId) async {
    try {
      final response = await _dio.get('/damaged-products/$damageId');
      
      final damageData = response.data['data'];
      return ApiResponse<DamagedProductModel>(
        success: true,
        data: DamagedProductModel.fromJson(damageData),
      );
    } on DioException catch (e) {
      return ApiResponse<DamagedProductModel>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      return ApiResponse<DamagedProductModel>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Update a damage report
  Future<ApiResponse<DamagedProductModel>> updateDamageReport(
    String damageId, {
    int? quantity,
    double? estimatedLoss,
    String? damageType,
    String? severity,
    String? description,
    String? location,
    List<String>? images,
    String? status,
    InsuranceClaimInfo? insuranceClaim,
    String? actionTaken,
  }) async {
    try {
      final requestData = <String, dynamic>{};
      
      if (quantity != null) requestData['quantity'] = quantity;
      if (estimatedLoss != null) requestData['estimated_loss'] = estimatedLoss;
      if (damageType != null) requestData['damage_type'] = damageType;
      if (severity != null) requestData['severity'] = severity;
      if (description != null) requestData['description'] = description;
      if (location != null) requestData['location'] = location;
      if (images != null) requestData['images'] = images;
      if (status != null) requestData['status'] = status;
      if (insuranceClaim != null) requestData['insurance_claim'] = insuranceClaim.toJson();
      if (actionTaken != null) requestData['action_taken'] = actionTaken;

      final response = await _dio.put('/damaged-products/$damageId', data: requestData);
      
      final damageData = response.data['data'];
      return ApiResponse<DamagedProductModel>(
        success: true,
        data: DamagedProductModel.fromJson(damageData),
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return ApiResponse<DamagedProductModel>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      return ApiResponse<DamagedProductModel>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Get damage analytics
  Future<ApiResponse<Map<String, dynamic>>> getDamageAnalytics() async {
    try {
      final response = await _dio.get('/damaged-products/analytics/summary');
      
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

// Model classes for damaged products
class DamagedProductModel {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double originalPrice;
  final double estimatedLoss;
  final String damageType;
  final String severity;
  final String description;
  final String? location;
  final String discoveredBy;
  final DateTime dateDiscovered;
  final List<String> images;
  final String status;
  final InsuranceClaimInfo? insuranceClaim;
  final String? actionTaken;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DamagedProductModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.originalPrice,
    required this.estimatedLoss,
    required this.damageType,
    required this.severity,
    required this.description,
    this.location,
    required this.discoveredBy,
    required this.dateDiscovered,
    required this.images,
    required this.status,
    this.insuranceClaim,
    this.actionTaken,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DamagedProductModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return DamagedProductModel(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      originalPrice: (json['original_price'] ?? 0).toDouble(),
      estimatedLoss: (json['estimated_loss'] ?? 0).toDouble(),
      damageType: json['damage_type'] ?? '',
      severity: json['severity'] ?? '',
      description: json['description'] ?? '',
      location: json['location'],
      discoveredBy: json['discovered_by'] ?? '',
      dateDiscovered: json['date_discovered'] != null 
          ? DateTime.parse(json['date_discovered'] as String)
          : now,
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      status: json['status'] ?? 'reported',
      insuranceClaim: json['insurance_claim'] != null 
          ? InsuranceClaimInfo.fromJson(json['insurance_claim'])
          : null,
      actionTaken: json['action_taken'],
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
    'product_id': productId,
    'product_name': productName,
    'quantity': quantity,
    'original_price': originalPrice,
    'estimated_loss': estimatedLoss,
    'damage_type': damageType,
    'severity': severity,
    'description': description,
    'location': location,
    'discovered_by': discoveredBy,
    'date_discovered': dateDiscovered.toIso8601String(),
    'images': images,
    'status': status,
    'insurance_claim': insuranceClaim?.toJson(),
    'action_taken': actionTaken,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

class InsuranceClaimInfo {
  final String claimNumber;
  final double claimAmount;
  final String status;

  const InsuranceClaimInfo({
    required this.claimNumber,
    required this.claimAmount,
    required this.status,
  });

  factory InsuranceClaimInfo.fromJson(Map<String, dynamic> json) {
    return InsuranceClaimInfo(
      claimNumber: json['claim_number'] ?? '',
      claimAmount: (json['claim_amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() => {
    'claim_number': claimNumber,
    'claim_amount': claimAmount,
    'status': status,
  };
}
