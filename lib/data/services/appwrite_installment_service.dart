import 'package:appwrite/appwrite.dart';
import '../../core/services/appwrite_service.dart';
import '../../presentation/features/installments/models/installment_model.dart';
import '../../presentation/features/installments/models/installment_payment_model.dart';
import '../../presentation/features/clients/models/client_model.dart';

/// Service for handling installment operations using Appwrite backend
class AppwriteInstallmentService {
  final Databases _databases;
  final String _databaseId = 'shop_management_db';

  AppwriteInstallmentService() : _databases = AppwriteService().databases;

  /// Get all installments with optional filtering
  Future<List<InstallmentModel>> getInstallments({
    String? search,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      List<String> queries = [];

      // Add search functionality
      if (search != null && search.isNotEmpty) {
        queries.add(Query.search('client_name', search));
      }

      // Add status filter
      if (status != null && status.isNotEmpty) {
        queries.add(Query.equal('status', status));
      }

      // Add date filters
      if (startDate != null) {
        queries.add(Query.greaterThanEqual('start_date', startDate.toIso8601String()));
      }

      if (endDate != null) {
        queries.add(Query.lessThanEqual('start_date', endDate.toIso8601String()));
      }

      // Order by creation date (newest first)
      queries.add(Query.orderDesc('\$createdAt'));
      queries.add(Query.limit(100));

      final installmentDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'installments',
        queries: queries,
      );

      List<InstallmentModel> installments = [];

      for (var doc in installmentDocs.documents) {
        final data = Map<String, dynamic>.from(doc.data);
        data['id'] = doc.$id;
        
        // Get payments for this installment
        final payments = await getInstallmentPayments(doc.$id);
        data['payments'] = payments.map((p) => p.toJson()).toList();
        
        installments.add(InstallmentModel.fromJson(data));
      }

      return installments;
    } catch (e) {
      throw Exception('Failed to fetch installments: ${e.toString()}');
    }
  }

  /// Get a specific installment by ID
  Future<InstallmentModel> getInstallmentById(String installmentId) async {
    try {
      final installmentDoc = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: 'installments',
        documentId: installmentId,
      );

      final data = Map<String, dynamic>.from(installmentDoc.data);
      data['id'] = installmentDoc.$id;

      // Get payments for this installment
      final payments = await getInstallmentPayments(installmentId);
      data['payments'] = payments.map((p) => p.toJson()).toList();

      return InstallmentModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch installment: ${e.toString()}');
    }
  }

  /// Create a new installment plan
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
      final installmentId = ID.unique();

      // Prepare installment data
      final installmentData = {
        'client_id': client.id,
        'client_name': client.name,
        'client_phone': client.phoneNumber,
        'client_email': client.email,
        'client_address': client.address,
        'total_amount': totalAmount,
        'paid_amount': downPayment,
        'remaining_amount': totalAmount - downPayment,
        'down_payment': downPayment,
        'product_ids': productIds,
        'product_names': productNames,
        'start_date': startDate.toIso8601String(),
        'due_date': dueDate.toIso8601String(),
        'status': 'active',
        'notes': notes ?? '',
        '\$createdAt': DateTime.now().toIso8601String(),
        '\$updatedAt': DateTime.now().toIso8601String(),
      };

      // Create the installment document
      await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: 'installments',
        documentId: installmentId,
        data: installmentData,
      );

      // Create initial down payment if greater than 0
      if (downPayment > 0) {
        await addInstallmentPayment(
          installmentId: installmentId,
          amount: downPayment,
          paymentMethod: 'cash',
          paymentDate: DateTime.now(),
          notes: 'Initial down payment',
        );
      }

      // Get the created installment with payments
      return await getInstallmentById(installmentId);
    } catch (e) {
      throw Exception('Failed to create installment: ${e.toString()}');
    }
  }

  /// Add a payment to an installment (simplified version)
  Future<InstallmentModel> addPayment({
    required String installmentId,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    try {
      await addInstallmentPayment(
        installmentId: installmentId,
        amount: amount,
        paymentMethod: 'cash', // Default payment method
        paymentDate: date,
        notes: note,
      );

      return await getInstallmentById(installmentId);
    } catch (e) {
      throw Exception('Failed to add payment: ${e.toString()}');
    }
  }

  /// Get all payments for a specific installment
  Future<List<InstallmentPaymentModel>> getInstallmentPayments(String installmentId) async {
    try {
      final paymentDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'installment_payments',
        queries: [
          Query.equal('installment_id', installmentId),
          Query.orderDesc('\$createdAt'),
        ],
      );

      return paymentDocs.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['id'] = doc.$id;
        return InstallmentPaymentModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch installment payments: ${e.toString()}');
    }
  }

  /// Add a payment to an installment
  Future<InstallmentPaymentModel> addInstallmentPayment({
    required String installmentId,
    required double amount,
    required String paymentMethod,
    DateTime? paymentDate,
    String? receiptNumber,
    String? notes,
  }) async {
    try {
      final paymentId = ID.unique();
      final actualPaymentDate = paymentDate ?? DateTime.now();

      final paymentData = {
        'installment_id': installmentId,
        'amount': amount,
        'payment_date': actualPaymentDate.toIso8601String(),
        'payment_method': paymentMethod,
        'receipt_number': receiptNumber,
        'notes': notes,
        '\$createdAt': DateTime.now().toIso8601String(),
        '\$updatedAt': DateTime.now().toIso8601String(),
      };

      // Create the payment document
      final createdDoc = await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: 'installment_payments',
        documentId: paymentId,
        data: paymentData,
      );

      // Update installment paid amount and remaining amount
      await _updateInstallmentAmounts(installmentId, amount);

      final resultData = Map<String, dynamic>.from(createdDoc.data);
      resultData['id'] = createdDoc.$id;
      return InstallmentPaymentModel.fromJson(resultData);
    } catch (e) {
      throw Exception('Failed to add installment payment: ${e.toString()}');
    }
  }

  /// Update installment amounts after payment
  Future<void> _updateInstallmentAmounts(String installmentId, double paymentAmount) async {
    try {
      // Get current installment
      final installmentDoc = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: 'installments',
        documentId: installmentId,
      );

      final currentPaidAmount = (installmentDoc.data['paid_amount'] ?? 0.0).toDouble();
      final totalAmount = (installmentDoc.data['total_amount'] ?? 0.0).toDouble();
      
      final newPaidAmount = currentPaidAmount + paymentAmount;
      final newRemainingAmount = totalAmount - newPaidAmount;
      
      // Determine status
      String status = 'active';
      if (newRemainingAmount <= 0) {
        status = 'completed';
      }

      // Update installment
      await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: 'installments',
        documentId: installmentId,
        data: {
          'paid_amount': newPaidAmount,
          'remaining_amount': newRemainingAmount,
          'status': status,
          '\$updatedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to update installment amounts: ${e.toString()}');
    }
  }

  /// Update an existing installment
  Future<InstallmentModel> updateInstallment({
    required String id,
    double? totalAmount,
    double? downPayment,
    DateTime? dueDate,
    String? status,
    String? notes,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (totalAmount != null) {
        updateData['total_amount'] = totalAmount;
        
        // Recalculate remaining amount if total amount changes
        final installmentDoc = await _databases.getDocument(
          databaseId: _databaseId,
          collectionId: 'installments',
          documentId: id,
        );
        
        final paidAmount = (installmentDoc.data['paid_amount'] ?? 0.0).toDouble();
        updateData['remaining_amount'] = totalAmount - paidAmount;
      }
      
      if (downPayment != null) updateData['down_payment'] = downPayment;
      if (dueDate != null) updateData['due_date'] = dueDate.toIso8601String();
      if (status != null) updateData['status'] = status;
      if (notes != null) updateData['notes'] = notes;
      
      updateData['\$updatedAt'] = DateTime.now().toIso8601String();

      await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: 'installments',
        documentId: id,
        data: updateData,
      );

      return await getInstallmentById(id);
    } catch (e) {
      throw Exception('Failed to update installment: ${e.toString()}');
    }
  }

  /// Update installment status
  Future<InstallmentModel> updateInstallmentStatus(String id, String status) async {
    try {
      await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: 'installments',
        documentId: id,
        data: {
          'status': status,
          '\$updatedAt': DateTime.now().toIso8601String(),
        },
      );

      return await getInstallmentById(id);
    } catch (e) {
      throw Exception('Failed to update installment status: ${e.toString()}');
    }
  }

  /// Delete an installment
  Future<void> deleteInstallment(String id) async {
    try {
      // First, delete all payments for this installment
      final payments = await getInstallmentPayments(id);
      for (var payment in payments) {
        await _databases.deleteDocument(
          databaseId: _databaseId,
          collectionId: 'installment_payments',
          documentId: payment.id,
        );
      }

      // Then delete the installment
      await _databases.deleteDocument(
        databaseId: _databaseId,
        collectionId: 'installments',
        documentId: id,
      );
    } catch (e) {
      throw Exception('Failed to delete installment: ${e.toString()}');
    }
  }

  /// Get installment statistics
  Future<Map<String, dynamic>> getInstallmentStatistics() async {
    try {
      // Get all active installments
      final activeInstallments = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'installments',
        queries: [
          Query.equal('status', 'active'),
        ],
      );

      // Get completed installments
      final completedInstallments = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'installments',
        queries: [
          Query.equal('status', 'completed'),
        ],
      );

      // Get overdue installments
      final overdueInstallments = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'installments',
        queries: [
          Query.equal('status', 'active'),
          Query.lessThan('due_date', DateTime.now().toIso8601String()),
        ],
      );

      double totalActiveAmount = 0;
      double totalRemainingAmount = 0;
      
      for (var doc in activeInstallments.documents) {
        totalActiveAmount += (doc.data['total_amount'] ?? 0).toDouble();
        totalRemainingAmount += (doc.data['remaining_amount'] ?? 0).toDouble();
      }

      return {
        'active_count': activeInstallments.total,
        'completed_count': completedInstallments.total,
        'overdue_count': overdueInstallments.total,
        'total_active_amount': totalActiveAmount,
        'total_remaining_amount': totalRemainingAmount,
      };
    } catch (e) {
      throw Exception('Failed to fetch installment statistics: ${e.toString()}');
    }
  }
}