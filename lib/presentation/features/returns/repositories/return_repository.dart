import 'dart:io';

import '../../../../core/network/api_client.dart';
import '../models/return_model.dart';

abstract class ReturnRepository {
  Future<List<ReturnModel>> getReturns({
    String? search,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<ReturnModel> getReturnById(String id);

  Future<ReturnModel> createReturn({
    required String orderId,
    required List<ReturnItemModel> items,
    required String reason,
    required double amount,
    String? customerName,
    String? customerPhone,
    String? notes,
    File? evidenceImage,
  });

  Future<ReturnModel> updateReturnStatus({
    required String id,
    required String status,
    double? refundAmount,
    String? notes,
  });

  Future<void> deleteReturn(String id);

  Future<Map<String, dynamic>> getReturnStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });
}

class ReturnRepositoryImpl implements ReturnRepository {
  final ApiClient _apiClient;

  ReturnRepositoryImpl(this._apiClient);

  @override
  Future<List<ReturnModel>> getReturns({
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
        queryParams['start_date'] = _formatDateForApi(startDate);
      }
      
      if (endDate != null) {
        queryParams['end_date'] = _formatDateForApi(endDate);
      }

      final response = await _apiClient.get('/returns', queryParameters: queryParams);
      
      // For mock implementation, return dummy data until API is ready
      await Future.delayed(const Duration(milliseconds: 800));
      
      return _getMockReturns();
    } catch (e) {
      // Return mock data for now
      return _getMockReturns();
    }
  }

  @override
  Future<ReturnModel> getReturnById(String id) async {
    try {
      final response = await _apiClient.get('/returns/$id');
      
      // For mock implementation, return dummy data
      await Future.delayed(const Duration(milliseconds: 500));
      
      final mockReturns = _getMockReturns();
      final returnData = mockReturns.firstWhere((r) => r.id == id, 
          orElse: () => mockReturns.first);
          
      return returnData;
    } catch (e) {
      final mockReturns = _getMockReturns();
      return mockReturns.first;
    }
  }

  @override
  Future<ReturnModel> createReturn({
    required String orderId,
    required List<ReturnItemModel> items,
    required String reason,
    required double amount,
    String? customerName,
    String? customerPhone,
    String? notes,
    File? evidenceImage,
  }) async {
    try {
      final data = {
        'order_id': orderId,
        'items': items.map((item) => item.toJson()).toList(),
        'reason': reason,
        'amount': amount,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'notes': notes,
      };

      final response = await _apiClient.post('/returns', data: data);
      
      // For mock implementation, just return a fake response
      await Future.delayed(const Duration(milliseconds: 800));
      
      final mockReturns = _getMockReturns();
      return mockReturns.first;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ReturnModel> updateReturnStatus({
    required String id,
    required String status,
    double? refundAmount,
    String? notes,
  }) async {
    try {
      final data = {
        'status': status,
        if (refundAmount != null) 'refund_amount': refundAmount,
        if (notes != null) 'notes': notes,
      };

      final response = await _apiClient.patch('/returns/$id', data: data);
      
      // For mock implementation, just return a fake response
      await Future.delayed(const Duration(milliseconds: 500));
      
      final mockReturns = _getMockReturns();
      final returnData = mockReturns.firstWhere((r) => r.id == id, 
          orElse: () => mockReturns.first);
      
      return returnData;
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteReturn(String id) async {
    try {
      await _apiClient.delete('/returns/$id');
      
      // For mock implementation, just delay
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getReturnStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (startDate != null) {
        queryParams['start_date'] = _formatDateForApi(startDate);
      }
      
      if (endDate != null) {
        queryParams['end_date'] = _formatDateForApi(endDate);
      }

      final response = await _apiClient.get('/returns/statistics', queryParameters: queryParams);
      
      // Mock statistics
      return {
        'total_returns': 12,
        'total_amount': 550000,
        'approved_returns': 8,
        'rejected_returns': 2,
        'pending_returns': 2,
        'refunded_amount': 425000,
      };
    } catch (e) {
      // Return mock statistics on error
      return {
        'total_returns': 12,
        'total_amount': 550000,
        'approved_returns': 8,
        'rejected_returns': 2,
        'pending_returns': 2,
        'refunded_amount': 425000,
      };
    }
  }

  // Helper function to handle errors
  Exception _handleError(dynamic error) {
    return Exception('Failed to perform operation: ${error.toString()}');
  }

  // Helper function to format date for API
  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Temporary mock data method until API is ready
  List<ReturnModel> _getMockReturns() {
    return [
      ReturnModel(
        id: 'ret-001',
        orderId: 'ord-1234',
        customerName: 'John Smith',
        customerPhone: '+255 765 432 100',
        reason: 'Damaged product',
        amount: 85000,
        items: [
          ReturnItemModel(
            productId: 'prod-123',
            productName: 'Smartphone X',
            quantity: 1,
            price: 85000,
            reason: 'Screen cracked on arrival',
          ),
        ],
        status: 'approved',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        notes: 'Customer showed evidence of damage',
        isRefunded: true,
        refundAmount: 85000,
      ),
      ReturnModel(
        id: 'ret-002',
        orderId: 'ord-5678',
        customerName: 'Maria Johnson',
        customerPhone: '+255 712 345 678',
        reason: 'Wrong item',
        amount: 45000,
        items: [
          ReturnItemModel(
            productId: 'prod-456',
            productName: 'Bluetooth Headphones',
            quantity: 1,
            price: 45000,
            reason: 'Wrong color delivered',
          ),
        ],
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        notes: 'Awaiting manager approval',
      ),
      ReturnModel(
        id: 'ret-003',
        orderId: 'ord-9012',
        customerName: 'Robert Makala',
        customerPhone: '+255 789 012 345',
        reason: 'Product not working',
        amount: 120000,
        items: [
          ReturnItemModel(
            productId: 'prod-789',
            productName: 'Coffee Maker',
            quantity: 1,
            price: 120000,
            reason: 'Not heating properly',
          ),
        ],
        status: 'approved',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
        notes: 'Verified defect with the heating element',
        isRefunded: true,
        refundAmount: 120000,
      ),
      ReturnModel(
        id: 'ret-004',
        orderId: 'ord-3456',
        customerName: 'Sarah Kimaro',
        customerPhone: '+255 723 456 789',
        reason: 'Changed mind',
        amount: 35000,
        items: [
          ReturnItemModel(
            productId: 'prod-012',
            productName: 'Desk Lamp',
            quantity: 1,
            price: 35000,
            reason: 'Customer found better option elsewhere',
          ),
        ],
        status: 'rejected',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 6)),
        notes: 'Return period expired',
      ),
      ReturnModel(
        id: 'ret-005',
        orderId: 'ord-7890',
        customerName: 'Daniel Mtui',
        customerPhone: '+255 756 789 012',
        reason: 'Multiple issues',
        amount: 265000,
        items: [
          ReturnItemModel(
            productId: 'prod-345',
            productName: 'Microwave Oven',
            quantity: 1,
            price: 180000,
            reason: 'Door doesn\'t close properly',
          ),
          ReturnItemModel(
            productId: 'prod-678',
            productName: 'Kitchen Scale',
            quantity: 1,
            price: 85000,
            reason: 'Inaccurate measurements',
          ),
        ],
        status: 'approved',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 9)),
        notes: 'Both items verified as defective',
        isRefunded: true,
        refundAmount: 265000,
      ),
    ];
  }
}
