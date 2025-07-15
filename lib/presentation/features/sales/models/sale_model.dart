import 'package:intl/intl.dart';

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
}

class SaleModel {
  final String id;
  final String? customerName;
  final String? customerPhone;
  final List<SaleItemModel> items;
  final double totalAmount;
  final double discount;
  final String status;
  final String? paymentMethod;
  final DateTime dateTime;
  final String? note;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  SaleModel({
    required this.id,
    this.customerName,
    this.customerPhone,
    required this.items,
    required this.totalAmount,
    this.discount = 0.0,
    required this.status,
    this.paymentMethod,
    required this.dateTime,
    this.note,
    this.createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Factory constructor for current time
  factory SaleModel.withCurrentTime({
    required String id,
    String? customerName,
    String? customerPhone,
    required List<SaleItemModel> items,
    required double totalAmount,
    double discount = 0.0,
    required String status,
    String? paymentMethod,
    required DateTime dateTime,
    String? note,
    String? createdBy,
  }) {
    final now = DateTime.now();
    return SaleModel(
      id: id,
      customerName: customerName,
      customerPhone: customerPhone,
      items: items,
      totalAmount: totalAmount,
      discount: discount,
      status: status,
      paymentMethod: paymentMethod,
      dateTime: dateTime,
      note: note,
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return SaleModel(
      id: json['id'] ?? '',
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => SaleItemModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      paymentMethod: json['paymentMethod'],
      dateTime: json['dateTime'] != null 
          ? DateTime.parse(json['dateTime'] as String)
          : now,
      note: json['note'],
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : now,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : now,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'discount': discount,
      'status': status,
      'paymentMethod': paymentMethod,
      'dateTime': dateTime.toIso8601String(),
      'note': note,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get formattedAmount => NumberFormat.currency(
        symbol: 'TSh ',
        decimalDigits: 0,
      ).format(totalAmount);

  String get formattedDiscount => NumberFormat.currency(
        symbol: 'TSh ',
        decimalDigits: 0,
      ).format(discount);

  String get formattedDateTime => DateFormat('MMM d, yyyy • h:mm a').format(dateTime);

  String get formattedDate => DateFormat('MMM d, yyyy').format(dateTime);

  String get formattedTime => DateFormat('h:mm a').format(dateTime);

  double get subtotal => totalAmount + discount;

  String get formattedSubtotal => NumberFormat.currency(
        symbol: 'TSh ',
        decimalDigits: 0,
      ).format(subtotal);

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  int get uniqueProducts => items.length;
  bool get hasCustomerInfo => customerName != null && customerName!.isNotEmpty;

  SaleModel copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    List<SaleItemModel>? items,
    double? totalAmount,
    double? discount,
    String? status,
    String? paymentMethod,
    DateTime? dateTime,
    String? note,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SaleModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      discount: discount ?? this.discount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      dateTime: dateTime ?? this.dateTime,
      note: note ?? this.note,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaleModel &&
        other.id == id &&
        other.customerName == customerName &&
        other.customerPhone == customerPhone &&
        other.totalAmount == totalAmount &&
        other.status == status &&
        other.dateTime == dateTime;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        customerName.hashCode ^
        customerPhone.hashCode ^
        totalAmount.hashCode ^
        status.hashCode ^
        dateTime.hashCode;
  }

  @override
  String toString() {
    return 'SaleModel(id: $id, customerName: $customerName, totalAmount: $totalAmount, status: $status)';
  }
}

// Extension for additional utility methods
extension SaleModelExtensions on SaleModel {
  String get salesSummary {
    if (items.isEmpty) return 'No items';
    if (items.length == 1) {
      return '${items.first.productName} (${items.first.quantity})';
    }
    return '${items.length} items (${totalItems} total)';
  }

  String get statusColor {
    switch (status.toLowerCase()) {
      case 'completed':
        return '#4CAF50';
      case 'pending':
        return '#FF9800';
      case 'cancelled':
        return '#F44336';
      default:
        return '#9E9E9E';
    }
  }

  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year &&
           dateTime.month == now.month &&
           dateTime.day == now.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return dateTime.isAfter(startOfWeek) && dateTime.isBefore(now.add(const Duration(days: 1)));
  }

  bool get isThisMonth {
    final now = DateTime.now();
    return dateTime.year == now.year && dateTime.month == now.month;
  }
}
