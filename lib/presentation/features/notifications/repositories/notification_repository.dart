
import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
}

class NotificationRepositoryImpl implements NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepositoryImpl(this._apiClient);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiClient.get('/notifications');
      final List<dynamic> data = response['notifications'];
      return data.map((item) => NotificationModel.fromJson(item)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _apiClient.put(
        '/notifications/$id/read',
        data: {'is_read': true},
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _apiClient.put('/notifications/read-all');
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      await _apiClient.delete('/notifications/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    // Handle common network errors
    if (error.toString().contains('timeout')) {
      return Exception('Network timeout. Please check your internet connection.');
    }
    
    if (error.toString().contains('401') || error.toString().contains('unauthorized')) {
      return Exception('Authentication error. Please log in again.');
    }
    
    if (error.toString().contains('403') || error.toString().contains('forbidden')) {
      return Exception('You don\'t have permission to access this resource.');
    }
    
    if (error.toString().contains('404') || error.toString().contains('not found')) {
      return Exception('The requested notification was not found.');
    }
    
    // Generic error handling
    return Exception('Failed to complete notification operation: ${error.toString()}');
  }
}
