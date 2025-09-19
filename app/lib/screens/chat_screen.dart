import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/dynamic_form_widget.dart';
import '../widgets/rich_message_composer.dart';
import '../models/chat_message.dart';
import '../models/rich_message_models.dart';
import '../providers/chat_provider.dart';
import '../providers/dashboard_provider.dart';

/// Enhanced Chat Screen with Financial Analysis Support
///
/// This screen supports dynamic form rendering, general chat functionality,
/// and financial analysis commands through the AI assistant.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Initialize chat provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  /// Send a message through the chat provider
  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    _messageController.clear();
    _messageFocusNode.unfocus();

    // Send message through provider
    await context.read<ChatProvider>().sendMessage(
          messageText,
          authToken: 'mock-jwt-token', // TODO: Get from auth provider
        );

    // Scroll to bottom after sending message
    _scrollToBottom();
  }

  /// Scroll to the bottom of the messages list
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Handle form submission for dynamic forms
  void _handleFormSubmission(Map<String, String> formData) {
    // Convert form data to a readable message
    final responseText = StringBuffer('Financial information provided:');
    formData.forEach((section, input) {
      responseText.writeln('\n$section: $input');
    });

    // TODO: Process form data through appropriate service
    // For now, send the form data as a message
    context.read<ChatProvider>().sendMessage(
          responseText.toString(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('AI Financial Assistant'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ChatProvider>().clearMessages();
            },
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return Column(
            children: [
              // Messages list
              Expanded(
                child: chatProvider.messages.isEmpty
                    ? _buildEmptyState(colorScheme)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: chatProvider.messages.length,
                        itemBuilder: (context, index) {
                          final message = chatProvider.messages[index];
                          return _buildMessageWidget(message, colorScheme);
                        },
                      ),
              ),

              // Rich message composer
              RichMessageComposer(
                onSendMessage: _sendRichMessage,
                availableDashboardItems: _getAvailableDashboardItems(),
                isLoading: chatProvider.isLoading,
              ),
            ],
          );
        },
      ),
    );
  }

  /// Build empty state when no messages
  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Start a conversation',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask me to analyze your finances or help with financial questions',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Handle rich message sending
  Future<void> _sendRichMessage(RichMessageContent content) async {
    // Send rich message through provider
    await context.read<ChatProvider>().sendRichMessage(
          content,
          authToken: 'mock-jwt-token', // TODO: Get from auth provider
        );

    // Scroll to bottom after sending message
    _scrollToBottom();
  }

  /// Get available dashboard items for rich composer
  List<DashboardItem> _getAvailableDashboardItems() {
    final dashboardProvider = context.read<DashboardProvider>();
    final dashboardData = dashboardProvider.dashboardData;

    if (dashboardData == null) return [];

    final items = <DashboardItem>[];

    // Add transactions
    for (final transaction in dashboardData.recentTransactions) {
      items.add(TransactionDashboardItem.fromTransaction(transaction));
    }

    // Add budgets
    for (final budget in dashboardData.budgets) {
      items.add(BudgetDashboardItem.fromBudget(budget));
    }

    // Add accounts
    for (final account in dashboardData.moneyAccounts) {
      items.add(AccountDashboardItem.fromAccount(account));
    }

    return items;
  }

  /// Build individual message widget
  Widget _buildMessageWidget(ChatMessage message, ColorScheme colorScheme) {
    final isUser = message.isUser;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 18,
              backgroundColor: _getMessageColor(message, colorScheme),
              child: Icon(
                _getMessageIcon(message),
                size: 20,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUser
                        ? colorScheme.primary
                        : _getMessageBackgroundColor(message, colorScheme),
                    borderRadius: BorderRadius.circular(16),
                    border: message.isError
                        ? Border.all(color: colorScheme.error, width: 1)
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message text
                      Text(
                        message.text,
                        style: TextStyle(
                          color: isUser
                              ? colorScheme.onPrimary
                              : _getMessageTextColor(message, colorScheme),
                          fontSize: message.isAnalysis ? 15 : 14,
                          height: message.isAnalysis ? 1.5 : 1.4,
                        ),
                      ),

                      // Analysis summary if available
                      if (message.hasAnalysis &&
                          message.analysisData!['summary'] != null) ...[
                        const SizedBox(height: 12),
                        _buildAnalysisSummary(
                            message.analysisData!['summary'], colorScheme),
                      ],
                    ],
                  ),
                ),

                // Form widget if message has form data
                if (message.hasForm) ...[
                  const SizedBox(height: 12),
                  DynamicFormWidget(
                    formJson: message.formData!,
                    onFormSubmit: _handleFormSubmission,
                  ),
                ],

                // Timestamp for analysis messages
                if (message.isAnalysis) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Generated ${_formatTimestamp(message.timestamp)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 18,
              backgroundColor: colorScheme.secondary,
              child: Icon(
                Icons.person,
                size: 20,
                color: colorScheme.onSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build analysis summary widget
  Widget _buildAnalysisSummary(
      Map<String, dynamic> summary, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Summary',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          ...summary.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatSummaryKey(entry.key),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      entry.value.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// Get message icon based on message type
  IconData _getMessageIcon(ChatMessage message) {
    switch (message.messageType) {
      case ChatMessageType.welcome:
        return Icons.waving_hand;
      case ChatMessageType.analysis:
        return Icons.analytics;
      case ChatMessageType.loading:
        return Icons.hourglass_empty;
      case ChatMessageType.error:
        return Icons.error_outline;
      default:
        return Icons.smart_toy;
    }
  }

  /// Get message color based on message type
  Color _getMessageColor(ChatMessage message, ColorScheme colorScheme) {
    switch (message.messageType) {
      case ChatMessageType.analysis:
        return const Color(0xFF4CAF50); // Green for analysis
      case ChatMessageType.error:
        return colorScheme.error;
      case ChatMessageType.loading:
        return colorScheme.secondary;
      default:
        return colorScheme.primary;
    }
  }

  /// Get message background color
  Color _getMessageBackgroundColor(
      ChatMessage message, ColorScheme colorScheme) {
    switch (message.messageType) {
      case ChatMessageType.error:
        return colorScheme.errorContainer;
      case ChatMessageType.analysis:
        return const Color(0xFF4CAF50).withOpacity(0.1);
      default:
        return colorScheme.surfaceContainerHighest;
    }
  }

  /// Get message text color
  Color _getMessageTextColor(ChatMessage message, ColorScheme colorScheme) {
    switch (message.messageType) {
      case ChatMessageType.error:
        return colorScheme.onErrorContainer;
      default:
        return colorScheme.onSurface;
    }
  }

  /// Format timestamp for display
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  /// Format summary keys for display
  String _formatSummaryKey(String key) {
    switch (key) {
      case 'netWorth':
        return 'Net Worth';
      case 'cashFlow':
        return 'Cash Flow';
      case 'savingsRate':
        return 'Savings Rate';
      case 'budgetUtilization':
        return 'Budget Usage';
      default:
        return key
            .replaceAllMapped(
              RegExp(r'([A-Z])'),
              (match) => ' ${match.group(1)}',
            )
            .trim();
    }
  }
}
