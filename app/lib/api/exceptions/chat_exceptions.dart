import 'dart:convert';
import 'package:http/http.dart' as http;

/// Comprehensive exception classes for chat API errors

/// Base exception for all chat API related errors
abstract class ChatException implements Exception {
  final String message;
  final String code;
  final int? statusCode;
  final String? details;
  final DateTime timestamp;

  ChatException({
    required this.message,
    required this.code,
    this.statusCode,
    this.details,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => 'ChatException($code): $message';

  /// Get user-friendly error message
  String get userMessage => message;

  /// Check if error is retryable
  bool get isRetryable => false;

  /// Get retry delay if retryable
  Duration? get retryDelay => null;
}

/// Network-related errors (connection, timeout, etc.)
class NetworkException extends ChatException {
  NetworkException({
    required super.message,
    super.details,
    super.timestamp,
  }) : super(code: 'NETWORK_ERROR');

  @override
  bool get isRetryable => true;

  @override
  Duration get retryDelay => const Duration(seconds: 2);

  @override
  String get userMessage =>
      'Network error. Please check your connection and try again.';
}

/// Authentication and authorization errors
class AuthenticationException extends ChatException {
  final bool tokenExpired;
  final bool refreshable;

  AuthenticationException({
    required super.message,
    super.statusCode,
    super.details,
    super.timestamp,
    this.tokenExpired = false,
    this.refreshable = false,
  }) : super(code: 'AUTH_ERROR');

  @override
  bool get isRetryable => refreshable;

  @override
  String get userMessage => tokenExpired
      ? 'Your session has expired. Please log in again.'
      : 'Authentication failed. Please log in and try again.';
}

/// Input validation errors
class ValidationException extends ChatException {
  final List<String> validationErrors;

  ValidationException({
    required super.message,
    super.statusCode,
    super.details,
    super.timestamp,
    this.validationErrors = const [],
  }) : super(code: 'VALIDATION_ERROR');

  @override
  String get userMessage =>
      validationErrors.isNotEmpty ? validationErrors.join(', ') : message;
}

/// AI processing errors
class ProcessingException extends ChatException {
  final String? agentName;
  final bool temporaryFailure;

  ProcessingException({
    required super.message,
    super.statusCode,
    super.details,
    super.timestamp,
    this.agentName,
    this.temporaryFailure = true,
  }) : super(code: 'PROCESSING_ERROR');

  @override
  bool get isRetryable => temporaryFailure;

  @override
  Duration get retryDelay => const Duration(seconds: 5);

  @override
  String get userMessage => temporaryFailure
      ? 'AI agent is temporarily busy. Please try again in a moment.'
      : 'Unable to process your request. Please try rephrasing your message.';
}

/// Request timeout errors
class TimeoutException extends ChatException {
  final Duration timeout;

  TimeoutException({
    required super.message,
    super.details,
    super.timestamp,
    required this.timeout,
  }) : super(code: 'TIMEOUT_ERROR');

  @override
  bool get isRetryable => true;

  @override
  Duration get retryDelay => Duration(seconds: timeout.inSeconds ~/ 2);

  @override
  String get userMessage =>
      'Request timed out. The AI agent may be processing a complex request. Please try again.';
}

/// Server errors (5xx status codes)
class ServerException extends ChatException {
  final bool maintenanceMode;

  ServerException({
    required super.message,
    super.statusCode,
    super.details,
    super.timestamp,
    this.maintenanceMode = false,
  }) : super(code: 'SERVER_ERROR');

  @override
  bool get isRetryable => !maintenanceMode;

  @override
  Duration get retryDelay => const Duration(seconds: 10);

  @override
  String get userMessage => maintenanceMode
      ? 'Service is temporarily under maintenance. Please try again later.'
      : 'Server error occurred. Our team has been notified. Please try again.';
}

/// Rate limiting errors
class RateLimitException extends ChatException {
  final Duration retryAfter;
  final int? remainingRequests;

  RateLimitException({
    required super.message,
    super.statusCode,
    super.details,
    super.timestamp,
    required this.retryAfter,
    this.remainingRequests,
  }) : super(code: 'RATE_LIMIT_ERROR');

  @override
  bool get isRetryable => true;

  @override
  Duration get retryDelay => retryAfter;

  @override
  String get userMessage =>
      'Too many requests. Please wait ${retryAfter.inSeconds} seconds before trying again.';
}

/// Generic unknown errors
class UnknownException extends ChatException {
  UnknownException({
    required super.message,
    super.statusCode,
    super.details,
    super.timestamp,
  }) : super(code: 'UNKNOWN_ERROR');

  @override
  String get userMessage => 'An unexpected error occurred. Please try again.';
}

/// Factory for creating appropriate exceptions
class ChatExceptionFactory {
  /// Create exception from HTTP response
  static ChatException fromHttpResponse(http.Response response, String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      return fromErrorData(
        statusCode: response.statusCode,
        errorData: data,
      );
    } catch (e) {
      return UnknownException(
        message: 'Failed to parse error response',
        statusCode: response.statusCode,
        details: body,
      );
    }
  }

  /// Create exception from error data
  static ChatException fromErrorData({
    required int statusCode,
    required Map<String, dynamic> errorData,
  }) {
    final message = _extractMessage(errorData);
    final details = errorData.toString();

    switch (statusCode) {
      case 400:
        return ValidationException(
          message: message,
          statusCode: statusCode,
          details: details,
          validationErrors: _extractValidationErrors(errorData),
        );

      case 401:
        return AuthenticationException(
          message: message,
          statusCode: statusCode,
          details: details,
          tokenExpired: message.toLowerCase().contains('expired'),
          refreshable: message.toLowerCase().contains('expired'),
        );

      case 403:
        return AuthenticationException(
          message: message,
          statusCode: statusCode,
          details: details,
        );

      case 429:
        return RateLimitException(
          message: message,
          statusCode: statusCode,
          details: details,
          retryAfter: _extractRetryAfter(errorData),
        );

      case >= 500:
        return ServerException(
          message: message,
          statusCode: statusCode,
          details: details,
          maintenanceMode: message.toLowerCase().contains('maintenance'),
        );

      default:
        return UnknownException(
          message: message,
          statusCode: statusCode,
          details: details,
        );
    }
  }

  /// Create exception from Dart error
  static ChatException fromError(dynamic error) {
    final errorString = error.toString();

    if (errorString.contains('TimeoutException')) {
      return TimeoutException(
        message: 'Request timed out',
        details: errorString,
        timeout: const Duration(seconds: 30),
      );
    }

    if (errorString.contains('SocketException') ||
        errorString.contains('HandshakeException') ||
        errorString.contains('Connection refused')) {
      return NetworkException(
        message: 'Network connection failed',
        details: errorString,
      );
    }

    if (errorString.contains('FormatException') ||
        errorString.contains('Invalid JSON')) {
      return ProcessingException(
        message: 'Invalid response format',
        details: errorString,
        temporaryFailure: false,
      );
    }

    return UnknownException(
      message: 'Unexpected error occurred',
      details: errorString,
    );
  }

  /// Extract error message from error data
  static String _extractMessage(Map<String, dynamic> errorData) {
    // Try different common error message fields
    if (errorData['error'] is String) {
      return errorData['error'] as String;
    }

    if (errorData['error'] is Map<String, dynamic>) {
      final errorObj = errorData['error'] as Map<String, dynamic>;
      if (errorObj['message'] is String) {
        return errorObj['message'] as String;
      }
    }

    if (errorData['message'] is String) {
      return errorData['message'] as String;
    }

    return 'Unknown error occurred';
  }

  /// Extract validation errors from error data
  static List<String> _extractValidationErrors(Map<String, dynamic> errorData) {
    final errors = <String>[];

    if (errorData['errors'] is List) {
      final errorList = errorData['errors'] as List;
      errors.addAll(errorList.map((e) => e.toString()));
    }

    if (errorData['validation_errors'] is List) {
      final errorList = errorData['validation_errors'] as List;
      errors.addAll(errorList.map((e) => e.toString()));
    }

    return errors;
  }

  /// Extract retry after duration from error data
  static Duration _extractRetryAfter(Map<String, dynamic> errorData) {
    if (errorData['retry_after'] is int) {
      return Duration(seconds: errorData['retry_after'] as int);
    }

    if (errorData['retry_after'] is String) {
      final seconds = int.tryParse(errorData['retry_after'] as String);
      if (seconds != null) {
        return Duration(seconds: seconds);
      }
    }

    return const Duration(seconds: 60); // Default retry after 1 minute
  }
}
