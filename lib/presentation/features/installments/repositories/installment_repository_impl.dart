import 'dart:async';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../clients/models/client_model.dart';
import '../models/installment_model.dart';
import '../models/installment_payment_model.dart';
import 'installment_repository.dart';

class InstallmentRepositoryImpl implements InstallmentRepository {
  late final Dio _dio;
  final Uuid _uuid = const Uuid();

  InstallmentRepositoryImpl() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api/v1',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }

  @override
  Future<void> deleteInstallment(String id) async {
    try {
      await _dio.delete('/installments/$id');
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
      final List<dynamic> installmentsJson = response.data['data'] ?? [];
      return installmentsJson.map((json) => InstallmentModel.fromJson(json)).toList();
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
        'installment_id': installmentId,
        'amount': amount,
        'payment_method': paymentMethod,
        'payment_date': paymentDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
        if (receiptNumber != null) 'receipt_number': receiptNumber,
        if (notes != null) 'notes': notes,
      };

      final response = await _dio.post('/installments/$installmentId/payments', data: data);
      return InstallmentPaymentModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to add payment: ${e.toString()}');
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
      final data = <String, dynamic>{};
      
      if (totalAmount != null) data['total_amount'] = totalAmount;
      if (downPayment != null) data['down_payment'] = downPayment;
      if (dueDate != null) data['due_date'] = dueDate.toIso8601String();
      if (status != null) data['status'] = status;
      if (notes != null) data['notes'] = notes;
      
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
      final List<dynamic> paymentsJson = response.data['data'] ?? [];
      return paymentsJson.map((json) => InstallmentPaymentModel.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Helper function to handle errors
  Exception _handleError(dynamic e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return Exception('Network error. Please check your internet connection.');
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          if (statusCode == 404) {
            return Exception('Installment not found.');
          }
          if (statusCode == 401 || statusCode == 403) {
            return Exception('Authentication error. Please login again.');
          }
          return Exception('Server error: ${e.response?.statusMessage}');
        default:
          return Exception('An error occurred: ${e.message}');
      }
    }
    
    return Exception('An error occurred: ${e.toString()}');
  }

  // Helper function to format date for API
  String formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
