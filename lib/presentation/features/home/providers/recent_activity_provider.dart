import 'package:flutter/foundation.dart';
import '../repositories/analytics_repository.dart';

class RecentActivityProvider extends ChangeNotifier {
  final AnalyticsRepository _analyticsRepository;

  RecentActivityProvider(this._analyticsRepository);

  // Recent activities data
  List<Map<String, dynamic>> _recentActivities = [];
  bool _isLoadingActivities = false;
  String? _activitiesError;

  // Getters
  List<Map<String, dynamic>> get recentActivities => _recentActivities;
  bool get isLoadingActivities => _isLoadingActivities;
  String? get activitiesError => _activitiesError;

  /// Load recent activities from API
  Future<void> loadRecentActivities({int limit = 10}) async {
    _isLoadingActivities = true;
    _activitiesError = null;
    notifyListeners();

    try {
      // For now, just create mock activities
      // In the future, this could fetch real activity data from the analytics repository
      _recentActivities = _createMockActivities(limit);
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

  /// Create mock activities for demonstration
  List<Map<String, dynamic>> _createMockActivities(int limit) {
    final activities = <Map<String, dynamic>>[
      {
        'id': '1',
        'type': 'sale',
        'title': 'New sale recorded',
        'description': 'Sale of TSh 50,000 to John Doe',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
        'icon': 'shopping_cart',
      },
      {
        'id': '2',
        'type': 'inventory',
        'title': 'Low stock alert',
        'description': 'iPhone 14 Pro Max running low (5 units left)',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'icon': 'alert_triangle',
      },
      {
        'id': '3',
        'type': 'return',
        'title': 'Product returned',
        'description': 'Samsung Galaxy S23 returned by customer',
        'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
        'icon': 'rotate_ccw',
      },
      {
        'id': '4',
        'type': 'expense',
        'title': 'New expense added',
        'description': 'Office supplies - TSh 25,000',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'icon': 'receipt',
      },
    ];
    
    return activities.take(limit).toList();
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
