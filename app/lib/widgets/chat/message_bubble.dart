import 'package:flutter/material.dart';
import '../../models/message.dart';
import 'package:intl/intl.dart';
import 'rich_text_renderer.dart';
import 'financial_data_renderer.dart';
import 'link_renderer.dart';
import 'code_block_renderer.dart';
import 'mini_chart_renderer.dart';

/// Individual message bubble widget for chat interface
class MessageBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onRetry;

  const MessageBubble({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isUser = message.isFromUser;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAvatar(colorScheme),
            const SizedBox(width: 8),
          ],
          Flexible(
            flex: 3,
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _buildMessageBubble(theme, colorScheme, isUser),
                const SizedBox(height: 4),
                _buildMessageInfo(theme, colorScheme, isUser),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            _buildAvatar(colorScheme, isUser: true),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(ColorScheme colorScheme, {bool isUser = false}) {
    return CircleAvatar(
      radius: 16,
      backgroundColor:
          isUser ? colorScheme.primary : _getAgentColor(colorScheme),
      child: Icon(
        isUser ? Icons.person : _getAgentIcon(),
        size: 16,
        color: colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildMessageBubble(
      ThemeData theme, ColorScheme colorScheme, bool isUser) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _getBubbleColor(colorScheme, isUser),
        borderRadius: BorderRadius.circular(18),
        border: message.isFailed
            ? Border.all(color: colorScheme.error, width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser && message.agentType != null) ...[
            Text(
              message.agentType!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: _getTextColor(colorScheme, isUser).withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
          ],
          _buildMessageContent(theme, colorScheme, isUser),
          if (_hasMetadata()) _buildMetadata(theme, colorScheme, isUser),
        ],
      ),
    );
  }

  /// Build rich message content with appropriate renderers
  Widget _buildMessageContent(
      ThemeData theme, ColorScheme colorScheme, bool isUser) {
    final textColor = _getTextColor(colorScheme, isUser);
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      color: textColor,
      height: 1.4,
    );

    // Check if message contains structured rich content
    final metadata = message.metadata;
    final richContent = metadata?['rich_content'] as List<dynamic>?;

    if (richContent != null && richContent.isNotEmpty) {
      return _buildStructuredContent(richContent, textStyle, theme);
    }

    // Check for inline formatting, financial data, links, or code blocks
    if (_containsRichFormatting(message.content)) {
      return _buildInlineRichContent(message.content, textStyle, theme);
    }

    // Fallback to regular text with link detection
    return LinkRenderer(
      text: message.content,
      textStyle: textStyle,
      linkColor:
          isUser ? textColor.withOpacity(0.8) : theme.colorScheme.primary,
      onLinkTap: (url) => _handleLinkTap(url),
    );
  }

  /// Build structured rich content from metadata
  Widget _buildStructuredContent(
      List<dynamic> richContent, TextStyle? textStyle, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: richContent.asMap().entries.map((entry) {
        final index = entry.key;
        final contentItem = entry.value as Map<String, dynamic>;
        final type = contentItem['type'] as String;

        Widget contentWidget;

        switch (type) {
          case 'text':
            contentWidget = RichTextRenderer(
              content: contentItem['content'] ?? '',
              baseStyle: textStyle,
              onLinkTap: (url) => _handleLinkTap(url),
            );
            break;
          case 'financial_data':
            contentWidget = _buildFinancialDataWidget(contentItem);
            break;
          case 'code':
            contentWidget = CodeBlockRenderer(
              code: contentItem['content'] ?? '',
              language: contentItem['language'],
              showCopyButton: true,
              showLanguageLabel: true,
            );
            break;
          case 'chart':
            contentWidget = _buildChartWidget(contentItem);
            break;
          case 'link':
            contentWidget = LinkRenderer(
              text: contentItem['content'] ?? '',
              textStyle: textStyle,
              onLinkTap: (url) => _handleLinkTap(url),
            );
            break;
          default:
            contentWidget = Text(
              contentItem['content'] ?? '',
              style: textStyle,
            );
        }

        return Padding(
          padding:
              EdgeInsets.only(bottom: index < richContent.length - 1 ? 8 : 0),
          child: contentWidget,
        );
      }).toList(),
    );
  }

  /// Build inline rich content with auto-detection
  Widget _buildInlineRichContent(
      String content, TextStyle? textStyle, ThemeData theme) {
    // Check for code blocks first
    final codeBlockRegex = RegExp(r'```(\w+)?\n([\s\S]*?)```');
    final codeMatches = codeBlockRegex.allMatches(content);

    if (codeMatches.isNotEmpty) {
      return _buildContentWithCodeBlocks(
          content, codeMatches, textStyle, theme);
    }

    // Check for financial data patterns
    if (_containsFinancialData(content)) {
      return _buildContentWithFinancialData(content, textStyle, theme);
    }

    // Default to rich text renderer for formatting and links
    return RichTextRenderer(
      content: content,
      baseStyle: textStyle,
      onLinkTap: (url) => _handleLinkTap(url),
    );
  }

  /// Build content with embedded code blocks
  Widget _buildContentWithCodeBlocks(
      String content,
      Iterable<RegExpMatch> codeMatches,
      TextStyle? textStyle,
      ThemeData theme) {
    final widgets = <Widget>[];
    int lastEnd = 0;

    for (final match in codeMatches) {
      // Add text before code block
      if (match.start > lastEnd) {
        final textContent = content.substring(lastEnd, match.start).trim();
        if (textContent.isNotEmpty) {
          widgets.add(RichTextRenderer(
            content: textContent,
            baseStyle: textStyle,
            onLinkTap: (url) => _handleLinkTap(url),
          ));
          widgets.add(const SizedBox(height: 8));
        }
      }

      // Add code block
      final language = match.group(1);
      final code = match.group(2) ?? '';
      widgets.add(CodeBlockRenderer(
        code: code.trim(),
        language: language,
        showCopyButton: true,
        showLanguageLabel: language != null,
      ));

      lastEnd = match.end;
      if (lastEnd < content.length) {
        widgets.add(const SizedBox(height: 8));
      }
    }

    // Add remaining text
    if (lastEnd < content.length) {
      final remainingContent = content.substring(lastEnd).trim();
      if (remainingContent.isNotEmpty) {
        widgets.add(RichTextRenderer(
          content: remainingContent,
          baseStyle: textStyle,
          onLinkTap: (url) => _handleLinkTap(url),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  /// Build content with embedded financial data
  Widget _buildContentWithFinancialData(
      String content, TextStyle? textStyle, ThemeData theme) {
    // Extract financial data and replace with placeholders
    final financialRegex = RegExp(r'\$[\d,]+\.?\d*|\d+\.?\d*%|\$\d+[KMB]');
    final matches = financialRegex.allMatches(content);

    if (matches.isEmpty) {
      return RichTextRenderer(
        content: content,
        baseStyle: textStyle,
        onLinkTap: (url) => _handleLinkTap(url),
      );
    }

    // For now, just use rich text renderer with enhanced financial formatting
    return RichTextRenderer(
      content: content,
      baseStyle: textStyle,
      onLinkTap: (url) => _handleLinkTap(url),
    );
  }

  /// Build financial data widget from metadata
  Widget _buildFinancialDataWidget(Map<String, dynamic> contentItem) {
    final value = (contentItem['value'] ?? 0).toDouble();
    final typeString = contentItem['data_type'] ?? 'number';
    final currency = contentItem['currency'];
    final comparisonValue = contentItem['comparison_value']?.toDouble();

    FinancialDataType dataType;
    switch (typeString) {
      case 'currency':
        dataType = FinancialDataType.currency;
        break;
      case 'percentage':
        dataType = FinancialDataType.percentage;
        break;
      case 'change':
        dataType = FinancialDataType.change;
        break;
      default:
        dataType = FinancialDataType.number;
    }

    return FinancialDataRenderer(
      value: value,
      type: dataType,
      currency: currency,
      comparisonValue: comparisonValue,
      showTrend: comparisonValue != null,
      compact: false,
    );
  }

  /// Build chart widget from metadata
  Widget _buildChartWidget(Map<String, dynamic> contentItem) {
    final chartData = ChartData.fromJson(contentItem);
    final chartTypeString = contentItem['chart_type'] ?? 'bar';

    ChartType chartType;
    switch (chartTypeString) {
      case 'pie':
        chartType = ChartType.pie;
        break;
      case 'progress':
        chartType = ChartType.progress;
        break;
      case 'sparkline':
        chartType = ChartType.sparkline;
        break;
      default:
        chartType = ChartType.bar;
    }

    return MiniChartRenderer(
      chartData: chartData,
      chartType: chartType,
      showLabels: true,
      showValues: chartTypeString != 'sparkline',
    );
  }

  /// Check if content contains rich formatting
  bool _containsRichFormatting(String content) {
    // Check for markdown-like formatting
    final markdownRegex = RegExp(
        r'(\*\*.*?\*\*)|(\*.*?\*)|(__.*?__)|(_.*?_)|(```[\s\S]*?```)|(#{1,6}\s)|(^\s*[-*]\s)|(^\s*\d+\.\s)',
        multiLine: true);

    // Check for links
    final linkRegex = RegExp(r'https?://[^\s]+|\[.*?\]\(.*?\)');

    // Check for financial data
    final financialRegex = RegExp(r'\$[\d,]+\.?\d*|\d+\.?\d*%');

    return markdownRegex.hasMatch(content) ||
        linkRegex.hasMatch(content) ||
        financialRegex.hasMatch(content);
  }

  /// Check if content contains financial data
  bool _containsFinancialData(String content) {
    final financialRegex = RegExp(r'\$[\d,]+\.?\d*|\d+\.?\d*%|\$\d+[KMB]');
    return financialRegex.hasMatch(content);
  }

  /// Handle link tap
  void _handleLinkTap(String url) {
    // This would typically open the URL or handle internal navigation
    debugPrint('Link tapped: $url');
  }

  Widget _buildMessageInfo(
      ThemeData theme, ColorScheme colorScheme, bool isUser) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          DateFormat.Hm().format(message.timestamp),
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
        ),
        if (isUser) ...[
          const SizedBox(width: 4),
          _buildStatusIcon(colorScheme),
        ],
        if (message.isFailed && onRetry != null) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRetry,
            child: Icon(
              Icons.refresh,
              size: 16,
              color: colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusIcon(ColorScheme colorScheme) {
    IconData icon;
    Color color;

    switch (message.status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        color = colorScheme.onSurfaceVariant.withOpacity(0.6);
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = colorScheme.onSurfaceVariant.withOpacity(0.6);
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = colorScheme.primary;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = colorScheme.error;
        break;
    }

    return Icon(
      icon,
      size: 14,
      color: color,
    );
  }

  Widget _buildMetadata(ThemeData theme, ColorScheme colorScheme, bool isUser) {
    final metadata = message.metadata;
    if (metadata == null || metadata.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getTextColor(colorScheme, isUser).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (metadata['suggested_actions'] != null) ...[
            Text(
              'Suggested Actions:',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: _getTextColor(colorScheme, isUser),
              ),
            ),
            const SizedBox(height: 4),
            ...((metadata['suggested_actions'] as List<dynamic>?) ?? [])
                .map((action) => Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 2),
                      child: Text(
                        '• $action',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getTextColor(colorScheme, isUser),
                        ),
                      ),
                    )),
            const SizedBox(height: 8),
          ],
          if (metadata['educational_tips'] != null) ...[
            Text(
              'Tips:',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: _getTextColor(colorScheme, isUser),
              ),
            ),
            const SizedBox(height: 4),
            ...((metadata['educational_tips'] as List<dynamic>?) ?? [])
                .map((tip) => Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 2),
                      child: Text(
                        '💡 $tip',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getTextColor(colorScheme, isUser),
                        ),
                      ),
                    )),
          ],
        ],
      ),
    );
  }

  Color _getBubbleColor(ColorScheme colorScheme, bool isUser) {
    if (message.isFailed) {
      return colorScheme.errorContainer;
    }
    return isUser ? colorScheme.primary : colorScheme.surfaceContainerHighest;
  }

  Color _getTextColor(ColorScheme colorScheme, bool isUser) {
    if (message.isFailed) {
      return colorScheme.onErrorContainer;
    }
    return isUser ? colorScheme.onPrimary : colorScheme.onSurface;
  }

  Color _getAgentColor(ColorScheme colorScheme) {
    if (message.agentType?.contains('Welcome') == true) {
      return Colors.green;
    }
    if (message.agentType?.contains('System') == true) {
      return colorScheme.secondary;
    }
    return colorScheme.tertiary;
  }

  IconData _getAgentIcon() {
    if (message.agentType?.contains('Welcome') == true) {
      return Icons.waving_hand;
    }
    if (message.agentType?.contains('System') == true) {
      return Icons.info_outline;
    }
    return Icons.smart_toy;
  }

  bool _hasMetadata() {
    final metadata = message.metadata;
    if (metadata == null) return false;

    return metadata.containsKey('suggested_actions') ||
        metadata.containsKey('educational_tips') ||
        metadata.containsKey('next_steps');
  }
}
