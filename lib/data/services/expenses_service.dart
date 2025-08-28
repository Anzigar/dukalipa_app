import '../../data/models/api_models.dart';
import '../../presentation/features/expenses/models/expense_model.dart' as ui_expense;
import 'appwrite_expense_service.dart';

class ExpensesService {
  final AppwriteExpenseService _expenseService;

  ExpensesService() : _expenseService = AppwriteExpenseService();

  /// Create a new expense record
  Future<ApiResponse<ui_expense.ExpenseModel>> createExpense({
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
      return await _expenseService.createExpense(
        category: category,
        subcategory: subcategory,
        title: title,
        description: description,
        amount: amount,
        currency: currency,
        date: date,
        paymentMethod: paymentMethod,
        vendor: vendor,
        receiptNumber: receiptNumber,
        approvedBy: approvedBy,
        tags: tags,
        attachments: attachments,
        isRecurring: isRecurring,
        recurringPattern: recurringPattern,
        budgetCategory: budgetCategory,
        createdBy: createdBy,
      );
    } catch (e) {
      return ApiResponse<ui_expense.ExpenseModel>(
        success: false,
        message: 'Failed to create expense: ${e.toString()}',
      );
    }
  }

  /// Get all expenses with pagination and filtering
  Future<ApiResponse<List<ui_expense.ExpenseModel>>> getExpenses({
    int page = 1,
    int limit = 20,
    String? category,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _expenseService.getExpenses(
        page: page,
        limit: limit,
        category: category,
        status: status,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      return ApiResponse<List<ui_expense.ExpenseModel>>(
        success: false,
        message: 'Failed to fetch expenses: ${e.toString()}',
      );
    }
  }

  /// Get a specific expense by ID
  Future<ApiResponse<ui_expense.ExpenseModel>> getExpense(String expenseId) async {
    try {
      return await _expenseService.getExpense(expenseId);
    } catch (e) {
      return ApiResponse<ui_expense.ExpenseModel>(
        success: false,
        message: 'Failed to fetch expense: ${e.toString()}',
      );
    }
  }

  /// Update an expense record
  Future<ApiResponse<ui_expense.ExpenseModel>> updateExpense(
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
      return await _expenseService.updateExpense(
        expenseId,
        category: category,
        subcategory: subcategory,
        title: title,
        description: description,
        amount: amount,
        currency: currency,
        date: date,
        paymentMethod: paymentMethod,
        vendor: vendor,
        receiptNumber: receiptNumber,
        status: status,
        approvedBy: approvedBy,
        approvalDate: approvalDate,
        tags: tags,
        attachments: attachments,
        isRecurring: isRecurring,
        recurringPattern: recurringPattern,
        budgetCategory: budgetCategory,
      );
    } catch (e) {
      return ApiResponse<ui_expense.ExpenseModel>(
        success: false,
        message: 'Failed to update expense: ${e.toString()}',
      );
    }
  }

  /// Delete an expense record
  Future<ApiResponse<void>> deleteExpense(String expenseId) async {
    try {
      return await _expenseService.deleteExpense(expenseId);
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
      return await _expenseService.getExpenseCategories();
    } catch (e) {
      return ApiResponse<List<String>>(
        success: false,
        message: 'Failed to fetch expense categories: ${e.toString()}',
      );
    }
  }

  /// Get comprehensive expense analytics and summary
  Future<ApiResponse<Map<String, dynamic>>> getExpenseSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _expenseService.getExpenseSummary(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Failed to fetch expense summary: ${e.toString()}',
      );
    }
  }
}


