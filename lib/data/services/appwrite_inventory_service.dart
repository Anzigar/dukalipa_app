import 'dart:io';
import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import '../../config/environment.dart';
import '../../presentation/features/inventory/models/product_model.dart';
import '../../presentation/features/inventory/models/device_entry_model.dart';

class AppwriteInventoryService {
  late final Client _client;
  late final Databases _databases;
  late final Storage _storage;
  late final Account _account;

  static const String _databaseId = 'shop_management_db';
  static const String _productsCollectionId = 'products';
  static const String _storageId = 'product_images';

  AppwriteInventoryService() {
    _client = Client()
        .setEndpoint(Environment.appwritePublicEndpoint)
        .setProject(Environment.appwriteProjectId)
        .setSelfSigned(status: true);
    
    _databases = Databases(_client);
    _storage = Storage(_client);
    _account = Account(_client);
  }

  /// Get current user ID for data isolation
  Future<String?> _getCurrentUserId() async {
    try {
      final user = await _account.get();
      return user.$id;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current user: $e');
      }
      return null;
    }
  }

  /// Get all products with optional filters
  Future<List<ProductModel>> getProducts({
    String? search,
    String? category,
    String? supplier,
    int? page,
    int? pageSize,
    bool? lowStock,
  }) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Build queries for filtering
      List<String> queries = [
        Query.equal('user_id', userId),
      ];

      if (search != null && search.isNotEmpty) {
        queries.add(Query.search('name', search));
      }

      if (category != null && category.isNotEmpty) {
        queries.add(Query.equal('category', category));
      }

      if (supplier != null && supplier.isNotEmpty) {
        queries.add(Query.equal('supplier', supplier));
      }

      if (lowStock == true) {
        // This would require a complex query - we'll filter in memory for now
      }

      // Add pagination
      if (pageSize != null) {
        queries.add(Query.limit(pageSize));
      }

      if (page != null && pageSize != null) {
        final offset = (page - 1) * pageSize;
        queries.add(Query.offset(offset));
      }

      // Add ordering by creation date
      queries.add(Query.orderDesc('created_at'));

      final response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _productsCollectionId,
        queries: queries,
      );

      List<ProductModel> products = response.documents.map((doc) {
        final data = doc.data;
        
        // Handle JSON string fields
        Map<String, dynamic>? metadata;
        if (data['product_metadata'] != null) {
          try {
            metadata = jsonDecode(data['product_metadata'] as String);
          } catch (e) {
            metadata = null;
          }
        }

        List<dynamic>? deviceEntries;
        if (data['device_entries'] != null) {
          try {
            deviceEntries = jsonDecode(data['device_entries'] as String);
          } catch (e) {
            deviceEntries = null;
          }
        }

        // Convert Appwrite document to ProductModel
        return ProductModel(
          id: doc.$id,
          name: data['name'] ?? '',
          description: data['description'],
          barcode: data['barcode'],
          sellingPrice: (data['selling_price'] ?? 0).toDouble(),
          costPrice: (data['cost_price'] ?? 0).toDouble(),
          quantity: data['stock_quantity'] ?? 0,
          lowStockThreshold: data['low_stock_threshold'] ?? 5,
          reorderLevel: data['reorder_level'],
          category: data['category'],
          supplier: data['supplier'],
          imageUrl: data['image_url'],
          metadata: metadata,
          deviceEntries: deviceEntries?.map((e) => DeviceEntryModel.fromJson(e)).toList(),
          createdAt: DateTime.parse(data['created_at']),
          updatedAt: DateTime.parse(data['updated_at']),
        );
      }).toList();

      // Apply low stock filter if needed (since Appwrite doesn't support complex queries easily)
      if (lowStock == true) {
        products = products.where((p) => p.isLowStock).toList();
      }

      return products;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching products: $e');
      }
      throw Exception('Failed to fetch products: ${e.toString()}');
    }
  }

  /// Get a specific product by ID
  Future<ProductModel> getProductById(String productId) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: _productsCollectionId,
        documentId: productId,
      );

      // Verify the product belongs to the current user
      if (response.data['user_id'] != userId) {
        throw Exception('Product not found or access denied');
      }

      final data = response.data;
      
      // Handle JSON string fields
      Map<String, dynamic>? metadata;
      if (data['product_metadata'] != null) {
        try {
          metadata = jsonDecode(data['product_metadata'] as String);
        } catch (e) {
          metadata = null;
        }
      }

      List<dynamic>? deviceEntries;
      if (data['device_entries'] != null) {
        try {
          deviceEntries = jsonDecode(data['device_entries'] as String);
        } catch (e) {
          deviceEntries = null;
        }
      }

      return ProductModel(
        id: response.$id,
        name: data['name'] ?? '',
        description: data['description'],
        barcode: data['barcode'],
        sellingPrice: (data['selling_price'] ?? 0).toDouble(),
        costPrice: (data['cost_price'] ?? 0).toDouble(),
        quantity: data['stock_quantity'] ?? 0,
        lowStockThreshold: data['low_stock_threshold'] ?? 5,
        reorderLevel: data['reorder_level'],
        category: data['category'],
        supplier: data['supplier'],
        imageUrl: data['image_url'],
        metadata: metadata,
        deviceEntries: deviceEntries?.map((e) => DeviceEntryModel.fromJson(e)).toList(),
        createdAt: DateTime.parse(data['created_at']),
        updatedAt: DateTime.parse(data['updated_at']),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching product $productId: $e');
      }
      throw Exception('Failed to fetch product: ${e.toString()}');
    }
  }

  /// Get a specific product by barcode
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _productsCollectionId,
        queries: [
          Query.equal('user_id', userId),
          Query.equal('barcode', barcode),
          Query.limit(1),
        ],
      );

      if (response.documents.isEmpty) {
        return null;
      }

      final doc = response.documents.first;
      final data = doc.data;
      
      // Handle JSON string fields
      Map<String, dynamic>? metadata;
      if (data['product_metadata'] != null) {
        try {
          metadata = jsonDecode(data['product_metadata'] as String);
        } catch (e) {
          metadata = null;
        }
      }

      List<dynamic>? deviceEntries;
      if (data['device_entries'] != null) {
        try {
          deviceEntries = jsonDecode(data['device_entries'] as String);
        } catch (e) {
          deviceEntries = null;
        }
      }

      return ProductModel(
        id: doc.$id,
        name: data['name'] ?? '',
        description: data['description'],
        barcode: data['barcode'],
        sellingPrice: (data['selling_price'] ?? 0).toDouble(),
        costPrice: (data['cost_price'] ?? 0).toDouble(),
        quantity: data['stock_quantity'] ?? 0,
        lowStockThreshold: data['low_stock_threshold'] ?? 5,
        reorderLevel: data['reorder_level'],
        category: data['category'],
        supplier: data['supplier'],
        imageUrl: data['image_url'],
        metadata: metadata,
        deviceEntries: deviceEntries?.map((e) => DeviceEntryModel.fromJson(e)).toList(),
        createdAt: DateTime.parse(data['created_at']),
        updatedAt: DateTime.parse(data['updated_at']),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching product by barcode $barcode: $e');
      }
      return null;
    }
  }

  /// Create a new product
  Future<ProductModel> createProduct(Map<String, dynamic> productData, {File? imageFile}) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      String? imageFileId;
      String? imageUrl;

      // Upload image if provided
      if (imageFile != null) {
        final uploadResult = await _storage.createFile(
          bucketId: _storageId,
          fileId: ID.unique(),
          file: InputFile.fromPath(path: imageFile.path),
        );
        imageFileId = uploadResult.$id;
        imageUrl = 'https://cloud.appwrite.io/v1/storage/buckets/$_storageId/files/$imageFileId/view?project=${Environment.appwriteProjectId}';
      }

      // Prepare data for Appwrite
      final now = DateTime.now().toIso8601String();
      final data = {
        'user_id': userId,
        'name': productData['name'],
        'description': productData['description'],
        'barcode': productData['barcode'],
        'selling_price': productData['selling_price'],
        'cost_price': productData['cost_price'],
        'stock_quantity': productData['stock_quantity'] ?? 0,
        'low_stock_threshold': productData['low_stock_threshold'] ?? 5,
        'reorder_level': productData['reorder_level'],
        'category': productData['category'],
        'supplier': productData['supplier'],
        'image_url': imageUrl,
        'image_file_id': imageFileId,
        'product_metadata': productData['product_metadata'] != null 
            ? jsonEncode(productData['product_metadata']) 
            : null,
        'device_entries': productData['device_entries'] != null 
            ? jsonEncode(productData['device_entries']) 
            : null,
        'created_at': now,
        'updated_at': now,
      };

      final response = await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: _productsCollectionId,
        documentId: ID.unique(),
        data: data,
      );

      // Convert back to ProductModel
      return ProductModel(
        id: response.$id,
        name: data['name'] ?? '',
        description: data['description'],
        barcode: data['barcode'],
        sellingPrice: (data['selling_price'] ?? 0).toDouble(),
        costPrice: (data['cost_price'] ?? 0).toDouble(),
        quantity: data['stock_quantity'] ?? 0,
        lowStockThreshold: data['low_stock_threshold'] ?? 5,
        reorderLevel: data['reorder_level'],
        category: data['category'],
        supplier: data['supplier'],
        imageUrl: data['image_url'],
        metadata: productData['product_metadata'],
        deviceEntries: productData['device_entries']?.map((e) => DeviceEntryModel.fromJson(e)).toList(),
        createdAt: DateTime.parse(data['created_at']),
        updatedAt: DateTime.parse(data['updated_at']),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error creating product: $e');
      }
      throw Exception('Failed to create product: ${e.toString()}');
    }
  }

  /// Update an existing product
  Future<ProductModel> updateProduct(String productId, Map<String, dynamic> productData, {File? imageFile}) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Verify ownership
      final existingProduct = await getProductById(productId);

      String? imageFileId = existingProduct.imageUrl?.contains('files/') == true
          ? existingProduct.imageUrl!.split('files/')[1].split('/')[0]
          : null;
      String? imageUrl = existingProduct.imageUrl;

      // Upload new image if provided
      if (imageFile != null) {
        // Delete old image if exists
        if (imageFileId != null) {
          try {
            await _storage.deleteFile(bucketId: _storageId, fileId: imageFileId);
          } catch (e) {
            // Ignore deletion errors
          }
        }

        final uploadResult = await _storage.createFile(
          bucketId: _storageId,
          fileId: ID.unique(),
          file: InputFile.fromPath(path: imageFile.path),
        );
        imageFileId = uploadResult.$id;
        imageUrl = 'https://cloud.appwrite.io/v1/storage/buckets/$_storageId/files/$imageFileId/view?project=${Environment.appwriteProjectId}';
      }

      // Prepare data for update
      final data = {
        'name': productData['name'],
        'description': productData['description'],
        'barcode': productData['barcode'],
        'selling_price': productData['selling_price'],
        'cost_price': productData['cost_price'],
        'stock_quantity': productData['stock_quantity'],
        'low_stock_threshold': productData['low_stock_threshold'],
        'reorder_level': productData['reorder_level'],
        'category': productData['category'],
        'supplier': productData['supplier'],
        'image_url': imageUrl,
        'image_file_id': imageFileId,
        'product_metadata': productData['product_metadata'] != null 
            ? jsonEncode(productData['product_metadata']) 
            : null,
        'device_entries': productData['device_entries'] != null 
            ? jsonEncode(productData['device_entries']) 
            : null,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _productsCollectionId,
        documentId: productId,
        data: data,
      );

      // Handle JSON string fields
      Map<String, dynamic>? metadata;
      if (data['product_metadata'] != null) {
        try {
          metadata = jsonDecode(data['product_metadata'] as String);
        } catch (e) {
          metadata = null;
        }
      }

      List<dynamic>? deviceEntries;
      if (data['device_entries'] != null) {
        try {
          deviceEntries = jsonDecode(data['device_entries'] as String);
        } catch (e) {
          deviceEntries = null;
        }
      }

      return ProductModel(
        id: response.$id,
        name: data['name'] ?? '',
        description: data['description'],
        barcode: data['barcode'],
        sellingPrice: (data['selling_price'] ?? 0).toDouble(),
        costPrice: (data['cost_price'] ?? 0).toDouble(),
        quantity: data['stock_quantity'] ?? 0,
        lowStockThreshold: data['low_stock_threshold'] ?? 5,
        reorderLevel: data['reorder_level'],
        category: data['category'],
        supplier: data['supplier'],
        imageUrl: data['image_url'],
        metadata: metadata,
        deviceEntries: deviceEntries?.map((e) => DeviceEntryModel.fromJson(e)).toList(),
        createdAt: DateTime.parse(response.data['created_at']),
        updatedAt: DateTime.parse(data['updated_at']),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error updating product $productId: $e');
      }
      throw Exception('Failed to update product: ${e.toString()}');
    }
  }

  /// Update product stock
  Future<ProductModel> updateProductStock(String productId, Map<String, dynamic> stockData) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Verify ownership
      await getProductById(productId);

      final data = {
        'stock_quantity': stockData['quantity'],
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _productsCollectionId,
        documentId: productId,
        data: data,
      );

      return await getProductById(productId);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating product stock $productId: $e');
      }
      throw Exception('Failed to update product stock: ${e.toString()}');
    }
  }

  /// Delete a product
  Future<void> deleteProduct(String productId) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Verify ownership and get product details
      final existingProduct = await getProductById(productId);

      // Delete associated image if exists
      if (existingProduct.imageUrl?.contains('files/') == true) {
        final imageFileId = existingProduct.imageUrl!.split('files/')[1].split('/')[0];
        try {
          await _storage.deleteFile(bucketId: _storageId, fileId: imageFileId);
        } catch (e) {
          // Ignore deletion errors
        }
      }

      await _databases.deleteDocument(
        databaseId: _databaseId,
        collectionId: _productsCollectionId,
        documentId: productId,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting product $productId: $e');
      }
      throw Exception('Failed to delete product: ${e.toString()}');
    }
  }

  /// Get all categories
  Future<List<String>> getCategories() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _productsCollectionId,
        queries: [
          Query.equal('user_id', userId),
          Query.select(['category']),
        ],
      );

      final categories = response.documents
          .map((doc) => doc.data['category'] as String?)
          .where((category) => category != null && category.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();

      categories.sort();
      return categories;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching categories: $e');
      }
      throw Exception('Failed to fetch categories: ${e.toString()}');
    }
  }

  /// Get all suppliers
  Future<List<String>> getSuppliers() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _productsCollectionId,
        queries: [
          Query.equal('user_id', userId),
          Query.select(['supplier']),
        ],
      );

      final suppliers = response.documents
          .map((doc) => doc.data['supplier'] as String?)
          .where((supplier) => supplier != null && supplier.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();

      suppliers.sort();
      return suppliers;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching suppliers: $e');
      }
      throw Exception('Failed to fetch suppliers: ${e.toString()}');
    }
  }

  /// Get low stock products
  Future<List<ProductModel>> getLowStockProducts() async {
    try {
      final allProducts = await getProducts();
      return allProducts.where((product) => product.isLowStock).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching low stock products: $e');
      }
      throw Exception('Failed to fetch low stock products: ${e.toString()}');
    }
  }

  /// Get device entries for a product (from the product's device_entries field)
  Future<List<Map<String, dynamic>>> getDeviceEntries(String productId) async {
    try {
      final product = await getProductById(productId);
      return product.deviceEntries?.map((entry) => entry.toJson()).toList() ?? [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching device entries for product $productId: $e');
      }
      throw Exception('Failed to fetch device entries: ${e.toString()}');
    }
  }

  /// Add device entries for a product
  Future<void> addDeviceEntries(String productId, Map<String, dynamic> entriesData) async {
    try {
      final product = await getProductById(productId);
      
      // Get existing device entries
      List<DeviceEntryModel> existingEntries = product.deviceEntries ?? [];
      
      // Add new entries
      if (entriesData['entries'] is List) {
        final newEntries = (entriesData['entries'] as List)
            .map((entry) => DeviceEntryModel.fromJson(entry))
            .toList();
        existingEntries.addAll(newEntries);
      }

      // Update the product with new device entries
      final updatedData = {
        'device_entries': existingEntries.map((e) => e.toJson()).toList(),
      };

      await updateProduct(productId, updatedData);
    } catch (e) {
      if (kDebugMode) {
        print('Error adding device entries for product $productId: $e');
      }
      throw Exception('Failed to add device entries: ${e.toString()}');
    }
  }

  /// Get inventory summary with counts and values
  Future<Map<String, dynamic>> getInventorySummary() async {
    try {
      final products = await getProducts();
      
      final totalProducts = products.length;
      final lowStockProducts = products.where((p) => p.isLowStock).toList();
      final outOfStockProducts = products.where((p) => p.isOutOfStock).toList();
      final totalStockValue = products.fold<double>(0.0, (sum, product) => sum + product.inventoryValue);

      return {
        'total_products': totalProducts,
        'total_stock_value': totalStockValue,
        'low_stock_count': lowStockProducts.length,
        'out_of_stock_count': outOfStockProducts.length,
        'total_stock_quantity': products.fold<int>(0, (sum, product) => sum + product.quantity),
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching inventory summary: $e');
      }
      throw Exception('Failed to fetch inventory summary: ${e.toString()}');
    }
  }
}