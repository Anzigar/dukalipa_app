import 'dart:async';
import '../../../../core/network/api_client.dart';
import '../models/customer_model.dart';

abstract class CustomerRepository {
  Future<List<CustomerModel>> getCustomers({
    String? search,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<CustomerModel> getCustomerById(String id);
  
  Future<CustomerModel> createCustomer(CustomerModel customer);
  
  Future<CustomerModel> updateCustomer(CustomerModel customer);
  
  Future<void> deleteCustomer(String id);
  
  Future<List<CustomerModel>> searchClients(String query);
}

class CustomerRepositoryImpl implements CustomerRepository {
  final ApiClient _apiClient;
  
  CustomerRepositoryImpl(this._apiClient);
  
  @override
  Future<List<CustomerModel>> getCustomers({
    String? search,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (startDate != null) {
        queryParams['start_date'] = _formatDateForApi(startDate);
      }
      
      if (endDate != null) {
        queryParams['end_date'] = _formatDateForApi(endDate);
      }
      
      final response = await _apiClient.get('/customers', queryParameters: queryParams);
      
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => CustomerModel.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<CustomerModel> getCustomerById(String id) async {
    try {
      final response = await _apiClient.get('/customers/$id');
      return CustomerModel.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    try {
      final response = await _apiClient.post(
        '/customers',
        data: {
          'name': customer.name,
          'phone_number': customer.phoneNumber,
          'email': customer.email,
          'address': customer.address,
        },
      );
      
      return CustomerModel.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<CustomerModel> updateCustomer(CustomerModel customer) async {
    try {
      final response = await _apiClient.put(
        '/customers/${customer.id}',
        data: {
          'name': customer.name,
          'phone_number': customer.phoneNumber,
          'email': customer.email,
          'address': customer.address,
        },
      );
      
      return CustomerModel.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<void> deleteCustomer(String id) async {
    try {
      await _apiClient.delete('/customers/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<List<CustomerModel>> searchClients(String query) async {
    if (query.isEmpty) {
      return [];
    }
    
    try {
      final response = await _apiClient.get('/customers', queryParameters: {'search': query});
      
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => CustomerModel.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  Exception _handleError(dynamic e) {
    if (e.toString().contains('No connection')) {
      return Exception('Network error. Please check your internet connection.');
    }
    
    if (e.toString().contains('404')) {
      return Exception('Customer not found.');
    }
    
    if (e.toString().contains('401') || e.toString().contains('403')) {
      return Exception('Authentication error. Please login again.');
    }
    
    return Exception('An error occurred: ${e.toString()}');
  }
}
