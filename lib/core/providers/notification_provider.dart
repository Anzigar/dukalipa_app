import 'package:flutter/foundation.dart';
import '../../presentation/features/notifications/models/notification_model.dart';
import '../../presentation/features/notifications/repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _notificationRepository;
  
  // States
  bool _isLoading = false;
  String? _error;
  List<NotificationModel> _notifications = [];
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<NotificationModel> get notifications => _notifications;
  
  NotificationProvider(this._notificationRepository) {
    fetchNotifications();
  }
  
  Future<void> fetchNotifications() async {
    _setLoading(true);
    _clearError();
    
    try {
      final notifications = await _notificationRepository.getNotifications();
      _notifications = notifications;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }
  
  Future<void> markAsRead(String id) async {
    try {
      await _notificationRepository.markAsRead(id);
      
      // Update local state
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final updatedNotification = _notifications[index].copyWith(isRead: true);
        _notifications[index] = updatedNotification;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  Future<void> markAllAsRead() async {
    try {
      await _notificationRepository.markAllAsRead();
      
      // Update local state
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  Future<void> deleteNotification(String id) async {
    try {
      await _notificationRepository.deleteNotification(id);
      
      // Update local state
      _notifications.removeWhere((n) => n.id == id);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
