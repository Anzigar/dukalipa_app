import 'package:flutter/foundation.dart';
import '../../../../data/services/expenses_service.dart';

class ExpensesProvider with ChangeNotifier {
  final ExpensesService _expensesService;

  ExpensesProvider(this._expensesService);

  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ExpenseModel> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load expenses with optional filtering
  Future<void> loadExpenses({
    bool refresh = false,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (refresh) {
      _expenses.clear();
    }

    _setLoading(true);
    _clearError();

    try {
      final response = await _expensesService.getExpenses(
        category: category,
        startDate: startDate,
        endDate: endDate,
      );

      if (response.success && response.data != null) {
        _expenses = response.data!;
      } else {
        _setError(response.message ?? 'Failed to load expenses');
      }
    } catch (e) {
      _setError('Failed to load expenses: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get a specific expense by ID
  Future<ExpenseModel?> getExpense(String expenseId) async {
    try {
      final response = await _expensesService.getExpense(expenseId);
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        _setError(response.message ?? 'Failed to load expense');
        return null;
      }
    } catch (e) {
      _setError('Failed to load expense: $e');
      return null;
    }
  }

  /// Create a new expense
  Future<bool> createExpense({
    required String category,
    String? subcategory,
    required String title,
    String? description,
    required double amount,
    String currency = 'TZS',
    DateTime? date,
    required String paymentMethod,
    String? vendorName,
    String? vendorPhone,
    String? vendorEmail,
    String? receiptNumber,
    String? approvedBy,
    List<String>? tags,
    List<String>? attachmentUrls,
    bool isRecurring = false,
    String? recurringFrequency,
    String? budgetCategory,
    required String createdBy,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Create vendor info if vendor name is provided
      VendorInfo? vendorInfo;
      if (vendorName != null && vendorName.isNotEmpty) {
        vendorInfo = VendorInfo(
          name: vendorName,
          phone: vendorPhone,
          email: vendorEmail,
        );
      }

      // Create attachment info if URLs are provided
      List<AttachmentInfo>? attachmentInfos;
      if (attachmentUrls != null && attachmentUrls.isNotEmpty) {
        attachmentInfos = attachmentUrls.map((url) => AttachmentInfo(
          type: 'image',
          url: url,
          filename: url.split('/').last,
        )).toList();
      }

      // Create recurring pattern if specified
      RecurringPatternInfo? recurringPattern;
      if (isRecurring && recurringFrequency != null) {
        recurringPattern = RecurringPatternInfo(
          frequency: recurringFrequency,
          nextDueDate: null, // Will be calculated on backend
        );
      }

      final response = await _expensesService.createExpense(
        category: category,
        subcategory: subcategory,
        title: title,
        description: description,
        amount: amount,
        currency: currency,
        date: date ?? DateTime.now(),
        paymentMethod: paymentMethod,
        vendor: vendorInfo,
        receiptNumber: receiptNumber,
        approvedBy: approvedBy,
        tags: tags,
        attachments: attachmentInfos,
        isRecurring: isRecurring,
        recurringPattern: recurringPattern,
        budgetCategory: budgetCategory,
        createdBy: createdBy,
      );

      if (response.success && response.data != null) {
        // Add the new expense to the beginning of the list
        _expenses.insert(0, response.data!);
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to create expense');
        return false;
      }
    } catch (e) {
      _setError('Failed to create expense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an expense
  Future<bool> updateExpense(
    String expenseId, {
    String? category,
    String? subcategory,
    String? title,
    String? description,
    double? amount,
    String? currency,
    DateTime? date,
    String? paymentMethod,
    String? vendorName,
    String? vendorPhone,
    String? vendorEmail,
    String? receiptNumber,
    String? status,
    String? approvedBy,
    List<String>? tags,
    List<String>? attachmentUrls,
    bool? isRecurring,
    String? recurringFrequency,
    String? budgetCategory,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Create vendor info if vendor name is provided
      VendorInfo? vendorInfo;
      if (vendorName != null && vendorName.isNotEmpty) {
        vendorInfo = VendorInfo(
          name: vendorName,
          phone: vendorPhone,
          email: vendorEmail,
        );
      }

      // Create attachment info if URLs are provided
      List<AttachmentInfo>? attachmentInfos;
      if (attachmentUrls != null && attachmentUrls.isNotEmpty) {
        attachmentInfos = attachmentUrls.map((url) => AttachmentInfo(
          type: 'image',
          url: url,
          filename: url.split('/').last,
        )).toList();
      }

      // Create recurring pattern if specified
      RecurringPatternInfo? recurringPattern;
      if (isRecurring == true && recurringFrequency != null) {
        recurringPattern = RecurringPatternInfo(
          frequency: recurringFrequency,
          nextDueDate: null, // Will be calculated on backend
        );
      }

      final response = await _expensesService.updateExpense(
        expenseId,
        category: category,
        subcategory: subcategory,
        title: title,
        description: description,
        amount: amount,
        currency: currency,
        date: date,
        paymentMethod: paymentMethod,
        vendor: vendorInfo,
        receiptNumber: receiptNumber,
        status: status,
        approvedBy: approvedBy,
        tags: tags,
        attachments: attachmentInfos,
        isRecurring: isRecurring,
        recurringPattern: recurringPattern,
        budgetCategory: budgetCategory,
      );

      if (response.success && response.data != null) {
        // Update the expense in the list
        final index = _expenses.indexWhere((expense) => expense.id == expenseId);
        if (index != -1) {
          _expenses[index] = response.data!;
          notifyListeners();
        }
        return true;
      } else {
        _setError(response.message ?? 'Failed to update expense');
        return false;
      }
    } catch (e) {
      _setError('Failed to update expense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete an expense
  Future<bool> deleteExpense(String expenseId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _expensesService.deleteExpense(expenseId);

      if (response.success) {
        // Remove the expense from the list
        _expenses.removeWhere((expense) => expense.id == expenseId);
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to delete expense');
        return false;
      }
    } catch (e) {
      _setError('Failed to delete expense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Search expenses by description or vendor
  Future<void> searchExpenses(String query) async {
    // For now, we'll filter locally. In the future, this could be moved to the API
    if (query.isEmpty) {
      loadExpenses(refresh: true);
      return;
    }

    final filteredExpenses = _expenses.where((expense) {
      final description = expense.description?.toLowerCase() ?? '';
      final vendorName = expense.vendor?.name.toLowerCase() ?? '';
      final queryLower = query.toLowerCase();
      
      return description.contains(queryLower) ||
          vendorName.contains(queryLower) ||
          expense.title.toLowerCase().contains(queryLower);
    }).toList();

    _expenses = filteredExpenses;
    notifyListeners();
  }

  /// Get expenses analytics
  Future<Map<String, dynamic>?> getExpensesAnalytics({
    String? category,
    String? paymentMethod,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _expensesService.getExpenseSummary(
        startDate: startDate,
        endDate: endDate,
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        _setError(response.message ?? 'Failed to load analytics');
        return null;
      }
    } catch (e) {
      _setError('Failed to load analytics: $e');
      return null;
    }
  }

  /// Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear all data (useful for logout)
  void clear() {
    _expenses.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
