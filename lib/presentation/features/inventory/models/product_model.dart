import 'package:intl/intl.dart';
import 'dart:math';
import 'device_entry_model.dart';

class ProductModel {
  final String id;
  final String name;
  final String? description;
  final String? barcode;
  final double sellingPrice;
  final double costPrice;
  final int quantity;
  final int lowStockThreshold;
  final int? reorderLevel;
  final String? category;
  final String? supplier;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;
  final List<DeviceEntryModel>? deviceEntries;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductModel({
    required this.id,
    required this.name,
    this.description,
    this.barcode,
    required this.sellingPrice,
    required this.costPrice,
    required this.quantity,
    required this.lowStockThreshold,
    this.reorderLevel,
    this.category,
    this.supplier,
    this.imageUrl,
    this.metadata,
    this.deviceEntries,
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed properties
  bool get isOutOfStock => quantity <= 0;
  bool get isLowStock => quantity > 0 && quantity <= lowStockThreshold;
  double get inventoryValue => quantity * costPrice;
  double get profit => sellingPrice - costPrice;
  double get profitMargin => costPrice > 0 ? (profit / costPrice) * 100 : 0;

  // Product type helpers - determine if product has serial numbers
  bool get hasSerialNumber => _hasSerialNumber();
  bool get isAccessory => _isAccessoryProduct();
  
  // Helper method to determine if product requires serial numbers
  bool _hasSerialNumber() {
    // Products in these categories typically have serial numbers
    final serialNumberCategories = [
      'electronics', 'phones', 'smartphones', 'computers', 'laptops', 
      'tablets', 'cameras', 'appliances', 'vehicles', 'machinery'
    ];
    
    if (category == null) return false;
    
    return serialNumberCategories.any((cat) => 
      category!.toLowerCase().contains(cat.toLowerCase())
    );
  }
  
  // Helper method to determine if product is an accessory
  bool _isAccessoryProduct() {
    final accessoryCategories = [
      'accessories', 'cases', 'chargers', 'cables', 'covers',
      'screen protectors', 'earphones', 'headphones', 'adapters'
    ];
    
    if (category == null) return false;
    
    return accessoryCategories.any((cat) => 
      category!.toLowerCase().contains(cat.toLowerCase())
    );
  }

  // Formatted properties
  String get formattedCreatedAt => DateFormat('MMM d, yyyy').format(createdAt);
  String get formattedUpdatedAt => DateFormat('MMM d, yyyy').format(updatedAt);
  String get formattedPrice => 'TSh ${NumberFormat('#,###').format(sellingPrice)}';

  // Add sku getter that returns a formatted version of the ID
  String get sku => id.substring(0, min(8, id.length));

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    List<DeviceEntryModel>? deviceEntries;
    if (json['device_entries'] != null) {
      deviceEntries = (json['device_entries'] as List)
          .map((e) => DeviceEntryModel.fromJson(e))
          .toList();
    }

    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      barcode: json['barcode'],
      sellingPrice: (json['selling_price'] ?? json['sellingPrice'] ?? 0).toDouble(),
      costPrice: (json['cost_price'] ?? json['costPrice'] ?? 0).toDouble(),
      quantity: json['stock_quantity'] ?? json['quantity'] ?? 0,
      lowStockThreshold: json['low_stock_threshold'] ?? json['lowStockThreshold'] ?? 0,
      reorderLevel: json['reorder_level'] ?? json['reorderLevel'],
      category: json['category'],
      supplier: json['supplier'],
      imageUrl: json['image_url'] ?? json['imageUrl'],
      metadata: json['product_metadata'] ?? json['metadata'],
      deviceEntries: deviceEntries,
      createdAt: json['created_at'] != null || json['createdAt'] != null
          ? DateTime.parse(json['created_at'] ?? json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null || json['updatedAt'] != null
          ? DateTime.parse(json['updated_at'] ?? json['updatedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'barcode': barcode,
      'selling_price': sellingPrice,
      'cost_price': costPrice,
      'stock_quantity': quantity, // API expects stock_quantity
      'low_stock_threshold': lowStockThreshold,
      'reorder_level': reorderLevel,
      'category': category,
      'supplier': supplier,
      'image_url': imageUrl,
      'product_metadata': metadata,
      'device_entries': deviceEntries?.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    String? barcode,
    double? sellingPrice,
    double? costPrice,
    int? quantity,
    int? lowStockThreshold,
    int? reorderLevel,
    String? category,
    String? supplier,
    String? imageUrl,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      barcode: barcode ?? this.barcode,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      costPrice: costPrice ?? this.costPrice,
      quantity: quantity ?? this.quantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      category: category ?? this.category,
      supplier: supplier ?? this.supplier,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, quantity: $quantity)';
  }
}
