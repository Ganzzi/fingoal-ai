/// Notification Provider
///
/// Manages notification state and preferences for the FinGoal AI app.
/// Handles notification service integration, user preferences, and UI state.

import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';

/// Notification provider for state management
class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  // State variables
  bool _isInitialized = false;
  bool _hasPermission = false;
  String? _fcmToken;
  List<NotificationData> _notificationHistory = [];
  Map<NotificationType, bool> _typePreferences = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get hasPermission => _hasPermission;
  String? get fcmToken => _fcmToken;
  List<NotificationData> get notificationHistory =>
      List.unmodifiable(_notificationHistory);
  Map<NotificationType, bool> get typePreferences =>
      Map.unmodifiable(_typePreferences);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize notification provider
  Future<void> initialize({Function(String)? onNotificationTap}) async {
    if (_isInitialized) return;

    _setLoading(true);
    _clearError();

    try {
      // Initialize notification service
      await _notificationService.initialize(
          onNotificationTap: onNotificationTap);

      // Get current token
      _fcmToken = _notificationService.currentToken;

      // Load preferences
      await _loadNotificationPreferences();

      // Load notification history
      await _loadNotificationHistory();

      // Listen to notification stream
      _notificationService.notificationStream.listen(_handleNotification);

      // Handle initial message
      await _notificationService.handleInitialMessage();

      _hasPermission = true;
      _isInitialized = true;

      if (kDebugMode) {
        print('NotificationProvider initialized successfully');
      }
    } catch (e) {
      _setError('Failed to initialize notifications: $e');
      if (kDebugMode) {
        print('NotificationProvider initialization failed: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Handle incoming notification
  void _handleNotification(NotificationData data) {
    // Add to history
    _notificationHistory.insert(0, data);

    // Keep only last 50 notifications
    if (_notificationHistory.length > 50) {
      _notificationHistory = _notificationHistory.take(50).toList();
    }

    notifyListeners();
  }

  /// Load notification preferences
  Future<void> _loadNotificationPreferences() async {
    try {
      final preferences = <NotificationType, bool>{};

      for (final type in NotificationType.values) {
        preferences[type] =
            await _notificationService.isNotificationTypeEnabled(type);
      }

      _typePreferences = preferences;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load notification preferences: $e');
      }
    }
  }

  /// Load notification history
  Future<void> _loadNotificationHistory() async {
    try {
      _notificationHistory =
          await _notificationService.getNotificationHistory();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load notification history: $e');
      }
    }
  }

  /// Set notification type preference
  Future<void> setNotificationTypeEnabled(
      NotificationType type, bool enabled) async {
    _setLoading(true);
    _clearError();

    try {
      await _notificationService.setNotificationTypeEnabled(type, enabled);
      _typePreferences[type] = enabled;
      notifyListeners();
    } catch (e) {
      _setError('Failed to update notification preferences: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Clear all notification history
  Future<void> clearHistory() async {
    _setLoading(true);
    _clearError();

    try {
      await _notificationService.clearNotificationHistory();
      _notificationHistory.clear();
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear notification history: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh FCM token
  Future<void> refreshToken() async {
    _setLoading(true);
    _clearError();

    try {
      // Force token refresh by reinitializing the service
      await _notificationService.initialize();
      _fcmToken = _notificationService.currentToken;
      notifyListeners();
    } catch (e) {
      _setError('Failed to refresh FCM token: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get stored FCM token
  Future<String?> getStoredToken() async {
    try {
      return await _notificationService.getStoredFCMToken();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get stored token: $e');
      }
      return null;
    }
  }

  /// Mark notification as read
  void markAsRead(NotificationData notification) {
    final index = _notificationHistory.indexWhere(
      (n) =>
          n.timestamp == notification.timestamp &&
          n.title == notification.title,
    );

    if (index != -1) {
      // For now, we'll just remove from local list
      // In production, you'd want to sync this with backend
      notifyListeners();
    }
  }

  /// Get unread notification count
  int get unreadCount {
    // For now, return total count
    // In production, implement read/unread tracking
    return _notificationHistory.length;
  }

  /// Filter notifications by type
  List<NotificationData> getNotificationsByType(NotificationType type) {
    return _notificationHistory.where((n) => n.type == type).toList();
  }

  /// Get recent notifications (last 24 hours)
  List<NotificationData> get recentNotifications {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return _notificationHistory
        .where((n) => n.timestamp.isAfter(yesterday))
        .toList();
  }

  /// Check if notification type is enabled
  bool isTypeEnabled(NotificationType type) {
    return _typePreferences[type] ?? true;
  }

  /// Set loading state
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Set error message
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _notificationService.dispose();
    super.dispose();
  }
}
