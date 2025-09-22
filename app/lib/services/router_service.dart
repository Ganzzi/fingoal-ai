/// App Router Service
///
/// Handles navigation and deep linking for FinGoal AI app.
/// Processes notification deep links and manages app navigation state.
library;

import 'package:flutter/material.dart';

/// Deep link routes supported by the app
enum AppRoute {
  dashboard('/dashboard'),
  chat('/chat'),
  budgets('/dashboard?tab=budget'),
  goals('/dashboard?tab=goals'),
  transactions('/transactions'),
  insights('/dashboard?tab=insights'),
  notifications('/notifications'),
  settings('/settings'),
  profile('/profile');

  const AppRoute(this.path);
  final String path;

  static AppRoute? fromPath(String path) {
    for (final route in AppRoute.values) {
      if (route.path == path || path.startsWith(route.path)) {
        return route;
      }
    }
    return null;
  }
}

/// Navigation parameters for deep linking
class NavigationParams {
  final Map<String, String> queryParams;
  final Map<String, dynamic> extras;

  const NavigationParams({
    this.queryParams = const {},
    this.extras = const {},
  });

  factory NavigationParams.fromUri(Uri uri) {
    return NavigationParams(
      queryParams: uri.queryParameters,
      extras: {},
    );
  }
}

/// App Router Service
class RouterService {
  static final RouterService _instance = RouterService._internal();
  factory RouterService() => _instance;
  RouterService._internal();

  GlobalKey<NavigatorState>? _navigatorKey;

  /// Set the navigator key for global navigation
  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  /// Get the current navigator state
  NavigatorState? get navigator => _navigatorKey?.currentState;

  /// Get the current build context
  BuildContext? get context => _navigatorKey?.currentContext;

  /// Handle deep link navigation
  Future<void> handleDeepLink(String deepLink) async {
    try {
      final uri = Uri.parse(deepLink);
      final route = AppRoute.fromPath(uri.path);
      final params = NavigationParams.fromUri(uri);

      if (route == null) {
        print('Unknown route: ${uri.path}');
        return;
      }

      await _navigateToRoute(route, params);
    } catch (e) {
      print('Error handling deep link: $e');
    }
  }

  /// Navigate to a specific route
  Future<void> _navigateToRoute(AppRoute route, NavigationParams params) async {
    final navigator = this.navigator;
    if (navigator == null) {
      print('Navigator not available');
      return;
    }

    // Wait a bit for the app to be ready
    await Future.delayed(const Duration(milliseconds: 500));

    switch (route) {
      case AppRoute.dashboard:
        await _navigateToDashboard(params);
        break;
      case AppRoute.chat:
        await _navigateToChat(params);
        break;
      case AppRoute.budgets:
        await _navigateToDashboard(params.copyWith(tab: 'budget'));
        break;
      case AppRoute.goals:
        await _navigateToDashboard(params.copyWith(tab: 'goals'));
        break;
      case AppRoute.transactions:
        await _navigateToTransactions(params);
        break;
      case AppRoute.insights:
        await _navigateToDashboard(params.copyWith(tab: 'insights'));
        break;
      case AppRoute.notifications:
        await _navigateToNotifications();
        break;
      case AppRoute.settings:
        await _navigateToSettings();
        break;
      case AppRoute.profile:
        await _navigateToProfile();
        break;
    }
  }

  /// Navigate to dashboard with optional tab
  Future<void> _navigateToDashboard(NavigationParams params) async {
    // For now, just print the navigation intent
    // In a real app, you'd use your navigation system
    print('Navigating to dashboard with params: ${params.queryParams}');

    // You can use Navigator.pushNamedAndClearStack or similar
    // navigator?.pushNamedAndClearStack('/dashboard', arguments: params);
  }

  /// Navigate to chat with optional context
  Future<void> _navigateToChat(NavigationParams params) async {
    print('Navigating to chat with params: ${params.queryParams}');

    // Handle chat navigation with context
    final transactionId = params.queryParams['transaction_id'];
    final goalId = params.queryParams['goal_id'];
    final categoryId = params.queryParams['category_id'];

    if (transactionId != null) {
      print('Opening chat with transaction context: $transactionId');
    } else if (goalId != null) {
      print('Opening chat with goal context: $goalId');
    } else if (categoryId != null) {
      print('Opening chat with category context: $categoryId');
    }
  }

  /// Navigate to transactions
  Future<void> _navigateToTransactions(NavigationParams params) async {
    print('Navigating to transactions with params: ${params.queryParams}');
  }

  /// Navigate to notifications
  Future<void> _navigateToNotifications() async {
    final navigator = this.navigator;
    if (navigator != null) {
      // Import the notification widgets file
      // navigator.pushNamed('/notifications');
      print('Navigating to notifications');
    }
  }

  /// Navigate to settings
  Future<void> _navigateToSettings() async {
    print('Navigating to settings');
  }

  /// Navigate to profile
  Future<void> _navigateToProfile() async {
    print('Navigating to profile');
  }

  /// Handle notification tap from various states
  Future<void> handleNotificationTap(String? deepLink) async {
    if (deepLink == null) return;

    print('Handling notification tap: $deepLink');
    await handleDeepLink(deepLink);
  }

  /// Parse fingoal:// scheme URLs
  static String? parseFingoalScheme(String url) {
    if (url.startsWith('fingoal://')) {
      return url.replaceFirst('fingoal://', '');
    }
    return url;
  }
}

/// Extension to add copyWith to NavigationParams
extension NavigationParamsExtension on NavigationParams {
  NavigationParams copyWith({
    Map<String, String>? queryParams,
    Map<String, dynamic>? extras,
    String? tab,
  }) {
    final newQueryParams = Map<String, String>.from(this.queryParams);
    if (tab != null) {
      newQueryParams['tab'] = tab;
    }
    if (queryParams != null) {
      newQueryParams.addAll(queryParams);
    }

    return NavigationParams(
      queryParams: newQueryParams,
      extras: extras ?? this.extras,
    );
  }
}
