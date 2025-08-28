import 'package:appwrite/appwrite.dart';
import '../../core/services/appwrite_service.dart';
import '../../presentation/features/notifications/models/notification_model.dart';

/// Service for handling notifications using Appwrite backend
class AppwriteNotificationService {
  final Databases _databases;
  final String _databaseId = 'shop_management_db';

  AppwriteNotificationService() : _databases = AppwriteService().databases;

  /// Get all notifications for the current user
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final notificationDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'notifications',
        queries: [
          Query.orderDesc('\$createdAt'),
          Query.limit(100), // Limit to recent notifications
        ],
      );

      return notificationDocs.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['id'] = doc.$id;
        return NotificationModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications: ${e.toString()}');
    }
  }

  /// Create a new notification
  Future<NotificationModel> createNotification({
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notificationId = ID.unique();

      final notificationData = {
        'title': title,
        'message': message,
        'type': type,
        'is_read': false,
        'data': data ?? {},
        '\$createdAt': DateTime.now().toIso8601String(),
        '\$updatedAt': DateTime.now().toIso8601String(),
      };

      final createdDoc = await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: 'notifications',
        documentId: notificationId,
        data: notificationData,
      );

      final resultData = Map<String, dynamic>.from(createdDoc.data);
      resultData['id'] = createdDoc.$id;
      return NotificationModel.fromJson(resultData);
    } catch (e) {
      throw Exception('Failed to create notification: ${e.toString()}');
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String id) async {
    try {
      await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: 'notifications',
        documentId: id,
        data: {
          'is_read': true,
          '\$updatedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to mark notification as read: ${e.toString()}');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      // Get all unread notifications
      final unreadDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'notifications',
        queries: [
          Query.equal('is_read', false),
        ],
      );

      // Update each unread notification
      final futures = unreadDocs.documents.map((doc) =>
        _databases.updateDocument(
          databaseId: _databaseId,
          collectionId: 'notifications',
          documentId: doc.$id,
          data: {
            'is_read': true,
            '\$updatedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      await Future.wait(futures);
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: ${e.toString()}');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String id) async {
    try {
      await _databases.deleteDocument(
        databaseId: _databaseId,
        collectionId: 'notifications',
        documentId: id,
      );
    } catch (e) {
      throw Exception('Failed to delete notification: ${e.toString()}');
    }
  }

  /// Delete all read notifications
  Future<void> deleteReadNotifications() async {
    try {
      // Get all read notifications
      final readDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'notifications',
        queries: [
          Query.equal('is_read', true),
        ],
      );

      // Delete each read notification
      final futures = readDocs.documents.map((doc) =>
        _databases.deleteDocument(
          databaseId: _databaseId,
          collectionId: 'notifications',
          documentId: doc.$id,
        ),
      );

      await Future.wait(futures);
    } catch (e) {
      throw Exception('Failed to delete read notifications: ${e.toString()}');
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadCount() async {
    try {
      final unreadDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'notifications',
        queries: [
          Query.equal('is_read', false),
          Query.limit(1), // Just for count
        ],
      );

      return unreadDocs.total;
    } catch (e) {
      throw Exception('Failed to get unread count: ${e.toString()}');
    }
  }

  /// Get notifications by type
  Future<List<NotificationModel>> getNotificationsByType(String type) async {
    try {
      final notificationDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'notifications',
        queries: [
          Query.equal('type', type),
          Query.orderDesc('\$createdAt'),
        ],
      );

      return notificationDocs.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['id'] = doc.$id;
        return NotificationModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications by type: ${e.toString()}');
    }
  }

  /// Create system notifications for various events
  Future<void> createLowStockNotification(String productName, int currentStock) async {
    await createNotification(
      title: 'Low Stock Alert',
      message: '$productName is running low. Only $currentStock left in stock.',
      type: 'low_stock',
      data: {
        'product_name': productName,
        'current_stock': currentStock,
      },
    );
  }

  Future<void> createSaleNotification(String customerName, double amount) async {
    await createNotification(
      title: 'New Sale',
      message: 'Sale completed for $customerName - TSh ${amount.toStringAsFixed(0)}',
      type: 'sale',
      data: {
        'customer_name': customerName,
        'amount': amount,
      },
    );
  }

  Future<void> createPaymentNotification(String customerName, double amount) async {
    await createNotification(
      title: 'Payment Received',
      message: 'Payment of TSh ${amount.toStringAsFixed(0)} received from $customerName',
      type: 'payment',
      data: {
        'customer_name': customerName,
        'amount': amount,
      },
    );
  }

  Future<void> createReturnNotification(String productName, String reason) async {
    await createNotification(
      title: 'Product Return',
      message: '$productName returned. Reason: $reason',
      type: 'return',
      data: {
        'product_name': productName,
        'reason': reason,
      },
    );
  }
}