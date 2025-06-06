import 'package:intl/intl.dart';

class DamagedProductModel {
  final String id;
  final String productId;
  final String productName;
  final String? imageUrl;
  final int quantity;
  final double pricePerUnit;
  final String reason;
  final DateTime reportedDate;
  final String? notes;

  DamagedProductModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.imageUrl,
    required this.quantity,
    required this.pricePerUnit,
    required this.reason,
    required this.reportedDate,
    this.notes,
  });

  double get totalLoss => quantity * pricePerUnit;

  String get formattedTotalLoss {
    final formatter = NumberFormat("#,###");
    return 'TSh ${formatter.format(totalLoss)}';
  }

  String get formattedReportedDate {
    return DateFormat('MMM d, yyyy').format(reportedDate);
  }

  factory DamagedProductModel.fromJson(Map<String, dynamic> json) {
    return DamagedProductModel(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'],
      imageUrl: json['image_url'],
      quantity: json['quantity'],
      pricePerUnit: json['price_per_unit']?.toDouble() ?? 0.0,
      reason: json['reason'],
      reportedDate: DateTime.parse(json['reported_date']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'image_url': imageUrl,
      'quantity': quantity,
      'price_per_unit': pricePerUnit,
      'reason': reason,
      'reported_date': reportedDate.toIso8601String(),
      'notes': notes,
    };
  }
}
