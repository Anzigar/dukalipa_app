import 'package:intl/intl.dart';

class DeletedItemModel {
  final String id;
  final String itemId;
  final String itemName;
  final String itemType; // product, customer, supplier, sale, expense
  final String deletedBy;
  final DateTime deletedAt;
  final bool isRecoverable;

  DeletedItemModel({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.itemType,
    required this.deletedBy,
    required this.deletedAt,
    this.isRecoverable = true,
  });

  String get formattedDeletedAt {
    return DateFormat('MMM d, yyyy').format(deletedAt);
  }

  String get itemTypeCapitalized {
    return itemType.substring(0, 1).toUpperCase() + itemType.substring(1);
  }

  factory DeletedItemModel.fromJson(Map<String, dynamic> json) {
    return DeletedItemModel(
      id: json['id'],
      itemId: json['item_id'],
      itemName: json['item_name'],
      itemType: json['item_type'],
      deletedBy: json['deleted_by'],
      deletedAt: DateTime.parse(json['deleted_at']),
      isRecoverable: json['is_recoverable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'item_name': itemName,
      'item_type': itemType,
      'deleted_by': deletedBy,
      'deleted_at': deletedAt.toIso8601String(),
      'is_recoverable': isRecoverable,
    };
  }
}
