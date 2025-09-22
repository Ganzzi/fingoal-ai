import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/chat/message_list.dart';
import '../widgets/chat/message_composer.dart';
import '../providers/chat_provider.dart';

/// Chat Screen with AI Financial Assistant
///
/// This screen provides a chat interface to communicate with the AI assistant
/// for financial advice and guidance.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

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
    _scrollController.dispose();
    super.dispose();
  }

  /// Handle sending a message
  Future<void> _handleSendMessage(String message) async {
    await context.read<ChatProvider>().sendMessage(message);
  }

  /// Handle refreshing chat history
  Future<void> _handleRefresh() async {
    await context.read<ChatProvider>().refreshHistory();
  }

  /// Handle retrying a failed message
  Future<void> _handleRetryMessage(String messageId) async {
    await context.read<ChatProvider>().retryMessage(messageId);
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
                child: MessageList(
                  messages: chatProvider.messages,
                  scrollController: _scrollController,
                  onRefresh: _handleRefresh,
                  onRetryMessage: _handleRetryMessage,
                  isLoading: chatProvider.isLoading,
                ),
              ),

              // Message composer
              MessageComposer(
                onSendMessage: _handleSendMessage,
                isLoading: chatProvider.isLoading,
              ),
            ],
          );
        },
      ),
    );
  }
}
