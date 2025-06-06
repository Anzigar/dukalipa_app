class SaleItemModel {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final double total;

  SaleItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.total,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      productId: json['product_id'],
      productName: json['product_name'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
      total: (json['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'total': total,
    };
  }

  SaleItemModel copyWith({
    String? productId,
    String? productName,
    double? price,
    int? quantity,
    double? total,
  }) {
    return SaleItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      total: total ?? this.total,
    );
  }
}
