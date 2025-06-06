import 'package:intl/intl.dart';

class SupplierModel {
  final String id;
  final String name;
  final String contactName;
  final String phoneNumber;
  final String? email;
  final String? address;
  final double totalOrders;
  final int orderCount;
  final DateTime lastOrderDate;
  final DateTime createdAt;

  SupplierModel({
    required this.id,
    required this.name,
    required this.contactName,
    required this.phoneNumber,
    this.email,
    this.address,
    this.totalOrders = 0.0,
    this.orderCount = 0,
    required this.lastOrderDate,
    required this.createdAt,
  });

  String get formattedTotalOrders {
    final formatter = NumberFormat("#,###");
    return 'TSh ${formatter.format(totalOrders)}';
  }

  String get formattedLastOrderDate {
    return DateFormat('MMM d, yyyy').format(lastOrderDate);
  }

  String get initials {
    if (name.isEmpty) return '';
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'],
      name: json['name'],
      contactName: json['contact_name'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      address: json['address'],
      totalOrders: json['total_orders']?.toDouble() ?? 0.0,
      orderCount: json['order_count'] ?? 0,
      lastOrderDate: json['last_order_date'] != null
          ? DateTime.parse(json['last_order_date'])
          : DateTime.now(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact_name': contactName,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'total_orders': totalOrders,
      'order_count': orderCount,
      'last_order_date': lastOrderDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
