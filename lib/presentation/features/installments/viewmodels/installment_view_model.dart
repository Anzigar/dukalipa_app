import 'package:flutter/foundation.dart';

import '../models/installment_model.dart';
import '../models/installment_payment_model.dart';
import '../repositories/installment_repository.dart';

class InstallmentViewModel extends ChangeNotifier {
  final InstallmentRepository _repository;
  
  // State variables
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  List<InstallmentModel> _installments = [];
  InstallmentModel? _selectedInstallment;
  List<InstallmentPaymentModel> _payments = [];
  
  // Search and filter parameters
  String? _searchQuery;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  
  // Getters for state
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  List<InstallmentModel> get installments => _installments;
  InstallmentModel? get selectedInstallment => _selectedInstallment;
  List<InstallmentPaymentModel> get payments => _payments;
  
  // Constructor
  InstallmentViewModel(this._repository);
  
  // Methods to interact with repository
  Future<void> fetchInstallments() async {
    _setLoading(true);
    
    try {
      final installments = await _repository.getInstallments(
        search: _searchQuery,
        status: _selectedStatus,
        startDate: _startDate,
        endDate: _endDate,
      );
      
      _installments = installments;
      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  Future<void> fetchInstallmentById(String id) async {
    _setLoading(true);
    
    try {
      final installment = await _repository.getInstallmentById(id);
      _selectedInstallment = installment;
      
      // Also fetch payments for this installment
      await fetchPayments(id);
      
      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  Future<void> fetchPayments(String installmentId) async {
    try {
      final payments = await _repository.getInstallmentPayments(installmentId);
      _payments = payments;
      notifyListeners();
    } catch (e) {
      // Handle error but don't update main error state
      debugPrint('Error fetching payments: ${e.toString()}');
    }
  }
  
  Future<bool> addPayment({
    required String installmentId,
    required double amount,
    required String paymentMethod,
    String? receiptNumber,
    String? notes,
  }) async {
    _setLoading(true);
    
    try {
      await _repository.addInstallmentPayment(
        installmentId: installmentId,
        amount: amount,
        paymentMethod: paymentMethod,
        receiptNumber: receiptNumber,
        notes: notes,
      );
      
      // Refresh the installment and payments
      await fetchInstallmentById(installmentId);
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }
  
  // Filter setters
  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  void setStatusFilter(String? status) {
    _selectedStatus = status;
    notifyListeners();
  }
  
  void setDateRange(DateTime? startDate, DateTime? endDate) {
    _startDate = startDate;
    _endDate = endDate;
    notifyListeners();
  }
  
  void clearFilters() {
    _searchQuery = null;
    _selectedStatus = null;
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }
  
  // Helper methods for state management
  void _setLoading(bool loading) {
    _isLoading = loading;
    _hasError = false;
    notifyListeners();
  }
  
  void _setSuccess() {
    _isLoading = false;
    _hasError = false;
    notifyListeners();
  }
  
  void _setError(String message) {
    _isLoading = false;
    _hasError = true;
    _errorMessage = message;
    notifyListeners();
  }
  
  // Analytics and summaries
  Map<String, dynamic> getInstallmentsSummary() {
    double totalAmount = 0;
    double paidAmount = 0;
    double remainingAmount = 0;
    int overdueCount = 0;
    int completedCount = 0;
    int activeCount = 0;
    
    for (var installment in _installments) {
      totalAmount += installment.totalAmount;
      paidAmount += installment.paidAmount;
      remainingAmount += installment.remainingAmount;
      
      if (installment.isCompleted) {
        completedCount++;
      } else if (installment.isOverdue) {
        overdueCount++;
      } else if (installment.isActive) {
        activeCount++;
      }
    }
    
    return {
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'remainingAmount': remainingAmount,
      'totalCount': _installments.length,
      'activeCount': activeCount,
      'overdueCount': overdueCount,
      'completedCount': completedCount,
      'defaultedCount': _installments.length - (activeCount + overdueCount + completedCount),
    };
  }
}
