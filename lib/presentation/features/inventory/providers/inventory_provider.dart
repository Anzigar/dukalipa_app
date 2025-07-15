import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../repositories/inventory_repository.dart';

class InventoryProvider extends ChangeNotifier {
  final InventoryRepository _inventoryRepository;
  
  // Add disposal flag
  bool _isDisposed = false;

  InventoryProvider(this._inventoryRepository);

  // Product data
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  List<String> _categories = [];
  List<String> _suppliers = [];
  
  // Loading states
  bool _isLoadingProducts = false;
  bool _isLoadingCategories = false;
  bool _isLoadingSuppliers = false;
  bool _isCreatingProduct = false;
  bool _isUpdatingProduct = false;
  bool _isDeletingProduct = false;

  // Error states
  String? _productsError;
  String? _categoriesError;
  String? _suppliersError;
  String? _createError;
  String? _updateError;
  String? _deleteError;

  // Filter states
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedSupplier;
  
  // Pagination
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMoreProducts = true;

  // Getters
  List<ProductModel> get products => _filteredProducts;
  List<ProductModel> get allProducts => _products;
  List<String> get categories => _categories;
  List<String> get suppliers => _suppliers;

  bool get isLoadingProducts => _isLoadingProducts;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingSuppliers => _isLoadingSuppliers;
  bool get isCreatingProduct => _isCreatingProduct;
  bool get isUpdatingProduct => _isUpdatingProduct;
  bool get isDeletingProduct => _isDeletingProduct;

  String? get productsError => _productsError;
  String? get categoriesError => _categoriesError;
  String? get suppliersError => _suppliersError;
  String? get createError => _createError;
  String? get updateError => _updateError;
  String? get deleteError => _deleteError;

  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  String? get selectedSupplier => _selectedSupplier;
  
  int get currentPage => _currentPage;
  bool get hasMoreProducts => _hasMoreProducts;

  // Computed properties
  int get totalProducts => _products.length;
  int get lowStockCount => _products.where((p) => p.isLowStock).length;
  int get outOfStockCount => _products.where((p) => p.isOutOfStock).length;
  
  // Fix: Calculate total inventory value properly for all product types
  double get totalInventoryValue => _products.fold(0.0, (sum, product) {
    // Handle products with or without serial numbers
    // Use quantity * cost price for accessories and other non-serialized items
    double productValue = product.quantity * product.costPrice;
    return sum + productValue;
  });

  List<ProductModel> get lowStockProducts => _products.where((p) => p.isLowStock).toList();
  List<ProductModel> get outOfStockProducts => _products.where((p) => p.isOutOfStock).toList();

  /// Load products with optional filters and pagination
  Future<void> loadProducts({
    String? search,
    String? category,
    String? supplier,
    bool forceRefresh = false,
    bool loadMore = false,
  }) async {
    if (_isLoadingProducts && !forceRefresh) return;

    if (!loadMore || forceRefresh) {
      _currentPage = 1;
      _hasMoreProducts = true;
    }

    _isLoadingProducts = true;
    _productsError = null;
    
    if (!loadMore) {
      notifyListeners();
    }

    try {
      final newProducts = await _inventoryRepository.getProducts(
        search: search ?? _searchQuery,
        category: category ?? _selectedCategory,
        supplier: supplier ?? _selectedSupplier,
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (loadMore) {
        _products.addAll(newProducts);
        _hasMoreProducts = newProducts.length == _pageSize;
        _currentPage++;
      } else {
        _products = newProducts;
        _hasMoreProducts = newProducts.length == _pageSize;
        if (_hasMoreProducts) _currentPage++;
      }

      // Since filtering is done on backend, filtered products are same as products
      _filteredProducts = _products;
      _productsError = null;
    } catch (e) {
      _productsError = e.toString();
      if (kDebugMode) {
        print('Products loading error: $e');
      }
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  /// Load categories
  Future<void> loadCategories({bool forceRefresh = false}) async {
    if (_isLoadingCategories && !forceRefresh) return;
    if (_categories.isNotEmpty && !forceRefresh) return;

    _isLoadingCategories = true;
    _categoriesError = null;
    notifyListeners();

    try {
      _categories = await _inventoryRepository.getCategories();
      _categoriesError = null;
    } catch (e) {
      _categoriesError = e.toString();
      if (kDebugMode) {
        print('Categories loading error: $e');
      }
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  /// Load suppliers
  Future<void> loadSuppliers({bool forceRefresh = false}) async {
    if (_isLoadingSuppliers && !forceRefresh) return;
    if (_suppliers.isNotEmpty && !forceRefresh) return;

    _isLoadingSuppliers = true;
    _suppliersError = null;
    notifyListeners();

    try {
      _suppliers = await _inventoryRepository.getSuppliers();
      _suppliersError = null;
    } catch (e) {
      _suppliersError = e.toString();
      if (kDebugMode) {
        print('Suppliers loading error: $e');
      }
    } finally {
      _isLoadingSuppliers = false;
      notifyListeners();
    }
  }

  /// Create a new product
  Future<bool> createProduct(ProductModel product, {File? imageFile}) async {
    _isCreatingProduct = true;
    _createError = null;
    notifyListeners();

    try {
      final createdProduct = await _inventoryRepository.createProduct(product);
      if (imageFile != null) {
        // Handle image upload if necessary
        // await _inventoryService.uploadProductImage(createdProduct.id, imageFile);
      }           
      _products.insert(0, createdProduct);
      _filteredProducts = _products;
      _createError = null;
      
      return true;
    } catch (e) {
      _createError = e.toString();
      if (kDebugMode) {
        print('Product creation error: $e');
      }
      return false;
    } finally {
      _isCreatingProduct = false;
      notifyListeners();
    }
  }

  /// Update an existing product
  Future<bool> updateProduct(ProductModel product, {File? imageFile}) async {
    _isUpdatingProduct = true;
    _updateError = null;
    notifyListeners();

    try {
      final updatedProduct = await _inventoryRepository.updateProduct(
        product, 
        imageFile: imageFile,
      );
      
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updatedProduct;
        _filteredProducts = _products;
      }
      
      _updateError = null;
      return true;
    } catch (e) {
      _updateError = e.toString();
      if (kDebugMode) {
        print('Product update error: $e');
      }
      return false;
    } finally {
      _isUpdatingProduct = false;
      notifyListeners();
    }
  }

  /// Delete a product
  Future<bool> deleteProduct(String productId) async {
    _isDeletingProduct = true;
    _deleteError = null;
    notifyListeners();

    try {
      await _inventoryRepository.deleteProduct(productId);
      
      _products.removeWhere((p) => p.id == productId);
      _filteredProducts = _products;
      _deleteError = null;
      
      return true;
    } catch (e) {
      _deleteError = e.toString();
      if (kDebugMode) {
        print('Product deletion error: $e');
      }
      return false;
    } finally {
      _isDeletingProduct = false;
      notifyListeners();
    }
  }

  /// Get product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      // First check if we have it in our local cache
      final cachedProduct = _products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw StateError('Product not found in cache'),
      );
      return cachedProduct;
    } catch (e) {
      // If not in cache, fetch from repository
      try {
        return await _inventoryRepository.getProductById(productId);
      } catch (e) {
        if (kDebugMode) {
          print('Get product by ID error: $e');
        }
        return null;
      }
    }
  }

  /// Search products by barcode
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    try {
      return await _inventoryRepository.getProductByBarcode(barcode);
    } catch (e) {
      if (kDebugMode) {
        print('Barcode search error: $e');
      }
      return null;
    }
  }

  /// Apply search filter
  void searchProducts(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Apply category filter
  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  /// Apply supplier filter
  void filterBySupplier(String? supplier) {
    _selectedSupplier = supplier;
    _applyFilters();
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedSupplier = null;
    _applyFilters();
    notifyListeners();
  }

  /// Apply current filters to products list
  void _applyFilters() {
    _filteredProducts = _products.where((product) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = product.name.toLowerCase().contains(query);
        final matchesBarcode = product.barcode?.toLowerCase().contains(query) ?? false;
        final matchesCategory = product.category?.toLowerCase().contains(query) ?? false;
        
        if (!matchesName && !matchesBarcode && !matchesCategory) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
        if (product.category != _selectedCategory) {
          return false;
        }
      }

      // Supplier filter
      if (_selectedSupplier != null && _selectedSupplier!.isNotEmpty) {
        if (product.supplier != _selectedSupplier) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadProducts(forceRefresh: true),
      loadCategories(forceRefresh: true),
      loadSuppliers(forceRefresh: true),
    ]);
  }

  /// Clear all data and errors
  void clearData() {
    _products = [];
    _filteredProducts = [];
    _categories = [];
    _suppliers = [];
    
    _productsError = null;
    _categoriesError = null;
    _suppliersError = null;
    _createError = null;
    _updateError = null;
    _deleteError = null;
    
    _searchQuery = '';
    _selectedCategory = null;
    _selectedSupplier = null;
    _currentPage = 1;
    _hasMoreProducts = true;
    
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
