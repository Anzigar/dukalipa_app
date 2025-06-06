import 'package:intl/intl.dart';

class InstallmentPaymentModel {
  final String id;
  final String installmentId;
  final double amount;
  final DateTime paymentDate;
  final String paymentMethod; // cash, mobile money, bank transfer, etc.
  final String? receiptNumber;
  final String? notes;
  final String? receiptImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  InstallmentPaymentModel({
    required this.id,
    required this.installmentId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    this.receiptNumber,
    this.notes,
    this.receiptImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InstallmentPaymentModel.fromJson(Map<String, dynamic> json) {
    return InstallmentPaymentModel(
      id: json['id'],
      installmentId: json['installment_id'],
      amount: json['amount'].toDouble(),
      paymentDate: DateTime.parse(json['payment_date']),
      paymentMethod: json['payment_method'],
      receiptNumber: json['receipt_number'],
      notes: json['notes'],
      receiptImageUrl: json['receipt_image_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'installment_id': installmentId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String(),
      'payment_method': paymentMethod,
      'receipt_number': receiptNumber,
      'notes': notes,
      'receipt_image_url': receiptImageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper methods for UI
  String get formattedAmount => NumberFormat.currency(symbol: 'TSh ').format(amount);
  String get formattedPaymentDate => DateFormat('MMMM d, y').format(paymentDate);
  String get formattedDate => DateFormat('MMMM d, y').format(paymentDate); // Added missing getter
  String get formattedTime => DateFormat('h:mm a').format(paymentDate);
  String get dayOfWeek => DateFormat('EEEE').format(paymentDate);
}
