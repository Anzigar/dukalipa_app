import 'dart:async';
import '../../../../core/network/api_client.dart';
import '../models/branch_model.dart';

abstract class BranchRepository {
  Future<List<BranchModel>> getBranches({
    String? search,
    bool? isActive,
  });
  
  Future<BranchModel> getBranchById(String id);
  
  Future<BranchModel> createBranch({
    required String name,
    required String location,
    String? phoneNumber,
    String? email,
    String? managerName,
  });
  
  Future<BranchModel> updateBranch({
    required String id,
    String? name,
    String? location,
    String? phoneNumber,
    String? email,
    String? managerName,
    bool? isActive,
  });
  
  Future<void> deleteBranch(String id);
}

class BranchRepositoryImpl implements BranchRepository {
  final ApiClient _apiClient;

  BranchRepositoryImpl(this._apiClient);

  @override
  Future<List<BranchModel>> getBranches({
    String? search,
    bool? isActive,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (isActive != null) {
        queryParams['is_active'] = isActive.toString();
      }

      final response = await _apiClient.get('/branches', queryParameters: queryParams);
      final List<dynamic> data = response['data'] ?? [];
      return data.map((item) => BranchModel.fromJson(item)).toList();
    } catch (e) {
      // For demo purposes, return mock data
      return _getMockBranches();
    }
  }

  @override
  Future<BranchModel> getBranchById(String id) async {
    try {
      final response = await _apiClient.get('/branches/$id');
      return BranchModel.fromJson(response['data']);
    } catch (e) {
      // Return a mock branch
      return _getMockBranches().firstWhere((b) => b.id == id, 
        orElse: () => _getMockBranches().first);
    }
  }

  @override
  Future<BranchModel> createBranch({
    required String name,
    required String location,
    String? phoneNumber,
    String? email,
    String? managerName,
  }) async {
    try {
      final data = {
        'name': name,
        'location': location,
      };
      
      if (phoneNumber != null) data['phone_number'] = phoneNumber;
      if (email != null) data['email'] = email;
      if (managerName != null) data['manager_name'] = managerName;
      
      final response = await _apiClient.post('/branches', data: data);
      return BranchModel.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<BranchModel> updateBranch({
    required String id,
    String? name,
    String? location,
    String? phoneNumber,
    String? email,
    String? managerName,
    bool? isActive,
  }) async {
    try {
      final data = <String, dynamic>{};
      
      if (name != null) data['name'] = name;
      if (location != null) data['location'] = location;
      if (phoneNumber != null) data['phone_number'] = phoneNumber;
      if (email != null) data['email'] = email;
      if (managerName != null) data['manager_name'] = managerName;
      if (isActive != null) data['is_active'] = isActive;
      
      final response = await _apiClient.put('/branches/$id', data: data);
      return BranchModel.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteBranch(String id) async {
    try {
      await _apiClient.delete('/branches/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is TimeoutException) {
      return Exception('Connection timed out. Please check your internet connection.');
    }
    return Exception('Failed to perform operation: $error');
  }

  // Mock data for demonstration
  List<BranchModel> _getMockBranches() {
    return [
      BranchModel(
        id: '1',
        name: 'Main Branch',
        location: 'Dar es Salaam City Center',
        phoneNumber: '+255712345678',
        email: 'main@dukalipa.co.tz',
        managerName: 'John Manager',
        staffCount: 12,
        monthlyRevenue: 4500000,
        monthlyExpenses: 2800000,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        isActive: true,
      ),
      BranchModel(
        id: '2',
        name: 'Arusha Branch',
        location: 'Arusha Central Market',
        phoneNumber: '+255723456789',
        email: 'arusha@dukalipa.co.tz',
        managerName: 'Sarah Manager',
        staffCount: 8,
        monthlyRevenue: 3200000,
        monthlyExpenses: 1900000,
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
        isActive: true,
      ),
      BranchModel(
        id: '3',
        name: 'Mwanza Branch',
        location: 'Mwanza Shopping Mall',
        phoneNumber: '+255734567890',
        email: 'mwanza@dukalipa.co.tz',
        managerName: 'David Manager',
        staffCount: 6,
        monthlyRevenue: 2800000,
        monthlyExpenses: 1600000,
        createdAt: DateTime.now().subtract(const Duration(days: 240)),
        isActive: true,
      ),
      BranchModel(
        id: '4',
        name: 'Dodoma Branch',
        location: 'Dodoma Central Business District',
        phoneNumber: '+255745678901',
        email: 'dodoma@dukalipa.co.tz',
        managerName: 'Michael Manager',
        staffCount: 5,
        monthlyRevenue: 1800000,
        monthlyExpenses: 1200000,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        isActive: false,
      ),
      BranchModel(
        id: '5',
        name: 'Zanzibar Branch',
        location: 'Stone Town, Zanzibar',
        phoneNumber: '+255756789012',
        email: 'zanzibar@dukalipa.co.tz',
        managerName: 'Anna Manager',
        staffCount: 7,
        monthlyRevenue: 2500000,
        monthlyExpenses: 1500000,
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        isActive: true,
      ),
    ];
  }
}
