import 'package:appwrite/appwrite.dart';
import '../../core/services/appwrite_service.dart';
import '../models/api_models.dart';
import '../../presentation/features/expenses/models/expense_model.dart';

/// Service for handling expense operations using Appwrite backend
class AppwriteExpenseService {
  final Databases _databases;
  final String _databaseId = 'shop_management_db';

  AppwriteExpenseService() : _databases = AppwriteService().databases;

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
      final expenseId = ID.unique();

      // Prepare expense data for Appwrite
      final expenseData = {
        'category': category,
        'subcategory': subcategory,
        'title': title,
        'description': description ?? '',
        'amount': amount,
        'currency': currency,
        'date': date.toIso8601String(),
        'payment_method': paymentMethod,
        'vendor_name': vendor?.name,
        'vendor_phone': vendor?.phone,
        'vendor_email': vendor?.email,
        'receipt_number': receiptNumber,
        'receipt_url': attachments?.isNotEmpty == true ? attachments!.first.url : null,
        'approved_by': approvedBy,
        'tags': tags ?? [],
        'is_recurring': isRecurring,
        'recurring_frequency': recurringPattern?.frequency,
        'budget_category': budgetCategory,
        'created_by': createdBy,
        'status': 'pending',
        '\$createdAt': DateTime.now().toIso8601String(),
        '\$updatedAt': DateTime.now().toIso8601String(),
      };

      // Create the expense document
      final createdDoc = await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: 'expenses',
        documentId: expenseId,
        data: expenseData,
      );

      final resultData = Map<String, dynamic>.from(createdDoc.data);
      resultData['id'] = createdDoc.$id;

      // Convert to the simple ExpenseModel used by the UI
      final expense = _convertToUIExpenseModel(resultData);

      return ApiResponse<ExpenseModel>(
        success: true,
        data: expense,
        message: 'Expense created successfully',
      );
    } catch (e) {
      return ApiResponse<ExpenseModel>(
        success: false,
        message: 'Failed to create expense: ${e.toString()}',
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
      List<String> queries = [];

      // Add filters
      if (category != null && category.isNotEmpty) {
        queries.add(Query.equal('category', category));
      }

      if (status != null && status.isNotEmpty) {
        queries.add(Query.equal('status', status));
      }

      // Add date filters
      if (startDate != null) {
        queries.add(Query.greaterThanEqual('date', startDate.toIso8601String()));
      }

      if (endDate != null) {
        queries.add(Query.lessThanEqual('date', endDate.toIso8601String()));
      }

      // Add pagination and ordering
      queries.add(Query.orderDesc('\$createdAt'));
      queries.add(Query.limit(limit));
      
      if (page > 1) {
        queries.add(Query.offset((page - 1) * limit));
      }

      final expenseDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'expenses',
        queries: queries,
      );

      final expenses = expenseDocs.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['id'] = doc.$id;
        return _convertToUIExpenseModel(data);
      }).toList();

      return ApiResponse<List<ExpenseModel>>(
        success: true,
        data: expenses,
      );
    } catch (e) {
      return ApiResponse<List<ExpenseModel>>(
        success: false,
        message: 'Failed to fetch expenses: ${e.toString()}',
      );
    }
  }

  /// Get a specific expense by ID
  Future<ApiResponse<ExpenseModel>> getExpense(String expenseId) async {
    try {
      final expenseDoc = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: 'expenses',
        documentId: expenseId,
      );

      final data = Map<String, dynamic>.from(expenseDoc.data);
      data['id'] = expenseDoc.$id;

      final expense = _convertToUIExpenseModel(data);

      return ApiResponse<ExpenseModel>(
        success: true,
        data: expense,
      );
    } catch (e) {
      return ApiResponse<ExpenseModel>(
        success: false,
        message: 'Failed to fetch expense: ${e.toString()}',
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
      final updateData = <String, dynamic>{};

      if (category != null) updateData['category'] = category;
      if (subcategory != null) updateData['subcategory'] = subcategory;
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (amount != null) updateData['amount'] = amount;
      if (currency != null) updateData['currency'] = currency;
      if (date != null) updateData['date'] = date.toIso8601String();
      if (paymentMethod != null) updateData['payment_method'] = paymentMethod;
      if (vendor != null) {
        updateData['vendor_name'] = vendor.name;
        updateData['vendor_phone'] = vendor.phone;
        updateData['vendor_email'] = vendor.email;
      }
      if (receiptNumber != null) updateData['receipt_number'] = receiptNumber;
      if (status != null) updateData['status'] = status;
      if (approvedBy != null) updateData['approved_by'] = approvedBy;
      if (tags != null) updateData['tags'] = tags;
      if (attachments != null && attachments.isNotEmpty) {
        updateData['receipt_url'] = attachments.first.url;
      }
      if (isRecurring != null) updateData['is_recurring'] = isRecurring;
      if (recurringPattern != null) {
        updateData['recurring_frequency'] = recurringPattern.frequency;
      }
      if (budgetCategory != null) updateData['budget_category'] = budgetCategory;

      updateData['\$updatedAt'] = DateTime.now().toIso8601String();

      await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: 'expenses',
        documentId: expenseId,
        data: updateData,
      );

      // Get and return the updated expense
      return await getExpense(expenseId);
    } catch (e) {
      return ApiResponse<ExpenseModel>(
        success: false,
        message: 'Failed to update expense: ${e.toString()}',
      );
    }
  }

  /// Delete an expense record
  Future<ApiResponse<void>> deleteExpense(String expenseId) async {
    try {
      await _databases.deleteDocument(
        databaseId: _databaseId,
        collectionId: 'expenses',
        documentId: expenseId,
      );

      return const ApiResponse<void>(
        success: true,
        message: 'Expense deleted successfully',
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Failed to delete expense: ${e.toString()}',
      );
    }
  }

  /// Get all available expense categories
  Future<ApiResponse<List<String>>> getExpenseCategories() async {
    try {
      // Get unique categories from existing expenses
      final expenseDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'expenses',
        queries: [
          Query.select(['category']),
          Query.limit(1000),
        ],
      );

      final Set<String> categories = {};
      for (var doc in expenseDocs.documents) {
        final category = doc.data['category'] as String?;
        if (category != null && category.isNotEmpty) {
          categories.add(category);
        }
      }

      // Add default categories
      categories.addAll(ExpenseCategories.all);

      return ApiResponse<List<String>>(
        success: true,
        data: categories.toList()..sort(),
      );
    } catch (e) {
      return ApiResponse<List<String>>(
        success: true,
        data: ExpenseCategories.all, // Fall back to default categories
      );
    }
  }

  /// Get comprehensive expense analytics and summary
  Future<ApiResponse<Map<String, dynamic>>> getExpenseSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      List<String> queries = [];

      // Add date filters
      if (startDate != null) {
        queries.add(Query.greaterThanEqual('date', startDate.toIso8601String()));
      }

      if (endDate != null) {
        queries.add(Query.lessThanEqual('date', endDate.toIso8601String()));
      }

      queries.add(Query.limit(1000)); // Get all relevant expenses

      final expenseDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'expenses',
        queries: queries,
      );

      // Calculate analytics
      double totalAmount = 0;
      Map<String, double> categoryTotals = {};
      Map<String, int> categoryCount = {};
      Map<String, double> monthlyTotals = {};

      for (var doc in expenseDocs.documents) {
        final amount = (doc.data['amount'] ?? 0).toDouble();
        final category = doc.data['category'] as String? ?? 'Other';
        
        totalAmount += amount;

        // Category totals
        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;

        // Monthly totals
        final dateStr = doc.data['date'] as String?;
        if (dateStr != null) {
          final date = DateTime.parse(dateStr);
          final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
          monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + amount;
        }
      }

      final analytics = {
        'total_amount': totalAmount,
        'total_count': expenseDocs.total,
        'category_breakdown': categoryTotals,
        'category_count': categoryCount,
        'monthly_totals': monthlyTotals,
        'average_expense': expenseDocs.total > 0 ? totalAmount / expenseDocs.total : 0.0,
      };

      return ApiResponse<Map<String, dynamic>>(
        success: true,
        data: analytics,
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Failed to fetch expense summary: ${e.toString()}',
      );
    }
  }

  /// Convert Appwrite document to UI ExpenseModel
  ExpenseModel _convertToUIExpenseModel(Map<String, dynamic> data) {
    return ExpenseModel.fromJson({
      'id': data['id'],
      'amount': data['amount'],
      'description': data['description'],
      'category': data['category'],
      'date': data['date'],
      'receipt_url': data['receipt_url'],
      'receipt_number': data['receipt_number'],
      'payment_method': data['payment_method'],
      'created_at': data['\$createdAt'] ?? data['created_at'],
      'updated_at': data['\$updatedAt'] ?? data['updated_at'],
    });
  }
}

/// Supporting model classes for compatibility with the existing service
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