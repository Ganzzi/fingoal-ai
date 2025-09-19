import 'package:flutter/material.dart';
import '../models/rich_message_models.dart';
import 'dashboard_item_chip.dart';

/// Enhanced message composer that supports rich content including dashboard items
class RichMessageComposer extends StatefulWidget {
  final Function(RichMessageContent) onSendMessage;
  final List<DashboardItem> availableDashboardItems;
  final bool isLoading;
  final String hintText;

  const RichMessageComposer({
    super.key,
    required this.onSendMessage,
    this.availableDashboardItems = const [],
    this.isLoading = false,
    this.hintText = 'Ask me about your finances...',
  });

  @override
  State<RichMessageComposer> createState() => _RichMessageComposerState();
}

class _RichMessageComposerState extends State<RichMessageComposer> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  final List<DashboardItem> _selectedItems = [];

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  /// Send the composed message
  void _sendMessage() {
    final text = _textController.text.trim();

    // Must have either text or dashboard items
    if (text.isEmpty && _selectedItems.isEmpty) return;

    final richContent = RichMessageContent(
      text: text.isNotEmpty ? text : null,
      dashboardItems: List.from(_selectedItems),
    );

    // Clear the composer
    _textController.clear();
    _selectedItems.clear();
    _textFocusNode.unfocus();
    setState(() {});

    // Send the message
    widget.onSendMessage(richContent);
  }

  /// Add a dashboard item to the composer
  void _addDashboardItem(DashboardItem item) {
    if (!_selectedItems.any((existing) => existing.id == item.id)) {
      setState(() {
        _selectedItems.add(item);
      });
    }
  }

  /// Remove a dashboard item from the composer
  void _removeDashboardItem(String itemId) {
    setState(() {
      _selectedItems.removeWhere((item) => item.id == itemId);
    });
  }

  /// Show dashboard item selection sheet
  void _showDashboardItemSelection() {
    if (widget.availableDashboardItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No financial data available to add'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DashboardItemSelectionSheet(
        availableItems: widget.availableDashboardItems,
        selectedItemIds: _selectedItems.map((item) => item.id).toList(),
        onItemSelected: _addDashboardItem,
      ),
    );
  }

  /// Check if send button should be enabled
  bool get _canSend {
    return !widget.isLoading &&
        (_textController.text.trim().isNotEmpty || _selectedItems.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dashboard items chips container
            if (_selectedItems.isNotEmpty)
              DashboardItemChipsContainer(
                items: _selectedItems,
                onRemoveItem: _removeDashboardItem,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              ),

            // Message input row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Quick action buttons
                  _buildQuickActionButton(
                    icon: Icons.analytics,
                    tooltip: 'Analyze Finances',
                    onPressed: widget.isLoading
                        ? null
                        : () {
                            _textController.text = 'analyze my finances';
                            _sendMessage();
                          },
                  ),

                  const SizedBox(width: 8),

                  // Dashboard item selection button
                  _buildQuickActionButton(
                    icon: Icons.add_chart,
                    tooltip: 'Add Financial Data',
                    onPressed:
                        widget.isLoading ? null : _showDashboardItemSelection,
                  ),

                  const SizedBox(width: 12),

                  // Text input field
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: 48,
                        maxHeight: 120,
                      ),
                      child: TextField(
                        controller: _textController,
                        focusNode: _textFocusNode,
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: textTheme.bodyMedium?.copyWith(
                            color:
                                colorScheme.onSurfaceVariant.withOpacity(0.7),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainer,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          // Show attachment indicator if dashboard items are selected
                          prefixIcon: _selectedItems.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.attachment,
                                        size: 18,
                                        color: colorScheme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorScheme.primaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '${_selectedItems.length}',
                                          style: textTheme.bodySmall?.copyWith(
                                            color:
                                                colorScheme.onPrimaryContainer,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                )
                              : null,
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _canSend ? _sendMessage() : null,
                        enabled: !widget.isLoading,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Send button
                  _buildSendButton(colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.surfaceContainer,
        foregroundColor: colorScheme.onSurfaceVariant,
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildSendButton(ColorScheme colorScheme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: IconButton(
        onPressed: _canSend ? _sendMessage : null,
        icon: widget.isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              )
            : Icon(
                Icons.send,
                color: _canSend
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
        tooltip: 'Send Message',
        style: IconButton.styleFrom(
          backgroundColor: _canSend
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainer,
          side: BorderSide(
            color: _canSend
                ? colorScheme.primary.withOpacity(0.3)
                : colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
    );
  }
}

/// Preview widget for displaying rich message content in chat bubbles
class RichMessageContentPreview extends StatelessWidget {
  final RichMessageContent content;
  final bool isUserMessage;

  const RichMessageContentPreview({
    super.key,
    required this.content,
    this.isUserMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dashboard items (shown first in user messages)
        if (content.dashboardItems.isNotEmpty) ...[
          DashboardItemChipsContainer(
            items: content.dashboardItems,
            showRemoveButtons: false,
            padding: EdgeInsets.zero,
          ),
          if (content.text?.isNotEmpty == true) const SizedBox(height: 8),
        ],

        // Text content
        if (content.text?.isNotEmpty == true)
          Text(
            content.text!,
            style: textTheme.bodyMedium?.copyWith(
              color:
                  isUserMessage ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
          ),

        // Context indicator for AI responses
        if (!isUserMessage && content.dashboardItems.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Based on your financial data',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
