import 'package:intl/intl.dart';

class BranchModel {
  final String id;
  final String name;
  final String location;
  final String? phoneNumber;
  final String? email;
  final String? managerName;
  final int staffCount;
  final double monthlyRevenue;
  final double monthlyExpenses;
  final DateTime createdAt;
  final bool isActive;

  BranchModel({
    required this.id,
    required this.name,
    required this.location,
    this.phoneNumber,
    this.email,
    this.managerName,
    this.staffCount = 0,
    this.monthlyRevenue = 0.0,
    this.monthlyExpenses = 0.0,
    required this.createdAt,
    this.isActive = true,
  });

  double get monthlyProfit => monthlyRevenue - monthlyExpenses;

  String get formattedMonthlyRevenue {
    final formatter = NumberFormat("#,###");
    return 'TSh ${formatter.format(monthlyRevenue)}';
  }

  String get formattedMonthlyExpenses {
    final formatter = NumberFormat("#,###");
    return 'TSh ${formatter.format(monthlyExpenses)}';
  }

  String get formattedMonthlyProfit {
    final formatter = NumberFormat("#,###");
    return 'TSh ${formatter.format(monthlyProfit)}';
  }

  String get formattedCreatedAt {
    return DateFormat('MMM d, yyyy').format(createdAt);
  }

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      managerName: json['manager_name'],
      staffCount: json['staff_count'] ?? 0,
      monthlyRevenue: json['monthly_revenue']?.toDouble() ?? 0.0,
      monthlyExpenses: json['monthly_expenses']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at']),
      isActive: json['is_active'] ?? true,
    );
  }
}
