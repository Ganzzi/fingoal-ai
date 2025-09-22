import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/chat_response.dart' as models;
import '../api/auth_service.dart';
import 'exceptions/chat_exceptions.dart';

/// Message retry information for failed sends
class MessageRetry {
  final String messageId;
  final String message;
  final MessageType messageType;
  final String language;
  final Map<String, dynamic>? conversationContext;
  final Map<String, dynamic>? media;
  final int attemptCount;
  final DateTime lastAttempt;
  final ChatException lastError;

  const MessageRetry({
    required this.messageId,
    required this.message,
    required this.messageType,
    required this.language,
    this.conversationContext,
    this.media,
    required this.attemptCount,
    required this.lastAttempt,
    required this.lastError,
  });

  /// Get next retry delay based on exponential backoff
  Duration get nextRetryDelay {
    const baseDelay = Duration(seconds: 2);
    final exponentialDelay = Duration(
      seconds:
          (baseDelay.inSeconds * (attemptCount * attemptCount)).clamp(2, 60),
    );
    return exponentialDelay;
  }

  /// Check if retry should be attempted
  bool get shouldRetry {
    return attemptCount < 3 && lastError.isRetryable;
  }

  /// Create next retry attempt
  MessageRetry nextAttempt(ChatException error) {
    return MessageRetry(
      messageId: messageId,
      message: message,
      messageType: messageType,
      language: language,
      conversationContext: conversationContext,
      media: media,
      attemptCount: attemptCount + 1,
      lastAttempt: DateTime.now(),
      lastError: error,
    );
  }
}

/// Chat API request model with enhanced Router Agent support
class ChatRequest {
  final String message;
  final MessageType messageType;
  final String language;
  final Map<String, dynamic>? conversationContext;
  final Map<String, dynamic>? media;

  const ChatRequest({
    required this.message,
    this.messageType = MessageType.text,
    this.language = 'en',
    this.conversationContext,
    this.media,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'message_type': messageType.name,
      'language': language,
      if (conversationContext != null)
        'conversation_context': conversationContext,
      if (media != null) 'media': media,
    };
  }
}

/// Chat API response model
class ChatResponse {
  final bool success;
  final Map<String, dynamic>? content;
  final bool? complianceValidated;
  final DateTime timestamp;
  final String? error;

  const ChatResponse({
    required this.success,
    this.content,
    this.complianceValidated,
    required this.timestamp,
    this.error,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      success: json['success'] as bool,
      content: json['content'] as Map<String, dynamic>?,
      complianceValidated: json['compliance_validated'] as bool?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      error: json['error'] as String?,
    );
  }

  /// Get the main response message
  String get responseMessage {
    if (!success && error != null) return error!;
    if (content?['message'] != null) return content!['message'] as String;
    return '';
  }

  /// Get suggested actions
  List<String> get suggestedActions {
    final actions = content?['suggested_actions'] as List<dynamic>?;
    return actions?.map((e) => e as String).toList() ?? [];
  }

  /// Get next steps
  List<String> get nextSteps {
    final steps = content?['next_steps'] as List<dynamic>?;
    return steps?.map((e) => e as String).toList() ?? [];
  }

  /// Get educational tips
  List<String> get educationalTips {
    final tips = content?['educational_tips'] as List<dynamic>?;
    return tips?.map((e) => e as String).toList() ?? [];
  }

  /// Get disclaimers
  List<String> get disclaimers {
    final disclaimers = content?['disclaimers'] as List<dynamic>?;
    return disclaimers?.map((e) => e as String).toList() ?? [];
  }

  /// Get visualizations
  List<Map<String, dynamic>> get visualizations {
    final viz = content?['visualizations'] as List<dynamic>?;
    return viz?.map((e) => e as Map<String, dynamic>).toList() ?? [];
  }
}

/// Enhanced Chat API service for communicating with the Router Agent
class ChatApiService {
  static const String _baseUrl = 'http://localhost:5678';
  static const String _chatEndpoint = '/webhook/chat';
  static const Duration _defaultTimeout = Duration(seconds: 30);

  final AuthService _authService;
  final http.Client _client;
  final Map<String, MessageRetry> _retryQueue = {};

  ChatApiService({
    AuthService? authService,
    http.Client? client,
  })  : _authService = authService ?? AuthService(),
        _client = client ?? http.Client();

  /// Send a chat message to the Router Agent with retry support
  Future<ChatResponse> sendMessage({
    required String message,
    MessageType messageType = MessageType.text,
    String language = 'en',
    Map<String, dynamic>? conversationContext,
    Map<String, dynamic>? media,
    bool enableRetry = true,
  }) async {
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      return await _attemptSendMessage(
        messageId: messageId,
        message: message,
        messageType: messageType,
        language: language,
        conversationContext: conversationContext,
        media: media,
      );
    } catch (e) {
      final exception =
          e is ChatException ? e : ChatExceptionFactory.fromError(e);

      if (enableRetry && exception.isRetryable) {
        final retry = MessageRetry(
          messageId: messageId,
          message: message,
          messageType: messageType,
          language: language,
          conversationContext: conversationContext,
          media: media,
          attemptCount: 1,
          lastAttempt: DateTime.now(),
          lastError: exception,
        );

        _retryQueue[messageId] = retry;

        // Schedule retry after delay
        Future.delayed(retry.nextRetryDelay, () => _retryMessage(messageId));
      }

      rethrow;
    }
  }

  /// Attempt to send a message (internal method)
  Future<ChatResponse> _attemptSendMessage({
    required String messageId,
    required String message,
    required MessageType messageType,
    required String language,
    Map<String, dynamic>? conversationContext,
    Map<String, dynamic>? media,
  }) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw AuthenticationException(
        message: 'Authentication required',
      );
    }

    final user = await _authService.getUser();
    if (user == null || user['id'] == null) {
      throw AuthenticationException(
        message: 'User information not available',
      );
    }

    final request = ChatRequest(
      message: message,
      messageType: messageType,
      language: language,
      conversationContext: conversationContext,
      media: media,
    );

    final response = await _makeRequest(
      method: 'POST',
      endpoint: _chatEndpoint,
      body: request.toJson(),
      token: token,
    );

    return _handleResponse(response);
  }

  /// Retry a failed message
  Future<void> _retryMessage(String messageId) async {
    final retry = _retryQueue[messageId];
    if (retry == null || !retry.shouldRetry) {
      _retryQueue.remove(messageId);
      return;
    }

    try {
      await _attemptSendMessage(
        messageId: messageId,
        message: retry.message,
        messageType: retry.messageType,
        language: retry.language,
        conversationContext: retry.conversationContext,
        media: retry.media,
      );

      // Success - remove from retry queue
      _retryQueue.remove(messageId);
    } catch (e) {
      final exception =
          e is ChatException ? e : ChatExceptionFactory.fromError(e);
      final nextRetry = retry.nextAttempt(exception);

      if (nextRetry.shouldRetry) {
        _retryQueue[messageId] = nextRetry;
        Future.delayed(
            nextRetry.nextRetryDelay, () => _retryMessage(messageId));
      } else {
        // Max retries exceeded
        _retryQueue.remove(messageId);
      }
    }
  }

  /// Get current retry queue status
  List<MessageRetry> get pendingRetries => _retryQueue.values.toList();

  /// Clear retry queue
  void clearRetryQueue() => _retryQueue.clear();

  /// Send a quick notification message (for login/register notifications)
  Future<ChatResponse> sendNotification({
    required String message,
    String language = 'en',
  }) async {
    return sendMessage(
      message: message,
      language: language,
      conversationContext: {
        'notification': true,
        'timestamp': DateTime.now().toIso8601String(),
      },
      enableRetry: false, // Don't retry notifications
    );
  }

  /// Test connection to chat API
  Future<bool> testConnection() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final user = await _authService.getUser();
      if (user == null || user['id'] == null) return false;

      final response = await _makeRequest(
        method: 'POST',
        endpoint: _chatEndpoint,
        body: {
          'user_id': user['id'],
          'message': 'test connection',
          'message_type': 'text',
          'language': 'en',
        },
        token: token,
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200 || response.statusCode == 400;
    } catch (e) {
      return false;
    }
  }

  /// Make HTTP request with authentication
  Future<http.Response> _makeRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    required String token,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    switch (method.toUpperCase()) {
      case 'GET':
        return await _client
            .get(uri, headers: headers)
            .timeout(_defaultTimeout);
      case 'POST':
        return await _client
            .post(
              uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(_defaultTimeout);
      default:
        throw UnknownException(
          message: 'Unsupported HTTP method: $method',
        );
    }
  }

  /// Handle HTTP response with enhanced Router Agent support
  ChatResponse _handleResponse(http.Response response) {
    try {
      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Always use the standard ChatResponse format since our API returns this format
        final chatResponse = ChatResponse.fromJson(data);
        print('Parsed ChatResponse successfully: ${chatResponse.success}');
        return chatResponse;
      } else {
        throw ChatExceptionFactory.fromHttpResponse(response, response.body);
      }
    } catch (e) {
      print('Error parsing response: $e');
      print('Response body was: ${response.body}');

      if (e is ChatException) rethrow;

      throw ProcessingException(
        message: 'Failed to parse response: ${response.body}',
        details: e.toString(),
        temporaryFailure: false,
      );
    }
  }

  /// Create enhanced ChatResponse from AgentResponse
  ChatResponse _createEnhancedChatResponse(models.AgentResponse agentResponse) {
    final textResponse =
        models.ResponseFactory.createTextResponse(agentResponse);

    // Enhance content with parsed response data
    final enhancedContent = <String, dynamic>{
      ...agentResponse.content,
      if (textResponse != null) ...{
        'message': textResponse.message,
        'visualizations': textResponse.visualizations,
        'suggested_actions': textResponse.suggestedActions,
        'next_steps': textResponse.nextSteps,
        'educational_tips': textResponse.educationalTips,
        'disclaimers': textResponse.disclaimers,
      },
      'agent_info': {
        'agent': agentResponse.agent,
        'response_type': agentResponse.responseType,
        'detected_intent': agentResponse.detectedIntent,
        'session_info': agentResponse.sessionIdentification,
        'memory_updated': agentResponse.memoryUpdated,
      }
    };

    return ChatResponse(
      success: agentResponse.success,
      content: enhancedContent,
      complianceValidated:
          true, // Router Agent responses are compliance validated
      timestamp: agentResponse.timestamp ?? DateTime.now(),
      error: agentResponse.error,
    );
  }

  /// Dispose of resources
  void dispose() {
    _client.close();
    _retryQueue.clear();
  }
}
