import 'package:intl/intl.dart';

class CustomerModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String? address;
  final double totalPurchases;
  final int purchaseCount;
  final DateTime lastPurchaseDate;
  final DateTime createdAt;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.address,
    this.totalPurchases = 0.0,
    this.purchaseCount = 0,
    required this.lastPurchaseDate,
    required this.createdAt,
  });

  String get formattedTotalPurchases {
    final formatter = NumberFormat("#,###");
    return 'TSh ${formatter.format(totalPurchases)}';
  }

  String get formattedLastPurchaseDate {
    return DateFormat('MMM d, yyyy').format(lastPurchaseDate);
  }

  String get initials {
    if (name.isEmpty) return '';
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      address: json['address'],
      totalPurchases: json['total_purchases']?.toDouble() ?? 0.0,
      purchaseCount: json['purchase_count'] ?? 0,
      lastPurchaseDate: json['last_purchase_date'] != null 
          ? DateTime.parse(json['last_purchase_date']) 
          : DateTime.now(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'total_purchases': totalPurchases,
      'purchase_count': purchaseCount,
      'last_purchase_date': lastPurchaseDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
