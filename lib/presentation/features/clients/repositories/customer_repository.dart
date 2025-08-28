import 'dart:async';
import '../../../../data/services/appwrite_customer_service.dart';
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
  final AppwriteCustomerService _customerService;
  
  CustomerRepositoryImpl() : _customerService = AppwriteCustomerService();
  
  @override
  Future<List<CustomerModel>> getCustomers({
    String? search,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _customerService.getCustomers(
        search: search,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to fetch customers: ${e.toString()}');
    }
  }
  
  @override
  Future<CustomerModel> getCustomerById(String id) async {
    try {
      return await _customerService.getCustomerById(id);
    } catch (e) {
      throw Exception('Failed to fetch customer: ${e.toString()}');
    }
  }
  
  @override
  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    try {
      final data = customer.toJson();
      return await _customerService.createCustomer(data);
    } catch (e) {
      throw Exception('Failed to create customer: ${e.toString()}');
    }
  }
  
  @override
  Future<CustomerModel> updateCustomer(CustomerModel customer) async {
    try {
      final data = customer.toJson();
      return await _customerService.updateCustomer(customer.id, data);
    } catch (e) {
      throw Exception('Failed to update customer: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteCustomer(String id) async {
    try {
      await _customerService.deleteCustomer(id);
    } catch (e) {
      throw Exception('Failed to delete customer: ${e.toString()}');
    }
  }
  
  @override
  Future<List<CustomerModel>> searchClients(String query) async {
    try {
      return await _customerService.searchCustomers(query);
    } catch (e) {
      throw Exception('Failed to search customers: ${e.toString()}');
    }
  }
}