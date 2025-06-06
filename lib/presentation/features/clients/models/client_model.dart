import 'package:intl/intl.dart';

class ClientModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String? address;
  final double totalPurchases;
  final int purchaseCount;
  final String? profileImageUrl;
  final DateTime? lastPurchaseDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  ClientModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.address,
    required this.totalPurchases,
    required this.purchaseCount,
    this.profileImageUrl,
    this.lastPurchaseDate,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      address: json['address'],
      totalPurchases: (json['total_purchases'] as num).toDouble(),
      purchaseCount: json['purchase_count'] ?? 0,
      profileImageUrl: json['profile_image_url'],
      lastPurchaseDate: json['last_purchase_date'] != null
          ? DateTime.parse(json['last_purchase_date'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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
      'profile_image_url': profileImageUrl,
      'last_purchase_date': lastPurchaseDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  String get formattedTotalPurchases {
    return 'TSh ${NumberFormat('#,###').format(totalPurchases)}';
  }
  
  String get formattedLastPurchaseDate {
    if (lastPurchaseDate == null) return 'N/A';
    return DateFormat('MMM d, yyyy').format(lastPurchaseDate!);
  }
  
  String get formattedCreatedAt {
    return DateFormat('MMM d, yyyy').format(createdAt);
  }
  
  String get initials {
    if (name.isEmpty) return '';
    
    final nameParts = name.split(' ');
    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    } else {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
  }
}
