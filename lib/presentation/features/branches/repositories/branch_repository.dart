import '../../../../data/services/appwrite_branch_service.dart';
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
    int staffCount = 0,
    double monthlyRevenue = 0.0,
    double monthlyExpenses = 0.0,
  });
  
  Future<BranchModel> updateBranch(String id, {
    String? name,
    String? location,
    String? phoneNumber,
    String? email,
    String? managerName,
    int? staffCount,
    double? monthlyRevenue,
    double? monthlyExpenses,
    bool? isActive,
  });
  
  Future<void> deleteBranch(String id);
  
  Future<BranchModel> deactivateBranch(String id);
  
  Future<BranchModel> activateBranch(String id);
  
  Future<Map<String, dynamic>> getBranchStatistics();
  
  Future<List<BranchModel>> getTopPerformingBranches({int limit = 5});
  
  Future<List<BranchModel>> searchBranches(String query);
}

class BranchRepositoryImpl implements BranchRepository {
  final AppwriteBranchService _branchService;
  
  BranchRepositoryImpl() : _branchService = AppwriteBranchService();
  
  @override
  Future<List<BranchModel>> getBranches({
    String? search,
    bool? isActive,
  }) async {
    try {
      return await _branchService.getBranches(
        search: search,
        isActive: isActive,
      );
    } catch (e) {
      throw Exception('Failed to fetch branches: ${e.toString()}');
    }
  }
  
  @override
  Future<BranchModel> getBranchById(String id) async {
    try {
      return await _branchService.getBranchById(id);
    } catch (e) {
      throw Exception('Failed to fetch branch: ${e.toString()}');
    }
  }
  
  @override
  Future<BranchModel> createBranch({
    required String name,
    required String location,
    String? phoneNumber,
    String? email,
    String? managerName,
    int staffCount = 0,
    double monthlyRevenue = 0.0,
    double monthlyExpenses = 0.0,
  }) async {
    try {
      return await _branchService.createBranch(
        name: name,
        location: location,
        phoneNumber: phoneNumber,
        email: email,
        managerName: managerName,
        staffCount: staffCount,
        monthlyRevenue: monthlyRevenue,
        monthlyExpenses: monthlyExpenses,
      );
    } catch (e) {
      throw Exception('Failed to create branch: ${e.toString()}');
    }
  }
  
  @override
  Future<BranchModel> updateBranch(String id, {
    String? name,
    String? location,
    String? phoneNumber,
    String? email,
    String? managerName,
    int? staffCount,
    double? monthlyRevenue,
    double? monthlyExpenses,
    bool? isActive,
  }) async {
    try {
      return await _branchService.updateBranch(
        id,
        name: name,
        location: location,
        phoneNumber: phoneNumber,
        email: email,
        managerName: managerName,
        staffCount: staffCount,
        monthlyRevenue: monthlyRevenue,
        monthlyExpenses: monthlyExpenses,
        isActive: isActive,
      );
    } catch (e) {
      throw Exception('Failed to update branch: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteBranch(String id) async {
    try {
      await _branchService.deleteBranch(id);
    } catch (e) {
      throw Exception('Failed to delete branch: ${e.toString()}');
    }
  }
  
  @override
  Future<BranchModel> deactivateBranch(String id) async {
    try {
      return await _branchService.deactivateBranch(id);
    } catch (e) {
      throw Exception('Failed to deactivate branch: ${e.toString()}');
    }
  }
  
  @override
  Future<BranchModel> activateBranch(String id) async {
    try {
      return await _branchService.activateBranch(id);
    } catch (e) {
      throw Exception('Failed to activate branch: ${e.toString()}');
    }
  }
  
  @override
  Future<Map<String, dynamic>> getBranchStatistics() async {
    try {
      return await _branchService.getBranchStatistics();
    } catch (e) {
      throw Exception('Failed to fetch branch statistics: ${e.toString()}');
    }
  }
  
  @override
  Future<List<BranchModel>> getTopPerformingBranches({int limit = 5}) async {
    try {
      return await _branchService.getTopPerformingBranches(limit: limit);
    } catch (e) {
      throw Exception('Failed to fetch top performing branches: ${e.toString()}');
    }
  }
  
  @override
  Future<List<BranchModel>> searchBranches(String query) async {
    try {
      return await _branchService.searchBranches(query);
    } catch (e) {
      throw Exception('Failed to search branches: ${e.toString()}');
    }
  }
}