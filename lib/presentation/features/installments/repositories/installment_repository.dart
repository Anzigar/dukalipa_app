import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import '../models/installment_model.dart';
import '../../clients/models/client_model.dart';
import '../models/installment_payment_model.dart';

/// Interface defining operations for installment plans
abstract class InstallmentRepository {
  /// Fetches a list of installments with optional filtering
  Future<List<InstallmentModel>> getInstallments({
    String? search,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Fetches a specific installment by ID
  Future<InstallmentModel> getInstallmentById(String id);

  /// Creates a new installment plan
  Future<InstallmentModel> createInstallment({
    required ClientModel client,
    required double totalAmount,
    required double downPayment,
    required DateTime startDate,
    required DateTime dueDate,
    required List<String> productIds,
    required List<String> productNames,
    String? notes,
  });

  /// Adds a payment to an existing installment
  Future<InstallmentModel> addPayment({
    required String installmentId,
    required double amount,
    required DateTime date,
    String? note,
  });

  /// Updates an existing installment
  Future<InstallmentModel> updateInstallment({
    required String id,
    double? totalAmount,
    double? downPayment,
    DateTime? dueDate,
    String? status,
    String? notes,
  });

  /// Gets all payments for a specific installment
  Future<List<InstallmentPaymentModel>> getInstallmentPayments(String installmentId);

  /// Adds a payment to an installment
  Future<InstallmentPaymentModel> addInstallmentPayment({
    required String installmentId,
    required double amount,
    required String paymentMethod,
    DateTime? paymentDate,
    String? receiptNumber,
    String? notes,
  });

  /// Updates the status of an installment
  Future<InstallmentModel> updateInstallmentStatus(String id, String status);

  /// Deletes an installment
  Future<void> deleteInstallment(String id);
}

class InstallmentRepositoryImpl implements InstallmentRepository {
  final Dio _dio;
  final Uuid _uuid = const Uuid();

  InstallmentRepositoryImpl() : _dio = Dio(BaseOptions(
    baseUrl: 'http://127.0.0.1:8000/api/v1',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));
  
  @override
  Future<List<InstallmentModel>> getInstallments({
    String? search,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      
      if (startDate != null) {
        queryParams['start_date'] = formatDateForApi(startDate);
      }
      
      if (endDate != null) {
        queryParams['end_date'] = formatDateForApi(endDate);
      }
      
      final response = await _dio.get('/installments', queryParameters: queryParams);
      final List<dynamic> data = response.data['data'] ?? [];
      
      return data.map((item) => InstallmentModel.fromJson(item)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<InstallmentModel> getInstallmentById(String id) async {
    try {
      final response = await _dio.get('/installments/$id');
      return InstallmentModel.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<InstallmentModel> createInstallment({
    required ClientModel client,
    required double totalAmount,
    required double downPayment,
    required DateTime startDate,
    required DateTime dueDate,
    required List<String> productIds,
    required List<String> productNames,
    String? notes,
  }) async {
    try {
      // Generate an initial payment for the down payment
      final paymentId = _uuid.v4();
      final initialPayment = {
        'id': paymentId,
        'amount': downPayment,
        'date': DateTime.now().toIso8601String(),
        'payment_method': 'cash', // Default to cash
        'receipt_number': null,
        'notes': 'Initial down payment',
      };
      
      final data = {
        'client_id': client.id,
        'client_name': client.name,
        'client_phone': client.phoneNumber,
        'client_email': client.email,
        'client_address': client.address,
        'total_amount': totalAmount,
        'down_payment': downPayment,
        'remaining_amount': totalAmount - downPayment,
        'payments': [initialPayment],
        'start_date': startDate.toIso8601String(),
        'due_date': dueDate.toIso8601String(),
        'status': 'active',
        'product_ids': productIds,
        'product_names': productNames,
        'notes': notes,
      };
      
      final response = await _dio.post('/installments', data: data);
      return InstallmentModel.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<InstallmentModel> addPayment({
    required String installmentId,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    try {
      final data = {
        'amount': amount,
        'date': date.toIso8601String(),
        'note': note,
      };
      
      final response = await _dio.post(
        '/installments/$installmentId/payments',
        data: data,
      );
      
      return InstallmentModel.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<InstallmentModel> updateInstallment({
    required String id,
    double? totalAmount,
    double? downPayment,
    DateTime? dueDate,
    String? status,
    String? notes,
  }) async {
    try {
      final data = {
        'status': status,
        if (notes != null) 'notes': notes,
        if (totalAmount != null) 'total_amount': totalAmount,
        if (downPayment != null) 'down_payment': downPayment,
        if (dueDate != null) 'due_date': dueDate.toIso8601String(),
      };
      
      final response = await _dio.patch('/installments/$id', data: data);
      return InstallmentModel.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<List<InstallmentPaymentModel>> getInstallmentPayments(String installmentId) async {
    try {
      final response = await _dio.get('/installments/$installmentId/payments');
      final List<dynamic> data = response.data['data'] ?? [];
      
      return data.map((item) => InstallmentPaymentModel.fromJson(item)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<InstallmentPaymentModel> addInstallmentPayment({
    required String installmentId,
    required double amount,
    required String paymentMethod,
    DateTime? paymentDate,
    String? receiptNumber,
    String? notes,
  }) async {
    try {
      final data = {
        'amount': amount,
        'payment_method': paymentMethod,
        'payment_date': paymentDate?.toIso8601String(),
        'receipt_number': receiptNumber,
        'notes': notes,
      };
      
      final response = await _dio.post(
        '/installments/$installmentId/payments',
        data: data,
      );
      
      return InstallmentPaymentModel.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<InstallmentModel> updateInstallmentStatus(String id, String status) async {
    try {
      final data = {
        'status': status,
      };
      
      final response = await _dio.patch('/installments/$id', data: data);
      return InstallmentModel.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<void> deleteInstallment(String id) async {
    try {
      await _dio.delete('/installments/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Helper methods
  String formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      return Exception('Failed to process installment operation: ${error.message}');
    }
    if (error is Exception) {
      return Exception('Failed to process installment operation: ${error.toString()}');
    }
    return Exception('Failed to process installment operation: $error');
  }
}
