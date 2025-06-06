import 'dart:io';

import '../../../../core/network/api_client.dart';
import '../models/expense_model.dart';

abstract class ExpensesRepository {
  /// Get expenses with optional filtering
  Future<List<ExpenseModel>> getExpenses({
    String? search,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get expense by ID
  Future<ExpenseModel> getExpenseById(String id);

  /// Add a new expense
  Future<ExpenseModel> addExpense({
    required double amount,
    required String description,
    required String category,
    required DateTime date,
    String? paymentMethod,
    File? receiptImage,
  });

  /// Delete an expense
  Future<void> deleteExpense(String id);

  /// Get expense statistics
  Future<Map<String, dynamic>> getExpenseStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });
}

class ExpensesRepositoryImpl implements ExpensesRepository {
  final ApiClient _apiClient;

  ExpensesRepositoryImpl(this._apiClient);

  @override
  Future<List<ExpenseModel>> getExpenses({
    String? search,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (category != null) {
        queryParams['category'] = category;
      }
      
      if (startDate != null) {
        queryParams['start_date'] = formatDateForApi(startDate);
      }
      
      if (endDate != null) {
        queryParams['end_date'] = formatDateForApi(endDate);
      }

      final response = await _apiClient.get('/expenses', queryParameters: queryParams);
      
      final List<dynamic> expensesJson = response['data'];
      return expensesJson.map((json) => ExpenseModel.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ExpenseModel> getExpenseById(String id) async {
    try {
      final response = await _apiClient.get('/expenses/$id');
      return ExpenseModel.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ExpenseModel> addExpense({
    required double amount,
    required String description,
    required String category,
    required DateTime date,
    String? paymentMethod,
    File? receiptImage,
  }) async {
    try {
      // Handle file upload if receipt image is provided
      String? receiptUrl;
      if (receiptImage != null) {
        final uploadResponse = await _apiClient.uploadFile(
          '/uploads/receipts',
          receiptImage,
          fieldName: 'receipt',
        );
        receiptUrl = uploadResponse['data']['url'];
      }

      final data = {
        'amount': amount,
        'description': description,
        'category': category,
        'date': formatDateForApi(date),
        if (paymentMethod != null) 'payment_method': paymentMethod,
        if (receiptUrl != null) 'receipt': receiptUrl,
      };

      final response = await _apiClient.post('/expenses', data: data);
      return ExpenseModel.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      await _apiClient.delete('/expenses/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getExpenseStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (startDate != null) {
        queryParams['start_date'] = formatDateForApi(startDate);
      }
      
      if (endDate != null) {
        queryParams['end_date'] = formatDateForApi(endDate);
      }

      final response = await _apiClient.get('/expenses/statistics', queryParameters: queryParams);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Helper function to handle errors
  Exception _handleError(dynamic error) {
    // You can add more specific error handling here
    return Exception('Failed to perform operation: ${error.toString()}');
  }

  // Helper function to format date for API
  String formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
