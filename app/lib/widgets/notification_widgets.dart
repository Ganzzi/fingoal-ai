/// Notification Widgets
///
/// UI components for displaying and managing push notifications in FinGoal AI.
/// Includes notification list items, history screen, and settings interface.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/notification_provider.dart';
import '../services/notification_service.dart';

/// Notification list item widget
class NotificationListItem extends StatelessWidget {
  final NotificationData notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationListItem({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key('${notification.timestamp.millisecondsSinceEpoch}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: theme.colorScheme.error,
        child: Icon(
          Icons.delete,
          color: theme.colorScheme.onError,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: _buildNotificationIcon(context, notification.type),
          title: Text(
            notification.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.body,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatTimestamp(notification.timestamp),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          trailing: _buildNotificationActions(context),
          onTap: onTap,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  /// Build notification type icon
  Widget _buildNotificationIcon(BuildContext context, NotificationType type) {
    final theme = Theme.of(context);
    IconData icon;
    Color color;

    switch (type) {
      case NotificationType.budgetWarning:
        icon = Icons.warning_amber;
        color = theme.colorScheme.tertiary;
        break;
      case NotificationType.budgetCritical:
        icon = Icons.error;
        color = theme.colorScheme.error;
        break;
      case NotificationType.budgetSuccess:
        icon = Icons.check_circle;
        color = theme.colorScheme.primary;
        break;
      case NotificationType.goalMilestone:
        icon = Icons.flag;
        color = theme.colorScheme.secondary;
        break;
      case NotificationType.goalAchievement:
        icon = Icons.emoji_events;
        color = const Color(0xFFFFD700); // Gold
        break;
      case NotificationType.goalReminder:
        icon = Icons.schedule;
        color = theme.colorScheme.outline;
        break;
      case NotificationType.spendingPattern:
        icon = Icons.trending_up;
        color = theme.colorScheme.tertiary;
        break;
      case NotificationType.savingsOpportunity:
        icon = Icons.savings;
        color = theme.colorScheme.primary;
        break;
      case NotificationType.financialHealth:
        icon = Icons.favorite;
        color = Colors.pink;
        break;
      case NotificationType.security:
        icon = Icons.security;
        color = theme.colorScheme.error;
        break;
      case NotificationType.systemUpdate:
        icon = Icons.system_update;
        color = theme.colorScheme.outline;
        break;
      case NotificationType.syncStatus:
        icon = Icons.sync;
        color = theme.colorScheme.outline;
        break;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }

  /// Build notification actions
  Widget _buildNotificationActions(BuildContext context) {
    if (notification.action != null) {
      return IconButton(
        icon: const Icon(Icons.arrow_forward_ios, size: 16),
        onPressed: onTap,
      );
    }
    return const SizedBox.shrink();
  }

  /// Format timestamp for display
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return DateFormat('MMM d, HH:mm').format(timestamp);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Notification history screen
class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  NotificationType? _selectedFilter;
  bool _showFilterOptions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: Icon(_showFilterOptions ? Icons.close : Icons.filter_list),
            onPressed: () =>
                setState(() => _showFilterOptions = !_showFilterOptions),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Clear All'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
            onSelected: _handleMenuAction,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilterOptions) _buildFilterOptions(),
          Expanded(
            child: Consumer<NotificationProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.error!,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.initialize(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final notifications = _getFilteredNotifications(provider);

                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter == null
                              ? 'No notifications yet'
                              : 'No ${_selectedFilter?.value} notifications',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You\'ll receive notifications about your financial activity here',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return NotificationListItem(
                      notification: notification,
                      onTap: () =>
                          _handleNotificationTap(context, notification),
                      onDismiss: () =>
                          _handleNotificationDismiss(context, notification),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build filter options
  Widget _buildFilterOptions() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by type',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _selectedFilter == null,
                onSelected: (_) => setState(() => _selectedFilter = null),
              ),
              ...NotificationType.values.map(
                (type) => FilterChip(
                  label: Text(_getTypeDisplayName(type)),
                  selected: _selectedFilter == type,
                  onSelected: (_) => setState(() => _selectedFilter = type),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Get filtered notifications
  List<NotificationData> _getFilteredNotifications(
      NotificationProvider provider) {
    if (_selectedFilter == null) {
      return provider.notificationHistory;
    }
    return provider.getNotificationsByType(_selectedFilter!);
  }

  /// Get display name for notification type
  String _getTypeDisplayName(NotificationType type) {
    switch (type) {
      case NotificationType.budgetWarning:
        return 'Budget Warnings';
      case NotificationType.budgetCritical:
        return 'Budget Critical';
      case NotificationType.budgetSuccess:
        return 'Budget Success';
      case NotificationType.goalMilestone:
        return 'Goal Milestones';
      case NotificationType.goalAchievement:
        return 'Achievements';
      case NotificationType.goalReminder:
        return 'Reminders';
      case NotificationType.spendingPattern:
        return 'Spending Patterns';
      case NotificationType.savingsOpportunity:
        return 'Savings Tips';
      case NotificationType.financialHealth:
        return 'Health Reports';
      case NotificationType.security:
        return 'Security';
      case NotificationType.systemUpdate:
        return 'System Updates';
      case NotificationType.syncStatus:
        return 'Sync Status';
    }
  }

  /// Handle menu actions
  void _handleMenuAction(String action) {
    final provider = Provider.of<NotificationProvider>(context, listen: false);

    switch (action) {
      case 'clear_all':
        _showClearAllDialog(provider);
        break;
      case 'settings':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const NotificationSettingsScreen(),
          ),
        );
        break;
    }
  }

  /// Show clear all confirmation dialog
  void _showClearAllDialog(NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text(
            'Are you sure you want to clear all notification history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              provider.clearHistory();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  /// Handle notification tap
  void _handleNotificationTap(
      BuildContext context, NotificationData notification) {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    provider.markAsRead(notification);

    // Handle deep linking based on notification type
    if (notification.deepLink != null) {
      _navigateToDeepLink(context, notification.deepLink!);
    } else {
      // Show notification details
      _showNotificationDetails(context, notification);
    }
  }

  /// Handle notification dismiss
  void _handleNotificationDismiss(
      BuildContext context, NotificationData notification) {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    provider.markAsRead(notification);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification dismissed'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Navigate to deep link
  void _navigateToDeepLink(BuildContext context, String deepLink) {
    // Parse deep link and navigate accordingly
    // This would integrate with your app's routing system
    print('Navigating to: $deepLink');

    // For now, just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening: $deepLink'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show notification details
  void _showNotificationDetails(
      BuildContext context, NotificationData notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(notification.body),
              const SizedBox(height: 16),
              Text(
                'Received: ${DateFormat('MMM d, yyyy HH:mm').format(notification.timestamp)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (notification.data.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Additional Data:'),
                const SizedBox(height: 8),
                ...notification.data.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('${entry.key}: ${entry.value}'),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (notification.deepLink != null)
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToDeepLink(context, notification.deepLink!);
              },
              child: const Text('Open'),
            ),
        ],
      ),
    );
  }
}

/// Notification settings screen
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (!provider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: [
              const SizedBox(height: 16),

              // FCM Token Section (Debug only)
              if (provider.fcmToken != null) ...[
                const ListTile(
                  title: Text(
                    'Device Information',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ListTile(
                  title: const Text('FCM Token'),
                  subtitle: Text(
                    '${provider.fcmToken?.substring(0, 20)}...',
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => provider.refreshToken(),
                  ),
                ),
                const Divider(),
              ],

              // Notification Type Preferences
              const ListTile(
                title: Text(
                  'Notification Types',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                    'Choose which types of notifications you want to receive'),
              ),

              ...NotificationType.values.map(
                (type) => SwitchListTile(
                  title: Text(_getTypeDisplayName(type)),
                  subtitle: Text(_getTypeDescription(type)),
                  value: provider.isTypeEnabled(type),
                  onChanged: (enabled) =>
                      provider.setNotificationTypeEnabled(type, enabled),
                ),
              ),

              const Divider(),

              // Actions
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('View Notification History'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NotificationHistoryScreen(),
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.clear_all),
                title: const Text('Clear All History'),
                textColor: Theme.of(context).colorScheme.error,
                iconColor: Theme.of(context).colorScheme.error,
                onTap: () => _showClearHistoryDialog(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Get display name for notification type
  String _getTypeDisplayName(NotificationType type) {
    switch (type) {
      case NotificationType.budgetWarning:
        return 'Budget Warnings';
      case NotificationType.budgetCritical:
        return 'Budget Exceeded';
      case NotificationType.budgetSuccess:
        return 'Budget Success';
      case NotificationType.goalMilestone:
        return 'Goal Milestones';
      case NotificationType.goalAchievement:
        return 'Goal Achievements';
      case NotificationType.goalReminder:
        return 'Goal Reminders';
      case NotificationType.spendingPattern:
        return 'Spending Insights';
      case NotificationType.savingsOpportunity:
        return 'Savings Opportunities';
      case NotificationType.financialHealth:
        return 'Financial Health';
      case NotificationType.security:
        return 'Security Alerts';
      case NotificationType.systemUpdate:
        return 'System Updates';
      case NotificationType.syncStatus:
        return 'Sync Status';
    }
  }

  /// Get description for notification type
  String _getTypeDescription(NotificationType type) {
    switch (type) {
      case NotificationType.budgetWarning:
        return 'Alerts when you approach your budget limits';
      case NotificationType.budgetCritical:
        return 'Alerts when you exceed your budget';
      case NotificationType.budgetSuccess:
        return 'Celebrate when you stay within budget';
      case NotificationType.goalMilestone:
        return 'Progress updates on your financial goals';
      case NotificationType.goalAchievement:
        return 'Celebrate when you achieve your goals';
      case NotificationType.goalReminder:
        return 'Reminders about upcoming goal deadlines';
      case NotificationType.spendingPattern:
        return 'AI insights about your spending habits';
      case NotificationType.savingsOpportunity:
        return 'Tips to save money on your expenses';
      case NotificationType.financialHealth:
        return 'Weekly and monthly financial summaries';
      case NotificationType.security:
        return 'Important security and login alerts';
      case NotificationType.systemUpdate:
        return 'App updates and new feature announcements';
      case NotificationType.syncStatus:
        return 'Data synchronization status updates';
    }
  }

  /// Show clear history confirmation dialog
  void _showClearHistoryDialog(
      BuildContext context, NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Notification History'),
        content: const Text(
            'Are you sure you want to clear all notification history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              provider.clearHistory();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
