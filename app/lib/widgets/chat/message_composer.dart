import 'package:flutter/material.dart';

/// Message input composer widget for chat interface
class MessageComposer extends StatefulWidget {
  final Function(String message) onSendMessage;
  final bool isLoading;
  final String? placeholder;

  const MessageComposer({
    super.key,
    required this.onSendMessage,
    this.isLoading = false,
    this.placeholder,
  });

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isEmpty = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final isEmpty = _controller.text.trim().isEmpty;
    if (isEmpty != _isEmpty) {
      setState(() {
        _isEmpty = isEmpty;
      });
    }
  }

  void _sendMessage() {
    if (_isEmpty || widget.isLoading) return;

    final message = _controller.text.trim();
    _controller.clear();
    _focusNode.unfocus();

    widget.onSendMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Message input field
            Expanded(
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 40,
                  maxHeight: 120,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _focusNode.hasFocus
                        ? colorScheme.primary
                        : colorScheme.outline.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !widget.isLoading,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText:
                        widget.placeholder ?? 'Ask me about your finances...',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: (!_isEmpty && !widget.isLoading)
                    ? colorScheme.primary
                    : colorScheme.outline.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: widget.isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(
                          colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : IconButton(
                      onPressed: (!_isEmpty && !widget.isLoading)
                          ? _sendMessage
                          : null,
                      icon: Icon(
                        Icons.send,
                        color: (!_isEmpty && !widget.isLoading)
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant.withOpacity(0.5),
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
