import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

/// Rich text renderer widget for parsing and displaying formatted text content
///
/// Supports markdown-like formatting including:
/// - Bold (**text** or __text__)
/// - Italic (*text* or _text_)
/// - Headings (# ## ###)
/// - Bullet points (- or *)
/// - Numbered lists (1. 2. 3.)
/// - Links [text](url) or bare URLs
///
/// Designed for responsive layouts and Material 3 theming
class RichTextRenderer extends StatelessWidget {
  final String content;
  final TextStyle? baseStyle;
  final double? fontSize;
  final Color? textColor;
  final int? maxLines;
  final TextAlign textAlign;
  final Function(String)? onLinkTap;

  const RichTextRenderer({
    super.key,
    required this.content,
    this.baseStyle,
    this.fontSize,
    this.textColor,
    this.maxLines,
    this.textAlign = TextAlign.start,
    this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = baseStyle ??
        theme.textTheme.bodyMedium!.copyWith(
          fontSize: fontSize,
          color: textColor ?? theme.colorScheme.onSurface,
        );

    final parsedContent = _parseContent(content, defaultStyle, theme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parsedContent,
    );
  }

  /// Parse content into list of widgets for display
  List<Widget> _parseContent(
      String content, TextStyle baseStyle, ThemeData theme) {
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.isEmpty) {
        // Add small spacing for empty lines
        widgets.add(const SizedBox(height: 4));
        continue;
      }

      // Check for headings
      if (line.startsWith('#')) {
        widgets.add(_buildHeading(line, baseStyle, theme));
      }
      // Check for bullet points
      else if (line.startsWith('- ') || line.startsWith('* ')) {
        widgets.add(_buildBulletPoint(line.substring(2), baseStyle, theme));
      }
      // Check for numbered lists
      else if (RegExp(r'^\d+\.\s').hasMatch(line)) {
        widgets.add(_buildNumberedItem(line, baseStyle, theme));
      }
      // Regular paragraph
      else {
        widgets.add(_buildParagraph(line, baseStyle, theme));
      }

      // Add spacing between elements
      if (i < lines.length - 1) {
        widgets.add(const SizedBox(height: 8));
      }
    }

    return widgets;
  }

  /// Build heading widget from heading text
  Widget _buildHeading(String line, TextStyle baseStyle, ThemeData theme) {
    int level = 0;
    while (level < line.length && line[level] == '#') {
      level++;
    }

    final text = line.substring(level).trim();
    TextStyle headingStyle;

    switch (level) {
      case 1:
        headingStyle = theme.textTheme.headlineMedium!;
        break;
      case 2:
        headingStyle = theme.textTheme.headlineSmall!;
        break;
      case 3:
        headingStyle = theme.textTheme.titleLarge!;
        break;
      default:
        headingStyle = theme.textTheme.titleMedium!;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: headingStyle.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        textAlign: textAlign,
      ),
    );
  }

  /// Build bullet point widget
  Widget _buildBulletPoint(String text, TextStyle baseStyle, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: baseStyle.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: _buildRichText(text, baseStyle, theme),
          ),
        ],
      ),
    );
  }

  /// Build numbered list item widget
  Widget _buildNumberedItem(String line, TextStyle baseStyle, ThemeData theme) {
    final match = RegExp(r'^(\d+)\.\s(.*)').firstMatch(line);
    if (match == null) return _buildParagraph(line, baseStyle, theme);

    final number = match.group(1)!;
    final text = match.group(2)!;

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$number.',
              style: baseStyle.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: _buildRichText(text, baseStyle, theme),
          ),
        ],
      ),
    );
  }

  /// Build paragraph widget with rich text formatting
  Widget _buildParagraph(String text, TextStyle baseStyle, ThemeData theme) {
    return _buildRichText(text, baseStyle, theme);
  }

  /// Build rich text with inline formatting (bold, italic, links)
  Widget _buildRichText(String text, TextStyle baseStyle, ThemeData theme) {
    final spans = _parseInlineFormatting(text, baseStyle, theme);

    return RichText(
      text: TextSpan(children: spans),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.visible,
    );
  }

  /// Parse inline formatting like bold, italic, and links
  List<TextSpan> _parseInlineFormatting(
      String text, TextStyle baseStyle, ThemeData theme) {
    final spans = <TextSpan>[];
    final regex = RegExp(
        r'(\*\*.*?\*\*)|(__.*?__)|(\*.*?\*)|(_.*?_)|\[([^\]]+)\]\(([^)]+)\)|(https?://[^\s]+)');

    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      // Add text before match
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }

      final matchText = match.group(0)!;

      // Handle different formatting types
      if (matchText.startsWith('**') && matchText.endsWith('**')) {
        // Bold with **
        spans.add(TextSpan(
          text: matchText.substring(2, matchText.length - 2),
          style: baseStyle.copyWith(fontWeight: FontWeight.bold),
        ));
      } else if (matchText.startsWith('__') && matchText.endsWith('__')) {
        // Bold with __
        spans.add(TextSpan(
          text: matchText.substring(2, matchText.length - 2),
          style: baseStyle.copyWith(fontWeight: FontWeight.bold),
        ));
      } else if (matchText.startsWith('*') && matchText.endsWith('*')) {
        // Italic with *
        spans.add(TextSpan(
          text: matchText.substring(1, matchText.length - 1),
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      } else if (matchText.startsWith('_') && matchText.endsWith('_')) {
        // Italic with _
        spans.add(TextSpan(
          text: matchText.substring(1, matchText.length - 1),
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      } else if (match.group(5) != null && match.group(6) != null) {
        // Markdown link [text](url)
        final linkText = match.group(5)!;
        final linkUrl = match.group(6)!;
        spans.add(TextSpan(
          text: linkText,
          style: baseStyle.copyWith(
            color: theme.colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => onLinkTap?.call(linkUrl),
        ));
      } else if (match.group(7) != null) {
        // Bare URL
        final url = match.group(7)!;
        spans.add(TextSpan(
          text: url,
          style: baseStyle.copyWith(
            color: theme.colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => onLinkTap?.call(url),
        ));
      } else {
        // Fallback - add as regular text
        spans.add(TextSpan(
          text: matchText,
          style: baseStyle,
        ));
      }

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: baseStyle,
      ));
    }

    // Return at least one span to avoid empty RichText
    return spans.isEmpty ? [TextSpan(text: text, style: baseStyle)] : spans;
  }
}

/// Rich text content model for structured content
class RichTextContent {
  final String type;
  final String content;
  final Map<String, dynamic>? attributes;

  const RichTextContent({
    required this.type,
    required this.content,
    this.attributes,
  });

  factory RichTextContent.fromJson(Map<String, dynamic> json) {
    return RichTextContent(
      type: json['type'] ?? 'text',
      content: json['content'] ?? '',
      attributes: json['attributes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'content': content,
      if (attributes != null) 'attributes': attributes,
    };
  }
}
