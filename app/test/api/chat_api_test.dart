import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:fingoal/api/chat_api_service.dart';
import 'package:fingoal/api/exceptions/chat_exceptions.dart';
import 'package:fingoal/models/message.dart';

void main() {
  group('Enhanced Chat API Tests', () {
    late ChatApiService chatApiService;

    setUp(() {
      chatApiService = ChatApiService();
    });

    tearDown(() {
      chatApiService.dispose();
    });

    test('ChatApiService can be instantiated', () {
      expect(chatApiService, isNotNull);
    });

    test('ChatRequest model serialization works correctly', () {
      final request = ChatRequest(
        message: 'Test message',
        messageType: MessageType.text,
        language: 'en',
        conversationContext: {
          'session_id': 'session-123',
          'topic': 'budgeting',
        },
      );

      final json = request.toJson();

      expect(json['message'], equals('Test message'));
      expect(json['message_type'], equals('text'));
      expect(json['language'], equals('en'));
      expect(json['conversation_context'], isNotNull);
      expect(json['conversation_context']['session_id'], equals('session-123'));
    });

    test('ChatResponse model parsing works correctly', () {
      final jsonData = {
        'success': true,
        'content': {
          'message': 'Hello from AI agent',
          'suggested_actions': ['Action 1', 'Action 2'],
          'visualizations': [
            {'type': 'chart', 'data': 'chart_data'}
          ],
        },
        'compliance_validated': true,
        'timestamp': '2025-09-21T10:30:00.000Z',
      };

      final response = ChatResponse.fromJson(jsonData);

      expect(response.success, isTrue);
      expect(response.responseMessage, equals('Hello from AI agent'));
      expect(response.suggestedActions, hasLength(2));
      expect(response.suggestedActions.first, equals('Action 1'));
      expect(response.visualizations, hasLength(1));
      expect(response.complianceValidated, isTrue);
    });

    test('MessageRetry model works correctly', () {
      final error = NetworkException(message: 'Connection failed');

      final retry = MessageRetry(
        messageId: 'msg-123',
        message: 'Test message',
        messageType: MessageType.text,
        language: 'en',
        attemptCount: 1,
        lastAttempt: DateTime.now(),
        lastError: error,
      );

      expect(retry.shouldRetry, isTrue);
      expect(retry.nextRetryDelay.inSeconds, greaterThan(0));

      final nextRetry = retry.nextAttempt(error);
      expect(nextRetry.attemptCount, equals(2));
      expect(nextRetry.nextRetryDelay.inSeconds,
          greaterThan(retry.nextRetryDelay.inSeconds));
    });

    test('Exception system works correctly', () {
      // Test NetworkException
      final networkError = NetworkException(message: 'Network failed');
      expect(networkError.isRetryable, isTrue);
      expect(networkError.userMessage, contains('Network error'));

      // Test AuthenticationException
      final authError = AuthenticationException(
        message: 'Token expired',
        tokenExpired: true,
        refreshable: true,
      );
      expect(authError.isRetryable, isTrue);
      expect(authError.userMessage, contains('session has expired'));

      // Test ValidationException
      final validationError = ValidationException(
        message: 'Invalid input',
        validationErrors: ['Field required', 'Invalid format'],
      );
      expect(validationError.isRetryable, isFalse);
      expect(validationError.userMessage, contains('Field required'));
    });

    test('Retry queue management works correctly', () {
      expect(chatApiService.pendingRetries, isEmpty);

      // The retry queue is managed internally and tested through integration
      chatApiService.clearRetryQueue();
      expect(chatApiService.pendingRetries, isEmpty);
    });

    test('Message model serialization works correctly', () {
      final message = Message.user(
        id: 'test-id',
        content: 'Test message',
        messageType: MessageType.text,
      );

      final json = message.toJson();
      final reconstructed = Message.fromJson(json);

      expect(reconstructed.id, equals(message.id));
      expect(reconstructed.content, equals(message.content));
      expect(reconstructed.sender, equals(message.sender));
      expect(reconstructed.messageType, equals(message.messageType));
    });

    test('Message status updates work correctly', () {
      final message = Message.user(
        id: 'test-id',
        content: 'Test message',
        status: MessageStatus.sending,
      );

      expect(message.isSending, isTrue);
      expect(message.isFailed, isFalse);

      final updatedMessage = message.copyWith(status: MessageStatus.delivered);
      expect(updatedMessage.isSending, isFalse);
      expect(updatedMessage.status, equals(MessageStatus.delivered));
    });

    test('Agent message creation works correctly', () {
      final message = Message.agent(
        id: 'agent-id',
        content: 'Agent response',
        agentType: 'AI Financial Advisor',
      );

      expect(message.isFromAgent, isTrue);
      expect(message.isFromUser, isFalse);
      expect(message.agentType, equals('AI Financial Advisor'));
      expect(message.status, equals(MessageStatus.delivered));

      // Test JSON serialization maps to sender_type for database
      final json = message.toJson();
      expect(json['sender_type'], equals('agent'));
      expect(json.containsKey('agent_type'),
          isFalse); // Old field should not exist
    });

    test('Message timestamps are properly formatted', () {
      final now = DateTime.now();
      final message = Message.user(
        id: 'test-id',
        content: 'Test message',
      );

      // Should be created with current time (within 1 second)
      final difference = now.difference(message.timestamp).inSeconds;
      expect(difference.abs(), lessThan(2));

      // Formatted time should not be empty
      expect(message.formattedTime, isNotEmpty);
      expect(message.formattedDate, isNotEmpty);
      expect(message.formattedDateTime, isNotEmpty);
    });
  });
}
