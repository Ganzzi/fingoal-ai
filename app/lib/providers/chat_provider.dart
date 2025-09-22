import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/message.dart';
import '../api/chat_api_service.dart';
import '../api/exceptions/chat_exceptions.dart';
import 'language_provider.dart';

/// Chat loading states
enum ChatLoadingState {
  idle,
  sendingMessage,
  loadingHistory,
  error,
}

/// Chat provider for managing chat messages and interactions
///
/// Handles message sending, local persistence, and chat state management
/// using the Provider pattern for state management.
class ChatProvider with ChangeNotifier {
  final ChatApiService _chatApiService;
  final LanguageProvider _languageProvider;

  // State management
  final List<Message> _messages = [];
  ChatLoadingState _loadingState = ChatLoadingState.idle;
  ChatException? _error;
  bool _hasInitialized = false;
  String? _currentSessionId;

  // Local storage keys
  static const String _messagesKey = 'chat_messages';
  static const String _sessionKey = 'chat_session_id';

  /// Constructor
  ChatProvider({
    ChatApiService? chatApiService,
    required LanguageProvider languageProvider,
  })  : _chatApiService = chatApiService ?? ChatApiService(),
        _languageProvider = languageProvider;

  // Getters
  List<Message> get messages => List.unmodifiable(_messages);
  ChatLoadingState get loadingState => _loadingState;
  ChatException? get error => _error;
  bool get hasInitialized => _hasInitialized;
  bool get isLoading =>
      _loadingState == ChatLoadingState.sendingMessage ||
      _loadingState == ChatLoadingState.loadingHistory;
  bool get hasError => _error != null;
  bool get isEmpty => _messages.isEmpty;
  String? get currentSessionId => _currentSessionId;

  /// Initialize the chat with welcome message and load history
  Future<void> initialize() async {
    if (_hasInitialized) return;

    try {
      _setLoadingState(ChatLoadingState.loadingHistory);

      // Load persisted messages
      await _loadPersistedMessages();

      // If no messages, add welcome message
      if (_messages.isEmpty) {
        _addWelcomeMessage();
      }

      // Generate session ID if not exists
      _currentSessionId ??= _generateSessionId();

      _hasInitialized = true;
      _setLoadingState(ChatLoadingState.idle);
    } catch (e) {
      _addWelcomeMessage();
      _hasInitialized = true;
      _setLoadingState(ChatLoadingState.idle);
    }
  }

  /// Send a message to the chat
  Future<void> sendMessage(String messageText) async {
    if (messageText.trim().isEmpty) return;

    final messageId = _generateMessageId();

    // Add user message to chat
    final userMessage = Message.user(
      id: messageId,
      content: messageText.trim(),
      status: MessageStatus.sending,
      language: _languageProvider.currentLanguageCode,
    );
    _addMessage(userMessage);

    // Save to local storage
    await _persistMessages();

    try {
      _setLoadingState(ChatLoadingState.sendingMessage);
      _clearError();

      // Update message status to sent
      _updateMessageStatus(messageId, MessageStatus.sent);

      // Send to API
      final response = await _chatApiService.sendMessage(
        message: messageText.trim(),
        messageType: MessageType.text,
        language: _languageProvider.currentLanguageCode,
        conversationContext: {
          'session_id': _currentSessionId,
        },
      );

      // Create agent response message
      final agentMessage = Message.agent(
        id: _generateMessageId(),
        content: response.responseMessage,
        agentType: 'AI Financial Advisor',
        language: _languageProvider.currentLanguageCode,
        metadata: {
          'suggested_actions': response.suggestedActions,
          'next_steps': response.nextSteps,
          'educational_tips': response.educationalTips,
          'disclaimers': response.disclaimers,
          'visualizations': response.visualizations,
          'compliance_validated': response.complianceValidated,
        },
      );

      _addMessage(agentMessage);

      // Update message status to delivered
      _updateMessageStatus(messageId, MessageStatus.delivered);

      // Save to local storage
      await _persistMessages();

      _setLoadingState(ChatLoadingState.idle);
    } catch (e) {
      // Update message status to failed
      _updateMessageStatus(messageId, MessageStatus.failed);

      // Handle error
      ChatException chatError;
      if (e is ChatException) {
        chatError = e;
      } else {
        chatError = UnknownException(message: e.toString());
      }

      _setError(chatError);
      _setLoadingState(ChatLoadingState.error);

      // Add error message to chat
      final errorMessage = Message.agent(
        id: _generateMessageId(),
        content: _getErrorMessage(chatError),
        agentType: 'System',
        language: _languageProvider.currentLanguageCode,
        metadata: {'error': true},
      );
      _addMessage(errorMessage);

      await _persistMessages();
    }
  }

  /// Send notification message for login/register events
  Future<void> sendNotificationMessage(String message) async {
    try {
      final response = await _chatApiService.sendNotification(
        message: message,
        language: _languageProvider.currentLanguageCode,
      );

      if (response.success && response.responseMessage.isNotEmpty) {
        final notificationMessage = Message.agent(
          id: _generateMessageId(),
          content: response.responseMessage,
          agentType: 'System',
          language: _languageProvider.currentLanguageCode,
          metadata: {'notification': true},
        );

        _addMessage(notificationMessage);
        await _persistMessages();
      }
    } catch (e) {
      // Silently fail notification messages - they're not critical
      debugPrint('Failed to send notification message: $e');
    }
  }

  /// Refresh chat history from server
  Future<void> refreshHistory() async {
    try {
      _setLoadingState(ChatLoadingState.loadingHistory);
      _clearError();

      // TODO: Implement API call to fetch recent messages from server
      // For now, just reload from local storage
      await _loadPersistedMessages();

      _setLoadingState(ChatLoadingState.idle);
    } catch (e) {
      ChatException chatError;
      if (e is ChatException) {
        chatError = e;
      } else {
        chatError = UnknownException(message: e.toString());
      }
      _setError(chatError);
      _setLoadingState(ChatLoadingState.error);
    }
  }

  /// Clear all messages
  Future<void> clearMessages() async {
    _messages.clear();
    _currentSessionId = _generateSessionId();
    _addWelcomeMessage();
    await _persistMessages();
    notifyListeners();
  }

  /// Retry sending a failed message
  Future<void> retryMessage(String messageId) async {
    final messageIndex = _messages.indexWhere((m) => m.id == messageId);
    if (messageIndex == -1) return;

    final message = _messages[messageIndex];
    if (!message.isFailed || !message.isFromUser) return;

    // Retry sending the message
    await sendMessage(message.content);
  }

  /// Add welcome message when chat initializes
  void _addWelcomeMessage() {
    final welcomeMessage = Message.agent(
      id: _generateMessageId(),
      content:
          '''Hello! I'm your AI financial assistant. I can help you understand your financial situation and provide personalized advice.

Here are some things you can ask me:
• "Help me create a budget"
• "Analyze my spending patterns"
• "What are some ways to save money?"
• "How can I improve my financial health?"

How can I assist you with your finances today?''',
      agentType: 'Welcome Agent',
      language: _languageProvider.currentLanguageCode,
      metadata: {'welcome': true},
    );
    _addMessage(welcomeMessage);
  }

  /// Add a message to the chat
  void _addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  /// Update message status
  void _updateMessageStatus(String messageId, MessageStatus status) {
    final messageIndex = _messages.indexWhere((m) => m.id == messageId);
    if (messageIndex != -1) {
      _messages[messageIndex] =
          _messages[messageIndex].copyWith(status: status);
      notifyListeners();
    }
  }

  /// Build conversation context for API
  Map<String, dynamic> _buildConversationContext() {
    final recentMessages = _messages
        .where((m) => m.isFromUser && !m.isFailed)
        .take(5)
        .map((m) => m.content)
        .toList()
        .reversed
        .toList();

    return {
      'session_id': _currentSessionId,
      'recent_messages': recentMessages,
      'current_topic': null, // TODO: Implement topic detection
    };
  }

  /// Load persisted messages from local storage
  Future<void> _loadPersistedMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString(_messagesKey);
      final sessionId = prefs.getString(_sessionKey);

      if (messagesJson != null) {
        final List<dynamic> messagesList = jsonDecode(messagesJson);
        _messages.clear();
        _messages.addAll(
          messagesList.map((json) => Message.fromJson(json)).toList(),
        );
      }

      _currentSessionId = sessionId ?? _generateSessionId();
    } catch (e) {
      debugPrint('Failed to load persisted messages: $e');
    }
  }

  /// Persist messages to local storage
  Future<void> _persistMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = jsonEncode(
        _messages.map((m) => m.toJson()).toList(),
      );

      await prefs.setString(_messagesKey, messagesJson);
      if (_currentSessionId != null) {
        await prefs.setString(_sessionKey, _currentSessionId!);
      }
    } catch (e) {
      debugPrint('Failed to persist messages: $e');
    }
  }

  /// Generate a unique message ID
  String _generateMessageId() {
    return 'msg_${DateTime.now().millisecondsSinceEpoch}_${_messages.length}';
  }

  /// Generate a unique session ID
  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Get user-friendly error message
  String _getErrorMessage(ChatException error) {
    if (error is NetworkException) {
      return 'I\'m having trouble connecting. Please check your internet connection and try again.';
    } else if (error is AuthenticationException) {
      return 'There was an authentication issue. Please make sure you\'re logged in and try again.';
    } else if (error is TimeoutException) {
      return 'The request is taking longer than expected. Please try again in a moment.';
    } else if (error is ServerException) {
      return 'I\'m experiencing technical difficulties. Please try again later.';
    } else if (error is ValidationException) {
      return 'There was an issue with your message. Please check and try again.';
    } else {
      return 'I encountered an unexpected error. Please try again or contact support if the problem persists.';
    }
  }

  /// Set loading state
  void _setLoadingState(ChatLoadingState state) {
    _loadingState = state;
    notifyListeners();
  }

  /// Set error
  void _setError(ChatException error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error
  void _clearError() {
    _error = null;
  }

  /// Test connection to chat service
  Future<bool> testConnection() async {
    return await _chatApiService.testConnection();
  }

  @override
  void dispose() {
    _chatApiService.dispose();
    super.dispose();
  }
}
