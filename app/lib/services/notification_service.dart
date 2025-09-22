/// Push Notification Service
///
/// Handles Firebase Cloud Messaging (FCM) integration for FinGoal AI app.
/// Manages device token registration, notification permissions, and message handling.
///
/// NOTE: Firebase dependencies have been REMOVED as of September 2025.
/// All Firebase-related code has been stubbed out and commented for future reference.
/// A new notification technique will be implemented in the future.
///
/// Features:
/// - FCM token management and registration (STUBBED)
/// - Notification permission handling
/// - Foreground, background, and terminated state message processing (STUBBED)
/// - Deep linking from notifications (STUBBED)
/// - Local notification display
/// - User preference management

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart'; // REMOVED: Firebase dependency
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notification types supported by FinGoal AI
enum NotificationType {
  budgetWarning('budget_warning'),
  budgetCritical('budget_critical'),
  budgetSuccess('budget_success'),
  goalMilestone('goal_milestone'),
  goalAchievement('goal_achievement'),
  goalReminder('goal_reminder'),
  spendingPattern('spending_pattern'),
  savingsOpportunity('savings_opportunity'),
  financialHealth('financial_health'),
  security('security'),
  systemUpdate('system_update'),
  syncStatus('sync_status');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.systemUpdate,
    );
  }
}

/// Notification data structure
class NotificationData {
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String? deepLink;
  final String? action;
  final DateTime timestamp;

  const NotificationData({
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    this.deepLink,
    this.action,
    required this.timestamp,
  });

  factory NotificationData.fromRemoteMessage(/* RemoteMessage message */) {
    // REMOVED: Firebase RemoteMessage parsing
    // final notification = message.notification;
    // final data = message.data;
    //
    // return NotificationData(
    //   type: NotificationType.fromString(data['type'] ?? 'system_update'),
    //   title: notification?.title ?? 'FinGoal AI',
    //   body: notification?.body ?? 'You have a new notification',
    //   data: data,
    //   deepLink: data['deep_link'],
    //   action: data['action'],
    //   timestamp: DateTime.now(),
    // );

    // Stub implementation - return default notification
    return NotificationData(
      type: NotificationType.systemUpdate,
      title: 'FinGoal AI',
      body: 'Notification system initialized (Firebase removed)',
      data: {},
      timestamp: DateTime.now(),
    );
  }

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      type: NotificationType.fromString(json['type'] ?? 'system_update'),
      title: json['title'] ?? 'FinGoal AI',
      body: json['body'] ?? 'You have a new notification',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      deepLink: json['deep_link'],
      action: json['action'],
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.value,
        'title': title,
        'body': body,
        'data': data,
        'deep_link': deepLink,
        'action': action,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Push Notification Service
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // REMOVED: Firebase Messaging instance
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Local notifications plugin
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Stream controller for notification callbacks
  final StreamController<NotificationData> _notificationStreamController =
      StreamController<NotificationData>.broadcast();

  // Current FCM token
  String? _currentToken;

  // Navigation callback for deep linking
  Function(String)? _onNotificationTap;

  // Initialization status
  bool _isInitialized = false;

  /// Stream of notification data
  Stream<NotificationData> get notificationStream =>
      _notificationStreamController.stream;

  /// Current FCM token
  String? get currentToken => _currentToken;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the notification service
  Future<void> initialize({Function(String)? onNotificationTap}) async {
    if (_isInitialized) return;

    try {
      _onNotificationTap = onNotificationTap;

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permissions
      await _requestPermissions();

      // Initialize FCM
      await _initializeFirebaseMessaging();

      // Get and store FCM token
      await _refreshFCMToken();

      // Set up message handlers
      _setupMessageHandlers();

      _isInitialized = true;
      if (kDebugMode) {
        print('NotificationService initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize NotificationService: $e');
      }
      rethrow;
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    // Android initialization settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    const channels = [
      AndroidNotificationChannel(
        'budget_alerts',
        'Budget Alerts',
        description: 'Notifications about budget status and warnings',
        importance: Importance.high,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'goal_notifications',
        'Goal Updates',
        description: 'Notifications about goal progress and achievements',
        importance: Importance.defaultImportance,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'insights',
        'Financial Insights',
        description: 'AI-generated financial insights and recommendations',
        importance: Importance.defaultImportance,
        playSound: false,
      ),
      AndroidNotificationChannel(
        'system',
        'System Notifications',
        description: 'App updates and system messages',
        importance: Importance.low,
        playSound: false,
      ),
    ];

    for (final channel in channels) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Request notification permissions - STUB: Firebase removed
  Future<void> _requestPermissions() async {
    // REMOVED: Firebase Messaging permissions
    // final settings = await _firebaseMessaging.requestPermission(
    //   alert: true,
    //   announcement: false,
    //   badge: true,
    //   carPlay: false,
    //   criticalAlert: false,
    //   provisional: false,
    //   sound: true,
    // );
    //
    // if (kDebugMode) {
    //   print('Notification permission status: ${settings.authorizationStatus}');
    // }

    // Request additional permissions on Android
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }

    if (kDebugMode) {
      print('Notification permissions requested - Firebase removed');
    }
  }

  /// Initialize Firebase Messaging - STUB: Firebase removed
  Future<void> _initializeFirebaseMessaging() async {
    // REMOVED: Firebase foreground notification presentation options
    // await _firebaseMessaging.setForegroundNotificationPresentationOptions(
    //   alert: true,
    //   badge: true,
    //   sound: true,
    // );

    // Stub implementation
    if (kDebugMode) {
      print('Firebase messaging initialization skipped - Firebase removed');
    }
  }

  /// Setup FCM message handlers - STUB: Firebase removed
  void _setupMessageHandlers() {
    // REMOVED: Firebase message handlers
    // // Handle messages when app is in foreground
    // FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    //
    // // Handle messages when app is in background but not terminated
    // FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    //
    // // Handle token refresh
    // _firebaseMessaging.onTokenRefresh.listen(_handleTokenRefresh);

    // Stub implementation - no Firebase message handling
    if (kDebugMode) {
      print('Message handlers setup skipped - Firebase removed');
    }
  }

  /// Handle foreground message - STUB: Firebase removed
  Future<void> _handleForegroundMessage(/* RemoteMessage message */) async {
    // REMOVED: Firebase foreground message handling
    // if (kDebugMode) {
    //   print('Received foreground message: ${message.messageId}');
    // }
    //
    // final notificationData = NotificationData.fromRemoteMessage(message);
    //
    // // Display local notification
    // await _showLocalNotification(notificationData);
    //
    // // Emit to stream
    // _notificationStreamController.add(notificationData);
    //
    // // Store notification history
    // await _storeNotification(notificationData);

    // Stub implementation
    if (kDebugMode) {
      print('Foreground message handling skipped - Firebase removed');
    }
  }

  /// Handle notification tap (app opened from background) - STUB: Firebase removed
  Future<void> _handleNotificationTap(/* RemoteMessage message */) async {
    // REMOVED: Firebase notification tap handling
    // if (kDebugMode) {
    //   print('Notification tapped: ${message.messageId}');
    // }
    //
    // final notificationData = NotificationData.fromRemoteMessage(message);
    //
    // // Handle deep linking
    // if (notificationData.deepLink != null && _onNotificationTap != null) {
    //   _onNotificationTap!(notificationData.deepLink!);
    // }
    //
    // // Emit to stream
    // _notificationStreamController.add(notificationData);
    //
    // // Store notification history
    // await _storeNotification(notificationData);

    // Stub implementation
    if (kDebugMode) {
      print('Notification tap handling skipped - Firebase removed');
    }
  }

  /// Handle local notification tap
  void _onLocalNotificationTap(NotificationResponse response) {
    if (kDebugMode) {
      print('Local notification tapped: ${response.id}');
    }

    final payload = response.payload;
    if (payload != null && _onNotificationTap != null) {
      try {
        final data = jsonDecode(payload);
        final deepLink = data['deep_link'] as String?;
        if (deepLink != null) {
          _onNotificationTap!(deepLink);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing notification payload: $e');
        }
      }
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(NotificationData data) async {
    final channelId = _getChannelIdForType(data.type);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelNameForType(data.type),
      channelDescription: _getChannelDescriptionForType(data.type),
      importance: _getImportanceForType(data.type),
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      color: _getColorForType(data.type),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      data.title,
      data.body,
      details,
      payload: jsonEncode(data.toJson()),
    );
  }

  /// Get notification channel ID for type
  String _getChannelIdForType(NotificationType type) {
    switch (type) {
      case NotificationType.budgetWarning:
      case NotificationType.budgetCritical:
      case NotificationType.budgetSuccess:
        return 'budget_alerts';
      case NotificationType.goalMilestone:
      case NotificationType.goalAchievement:
      case NotificationType.goalReminder:
        return 'goal_notifications';
      case NotificationType.spendingPattern:
      case NotificationType.savingsOpportunity:
      case NotificationType.financialHealth:
        return 'insights';
      default:
        return 'system';
    }
  }

  /// Get channel name for type
  String _getChannelNameForType(NotificationType type) {
    switch (type) {
      case NotificationType.budgetWarning:
      case NotificationType.budgetCritical:
      case NotificationType.budgetSuccess:
        return 'Budget Alerts';
      case NotificationType.goalMilestone:
      case NotificationType.goalAchievement:
      case NotificationType.goalReminder:
        return 'Goal Updates';
      case NotificationType.spendingPattern:
      case NotificationType.savingsOpportunity:
      case NotificationType.financialHealth:
        return 'Financial Insights';
      default:
        return 'System Notifications';
    }
  }

  /// Get channel description for type
  String _getChannelDescriptionForType(NotificationType type) {
    switch (type) {
      case NotificationType.budgetWarning:
      case NotificationType.budgetCritical:
      case NotificationType.budgetSuccess:
        return 'Notifications about budget status and warnings';
      case NotificationType.goalMilestone:
      case NotificationType.goalAchievement:
      case NotificationType.goalReminder:
        return 'Notifications about goal progress and achievements';
      case NotificationType.spendingPattern:
      case NotificationType.savingsOpportunity:
      case NotificationType.financialHealth:
        return 'AI-generated financial insights and recommendations';
      default:
        return 'App updates and system messages';
    }
  }

  /// Get importance for notification type
  Importance _getImportanceForType(NotificationType type) {
    switch (type) {
      case NotificationType.budgetCritical:
      case NotificationType.security:
        return Importance.max;
      case NotificationType.budgetWarning:
      case NotificationType.goalAchievement:
        return Importance.high;
      case NotificationType.goalMilestone:
      case NotificationType.goalReminder:
      case NotificationType.budgetSuccess:
        return Importance.defaultImportance;
      default:
        return Importance.low;
    }
  }

  /// Get color for notification type
  Color? _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.budgetCritical:
        return const Color(0xFFE53E3E); // Red
      case NotificationType.budgetWarning:
        return const Color(0xFFED8936); // Orange
      case NotificationType.budgetSuccess:
      case NotificationType.goalAchievement:
        return const Color(0xFF38A169); // Green
      case NotificationType.goalMilestone:
      case NotificationType.goalReminder:
        return const Color(0xFF3182CE); // Blue
      default:
        return const Color(0xFF805AD5); // Purple
    }
  }

  /// Refresh FCM token - STUB: Firebase removed
  Future<void> _refreshFCMToken() async {
    // REMOVED: Firebase token retrieval
    // try {
    //   final token = await _firebaseMessaging.getToken();
    //   if (token != null && token != _currentToken) {
    //     _currentToken = token;
    //     await _storeFCMToken(token);
    //     if (kDebugMode) {
    //       print('FCM Token: $token');
    //     }
    //   }
    // } catch (e) {
    //   if (kDebugMode) {
    //     print('Failed to get FCM token: $e');
    //   }
    // }

    // Stub implementation - no token available without Firebase
    if (kDebugMode) {
      print('FCM token refresh skipped - Firebase removed');
    }
  }

  /// Handle token refresh - STUB: Firebase removed
  Future<void> _handleTokenRefresh(String token) async {
    // REMOVED: Firebase token refresh handling
    // _currentToken = token;
    // await _storeFCMToken(token);
    // if (kDebugMode) {
    //   print('FCM Token refreshed: $token');
    // }

    // Stub implementation
    if (kDebugMode) {
      print('Token refresh handling skipped - Firebase removed');
    }
  }

  /// Store FCM token locally
  Future<void> _storeFCMToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
    await prefs.setString(
        'fcm_token_timestamp', DateTime.now().toIso8601String());
  }

  /// Get stored FCM token
  Future<String?> getStoredFCMToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  /// Store notification in history
  Future<void> _storeNotification(NotificationData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingHistory = prefs.getStringList('notification_history') ?? [];

      // Add new notification
      existingHistory.insert(0, jsonEncode(data.toJson()));

      // Keep only last 50 notifications
      if (existingHistory.length > 50) {
        existingHistory.removeRange(50, existingHistory.length);
      }

      await prefs.setStringList('notification_history', existingHistory);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to store notification: $e');
      }
    }
  }

  /// Get notification history
  Future<List<NotificationData>> getNotificationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('notification_history') ?? [];

      return historyJson
          .map((json) => NotificationData.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get notification history: $e');
      }
      return [];
    }
  }

  /// Clear notification history
  Future<void> clearNotificationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notification_history');
  }

  /// Check if notifications are enabled for type
  Future<bool> isNotificationTypeEnabled(NotificationType type) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notification_${type.value}_enabled') ?? true;
  }

  /// Set notification type enabled/disabled
  Future<void> setNotificationTypeEnabled(
      NotificationType type, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_${type.value}_enabled', enabled);
  }

  /// Handle initial message when app is opened from terminated state - STUB: Firebase removed
  Future<void> handleInitialMessage() async {
    // REMOVED: Firebase initial message handling
    // final message = await _firebaseMessaging.getInitialMessage();
    // if (message != null) {
    //   await _handleNotificationTap(message);
    // }

    // Stub implementation
    if (kDebugMode) {
      print('Initial message handling skipped - Firebase removed');
    }
  }

  /// Dispose resources
  void dispose() {
    _notificationStreamController.close();
  }
}
