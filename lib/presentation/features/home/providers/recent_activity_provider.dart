import 'package:flutter/foundation.dart';
import '../../../../data/services/recent_activity_service.dart';

class RecentActivityProvider extends ChangeNotifier {
  final RecentActivityService _activityService;

  RecentActivityProvider(this._activityService);

  // Recent activities data
  List<RecentActivityItem> _recentActivities = [];
  bool _isLoadingActivities = false;
  String? _activitiesError;

  // Getters
  List<RecentActivityItem> get recentActivities => _recentActivities;
  bool get isLoadingActivities => _isLoadingActivities;
  String? get activitiesError => _activitiesError;

  /// Load recent activities from API
  Future<void> loadRecentActivities({int limit = 10}) async {
    _isLoadingActivities = true;
    _activitiesError = null;
    notifyListeners();

    try {
      _recentActivities = await _activityService.getRecentActivities(limit: limit);
      _activitiesError = null;
    } catch (e) {
      _activitiesError = 'Failed to load recent activities: $e';
      if (kDebugMode) {
        print('Error loading recent activities: $e');
      }
    } finally {
      _isLoadingActivities = false;
      notifyListeners();
    }
  }

  /// Refresh recent activities
  Future<void> refreshActivities() async {
    await loadRecentActivities();
  }

  /// Clear activities data
  void clearActivities() {
    _recentActivities = [];
    _activitiesError = null;
    notifyListeners();
  }
}
