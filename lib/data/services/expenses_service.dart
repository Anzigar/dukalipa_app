import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../../data/models/api_models.dart';

class ExpensesService {
  late final Dio _dio;

  ExpensesService() {
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

  /// Create a new expense record
  Future<ApiResponse<ExpenseModel>> createExpense({
    required String category,
    String? subcategory,
    required String title,
    String? description,
    required double amount,
    String currency = 'TZS',
    required DateTime date,
    required String paymentMethod,
    VendorInfo? vendor,
    String? receiptNumber,
    String? approvedBy,
    List<String>? tags,
    List<AttachmentInfo>? attachments,
    bool isRecurring = false,
    RecurringPatternInfo? recurringPattern,
    String? budgetCategory,
    required String createdBy,
  }) async {
    try {
      final requestData = {
        'category': category,
        'subcategory': subcategory,
        'title': title,
        'description': description,
        'amount': amount,
        'currency': currency,
        'date': date.toIso8601String(),
        'payment_method': paymentMethod,
        'vendor': vendor?.toJson(),
        'receipt_number': receiptNumber,
        'approved_by': approvedBy,
        'tags': tags,
        'attachments': attachments?.map((a) => a.toJson()).toList(),
        'is_recurring': isRecurring,
        'recurring_pattern': recurringPattern?.toJson(),
        'budget_category': budgetCategory,
        'created_by': createdBy,
      };

      final response = await _dio.post('/expenses/', data: requestData);
      
      final expenseData = response.data['data'];
      return ApiResponse<ExpenseModel>(
        success: true,
        data: ExpenseModel.fromJson(expenseData),
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return ApiResponse<ExpenseModel>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      return ApiResponse<ExpenseModel>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Get all expenses with pagination and filtering
  Future<ApiResponse<List<ExpenseModel>>> getExpenses({
    int page = 1,
    int limit = 20,
    String? category,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (category != null) queryParams['category'] = category;
      if (status != null) queryParams['status'] = status;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await _dio.get('/expenses/', queryParameters: queryParams);
      
      // Parse the response according to the API documentation structure
      if (response.data['status'] == 'success' && response.data['data'] != null) {
        final expensesData = response.data['data'];
        List<ExpenseModel> expenses = [];
        
        // Handle if data is a list or contains a list
        if (expensesData is List) {
          expenses = expensesData.map((item) => ExpenseModel.fromJson(item)).toList();
        } else if (expensesData is Map && expensesData['expenses'] != null) {
          expenses = (expensesData['expenses'] as List)
              .map((item) => ExpenseModel.fromJson(item))
              .toList();
        }
        
        return ApiResponse<List<ExpenseModel>>(
          success: true,
          data: expenses,
        );
      } else {
        return ApiResponse<List<ExpenseModel>>(
          success: false,
          message: response.data['message'] ?? 'Failed to load expenses',
        );
      }
    } on DioException catch (e) {
      return ApiResponse<List<ExpenseModel>>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      return ApiResponse<List<ExpenseModel>>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Get a specific expense by ID
  Future<ApiResponse<ExpenseModel>> getExpense(String expenseId) async {
    try {
      final response = await _dio.get('/expenses/$expenseId');
      
      final expenseData = response.data['data'];
      return ApiResponse<ExpenseModel>(
        success: true,
        data: ExpenseModel.fromJson(expenseData),
      );
    } on DioException catch (e) {
      return ApiResponse<ExpenseModel>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      return ApiResponse<ExpenseModel>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Update an expense record
  Future<ApiResponse<ExpenseModel>> updateExpense(
    String expenseId, {
    String? category,
    String? subcategory,
    String? title,
    String? description,
    double? amount,
    String? currency,
    DateTime? date,
    String? paymentMethod,
    VendorInfo? vendor,
    String? receiptNumber,
    String? status,
    String? approvedBy,
    DateTime? approvalDate,
    List<String>? tags,
    List<AttachmentInfo>? attachments,
    bool? isRecurring,
    RecurringPatternInfo? recurringPattern,
    String? budgetCategory,
  }) async {
    try {
      final requestData = <String, dynamic>{};
      
      if (category != null) requestData['category'] = category;
      if (subcategory != null) requestData['subcategory'] = subcategory;
      if (title != null) requestData['title'] = title;
      if (description != null) requestData['description'] = description;
      if (amount != null) requestData['amount'] = amount;
      if (currency != null) requestData['currency'] = currency;
      if (date != null) requestData['date'] = date.toIso8601String();
      if (paymentMethod != null) requestData['payment_method'] = paymentMethod;
      if (vendor != null) requestData['vendor'] = vendor.toJson();
      if (receiptNumber != null) requestData['receipt_number'] = receiptNumber;
      if (status != null) requestData['status'] = status;
      if (approvedBy != null) requestData['approved_by'] = approvedBy;
      if (approvalDate != null) requestData['approval_date'] = approvalDate.toIso8601String();
      if (tags != null) requestData['tags'] = tags;
      if (attachments != null) requestData['attachments'] = attachments.map((a) => a.toJson()).toList();
      if (isRecurring != null) requestData['is_recurring'] = isRecurring;
      if (recurringPattern != null) requestData['recurring_pattern'] = recurringPattern.toJson();
      if (budgetCategory != null) requestData['budget_category'] = budgetCategory;

      final response = await _dio.put('/expenses/$expenseId', data: requestData);
      
      final expenseData = response.data['data'];
      return ApiResponse<ExpenseModel>(
        success: true,
        data: ExpenseModel.fromJson(expenseData),
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return ApiResponse<ExpenseModel>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      return ApiResponse<ExpenseModel>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Delete an expense record
  Future<ApiResponse<void>> deleteExpense(String expenseId) async {
    try {
      final response = await _dio.delete('/expenses/$expenseId');
      
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

  /// Get all available expense categories
  Future<ApiResponse<List<String>>> getExpenseCategories() async {
    try {
      final response = await _dio.get('/expenses/categories/list');
      
      final categories = (response.data['data'] as List<dynamic>?)?.cast<String>() ?? [];
      return ApiResponse<List<String>>(
        success: true,
        data: categories,
      );
    } on DioException catch (e) {
      return ApiResponse<List<String>>(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      return ApiResponse<List<String>>(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Get comprehensive expense analytics and summary
  Future<ApiResponse<Map<String, dynamic>>> getExpenseSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await _dio.get('/expenses/summary/analytics', queryParameters: queryParams);
      
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

// Model classes for expenses
class ExpenseModel {
  final String id;
  final String category;
  final String? subcategory;
  final String title;
  final String? description;
  final double amount;
  final String currency;
  final DateTime date;
  final String paymentMethod;
  final VendorInfo? vendor;
  final String? receiptNumber;
  final String status;
  final String? approvedBy;
  final DateTime? approvalDate;
  final List<String> tags;
  final List<AttachmentInfo> attachments;
  final bool isRecurring;
  final RecurringPatternInfo? recurringPattern;
  final String? budgetCategory;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseModel({
    required this.id,
    required this.category,
    this.subcategory,
    required this.title,
    this.description,
    required this.amount,
    required this.currency,
    required this.date,
    required this.paymentMethod,
    this.vendor,
    this.receiptNumber,
    required this.status,
    this.approvedBy,
    this.approvalDate,
    required this.tags,
    required this.attachments,
    required this.isRecurring,
    this.recurringPattern,
    this.budgetCategory,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return ExpenseModel(
      id: json['id'] ?? '',
      category: json['category'] ?? '',
      subcategory: json['subcategory'],
      title: json['title'] ?? '',
      description: json['description'],
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'TZS',
      date: json['date'] != null 
          ? DateTime.parse(json['date'] as String)
          : now,
      paymentMethod: json['payment_method'] ?? '',
      vendor: json['vendor'] != null 
          ? VendorInfo.fromJson(json['vendor'])
          : null,
      receiptNumber: json['receipt_number'],
      status: json['status'] ?? 'pending',
      approvedBy: json['approved_by'],
      approvalDate: json['approval_date'] != null 
          ? DateTime.parse(json['approval_date'] as String)
          : null,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((a) => AttachmentInfo.fromJson(a as Map<String, dynamic>))
          .toList() ?? [],
      isRecurring: json['is_recurring'] ?? false,
      recurringPattern: json['recurring_pattern'] != null 
          ? RecurringPatternInfo.fromJson(json['recurring_pattern'])
          : null,
      budgetCategory: json['budget_category'],
      createdBy: json['created_by'] ?? '',
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
    'category': category,
    'subcategory': subcategory,
    'title': title,
    'description': description,
    'amount': amount,
    'currency': currency,
    'date': date.toIso8601String(),
    'payment_method': paymentMethod,
    'vendor': vendor?.toJson(),
    'receipt_number': receiptNumber,
    'status': status,
    'approved_by': approvedBy,
    'approval_date': approvalDate?.toIso8601String(),
    'tags': tags,
    'attachments': attachments.map((a) => a.toJson()).toList(),
    'is_recurring': isRecurring,
    'recurring_pattern': recurringPattern?.toJson(),
    'budget_category': budgetCategory,
    'created_by': createdBy,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  // Formatted getters
  String get formattedAmount => 'TSh ${amount.toStringAsFixed(0)}';
  
  String get formattedDate => DateFormat('dd MMM yyyy').format(date);
  
  String get monthYear => DateFormat('MMMM yyyy').format(date);
}

class VendorInfo {
  final String name;
  final String? phone;
  final String? email;

  const VendorInfo({
    required this.name,
    this.phone,
    this.email,
  });

  factory VendorInfo.fromJson(Map<String, dynamic> json) {
    return VendorInfo(
      name: json['name'] ?? '',
      phone: json['phone'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'email': email,
  };
}

class AttachmentInfo {
  final String type;
  final String url;
  final String filename;

  const AttachmentInfo({
    required this.type,
    required this.url,
    required this.filename,
  });

  factory AttachmentInfo.fromJson(Map<String, dynamic> json) {
    return AttachmentInfo(
      type: json['type'] ?? '',
      url: json['url'] ?? '',
      filename: json['filename'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'url': url,
    'filename': filename,
  };
}

class RecurringPatternInfo {
  final String frequency;
  final DateTime? nextDueDate;

  const RecurringPatternInfo({
    required this.frequency,
    this.nextDueDate,
  });

  factory RecurringPatternInfo.fromJson(Map<String, dynamic> json) {
    return RecurringPatternInfo(
      frequency: json['frequency'] ?? '',
      nextDueDate: json['next_due_date'] != null 
          ? DateTime.parse(json['next_due_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'frequency': frequency,
    'next_due_date': nextDueDate?.toIso8601String(),
  };
}

// Expense categories constants
class ExpenseCategories {
  static const List<String> all = [
    'Food & Drinks',
    'Transportation',
    'Utilities',
    'Rent',
    'Salary',
    'Shopping',
    'Entertainment',
    'Healthcare',
    'Education',
    'Taxes',
    'Maintenance',
    'Other',
  ];
}
