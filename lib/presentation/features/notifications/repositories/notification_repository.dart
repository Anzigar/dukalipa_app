import 'package:dio/dio.dart';
import '../models/notification_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String id);
}

class NotificationRepositoryImpl implements NotificationRepository {
  late final Dio _dio;

  NotificationRepositoryImpl() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api/v1',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      final List<dynamic> data = response.data['notifications'];
      return data.map((item) => NotificationModel.fromJson(item)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _dio.post(
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
      await _dio.post('/notifications/read-all');
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      await _dio.delete('/notifications/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return Exception('Network error. Please check your internet connection.');
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          if (statusCode == 404) {
            return Exception('Notification not found.');
          }
          if (statusCode == 401 || statusCode == 403) {
            return Exception('Authentication error. Please login again.');
          }
          return Exception('Server error: ${e.response?.statusMessage}');
        default:
          return Exception('An error occurred: ${e.message}');
      }
    }
    
    return Exception('An error occurred: ${e.toString()}');
  }
}
