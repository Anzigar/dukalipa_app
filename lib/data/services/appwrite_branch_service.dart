import 'package:appwrite/appwrite.dart';
import '../../core/services/appwrite_service.dart';
import '../../presentation/features/branches/models/branch_model.dart';

/// Service for handling branch operations using Appwrite backend
class AppwriteBranchService {
  final Databases _databases;
  final String _databaseId = 'shop_management_db';

  AppwriteBranchService() : _databases = AppwriteService().databases;

  /// Get all branches with optional filtering
  Future<List<BranchModel>> getBranches({
    String? search,
    bool? isActive,
  }) async {
    try {
      List<String> queries = [];

      // Add search functionality
      if (search != null && search.isNotEmpty) {
        queries.add(Query.search('name', search));
      }

      // Add active status filter
      if (isActive != null) {
        queries.add(Query.equal('is_active', isActive));
      }

      // Order by creation date (newest first)
      queries.add(Query.orderDesc('\$createdAt'));
      queries.add(Query.limit(100));

      final branchDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'branches',
        queries: queries,
      );

      return branchDocs.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['id'] = doc.$id;
        return BranchModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch branches: ${e.toString()}');
    }
  }

  /// Get a specific branch by ID
  Future<BranchModel> getBranchById(String branchId) async {
    try {
      final branchDoc = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: 'branches',
        documentId: branchId,
      );

      final data = Map<String, dynamic>.from(branchDoc.data);
      data['id'] = branchDoc.$id;

      return BranchModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch branch: ${e.toString()}');
    }
  }

  /// Create a new branch
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
      final branchId = ID.unique();

      final branchData = {
        'name': name,
        'location': location,
        'phone_number': phoneNumber,
        'email': email,
        'manager_name': managerName,
        'staff_count': staffCount,
        'monthly_revenue': monthlyRevenue,
        'monthly_expenses': monthlyExpenses,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        '\$createdAt': DateTime.now().toIso8601String(),
        '\$updatedAt': DateTime.now().toIso8601String(),
      };

      final createdDoc = await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: 'branches',
        documentId: branchId,
        data: branchData,
      );

      final resultData = Map<String, dynamic>.from(createdDoc.data);
      resultData['id'] = createdDoc.$id;
      return BranchModel.fromJson(resultData);
    } catch (e) {
      throw Exception('Failed to create branch: ${e.toString()}');
    }
  }

  /// Update an existing branch
  Future<BranchModel> updateBranch(String branchId, {
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
      final updateData = <String, dynamic>{};

      if (name != null) updateData['name'] = name;
      if (location != null) updateData['location'] = location;
      if (phoneNumber != null) updateData['phone_number'] = phoneNumber;
      if (email != null) updateData['email'] = email;
      if (managerName != null) updateData['manager_name'] = managerName;
      if (staffCount != null) updateData['staff_count'] = staffCount;
      if (monthlyRevenue != null) updateData['monthly_revenue'] = monthlyRevenue;
      if (monthlyExpenses != null) updateData['monthly_expenses'] = monthlyExpenses;
      if (isActive != null) updateData['is_active'] = isActive;

      updateData['\$updatedAt'] = DateTime.now().toIso8601String();

      await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: 'branches',
        documentId: branchId,
        data: updateData,
      );

      return await getBranchById(branchId);
    } catch (e) {
      throw Exception('Failed to update branch: ${e.toString()}');
    }
  }

  /// Delete a branch
  Future<void> deleteBranch(String branchId) async {
    try {
      await _databases.deleteDocument(
        databaseId: _databaseId,
        collectionId: 'branches',
        documentId: branchId,
      );
    } catch (e) {
      throw Exception('Failed to delete branch: ${e.toString()}');
    }
  }

  /// Deactivate a branch (soft delete)
  Future<BranchModel> deactivateBranch(String branchId) async {
    try {
      return await updateBranch(branchId, isActive: false);
    } catch (e) {
      throw Exception('Failed to deactivate branch: ${e.toString()}');
    }
  }

  /// Activate a branch
  Future<BranchModel> activateBranch(String branchId) async {
    try {
      return await updateBranch(branchId, isActive: true);
    } catch (e) {
      throw Exception('Failed to activate branch: ${e.toString()}');
    }
  }

  /// Get branch performance statistics
  Future<Map<String, dynamic>> getBranchStatistics() async {
    try {
      final branchDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'branches',
        queries: [
          Query.limit(1000),
        ],
      );

      int activeBranches = 0;
      int inactiveBranches = 0;
      double totalRevenue = 0;
      double totalExpenses = 0;
      int totalStaff = 0;

      for (var doc in branchDocs.documents) {
        final isActive = doc.data['is_active'] as bool? ?? true;
        final revenue = (doc.data['monthly_revenue'] ?? 0).toDouble();
        final expenses = (doc.data['monthly_expenses'] ?? 0).toDouble();
        final staff = (doc.data['staff_count'] ?? 0) as int;

        if (isActive) {
          activeBranches++;
          totalRevenue += revenue;
          totalExpenses += expenses;
          totalStaff += staff;
        } else {
          inactiveBranches++;
        }
      }

      return {
        'total_branches': branchDocs.total,
        'active_branches': activeBranches,
        'inactive_branches': inactiveBranches,
        'total_revenue': totalRevenue,
        'total_expenses': totalExpenses,
        'total_profit': totalRevenue - totalExpenses,
        'total_staff': totalStaff,
        'average_revenue_per_branch': activeBranches > 0 ? totalRevenue / activeBranches : 0.0,
        'average_staff_per_branch': activeBranches > 0 ? totalStaff / activeBranches : 0.0,
      };
    } catch (e) {
      throw Exception('Failed to fetch branch statistics: ${e.toString()}');
    }
  }

  /// Get top performing branches by revenue
  Future<List<BranchModel>> getTopPerformingBranches({int limit = 5}) async {
    try {
      final branchDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'branches',
        queries: [
          Query.equal('is_active', true),
          Query.orderDesc('monthly_revenue'),
          Query.limit(limit),
        ],
      );

      return branchDocs.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['id'] = doc.$id;
        return BranchModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch top performing branches: ${e.toString()}');
    }
  }

  /// Search branches by name or location
  Future<List<BranchModel>> searchBranches(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      // Search by name
      final nameResults = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'branches',
        queries: [
          Query.search('name', query),
          Query.limit(20),
        ],
      );

      // Search by location
      final locationResults = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'branches',
        queries: [
          Query.search('location', query),
          Query.limit(20),
        ],
      );

      // Combine results and remove duplicates
      Set<String> seenIds = {};
      List<BranchModel> branches = [];

      for (var doc in [...nameResults.documents, ...locationResults.documents]) {
        if (!seenIds.contains(doc.$id)) {
          seenIds.add(doc.$id);
          final data = Map<String, dynamic>.from(doc.data);
          data['id'] = doc.$id;
          branches.add(BranchModel.fromJson(data));
        }
      }

      return branches;
    } catch (e) {
      throw Exception('Failed to search branches: ${e.toString()}');
    }
  }

  /// Update branch financial data
  Future<BranchModel> updateBranchFinancials(
    String branchId, {
    required double monthlyRevenue,
    required double monthlyExpenses,
  }) async {
    try {
      return await updateBranch(
        branchId,
        monthlyRevenue: monthlyRevenue,
        monthlyExpenses: monthlyExpenses,
      );
    } catch (e) {
      throw Exception('Failed to update branch financials: ${e.toString()}');
    }
  }
}