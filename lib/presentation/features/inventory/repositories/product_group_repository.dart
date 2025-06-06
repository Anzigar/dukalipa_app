import 'dart:io';
import '../models/product_group_model.dart';

abstract class ProductGroupRepository {
  Future<List<ProductGroupModel>> getGroups();
  Future<ProductGroupModel> getGroupById(String id);
  Future<ProductGroupModel> createGroup(ProductGroupModel group, {File? imageFile});
  Future<ProductGroupModel> updateGroup(ProductGroupModel group, {File? imageFile});
  Future<void> deleteGroup(String id);
  Future<List<ProductGroupModel>> searchGroups(String query);
}

class ProductGroupRepositoryImpl implements ProductGroupRepository {
  // Dummy implementation for now
  static final List<ProductGroupModel> _dummyGroups = [
    ProductGroupModel(
      id: '1',
      name: 'Electronics',
      description: 'Electronic devices and accessories',
      color: '#2196F3',
      categories: ['Smartphones', 'Laptops', 'Tablets', 'Accessories'],
      productCount: 15,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
    ProductGroupModel(
      id: '2',
      name: 'Clothing',
      description: 'Fashion and apparel items',
      color: '#E91E63',
      categories: ['Men\'s Wear', 'Women\'s Wear', 'Kids Wear', 'Shoes'],
      productCount: 25,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now(),
    ),
    ProductGroupModel(
      id: '3',
      name: 'Food & Beverages',
      description: 'Food items and drinks',
      color: '#4CAF50',
      categories: ['Snacks', 'Beverages', 'Dairy', 'Fruits'],
      productCount: 40,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<ProductGroupModel>> getGroups() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_dummyGroups);
  }

  @override
  Future<ProductGroupModel> getGroupById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _dummyGroups.firstWhere((group) => group.id == id);
  }

  @override
  Future<ProductGroupModel> createGroup(ProductGroupModel group, {File? imageFile}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _dummyGroups.add(group);
    return group;
  }

  @override
  Future<ProductGroupModel> updateGroup(ProductGroupModel group, {File? imageFile}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final index = _dummyGroups.indexWhere((g) => g.id == group.id);
    if (index != -1) {
      _dummyGroups[index] = group;
    }
    return group;
  }

  @override
  Future<void> deleteGroup(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _dummyGroups.removeWhere((group) => group.id == id);
  }

  @override
  Future<List<ProductGroupModel>> searchGroups(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _dummyGroups.where((group) => 
      group.name.toLowerCase().contains(query.toLowerCase()) ||
      group.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
