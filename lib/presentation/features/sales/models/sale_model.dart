import 'package:intl/intl.dart';
import 'sale_item_model.dart';

class SaleModel {
  final String id;
  final List<SaleItemModel> items;
  final double totalAmount;
  final double discount;
  final String? customerName;
  final String? customerPhone;
  final String status;
  final String? paymentMethod;
  final String? note;
  final DateTime dateTime;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SaleModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    this.discount = 0,
    this.customerName,
    this.customerPhone,
    required this.status,
    this.paymentMethod,
    this.note,
    required this.dateTime,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['id'],
      items: (json['items'] as List<dynamic>)
          .map((item) => SaleItemModel.fromJson(item))
          .toList(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      discount: json['discount'] != null ? (json['discount'] as num).toDouble() : 0,
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      status: json['status'] ?? 'completed',
      paymentMethod: json['payment_method'],
      note: json['note'],
      dateTime: DateTime.parse(json['date_time'] ?? json['created_at']),
      createdBy: json['created_by'] ?? 'Unknown',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'total_amount': totalAmount,
      'discount': discount,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'status': status,
      'payment_method': paymentMethod,
      'note': note,
      'date_time': dateTime.toIso8601String(),
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Format the amount
  String get formattedAmount => NumberFormat.currency(
        symbol: 'TSh ',
        decimalDigits: 0,
      ).format(totalAmount);

  // Format the date and time
  String get formattedDateTime => DateFormat('MMM d, yyyy • h:mm a').format(dateTime);

  // Format date only
  String get formattedDate => DateFormat('MMM d, yyyy').format(dateTime);

  // Format time only
  String get formattedTime => DateFormat('h:mm a').format(dateTime);

  SaleModel copyWith({
    String? id,
    List<SaleItemModel>? items,
    double? totalAmount,
    double? discount,
    String? customerName,
    String? customerPhone,
    String? status,
    String? paymentMethod,
    String? note,
    DateTime? dateTime,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SaleModel(
      id: id ?? this.id,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      discount: discount ?? this.discount,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      note: note ?? this.note,
      dateTime: dateTime ?? this.dateTime,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
