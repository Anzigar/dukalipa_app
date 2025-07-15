class DeletedItemModel {
  final String id;
  final String name;
  final String sku;
  final double price;
  final String category;
  final DateTime deletedAt;
  final String deletedBy;
  final String reason;
  final String? imageUrl;
  final int originalQuantity;

  DeletedItemModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.category,
    required this.deletedAt,
    required this.deletedBy,
    required this.reason,
    this.imageUrl,
    required this.originalQuantity,
  });

  factory DeletedItemModel.fromJson(Map<String, dynamic> json) {
    return DeletedItemModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      category: json['category'] ?? '',
      deletedAt: DateTime.tryParse(json['deletedAt'] ?? '') ?? DateTime.now(),
      deletedBy: json['deletedBy'] ?? '',
      reason: json['reason'] ?? '',
      imageUrl: json['imageUrl'],
      originalQuantity: json['originalQuantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'price': price,
      'category': category,
      'deletedAt': deletedAt.toIso8601String(),
      'deletedBy': deletedBy,
      'reason': reason,
      'imageUrl': imageUrl,
      'originalQuantity': originalQuantity,
    };
  }
}
