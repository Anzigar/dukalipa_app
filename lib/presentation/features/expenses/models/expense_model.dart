import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseModel {
  final String id;
  final double amount;
  final String description;
  final String category;
  final DateTime date;
  final String? receiptUrl;
  final String? receiptNumber;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
    this.receiptUrl,
    this.receiptNumber,
    this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  // New constructor with slightly different parameters
  ExpenseModel.create({
    required String id,
    required double amount,
    required String description,
    required String category,
    required DateTime date,
    String? receipt,
    String? paymentMethod,
    required String createdBy,
    required DateTime createdAt,
  }) : this(
    id: id,
    amount: amount,
    description: description,
    category: category,
    date: date,
    receiptUrl: receipt,
    paymentMethod: paymentMethod,
    createdAt: createdAt,
    updatedAt: createdAt, // Initialize updatedAt with createdAt
  );

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      category: json['category'] ?? 'Other',
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : DateTime.now(),
      receiptUrl: json['receipt_url'],
      receiptNumber: json['receipt_number'],
      paymentMethod: json['payment_method'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'category': category,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD
      'receipt_url': receiptUrl,
      'receipt_number': receiptNumber,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Format the amount
  String get formattedAmount => 'TSh ${NumberFormat('#,###').format(amount)}';
  
  // Format the date
  String get formattedDate => DateFormat('MMM d, yyyy').format(date);
  
  // Format for grouping by month
  String get monthYear => DateFormat('MMMM yyyy').format(date);

  ExpenseModel copyWith({
    String? id,
    double? amount,
    String? description,
    String? category,
    DateTime? date,
    String? receiptUrl,
    String? paymentMethod,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Common expense categories for dropdown options
class ExpenseCategories {
  static const String rent = 'Rent';
  static const String utilities = 'Utilities';
  static const String salary = 'Salary';
  static const String inventory = 'Inventory';
  static const String marketing = 'Marketing';
  static const String maintenance = 'Maintenance';
  static const String transportation = 'Transportation';
  static const String officeSupplies = 'Office Supplies';
  static const String taxes = 'Taxes';
  static const String other = 'Other';
  
  static List<String> all = [
    rent, utilities, salary, inventory, marketing, 
    maintenance, transportation, officeSupplies, taxes, other
  ];
  
  // Get category icon
  static IconData getIcon(String category) {
    switch (category) {
      case rent: return Icons.home_outlined;
      case utilities: return Icons.electric_bolt_outlined;
      case salary: return Icons.people_outline;
      case inventory: return Icons.inventory_2_outlined;
      case marketing: return Icons.campaign_outlined;
      case maintenance: return Icons.build_outlined;
      case transportation: return Icons.local_shipping_outlined;
      case officeSupplies: return Icons.shopping_bag_outlined;
      case taxes: return Icons.account_balance_outlined;
      case other: return Icons.category_outlined;
      default: return Icons.attach_money;
    }
  }
}
