import 'package:intl/intl.dart';
import 'dart:math';

class ProductModel {
  final String id;
  final String name;
  final String? description;
  final String? barcode; 
  final double sellingPrice;
  final double costPrice;
  final int quantity;
  final int lowStockThreshold; // This field exists but was missing in constructor
  final int reorderLevel; // Add reorderLevel property
  final String? category;
  final String? supplier;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    this.barcode,
    required this.sellingPrice,
    required this.costPrice,
    required this.quantity,
    required this.lowStockThreshold, // Added the missing parameter
    this.reorderLevel = 5, // Default value for reorderLevel
    this.category,
    this.supplier,
    this.imageUrl,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed properties
  bool get isOutOfStock => quantity <= 0;
  bool get isLowStock => quantity > 0 && quantity <= lowStockThreshold;
  double get inventoryValue => quantity * costPrice;
  
  // Formatted properties
  String get formattedCreatedAt => DateFormat('MMM d, yyyy').format(createdAt);
  String get formattedUpdatedAt => DateFormat('MMM d, yyyy').format(updatedAt);
  String get formattedPrice => 'TSh ${NumberFormat('#,###').format(sellingPrice)}';

  // Add sku getter that returns a formatted version of the ID
  String get sku => id.substring(0, min(8, id.length));

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      barcode: json['barcode'],
      sellingPrice: json['selling_price'] is int 
          ? (json['selling_price'] as int).toDouble() 
          : json['selling_price'],
      costPrice: json['cost_price'] is int 
          ? (json['cost_price'] as int).toDouble() 
          : json['cost_price'],
      quantity: json['quantity'],
      lowStockThreshold: json['low_stock_threshold'] ?? 5,
      reorderLevel: json['reorder_level'] ?? 5, // Parse from JSON
      category: json['category'],
      supplier: json['supplier'],
      imageUrl: json['image_url'],
      metadata: json['metadata'],
      createdAt: json['created_at'] is String 
          ? DateTime.parse(json['created_at']) 
          : json['created_at'] ?? DateTime.now(),
      updatedAt: json['updated_at'] is String 
          ? DateTime.parse(json['updated_at']) 
          : json['updated_at'] ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (barcode != null) 'barcode': barcode,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'quantity': quantity,
      'low_stock_threshold': lowStockThreshold,
      'reorder_level': reorderLevel, // Include in JSON output
      if (imageUrl != null) 'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }
}
