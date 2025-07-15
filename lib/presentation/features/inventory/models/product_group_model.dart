class ProductGroupModel {
  final String id;
  final String name;
  final String description;
  final String? color;
  final List<String> categories;
  final int productCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductGroupModel({
    required this.id,
    required this.name,
    required this.description,
    this.color,
    required this.categories,
    this.productCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductGroupModel.fromJson(Map<String, dynamic> json) {
    return ProductGroupModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      color: json['color'],
      categories: List<String>.from(json['categories'] ?? []),
      productCount: json['productCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'categories': categories,
      'productCount': productCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ProductGroupModel copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    List<String>? categories,
    int? productCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductGroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      categories: categories ?? this.categories,
      productCount: productCount ?? this.productCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
