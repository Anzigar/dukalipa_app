class SaleItemModel {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final double total;

  const SaleItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }

  SaleItemModel copyWith({
    String? productId,
    String? productName,
    int? quantity,
    double? price,
    double? total,
  }) {
    return SaleItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      total: total ?? this.total,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaleItemModel &&
        other.productId == productId &&
        other.productName == productName &&
        other.quantity == quantity &&
        other.price == price &&
        other.total == total;
  }

  @override
  int get hashCode {
    return productId.hashCode ^
        productName.hashCode ^
        quantity.hashCode ^
        price.hashCode ^
        total.hashCode;
  }

  @override
  String toString() {
    return 'SaleItemModel(productId: $productId, productName: $productName, quantity: $quantity, price: $price, total: $total)';
  }
}
