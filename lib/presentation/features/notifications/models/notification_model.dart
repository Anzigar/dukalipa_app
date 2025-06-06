import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum NotificationType {
  info,
  success,
  warning,
  error,
  // Shop specific notification types
  newSale,
  lowStock,
  outOfStock,
  newExpense,
  productUpdate
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String? actionRoute;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.actionRoute,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      type: _parseNotificationType(json['type']),
      isRead: json['is_read'] ?? false,
      actionRoute: json['action_route'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'is_read': isRead,
      'action_route': actionRoute,
      'data': data,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    String? actionRoute,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute ?? this.actionRoute,
      data: data ?? this.data,
    );
  }

  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      // More than a week ago, show full date
      return DateFormat('MMM d, yyyy • h:mm a').format(timestamp);
    } else if (difference.inDays > 0) {
      // Days ago
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      // Hours ago
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      // Minutes ago
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      // Just now
      return 'Just now';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case NotificationType.info:
        return Icons.info_outline;
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.warning:
        return Icons.warning_amber_outlined;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.newSale:
        return Icons.shopping_cart_outlined;
      case NotificationType.lowStock:
        return Icons.inventory_2_outlined;
      case NotificationType.outOfStock:
        return Icons.inventory_2_outlined;
      case NotificationType.newExpense:
        return Icons.receipt_long_outlined;
      case NotificationType.productUpdate:
        return Icons.inventory_2_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  Color get typeColor {
    switch (type) {
      case NotificationType.info:
        return Colors.blue;
      case NotificationType.success:
        return Colors.green;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.newSale:
        return Colors.green;
      case NotificationType.lowStock:
        return Colors.orange;
      case NotificationType.outOfStock:
        return Colors.red;
      case NotificationType.newExpense:
        return Colors.purple;
      case NotificationType.productUpdate:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  static NotificationType _parseNotificationType(String? typeString) {
    if (typeString == null) return NotificationType.info;

    try {
      return NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == typeString,
        orElse: () => NotificationType.info,
      );
    } catch (e) {
      return NotificationType.info;
    }
  }
}
