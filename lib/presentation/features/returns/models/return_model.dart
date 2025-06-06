import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class ReturnModel {
  final String id;
  final String orderId;
  final String? customerName;
  final String? customerPhone;
  final String reason;
  final double amount;
  final List<ReturnItemModel> items;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final bool isRefunded;
  final double? refundAmount;

  ReturnModel({
    required this.id,
    required this.orderId,
    this.customerName,
    this.customerPhone,
    required this.reason,
    required this.amount,
    required this.items,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.isRefunded = false,
    this.refundAmount,
  });

  factory ReturnModel.fromJson(Map<String, dynamic> json) {
    return ReturnModel(
      id: json['id'],
      orderId: json['order_id'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      reason: json['reason'],
      amount: json['amount'].toDouble(),
      items: (json['items'] as List<dynamic>)
          .map((item) => ReturnItemModel.fromJson(item))
          .toList(),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      notes: json['notes'],
      isRefunded: json['is_refunded'] ?? false,
      refundAmount: json['refund_amount']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'reason': reason,
      'amount': amount,
      'items': items.map((item) => item.toJson()).toList(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'notes': notes,
      'is_refunded': isRefunded,
      'refund_amount': refundAmount,
    };
  }

  String get formattedAmount => 'TSh ${NumberFormat('#,###').format(amount)}';

  String get formattedDate => DateFormat('dd MMM yyyy').format(createdAt);

  String get formattedDateTime =>
      DateFormat('dd MMM yyyy, HH:mm').format(createdAt);

  String get monthYear => DateFormat('MMMM yyyy').format(createdAt);

  Color getStatusColor() {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}

class ReturnItemModel {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String? reason;

  ReturnItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.reason,
  });

  factory ReturnItemModel.fromJson(Map<String, dynamic> json) {
    return ReturnItemModel(
      productId: json['product_id'],
      productName: json['product_name'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
      reason: json['reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'reason': reason,
    };
  }

  double get totalPrice => price * quantity;

  String get formattedPrice => 'TSh ${NumberFormat('#,###').format(price)}';

  String get formattedTotalPrice =>
      'TSh ${NumberFormat('#,###').format(totalPrice)}';
}
