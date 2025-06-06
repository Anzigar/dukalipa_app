class ProductGroupModel {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String? color; // Hex color for group identification
  final List<String> categories; // Related categories
  final int productCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  const ProductGroupModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.color,
    this.categories = const [],
    this.productCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  factory ProductGroupModel.fromJson(Map<String, dynamic> json) {
    return ProductGroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      color: json['color'] as String?,
      categories: List<String>.from(json['categories'] ?? []),
      productCount: json['productCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'color': color,
      'categories': categories,
      'productCount': productCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  ProductGroupModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? color,
    List<String>? categories,
    int? productCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ProductGroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      color: color ?? this.color,
      categories: categories ?? this.categories,
      productCount: productCount ?? this.productCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
