import 'package:intl/intl.dart';
import 'installment_payment_model.dart';

class InstallmentModel {
  final String id;
  final String clientName;
  final String clientPhone;
  final String? clientEmail;
  final String? clientAddress;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final double downPayment; // Added missing field
  final List<String> productIds;
  final List<String> productNames;
  final DateTime startDate;
  final DateTime dueDate;
  final String status; // active, completed, defaulted
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<InstallmentPaymentModel> payments;

  InstallmentModel({
    required this.id,
    required this.clientName,
    required this.clientPhone,
    this.clientEmail,
    this.clientAddress,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.downPayment, // Added parameter
    required this.productIds,
    required this.productNames,
    required this.startDate,
    required this.dueDate,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.payments = const [],
  });

  factory InstallmentModel.fromJson(Map<String, dynamic> json) {
    return InstallmentModel(
      id: json['id'],
      clientName: json['client_name'],
      clientPhone: json['client_phone'],
      clientEmail: json['client_email'],
      clientAddress: json['client_address'],
      totalAmount: json['total_amount'].toDouble(),
      paidAmount: json['paid_amount'].toDouble(),
      remainingAmount: json['remaining_amount'].toDouble(),
      downPayment: json['down_payment']?.toDouble() ?? 0.0, // Added with null safety
      productIds: List<String>.from(json['product_ids'] ?? []),
      productNames: List<String>.from(json['product_names'] ?? []),
      startDate: DateTime.parse(json['start_date']),
      dueDate: DateTime.parse(json['due_date']),
      status: json['status'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      payments: json['payments'] != null
          ? List<InstallmentPaymentModel>.from(
              json['payments']
                  .map((payment) => InstallmentPaymentModel.fromJson(payment))
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_name': clientName,
      'client_phone': clientPhone,
      'client_email': clientEmail,
      'client_address': clientAddress,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      'down_payment': downPayment, // Added to JSON output
      'product_ids': productIds,
      'product_names': productNames,
      'start_date': startDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'payments': payments.map((payment) => payment.toJson()).toList(),
    };
  }

  // Helper getters for UI
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isDefaulted => status == 'defaulted';
  bool get isOverdue => isActive && DateTime.now().isAfter(dueDate);

  double get paymentProgress => paidAmount / totalAmount;
  double get percentagePaid => (paidAmount / totalAmount) * 100;

  String get formattedTotalAmount =>
      NumberFormat.currency(symbol: 'TSh ').format(totalAmount);
  String get formattedPaidAmount =>
      NumberFormat.currency(symbol: 'TSh ').format(paidAmount);
  String get formattedRemainingAmount =>
      NumberFormat.currency(symbol: 'TSh ').format(remainingAmount);
  String get formattedDownPayment =>
      NumberFormat.currency(symbol: 'TSh ').format(downPayment); // Added missing getter
  String get formattedDueDate => DateFormat('MMMM d, y').format(dueDate);
  String get formattedStartDate => DateFormat('MMMM d, y').format(startDate);
  String get monthYear => DateFormat('MMMM yyyy').format(createdAt);

  // Duration calculation
  int get totalDurationInDays => dueDate.difference(startDate).inDays;
  int get remainingDurationInDays =>
      dueDate.difference(DateTime.now()).inDays;
  double get percentageTimeElapsed {
    final totalDays = totalDurationInDays;
    if (totalDays <= 0) return 100;

    final elapsedDays = totalDays - remainingDurationInDays;
    return (elapsedDays / totalDays) * 100;
  }
}
