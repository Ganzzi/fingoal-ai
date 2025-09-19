import 'dart:convert';
import 'package:http/http.dart' as http;

/// Exception types for chat service errors
enum ChatServiceExceptionType {
  network,
  authentication,
  serverError,
  timeout,
  parsing,
  unknown,
}

/// Custom exception for chat service errors
class ChatServiceException implements Exception {
  final String message;
  final ChatServiceExceptionType type;
  final int? statusCode;
  final String? details;

  const ChatServiceException({
    required this.message,
    required this.type,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => 'ChatServiceException: $message';
}

/// Chat service for communicating with Router Agent
///
/// Handles command processing, analysis requests, and general chat
/// functionality through the n8n Router Agent workflow.
class ChatService {
  static const String _baseUrl = 'http://localhost:5678';
  static const Duration _defaultTimeout = Duration(seconds: 30);

  final http.Client _client;

  ChatService({http.Client? client}) : _client = client ?? http.Client();

  /// Send a message/command to the Router Agent
  Future<Map<String, dynamic>> sendMessage({
    required String message,
    required String authToken,
    String language = 'en',
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/webhook/router');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': authToken,
      };

      final body = jsonEncode({
        'message': message,
        'language': language,
        'timestamp': DateTime.now().toIso8601String(),
      });

      final response = await _client
          .post(url, headers: headers, body: body)
          .timeout(_defaultTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Check if a message contains an analysis command
  bool isAnalysisCommand(String message) {
    final normalizedMessage = message.toLowerCase().trim();

    // Check for various analysis command patterns
    final analysisPatterns = [
      'analyze my finances',
      'analyze finances',
      'financial analysis',
      'analyze my money',
      'analyze my budget',
      'financial review',
      'check my finances',
      'review my finances',
      'phân tích tài chính', // Vietnamese
      'phân tích tiền', // Vietnamese
    ];

    return analysisPatterns
        .any((pattern) => normalizedMessage.contains(pattern));
  }

  /// Test connection to Router Agent
  Future<bool> testConnection() async {
    try {
      final url = Uri.parse('$_baseUrl/webhook/router');

      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': 'test',
              'language': 'en',
            }),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200 || response.statusCode == 400;
    } catch (e) {
      return false;
    }
  }

  /// Handle HTTP response and extract data
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw ChatServiceException(
          message: data['message'] ?? 'Request failed',
          type: _getExceptionTypeFromStatusCode(response.statusCode),
          statusCode: response.statusCode,
          details: data.toString(),
        );
      }
    } catch (e) {
      if (e is ChatServiceException) rethrow;

      throw ChatServiceException(
        message: 'Failed to parse response: ${response.body}',
        type: ChatServiceExceptionType.parsing,
        statusCode: response.statusCode,
      );
    }
  }

  /// Handle errors and convert to ChatServiceException
  ChatServiceException _handleError(dynamic error) {
    if (error is ChatServiceException) return error;

    if (error.toString().contains('TimeoutException')) {
      return const ChatServiceException(
        message: 'Request timed out. Please check your connection.',
        type: ChatServiceExceptionType.timeout,
      );
    }

    if (error.toString().contains('SocketException') ||
        error.toString().contains('HandshakeException')) {
      return const ChatServiceException(
        message: 'Network error. Please check your internet connection.',
        type: ChatServiceExceptionType.network,
      );
    }

    return ChatServiceException(
      message: 'Unexpected error: ${error.toString()}',
      type: ChatServiceExceptionType.unknown,
      details: error.toString(),
    );
  }

  /// Get exception type from HTTP status code
  ChatServiceExceptionType _getExceptionTypeFromStatusCode(int statusCode) {
    switch (statusCode) {
      case 401:
      case 403:
        return ChatServiceExceptionType.authentication;
      case 404:
      case 500:
      case 502:
      case 503:
      case 504:
        return ChatServiceExceptionType.serverError;
      default:
        return ChatServiceExceptionType.unknown;
    }
  }

  /// Dispose of resources
  void dispose() {
    _client.close();
  }
}
