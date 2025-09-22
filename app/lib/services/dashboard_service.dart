import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/dashboard_models.dart';

/// Service for managing dashboard data via n8n Dashboard Agent API
///
/// This service handles all API communication for dashboard data,
/// including fetching comprehensive financial information and
/// handling authentication and error scenarios.
class DashboardService {
  static const String _baseUrl = 'http://localhost:5678/webhook';
  static const Duration _timeout = Duration(seconds: 30);

  /// Fetch complete dashboard data for the authenticated user
  ///
  /// Returns a [DashboardData] containing all financial information
  /// including money accounts, budgets, recent transactions, and
  /// financial overview calculations. Handles empty state scenarios
  /// for new users with no financial data.
  Future<DashboardData> getDashboardData({
    required String authToken,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/dashboard');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ).timeout(_timeout);

      final responseData = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        // Check if response has success field
        if (responseData['success'] == true) {
          return DashboardData.fromJson(responseData);
        } else {
          throw DashboardServiceException(
            message: responseData['error']?['message'] as String? ??
                'API returned unsuccessful response',
            statusCode: response.statusCode,
            type: DashboardServiceExceptionType.apiError,
          );
        }
      } else {
        // Handle error response
        final errorMessage = responseData['error']?['message'] as String? ??
            responseData['message'] as String? ??
            'Failed to fetch dashboard data';

        throw DashboardServiceException(
          message: errorMessage,
          statusCode: response.statusCode,
          type: response.statusCode == 401
              ? DashboardServiceExceptionType.authenticationError
              : DashboardServiceExceptionType.apiError,
        );
      }
    } on FormatException {
      throw const DashboardServiceException(
        message: 'Invalid response format from server',
        type: DashboardServiceExceptionType.parseError,
      );
    } on SocketException {
      throw const DashboardServiceException(
        message: 'No internet connection available',
        type: DashboardServiceExceptionType.networkError,
      );
    } on http.ClientException {
      throw const DashboardServiceException(
        message: 'Network request failed',
        type: DashboardServiceExceptionType.networkError,
      );
    } catch (e) {
      if (e is DashboardServiceException) rethrow;
      throw DashboardServiceException(
        message: e.toString(),
        type: DashboardServiceExceptionType.unknown,
      );
    }
  }

  /// Refresh dashboard data (alias for getDashboardData)
  ///
  /// This method provides a semantic alias for refreshing dashboard data,
  /// useful for pull-to-refresh scenarios and manual reload operations.
  Future<DashboardData> refreshDashboardData({
    required String authToken,
  }) async {
    return getDashboardData(authToken: authToken);
  }

  /// Test API connectivity
  ///
  /// Performs a lightweight test to check if the Dashboard API
  /// endpoint is reachable and responding. Useful for diagnostics
  /// and network connectivity validation.
  Future<bool> testConnectivity() async {
    try {
      final uri = Uri.parse('$_baseUrl/dashboard');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer test-token',
        },
      ).timeout(const Duration(seconds: 5));

      // We expect either 200 (success) or 401 (auth error)
      // Both indicate the service is reachable
      return response.statusCode == 200 || response.statusCode == 401;
    } catch (e) {
      return false;
    }
  }
}

/// Exception types for dashboard service operations
enum DashboardServiceExceptionType {
  networkError,
  apiError,
  parseError,
  authenticationError,
  unknown,
}

/// Custom exception for dashboard service operations
class DashboardServiceException implements Exception {
  final String message;
  final int? statusCode;
  final DashboardServiceExceptionType type;

  const DashboardServiceException({
    required this.message,
    this.statusCode,
    required this.type,
  });

  @override
  String toString() {
    return 'DashboardServiceException(type: $type, message: $message, statusCode: $statusCode)';
  }

  /// Check if this is a network-related error
  bool get isNetworkError => type == DashboardServiceExceptionType.networkError;

  /// Check if this is a server/API error
  bool get isApiError => type == DashboardServiceExceptionType.apiError;

  /// Check if this is an authentication error
  bool get isAuthenticationError =>
      type == DashboardServiceExceptionType.authenticationError ||
      (statusCode != null && statusCode == 401);

  /// Check if this is a parse/format error
  bool get isParseError => type == DashboardServiceExceptionType.parseError;

  /// Get user-friendly error message
  String get userFriendlyMessage {
    switch (type) {
      case DashboardServiceExceptionType.networkError:
        return 'Please check your internet connection and try again.';
      case DashboardServiceExceptionType.apiError:
        if (statusCode == 401) {
          return 'Please log in again to continue.';
        } else if (statusCode == 403) {
          return 'You do not have permission to access this data.';
        } else if (statusCode == 404) {
          return 'Dashboard service is not available.';
        } else if (statusCode == 500) {
          return 'Server error occurred. Please try again later.';
        }
        return 'Unable to load dashboard data. Please try again.';
      case DashboardServiceExceptionType.authenticationError:
        return 'Authentication failed. Please log in again.';
      case DashboardServiceExceptionType.parseError:
        return 'Invalid server response. Please try again.';
      case DashboardServiceExceptionType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Get error category for analytics/debugging
  String get errorCategory {
    switch (type) {
      case DashboardServiceExceptionType.networkError:
        return 'network';
      case DashboardServiceExceptionType.apiError:
        return 'api';
      case DashboardServiceExceptionType.authenticationError:
        return 'auth';
      case DashboardServiceExceptionType.parseError:
        return 'parse';
      case DashboardServiceExceptionType.unknown:
        return 'unknown';
    }
  }

  /// Check if error is retryable (user should try again)
  bool get isRetryable {
    switch (type) {
      case DashboardServiceExceptionType.networkError:
      case DashboardServiceExceptionType.apiError:
        return statusCode != 401 && statusCode != 403;
      case DashboardServiceExceptionType.authenticationError:
        return false; // User needs to re-authenticate
      case DashboardServiceExceptionType.parseError:
        return true; // Might be temporary server issue
      case DashboardServiceExceptionType.unknown:
        return true; // Worth retrying unknown errors
    }
  }
}

/// Dashboard service response wrapper for additional metadata
class DashboardResponse {
  final DashboardData data;
  final DateTime fetchedAt;
  final Duration fetchDuration;
  final bool fromCache;

  const DashboardResponse({
    required this.data,
    required this.fetchedAt,
    required this.fetchDuration,
    this.fromCache = false,
  });

  /// Check if data is fresh (less than 5 minutes old)
  bool get isFresh {
    final now = DateTime.now();
    final age = now.difference(fetchedAt);
    return age.inMinutes < 5;
  }

  /// Check if data is stale (more than 15 minutes old)
  bool get isStale {
    final now = DateTime.now();
    final age = now.difference(fetchedAt);
    return age.inMinutes > 15;
  }

  /// Get age of data in human-readable format
  String get ageDescription {
    final now = DateTime.now();
    final age = now.difference(fetchedAt);

    if (age.inMinutes < 1) {
      return 'Just now';
    } else if (age.inMinutes < 60) {
      return '${age.inMinutes} minute${age.inMinutes == 1 ? '' : 's'} ago';
    } else if (age.inHours < 24) {
      return '${age.inHours} hour${age.inHours == 1 ? '' : 's'} ago';
    } else {
      return '${age.inDays} day${age.inDays == 1 ? '' : 's'} ago';
    }
  }
}
