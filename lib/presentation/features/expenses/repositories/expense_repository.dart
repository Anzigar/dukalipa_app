import '../../../../data/services/appwrite_expense_service.dart';
import '../models/expense_model.dart';

abstract class ExpenseRepository {
  Future<List<ExpenseModel>> getExpenses({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<ExpenseModel> getExpenseById(String id);
  
  Future<ExpenseModel> createExpense({
    required String category,
    required String description,
    required double amount,
    required DateTime date,
    String? paymentMethod,
    String? receiptNumber,
  });
  
  Future<ExpenseModel> updateExpense(ExpenseModel expense);
  
  Future<void> deleteExpense(String id);
  
  Future<Map<String, dynamic>> getExpenseAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });
}

class ExpenseRepositoryImpl implements ExpenseRepository {
  final AppwriteExpenseService _expenseService;
  
  ExpenseRepositoryImpl() : _expenseService = AppwriteExpenseService();
  
  @override
  Future<List<ExpenseModel>> getExpenses({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _expenseService.getExpenses(
        category: category,
        startDate: startDate,
        endDate: endDate,
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to fetch expenses');
      }
    } catch (e) {
      throw Exception('Failed to fetch expenses: ${e.toString()}');
    }
  }
  
  @override
  Future<ExpenseModel> getExpenseById(String id) async {
    try {
      final response = await _expenseService.getExpense(id);
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to fetch expense');
      }
    } catch (e) {
      throw Exception('Failed to fetch expense: ${e.toString()}');
    }
  }
  
  @override
  Future<ExpenseModel> createExpense({
    required String category,
    required String description,
    required double amount,
    required DateTime date,
    String? paymentMethod,
    String? receiptNumber,
  }) async {
    try {
      final response = await _expenseService.createExpense(
        category: category,
        title: description.split(' ').take(3).join(' '), // Use first 3 words as title
        description: description,
        amount: amount,
        date: date,
        paymentMethod: paymentMethod ?? 'cash',
        receiptNumber: receiptNumber,
        createdBy: 'user', // This should come from auth context
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to create expense');
      }
    } catch (e) {
      throw Exception('Failed to create expense: ${e.toString()}');
    }
  }
  
  @override
  Future<ExpenseModel> updateExpense(ExpenseModel expense) async {
    try {
      final response = await _expenseService.updateExpense(
        expense.id,
        category: expense.category,
        description: expense.description,
        amount: expense.amount,
        date: expense.date,
        paymentMethod: expense.paymentMethod,
        receiptNumber: expense.receiptNumber,
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to update expense');
      }
    } catch (e) {
      throw Exception('Failed to update expense: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteExpense(String id) async {
    try {
      final response = await _expenseService.deleteExpense(id);
      
      if (!response.success) {
        throw Exception(response.message ?? 'Failed to delete expense');
      }
    } catch (e) {
      throw Exception('Failed to delete expense: ${e.toString()}');
    }
  }
  
  @override
  Future<Map<String, dynamic>> getExpenseAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _expenseService.getExpenseSummary(
        startDate: startDate,
        endDate: endDate,
      );
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to fetch expense analytics');
      }
    } catch (e) {
      throw Exception('Failed to fetch expense analytics: ${e.toString()}');
    }
  }
}