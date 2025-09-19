import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/dashboard_models.dart';
import '../models/rich_message_models.dart';
import '../services/chat_service.dart';

/// Chat loading states
enum ChatLoadingState {
  idle,
  sendingMessage,
  processingAnalysis,
  error,
}

/// Chat provider for managing chat messages and interactions
///
/// Handles message sending, analysis commands, and chat state management
/// using the Provider pattern for state management.
class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();

  // State management
  final List<ChatMessage> _messages = [];
  ChatLoadingState _loadingState = ChatLoadingState.idle;
  ChatServiceException? _error;
  bool _hasInitialized = false;

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  ChatLoadingState get loadingState => _loadingState;
  ChatServiceException? get error => _error;
  bool get hasInitialized => _hasInitialized;
  bool get isLoading =>
      _loadingState == ChatLoadingState.sendingMessage ||
      _loadingState == ChatLoadingState.processingAnalysis;
  bool get hasError => _error != null;
  bool get isEmpty => _messages.isEmpty;

  /// Initialize the chat with welcome message
  void initialize() {
    if (_hasInitialized) return;

    _hasInitialized = true;
    _addWelcomeMessage();
    notifyListeners();
  }

  /// Send a message to the chat
  Future<void> sendMessage(String messageText,
      {String authToken = 'mock-token'}) async {
    if (messageText.trim().isEmpty) return;

    // Add user message to chat
    final userMessage = ChatMessage(
      text: messageText.trim(),
      isUser: true,
    );
    _addMessage(userMessage);

    // Check if this is an analysis command
    if (_chatService.isAnalysisCommand(messageText)) {
      await _handleAnalysisCommand(messageText, authToken);
    } else {
      await _handleGeneralMessage(messageText, authToken);
    }
  }

  /// Send a rich message with dashboard context
  Future<void> sendRichMessage(RichMessageContent content,
      {String authToken = 'mock-token'}) async {
    if (!content.hasContent) return;

    // Add rich user message to chat
    final userMessage = ChatMessage.rich(
      content: content,
      isUser: true,
    );
    _addMessage(userMessage);

    // Process the rich message with context
    await _handleRichMessage(content, authToken);
  }

  /// Handle analysis commands (analyze my finances)
  Future<void> _handleAnalysisCommand(String message, String authToken) async {
    try {
      _setLoadingState(ChatLoadingState.processingAnalysis);
      _clearError();

      // Add loading message
      final loadingMessage = ChatMessage(
        text: 'Analyzing your financial data... This may take a moment.',
        isUser: false,
        messageType: ChatMessageType.loading,
      );
      _addMessage(loadingMessage);

      // Send analysis request to Router Agent
      final response = await _chatService.sendMessage(
        message: message,
        authToken: authToken,
        language: 'en', // TODO: Get from user preferences
      );

      // Remove loading message
      _removeMessage(loadingMessage);

      // Handle analysis response
      if (response['type'] == 'financial_analysis') {
        final analysisMessage = ChatMessage(
          text: response['analysis']['content'] ?? 'Analysis completed',
          isUser: false,
          messageType: ChatMessageType.analysis,
          analysisData: response['analysis'],
        );
        _addMessage(analysisMessage);
      } else {
        // Fallback for unexpected response format
        final fallbackMessage = ChatMessage(
          text: response['message'] ?? 'Analysis completed successfully',
          isUser: false,
        );
        _addMessage(fallbackMessage);
      }

      _setLoadingState(ChatLoadingState.idle);
    } catch (e) {
      // Remove loading message if it exists
      _messages
          .removeWhere((msg) => msg.messageType == ChatMessageType.loading);

      _setError(e as ChatServiceException);
      _setLoadingState(ChatLoadingState.error);

      // Add error message to chat
      final errorMessage = ChatMessage(
        text: _getErrorMessage(e),
        isUser: false,
        messageType: ChatMessageType.error,
      );
      _addMessage(errorMessage);
    }
  }

  /// Handle rich messages with dashboard context
  Future<void> _handleRichMessage(
      RichMessageContent content, String authToken) async {
    try {
      _setLoadingState(ChatLoadingState.sendingMessage);
      _clearError();

      // Determine if this is an analysis command or contextual question
      final text = content.text?.toLowerCase() ?? '';
      final hasDashboardItems = content.dashboardItems.isNotEmpty;

      if (_chatService.isAnalysisCommand(text) || hasDashboardItems) {
        // This is a contextual analysis request
        await _handleContextualAnalysis(content, authToken);
      } else {
        // Regular message with potential context
        await _handleContextualMessage(content, authToken);
      }
    } catch (e) {
      _setError(e as ChatServiceException);
      _setLoadingState(ChatLoadingState.error);

      final errorMessage = ChatMessage(
        text:
            'Sorry, I encountered an error processing your message with context.',
        isUser: false,
        messageType: ChatMessageType.error,
      );
      _addMessage(errorMessage);
    }
  }

  /// Handle contextual analysis with dashboard items
  Future<void> _handleContextualAnalysis(
      RichMessageContent content, String authToken) async {
    _setLoadingState(ChatLoadingState.processingAnalysis);

    // Add loading message
    final loadingMessage = ChatMessage(
      text:
          'Analyzing your financial data with context... This may take a moment.',
      isUser: false,
      messageType: ChatMessageType.loading,
    );
    _addMessage(loadingMessage);

    // Simulate processing with context
    await Future.delayed(const Duration(milliseconds: 1500));

    // Remove loading message
    _removeMessage(loadingMessage);

    // Generate contextual response
    final response = _generateContextualResponse(content);
    final responseMessage = ChatMessage(
      text: response,
      isUser: false,
      messageType: ChatMessageType.analysis,
    );
    _addMessage(responseMessage);

    _setLoadingState(ChatLoadingState.idle);
  }

  /// Handle contextual messages
  Future<void> _handleContextualMessage(
      RichMessageContent content, String authToken) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final response = _generateContextualResponse(content);
    final responseMessage = ChatMessage(
      text: response,
      isUser: false,
    );
    _addMessage(responseMessage);

    _setLoadingState(ChatLoadingState.idle);
  }

  /// Generate contextual response based on dashboard items
  String _generateContextualResponse(RichMessageContent content) {
    final text = content.text ?? '';
    final items = content.dashboardItems;

    if (items.isEmpty) {
      return _getHelpfulResponse(text);
    }

    // Generate response based on dashboard item types and context
    final responseBuffer = StringBuffer();

    if (text.isNotEmpty) {
      responseBuffer.writeln(
          'Based on your question about "${text.trim()}" and the financial data you\'ve selected:');
      responseBuffer.writeln();
    } else {
      responseBuffer.writeln('Looking at the financial data you\'ve selected:');
      responseBuffer.writeln();
    }

    for (final item in items) {
      switch (item.type) {
        case DashboardItemType.transaction:
          final transaction = (item as TransactionDashboardItem).transaction;
          responseBuffer.writeln(
              '📄 **${transaction.displayDescription}** (${transaction.formattedAmount})');
          responseBuffer.writeln(
              '   Category: ${transaction.category ?? 'Uncategorized'}');
          responseBuffer.writeln('   Date: ${transaction.formattedFullDate}');

          if (text.toLowerCase().contains('necessary') ||
              text.toLowerCase().contains('need')) {
            responseBuffer.writeln(
                '   💡 This appears to be a ${transaction.category?.toLowerCase() ?? 'general'} expense. Consider if this aligns with your financial priorities.');
          }
          responseBuffer.writeln();
          break;

        case DashboardItemType.budget:
          final budget = (item as BudgetDashboardItem).budget;
          responseBuffer.writeln('💰 **${budget.categoryName} Budget**');
          responseBuffer.writeln(
              '   Status: ${budget.status.displayName} (${budget.percentageUsed.toInt()}% used)');
          responseBuffer.writeln(
              '   Spent: ${budget.formattedSpent} of ${budget.formattedAllocated}');
          responseBuffer.writeln('   Remaining: ${budget.formattedRemaining}');

          if (budget.status == BudgetStatus.overBudget) {
            responseBuffer.writeln(
                '   ⚠️ You\'re over budget in this category. Consider reducing spending or adjusting your budget allocation.');
          } else if (budget.status == BudgetStatus.nearLimit) {
            responseBuffer.writeln(
                '   ⚡ You\'re approaching your budget limit. Monitor your spending carefully.');
          }
          responseBuffer.writeln();
          break;

        case DashboardItemType.account:
          final account = (item as AccountDashboardItem).account;
          responseBuffer
              .writeln('🏦 **${account.name}** (${account.typeDisplayName})');
          responseBuffer.writeln('   Balance: ${account.formattedBalance}');
          if (account.institution != null) {
            responseBuffer.writeln('   Institution: ${account.institution}');
          }
          responseBuffer.writeln();
          break;

        default:
          responseBuffer.writeln('📊 **${item.title}**');
          responseBuffer.writeln('   ${item.subtitle}');
          responseBuffer.writeln();
      }
    }

    // Add contextual advice
    if (text.toLowerCase().contains('advice') ||
        text.toLowerCase().contains('recommend')) {
      responseBuffer.writeln('💡 **Recommendations:**');
      responseBuffer.writeln('• Review your spending patterns regularly');
      responseBuffer.writeln('• Set up budget alerts to avoid overspending');
      responseBuffer
          .writeln('• Consider automating savings to build emergency funds');
      responseBuffer
          .writeln('• Track your financial goals and celebrate progress');
    }

    return responseBuffer.toString().trim();
  }

  /// Handle general chat messages
  Future<void> _handleGeneralMessage(String message, String authToken) async {
    try {
      _setLoadingState(ChatLoadingState.sendingMessage);
      _clearError();

      // For now, provide a helpful response about available commands
      await Future.delayed(
          const Duration(milliseconds: 500)); // Simulate processing

      final responseMessage = ChatMessage(
        text: _getHelpfulResponse(message),
        isUser: false,
      );
      _addMessage(responseMessage);

      _setLoadingState(ChatLoadingState.idle);
    } catch (e) {
      _setError(e as ChatServiceException);
      _setLoadingState(ChatLoadingState.error);

      final errorMessage = ChatMessage(
        text: 'Sorry, I encountered an error processing your message.',
        isUser: false,
        messageType: ChatMessageType.error,
      );
      _addMessage(errorMessage);
    }
  }

  /// Add welcome message when chat initializes
  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      text:
          '''Hello! I'm your AI financial assistant. I can help you understand your financial situation and provide personalized advice.

Try asking me to "analyze my finances" to get a comprehensive financial review!

Other things I can help with:
• Budget analysis and recommendations
• Spending pattern insights
• Financial goal tracking
• General financial advice''',
      isUser: false,
      messageType: ChatMessageType.welcome,
    );
    _addMessage(welcomeMessage);
  }

  /// Add a message to the chat
  void _addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  /// Remove a specific message
  void _removeMessage(ChatMessage message) {
    _messages.remove(message);
    notifyListeners();
  }

  /// Clear all messages
  void clearMessages() {
    _messages.clear();
    _addWelcomeMessage();
    notifyListeners();
  }

  /// Retry last failed operation
  Future<void> retryLastOperation() async {
    if (!hasError) return;
    _clearError();
    // TODO: Implement retry logic based on last operation
    notifyListeners();
  }

  /// Get helpful response for general messages
  String _getHelpfulResponse(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('help') ||
        lowerMessage.contains('what can you do')) {
      return '''I can help you with various financial tasks:

🔍 **Financial Analysis**: Say "analyze my finances" for a comprehensive review
📊 **Budget Insights**: Get detailed budget performance analysis  
💰 **Spending Patterns**: Understand your spending habits
🎯 **Goal Tracking**: Monitor progress toward financial goals
💡 **Personalized Advice**: Receive actionable financial recommendations

Just ask me about any aspect of your finances!''';
    }

    if (lowerMessage.contains('budget')) {
      return 'I can help you analyze your budget performance! Try asking me to "analyze my finances" to see how you\'re doing with your budget allocations and spending patterns.';
    }

    if (lowerMessage.contains('spending') ||
        lowerMessage.contains('expenses')) {
      return 'I can provide insights into your spending patterns and help identify areas for optimization. Ask me to "analyze my finances" for a detailed spending breakdown.';
    }

    if (lowerMessage.contains('saving') || lowerMessage.contains('save')) {
      return 'I can help you understand your savings rate and provide recommendations for improving it. Request a financial analysis to see your current savings performance.';
    }

    // Default response
    return '''I understand you're asking about "$message". 

For the most comprehensive help, try asking me to **"analyze my finances"** - I'll provide detailed insights about your financial situation including budgets, spending, savings, and personalized recommendations.

What specific aspect of your finances would you like to explore?''';
  }

  /// Get user-friendly error message
  String _getErrorMessage(ChatServiceException error) {
    switch (error.type) {
      case ChatServiceExceptionType.network:
        return 'I\'m having trouble connecting to analyze your finances. Please check your internet connection and try again.';
      case ChatServiceExceptionType.authentication:
        return 'There was an authentication issue. Please make sure you\'re logged in and try again.';
      case ChatServiceExceptionType.timeout:
        return 'The analysis is taking longer than expected. Please try again in a moment.';
      case ChatServiceExceptionType.serverError:
        return 'I\'m experiencing technical difficulties. Please try again later.';
      default:
        return 'I encountered an unexpected error. Please try again or contact support if the problem persists.';
    }
  }

  /// Set loading state
  void _setLoadingState(ChatLoadingState state) {
    _loadingState = state;
    notifyListeners();
  }

  /// Set error
  void _setError(ChatServiceException error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error
  void _clearError() {
    _error = null;
  }

  /// Test connection to chat service
  Future<bool> testConnection() async {
    return await _chatService.testConnection();
  }

  @override
  void dispose() {
    _chatService.dispose();
    super.dispose();
  }
}
