import 'package:flutter/material.dart';
import '../../models/message.dart';
import 'message_bubble.dart';

/// Message list widget for displaying chat messages
class MessageList extends StatefulWidget {
  final List<Message> messages;
  final ScrollController? scrollController;
  final VoidCallback? onRefresh;
  final Function(String messageId)? onRetryMessage;
  final bool isLoading;

  const MessageList({
    super.key,
    required this.messages,
    this.scrollController,
    this.onRefresh,
    this.onRetryMessage,
    this.isLoading = false,
  });

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();

    // Auto-scroll to bottom when new messages are added
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void didUpdateWidget(MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Auto-scroll to bottom when new messages are added
    if (oldWidget.messages.length != widget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom({bool animate = true}) {
    if (!_scrollController.hasClients) return;

    if (animate) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.messages.isEmpty && !widget.isLoading) {
      return _buildEmptyState(theme, colorScheme);
    }

    return RefreshIndicator(
      onRefresh: () async {
        widget.onRefresh?.call();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: widget.messages.length + (widget.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          // Show loading indicator at the bottom
          if (index == widget.messages.length && widget.isLoading) {
            return _buildLoadingIndicator(colorScheme);
          }

          final message = widget.messages[index];
          return MessageBubble(
            message: message,
            onRetry: message.isFailed
                ? () => widget.onRetryMessage?.call(message.id)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Start Your Financial Journey',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Ask me anything about budgeting, saving, investing, or your financial goals. I\'m here to help!',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildSuggestionChips(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChips(ThemeData theme, ColorScheme colorScheme) {
    final suggestions = [
      'Help me create a budget',
      'How can I save more money?',
      'Explain investing basics',
      'Financial health checkup',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: suggestions.map((suggestion) {
        return ActionChip(
          label: Text(
            suggestion,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          backgroundColor: colorScheme.secondaryContainer,
          side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
          onPressed: () {
            // TODO: Send suggestion as message
            // This would need to be connected to the parent widget
          },
        );
      }).toList(),
    );
  }

  Widget _buildLoadingIndicator(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: colorScheme.tertiary,
            child: Icon(
              Icons.psychology_alt,
              size: 16,
              color: colorScheme.onTertiary,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingAnimation(colorScheme),
                const SizedBox(width: 12),
                Text(
                  'Analyzing your financial needs...',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingAnimation(ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 600 + (index * 200)),
          curve: Curves.easeInOut,
          margin: EdgeInsets.only(right: index < 2 ? 2 : 0),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.4, end: 1.0),
            duration: Duration(milliseconds: 600),
            builder: (context, value, child) {
              return Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(value),
                  shape: BoxShape.circle,
                ),
              );
            },
            onEnd: () {
              // This will restart the animation automatically due to the AnimatedContainer
            },
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }
}
