import 'dart:async';
import '../../../../data/services/appwrite_supplier_service.dart';
import '../models/supplier_model.dart';

abstract class SupplierRepository {
  Future<List<SupplierModel>> getSuppliers({
    String? search,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<SupplierModel> getSupplierById(String id);
  
  Future<SupplierModel> createSupplier(SupplierModel supplier);
  
  Future<SupplierModel> updateSupplier(SupplierModel supplier);
  
  Future<void> deleteSupplier(String id);
}

class SupplierRepositoryImpl implements SupplierRepository {
  final AppwriteSupplierService _supplierService;

  SupplierRepositoryImpl() : _supplierService = AppwriteSupplierService();

  @override
  Future<List<SupplierModel>> getSuppliers({
    String? search,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _supplierService.getSuppliers(
        search: search,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to fetch suppliers: ${e.toString()}');
    }
  }

  @override
  Future<SupplierModel> getSupplierById(String id) async {
    try {
      return await _supplierService.getSupplierById(id);
    } catch (e) {
      throw Exception('Failed to fetch supplier: ${e.toString()}');
    }
  }

  @override
  Future<SupplierModel> createSupplier(SupplierModel supplier) async {
    try {
      return await _supplierService.createSupplier(supplier);
    } catch (e) {
      throw Exception('Failed to create supplier: ${e.toString()}');
    }
  }

  @override
  Future<SupplierModel> updateSupplier(SupplierModel supplier) async {
    try {
      return await _supplierService.updateSupplier(supplier);
    } catch (e) {
      throw Exception('Failed to update supplier: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteSupplier(String id) async {
    try {
      await _supplierService.deleteSupplier(id);
    } catch (e) {
      throw Exception('Failed to delete supplier: ${e.toString()}');
    }
  }

}
