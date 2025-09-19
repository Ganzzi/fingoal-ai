import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/dashboard_models.dart';
import '../services/dashboard_service.dart';

/// Dashboard data provider using Provider pattern
///
/// Manages dashboard data state, loading states, error handling,
/// and data persistence for offline viewing. Provides methods
/// for fetching, refreshing, and managing dashboard data.
class DashboardProvider with ChangeNotifier {
  final DashboardService _dashboardService = DashboardService();

  // State management
  DashboardData? _dashboardData;
  DashboardLoadingState _loadingState = DashboardLoadingState.initial;
  DashboardServiceException? _error;
  DateTime? _lastFetched;
  bool _hasInitialized = false;

  // Getters
  DashboardData? get dashboardData => _dashboardData;
  DashboardLoadingState get loadingState => _loadingState;
  DashboardServiceException? get error => _error;
  DateTime? get lastFetched => _lastFetched;
  bool get hasInitialized => _hasInitialized;
  bool get hasData => _dashboardData != null;
  bool get hasError => _error != null;
  bool get isLoading => _loadingState == DashboardLoadingState.loading;
  bool get isRefreshing => _loadingState == DashboardLoadingState.refreshing;
  bool get isEmpty => _dashboardData?.isEmpty ?? false;

  /// Initialize the provider and attempt to load cached data
  Future<void> initialize() async {
    if (_hasInitialized) return;

    _hasInitialized = true;
    await _loadCachedData();
    notifyListeners();
  }

  /// Fetch dashboard data from API
  Future<void> fetchDashboardData({
    required String authToken,
    bool isRefresh = false,
  }) async {
    try {
      // Set loading state
      _setLoadingState(isRefresh
          ? DashboardLoadingState.refreshing
          : DashboardLoadingState.loading);
      _clearError();

      // Fetch data from API
      final dashboardData = await _dashboardService.getDashboardData(
        authToken: authToken,
      );

      // Update state
      _dashboardData = dashboardData;
      _lastFetched = DateTime.now();
      _setLoadingState(DashboardLoadingState.success);

      // Cache the data for offline access
      await _cacheData(dashboardData);

      notifyListeners();
    } on DashboardServiceException catch (e) {
      _setError(e);
      _setLoadingState(DashboardLoadingState.error);
      notifyListeners();
    } catch (e) {
      final exception = DashboardServiceException(
        message: e.toString(),
        type: DashboardServiceExceptionType.unknown,
      );
      _setError(exception);
      _setLoadingState(DashboardLoadingState.error);
      notifyListeners();
    }
  }

  /// Refresh dashboard data (pull-to-refresh)
  Future<void> refreshDashboardData({
    required String authToken,
  }) async {
    await fetchDashboardData(authToken: authToken, isRefresh: true);
  }

  /// Retry fetching data after an error
  Future<void> retryFetch({
    required String authToken,
  }) async {
    if (!hasError) return;
    await fetchDashboardData(authToken: authToken);
  }

  /// Clear all data and reset state
  void clearData() {
    _dashboardData = null;
    _lastFetched = null;
    _setLoadingState(DashboardLoadingState.initial);
    _clearError();
    _clearCachedData();
    notifyListeners();
  }

  /// Get data age in minutes
  int? get dataAgeInMinutes {
    if (_lastFetched == null) return null;
    final now = DateTime.now();
    return now.difference(_lastFetched!).inMinutes;
  }

  /// Check if data is stale (older than 15 minutes)
  bool get isDataStale {
    final age = dataAgeInMinutes;
    return age != null && age > 15;
  }

  /// Get formatted data age string
  String get dataAgeString {
    final age = dataAgeInMinutes;
    if (age == null) return 'Never updated';

    if (age < 1) {
      return 'Just now';
    } else if (age < 60) {
      return '$age minute${age == 1 ? '' : 's'} ago';
    } else {
      final hours = (age / 60).floor();
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    }
  }

  /// Get summary statistics for UI display
  DashboardSummary get summary {
    if (_dashboardData == null) {
      return const DashboardSummary(
        totalAccounts: 0,
        totalBudgets: 0,
        totalTransactions: 0,
        netWorth: 0,
        isEmpty: true,
      );
    }

    return DashboardSummary(
      totalAccounts: _dashboardData!.moneyAccounts.length,
      totalBudgets: _dashboardData!.budgets.length,
      totalTransactions: _dashboardData!.recentTransactions.length,
      netWorth: _dashboardData!.financialOverview.netWorth,
      isEmpty: _dashboardData!.isEmpty,
    );
  }

  // Private methods

  void _setLoadingState(DashboardLoadingState state) {
    _loadingState = state;
  }

  void _setError(DashboardServiceException error) {
    _error = error;
  }

  void _clearError() {
    _error = null;
  }

  /// Cache dashboard data to local storage
  Future<void> _cacheData(DashboardData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'data': data.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      await prefs.setString('dashboard_cache', json.encode(cacheData));
    } catch (e) {
      // Silently fail caching - not critical for app functionality
      debugPrint('Failed to cache dashboard data: $e');
    }
  }

  /// Load cached dashboard data
  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString('dashboard_cache');

      if (cachedString != null) {
        final cacheData = json.decode(cachedString) as Map<String, dynamic>;
        final timestamp = DateTime.parse(cacheData['timestamp'] as String);

        // Only use cache if less than 1 hour old
        final age = DateTime.now().difference(timestamp);
        if (age.inHours < 1) {
          _dashboardData =
              DashboardData.fromJson(cacheData['data'] as Map<String, dynamic>);
          _lastFetched = timestamp;
          _setLoadingState(DashboardLoadingState.cached);
        }
      }
    } catch (e) {
      // Silently fail cache loading
      debugPrint('Failed to load cached dashboard data: $e');
    }
  }

  /// Clear cached dashboard data
  Future<void> _clearCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('dashboard_cache');
    } catch (e) {
      debugPrint('Failed to clear cached dashboard data: $e');
    }
  }
}

/// Dashboard loading state enumeration
enum DashboardLoadingState {
  initial,
  loading,
  refreshing,
  success,
  cached,
  error,
}

/// Dashboard summary model for quick stats
class DashboardSummary {
  final int totalAccounts;
  final int totalBudgets;
  final int totalTransactions;
  final double netWorth;
  final bool isEmpty;

  const DashboardSummary({
    required this.totalAccounts,
    required this.totalBudgets,
    required this.totalTransactions,
    required this.netWorth,
    required this.isEmpty,
  });

  /// Get total items count
  int get totalItems => totalAccounts + totalBudgets + totalTransactions;

  /// Check if has any financial data
  bool get hasData => totalItems > 0;

  /// Get formatted net worth
  String get formattedNetWorth {
    if (netWorth.abs() >= 1000000) {
      final millions = netWorth / 1000000;
      return '\$${millions.toStringAsFixed(1)}M';
    } else if (netWorth.abs() >= 1000) {
      final thousands = netWorth / 1000;
      return '\$${thousands.toStringAsFixed(1)}K';
    } else {
      return '\$${netWorth.toStringAsFixed(0)}';
    }
  }

  /// Check if net worth is positive
  bool get hasPositiveNetWorth => netWorth > 0;
}
