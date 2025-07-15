import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../models/notification_model.dart';
import '../../../common/widgets/empty_state.dart';
import '../../../common/widgets/shimmer_loading.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh notifications when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final notifications = notificationProvider.notifications;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          if (notifications.isNotEmpty && notifications.any((n) => !n.isRead))
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: l10n.markAllAsRead,
              onPressed: () => notificationProvider.markAllAsRead(),
            ),
        ],
      ),
      body: _buildBody(context, notificationProvider),
    );
  }

  Widget _buildBody(BuildContext context, NotificationProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    
    if (provider.isLoading) {
      return ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) => const TransactionCardShimmer(),
      );
    }
    
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.noNotifications,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              provider.error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.fetchNotifications(),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }
    
    if (provider.notifications.isEmpty) {
      return EmptyState(
        icon: Icons.notifications_none,
        title: l10n.noNotifications,
        message: 'You don\'t have any notifications yet',
        buttonText: l10n.refresh,
        onButtonPressed: () => provider.fetchNotifications(),
      );
    }
    
    // Group notifications by date for better organization
    final groupedNotifications = _groupNotificationsByDate(provider.notifications);
    
    return RefreshIndicator(
      onRefresh: () => provider.fetchNotifications(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groupedNotifications.length,
        itemBuilder: (context, index) {
          final dateGroup = groupedNotifications.keys.elementAt(index);
          final notificationsInGroup = groupedNotifications[dateGroup]!;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  dateGroup,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Notifications for this date
              ...notificationsInGroup.map((notification) {
                return Column(
                  children: [
                    NotificationTile(
                      notification: notification,
                      onTap: () {
                        if (!notification.isRead) {
                          provider.markAsRead(notification.id);
                        }
                        
                        if (notification.actionRoute != null) {
                          context.push(notification.actionRoute!);
                        }
                      },
                      onDismiss: () => provider.deleteNotification(notification.id),
                    ),
                    const Divider(),
                  ],
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  // Helper method to group notifications by date
  Map<String, List<NotificationModel>> _groupNotificationsByDate(List<NotificationModel> notifications) {
    final groupedNotifications = <String, List<NotificationModel>>{};
    
    for (var notification in notifications) {
      final date = _getFormattedDate(notification.timestamp);
      
      if (!groupedNotifications.containsKey(date)) {
        groupedNotifications[date] = [];
      }
      
      groupedNotifications[date]!.add(notification);
    }
    
    return groupedNotifications;
  }

  // Format date for grouping
  String _getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final notificationDate = DateTime(date.year, date.month, date.day);
    
    if (notificationDate == DateTime(now.year, now.month, now.day)) {
      return 'Today';
    } else if (notificationDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(l10n.deleteNotification),
              content: Text(l10n.deleteConfirmation),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(l10n.delete),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) => onDismiss(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification icon with type-specific styling
              _buildNotificationIcon(),
              const SizedBox(width: 12),
              
              // Notification content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            notification.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: notification.isRead 
                                  ? FontWeight.normal 
                                  : FontWeight.bold,
                              color: _getTitleColor(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: notification.typeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: notification.isRead
                            ? AppTheme.mkbhdLightGrey
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          notification.formattedTimestamp,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.mkbhdLightGrey,
                          ),
                        ),
                        if (notification.actionRoute != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: notification.typeColor,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build notification icon with type-specific styling
  Widget _buildNotificationIcon() {
    // Use different shapes based on notification type
    final isCircular = notification.type == 'alert' || notification.type == 'warning';
    
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: notification.typeColor.withOpacity(0.1),
        borderRadius: isCircular 
            ? BorderRadius.circular(20) 
            : BorderRadius.circular(12),
        border: notification.type == 'important' 
            ? Border.all(color: notification.typeColor, width: 1.5) 
            : null,
      ),
      child: Icon(
        notification.typeIcon,
        color: notification.typeColor,
        size: 24,
      ),
    );
  }

  // Get title color based on notification type
  Color _getTitleColor(BuildContext context) {
    if (!notification.isRead) {
      // Use type-specific colors for unread notifications
      if (notification.type == 'important' || notification.type == 'alert') {
        return notification.typeColor;
      }
    }
    
    // Use default text color for read notifications
    return notification.isRead
        ? Theme.of(context).textTheme.titleMedium!.color!.withOpacity(0.8)
        : Theme.of(context).textTheme.titleMedium!.color!;
  }
}
