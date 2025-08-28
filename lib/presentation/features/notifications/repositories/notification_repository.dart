import '../../../../data/services/appwrite_notification_service.dart';
import '../models/notification_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
  Future<int> getUnreadCount();
}

class NotificationRepositoryImpl implements NotificationRepository {
  final AppwriteNotificationService _notificationService;

  NotificationRepositoryImpl() : _notificationService = AppwriteNotificationService();

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      return await _notificationService.getNotifications();
    } catch (e) {
      throw Exception('Failed to fetch notifications: ${e.toString()}');
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _notificationService.markAsRead(id);
    } catch (e) {
      throw Exception('Failed to mark notification as read: ${e.toString()}');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      await _notificationService.deleteNotification(id);
    } catch (e) {
      throw Exception('Failed to delete notification: ${e.toString()}');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      return await _notificationService.getUnreadCount();
    } catch (e) {
      throw Exception('Failed to get unread count: ${e.toString()}');
    }
  }
}