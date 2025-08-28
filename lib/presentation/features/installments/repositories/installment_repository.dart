import '../../../../data/services/appwrite_installment_service.dart';
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
  final AppwriteInstallmentService _installmentService;

  InstallmentRepositoryImpl() : _installmentService = AppwriteInstallmentService();
  
  @override
  Future<List<InstallmentModel>> getInstallments({
    String? search,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _installmentService.getInstallments(
        search: search,
        status: status,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to fetch installments: ${e.toString()}');
    }
  }
  
  @override
  Future<InstallmentModel> getInstallmentById(String id) async {
    try {
      return await _installmentService.getInstallmentById(id);
    } catch (e) {
      throw Exception('Failed to fetch installment: ${e.toString()}');
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
      return await _installmentService.createInstallment(
        client: client,
        totalAmount: totalAmount,
        downPayment: downPayment,
        startDate: startDate,
        dueDate: dueDate,
        productIds: productIds,
        productNames: productNames,
        notes: notes,
      );
    } catch (e) {
      throw Exception('Failed to create installment: ${e.toString()}');
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
      return await _installmentService.addPayment(
        installmentId: installmentId,
        amount: amount,
        date: date,
        note: note,
      );
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
      return await _installmentService.updateInstallment(
        id: id,
        totalAmount: totalAmount,
        downPayment: downPayment,
        dueDate: dueDate,
        status: status,
        notes: notes,
      );
    } catch (e) {
      throw Exception('Failed to update installment: ${e.toString()}');
    }
  }
  
  @override
  Future<List<InstallmentPaymentModel>> getInstallmentPayments(String installmentId) async {
    try {
      return await _installmentService.getInstallmentPayments(installmentId);
    } catch (e) {
      throw Exception('Failed to fetch installment payments: ${e.toString()}');
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
      return await _installmentService.addInstallmentPayment(
        installmentId: installmentId,
        amount: amount,
        paymentMethod: paymentMethod,
        paymentDate: paymentDate,
        receiptNumber: receiptNumber,
        notes: notes,
      );
    } catch (e) {
      throw Exception('Failed to add installment payment: ${e.toString()}');
    }
  }
  
  @override
  Future<InstallmentModel> updateInstallmentStatus(String id, String status) async {
    try {
      return await _installmentService.updateInstallmentStatus(id, status);
    } catch (e) {
      throw Exception('Failed to update installment status: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteInstallment(String id) async {
    try {
      await _installmentService.deleteInstallment(id);
    } catch (e) {
      throw Exception('Failed to delete installment: ${e.toString()}');
    }
  }
}