import 'dart:async';
import 'package:dio/dio.dart';
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
  late final Dio _dio;
  
  CustomerRepositoryImpl() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api/v1',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }
  
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
      
      final response = await _dio.get('/customers', queryParameters: queryParams);
      
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => CustomerModel.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<CustomerModel> getCustomerById(String id) async {
    try {
      final response = await _dio.get('/customers/$id');
      return CustomerModel.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    try {
      final response = await _dio.post(
        '/customers',
        data: {
          'name': customer.name,
          'phone_number': customer.phoneNumber,
          'email': customer.email,
          'address': customer.address,
        },
      );
      
      return CustomerModel.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<CustomerModel> updateCustomer(CustomerModel customer) async {
    try {
      final response = await _dio.put(
        '/customers/${customer.id}',
        data: {
          'name': customer.name,
          'phone_number': customer.phoneNumber,
          'email': customer.email,
          'address': customer.address,
        },
      );
      
      return CustomerModel.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  @override
  Future<void> deleteCustomer(String id) async {
    try {
      await _dio.delete('/customers/$id');
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
      final response = await _dio.get('/customers', queryParameters: {'search': query});
      
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => CustomerModel.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  Exception _handleError(dynamic e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return Exception('Network error. Please check your internet connection.');
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          if (statusCode == 404) {
            return Exception('Customer not found.');
          }
          if (statusCode == 401 || statusCode == 403) {
            return Exception('Authentication error. Please login again.');
          }
          return Exception('Server error: ${e.response?.statusMessage}');
        default:
          return Exception('An error occurred: ${e.message}');
      }
    }
    
    return Exception('An error occurred: ${e.toString()}');
  }
}
