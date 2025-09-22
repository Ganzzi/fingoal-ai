import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Code block renderer widget for displaying syntax-highlighted code snippets
///
/// Supports:
/// - Multiple programming languages (JSON, SQL, JavaScript, Dart, etc.)
/// - Syntax highlighting with customizable themes
/// - Copy-to-clipboard functionality
/// - Line numbers and language indicators
/// - Material 3 theming integration
/// - Responsive design for different screen sizes
class CodeBlockRenderer extends StatelessWidget {
  final String code;
  final String? language;
  final bool showLineNumbers;
  final bool showCopyButton;
  final bool showLanguageLabel;
  final TextStyle? codeStyle;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final double? maxHeight;

  const CodeBlockRenderer({
    super.key,
    required this.code,
    this.language,
    this.showLineNumbers = false,
    this.showCopyButton = true,
    this.showLanguageLabel = true,
    this.codeStyle,
    this.backgroundColor,
    this.padding,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final codeLines = code.split('\n');

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLanguageLabel && language != null || showCopyButton)
            _buildCodeHeader(context, theme),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: maxHeight ?? double.infinity,
            ),
            child: SingleChildScrollView(
              padding: padding ?? const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showLineNumbers) ...[
                    _buildLineNumbers(codeLines, theme),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: _buildCodeContent(codeLines, theme),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build code header with language label and copy button
  Widget _buildCodeHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showLanguageLabel && language != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                language!.toUpperCase(),
                style: theme.textTheme.labelSmall!.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          if (showCopyButton)
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () => _copyToClipboard(context),
              tooltip: 'Copy code',
              style: IconButton.styleFrom(
                minimumSize: const Size(32, 32),
                padding: const EdgeInsets.all(4),
              ),
            ),
        ],
      ),
    );
  }

  /// Build line numbers column
  Widget _buildLineNumbers(List<String> codeLines, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: codeLines.asMap().entries.map((entry) {
        final lineNumber = entry.key + 1;
        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            lineNumber.toString(),
            style: (codeStyle ?? _getDefaultCodeStyle(theme)).copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Build main code content with syntax highlighting
  Widget _buildCodeContent(List<String> codeLines, ThemeData theme) {
    final defaultCodeStyle = codeStyle ?? _getDefaultCodeStyle(theme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: codeLines.map((line) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: _buildHighlightedLine(line, defaultCodeStyle, theme),
        );
      }).toList(),
    );
  }

  /// Build syntax-highlighted line
  Widget _buildHighlightedLine(
      String line, TextStyle baseStyle, ThemeData theme) {
    // Simple syntax highlighting based on language
    if (language == null) {
      return Text(line.isNotEmpty ? line : ' ', style: baseStyle);
    }

    final spans = _highlightSyntax(line, language!, baseStyle, theme);

    return RichText(
      text: TextSpan(
          children: spans.isNotEmpty
              ? spans
              : [
                  TextSpan(
                      text: line.isNotEmpty ? line : ' ', style: baseStyle),
                ]),
    );
  }

  /// Apply syntax highlighting based on language
  List<TextSpan> _highlightSyntax(
      String line, String lang, TextStyle baseStyle, ThemeData theme) {
    switch (lang.toLowerCase()) {
      case 'json':
        return _highlightJson(line, baseStyle, theme);
      case 'sql':
        return _highlightSql(line, baseStyle, theme);
      case 'javascript':
      case 'js':
        return _highlightJavaScript(line, baseStyle, theme);
      case 'dart':
        return _highlightDart(line, baseStyle, theme);
      default:
        return [TextSpan(text: line, style: baseStyle)];
    }
  }

  /// Highlight JSON syntax
  List<TextSpan> _highlightJson(
      String line, TextStyle baseStyle, ThemeData theme) {
    final spans = <TextSpan>[];
    final regex = RegExp(
        r'(".*?")|(\btrue\b|\bfalse\b|\bnull\b)|(\d+\.?\d*)|([{}[\],:])',
        caseSensitive: false);

    int lastEnd = 0;

    for (final match in regex.allMatches(line)) {
      // Add text before match
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: line.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }

      final matchText = match.group(0)!;
      TextStyle style = baseStyle;

      if (match.group(1) != null) {
        // String
        style = baseStyle.copyWith(color: theme.colorScheme.primary);
      } else if (match.group(2) != null) {
        // Boolean/null
        style = baseStyle.copyWith(color: theme.colorScheme.secondary);
      } else if (match.group(3) != null) {
        // Number
        style = baseStyle.copyWith(color: theme.colorScheme.tertiary);
      } else if (match.group(4) != null) {
        // Punctuation
        style = baseStyle.copyWith(color: theme.colorScheme.onSurfaceVariant);
      }

      spans.add(TextSpan(text: matchText, style: style));
      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < line.length) {
      spans.add(TextSpan(text: line.substring(lastEnd), style: baseStyle));
    }

    return spans;
  }

  /// Highlight SQL syntax
  List<TextSpan> _highlightSql(
      String line, TextStyle baseStyle, ThemeData theme) {
    final keywords = {
      'SELECT',
      'FROM',
      'WHERE',
      'INSERT',
      'UPDATE',
      'DELETE',
      'CREATE',
      'TABLE',
      'INDEX',
      'DROP',
      'ALTER',
      'JOIN',
      'INNER',
      'LEFT',
      'RIGHT',
      'OUTER',
      'GROUP',
      'ORDER',
      'BY',
      'HAVING',
      'LIMIT',
      'OFFSET',
      'AS',
      'AND',
      'OR',
      'NOT'
    };

    final spans = <TextSpan>[];
    final words = line.split(RegExp(r'(\s+)'));

    for (final word in words) {
      if (keywords.contains(word.toUpperCase())) {
        spans.add(TextSpan(
          text: word,
          style: baseStyle.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ));
      } else if (word.startsWith("'") && word.endsWith("'")) {
        spans.add(TextSpan(
          text: word,
          style: baseStyle.copyWith(color: theme.colorScheme.secondary),
        ));
      } else {
        spans.add(TextSpan(text: word, style: baseStyle));
      }
    }

    return spans;
  }

  /// Highlight JavaScript syntax
  List<TextSpan> _highlightJavaScript(
      String line, TextStyle baseStyle, ThemeData theme) {
    final keywords = {
      'function',
      'var',
      'let',
      'const',
      'if',
      'else',
      'for',
      'while',
      'return',
      'class',
      'extends',
      'import',
      'export',
      'async',
      'await',
      'try',
      'catch'
    };

    final spans = <TextSpan>[];
    final regex = RegExp(r'(\b\w+\b)|(".*?")|(\d+\.?\d*)|([{}()[\];,.])',
        caseSensitive: false);

    int lastEnd = 0;

    for (final match in regex.allMatches(line)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: line.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }

      final matchText = match.group(0)!;
      TextStyle style = baseStyle;

      if (match.group(1) != null &&
          keywords.contains(matchText.toLowerCase())) {
        // Keyword
        style = baseStyle.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        );
      } else if (match.group(2) != null) {
        // String
        style = baseStyle.copyWith(color: theme.colorScheme.secondary);
      } else if (match.group(3) != null) {
        // Number
        style = baseStyle.copyWith(color: theme.colorScheme.tertiary);
      }

      spans.add(TextSpan(text: matchText, style: style));
      lastEnd = match.end;
    }

    if (lastEnd < line.length) {
      spans.add(TextSpan(text: line.substring(lastEnd), style: baseStyle));
    }

    return spans;
  }

  /// Highlight Dart syntax
  List<TextSpan> _highlightDart(
      String line, TextStyle baseStyle, ThemeData theme) {
    final keywords = {
      'class',
      'extends',
      'implements',
      'with',
      'abstract',
      'final',
      'const',
      'static',
      'void',
      'int',
      'double',
      'String',
      'bool',
      'List',
      'Map',
      'if',
      'else',
      'for',
      'while',
      'switch',
      'case',
      'return',
      'async',
      'await'
    };

    final spans = <TextSpan>[];
    final regex = RegExp(r'(\b\w+\b)|(".*?")|(\d+\.?\d*)|([{}()[\];,.])',
        caseSensitive: false);

    int lastEnd = 0;

    for (final match in regex.allMatches(line)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: line.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }

      final matchText = match.group(0)!;
      TextStyle style = baseStyle;

      if (match.group(1) != null && keywords.contains(matchText)) {
        // Keyword
        style = baseStyle.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        );
      } else if (match.group(2) != null) {
        // String
        style = baseStyle.copyWith(color: theme.colorScheme.secondary);
      } else if (match.group(3) != null) {
        // Number
        style = baseStyle.copyWith(color: theme.colorScheme.tertiary);
      }

      spans.add(TextSpan(text: matchText, style: style));
      lastEnd = match.end;
    }

    if (lastEnd < line.length) {
      spans.add(TextSpan(text: line.substring(lastEnd), style: baseStyle));
    }

    return spans;
  }

  /// Get default monospace code style
  TextStyle _getDefaultCodeStyle(ThemeData theme) {
    return TextStyle(
      fontFamily: 'Monaco',
      fontSize: 14,
      color: theme.colorScheme.onSurface,
      height: 1.4,
    );
  }

  /// Copy code to clipboard
  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: code));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Code content model for structured code information
class CodeContent {
  final String code;
  final String? language;
  final String? title;
  final bool executable;
  final Map<String, dynamic>? metadata;

  const CodeContent({
    required this.code,
    this.language,
    this.title,
    this.executable = false,
    this.metadata,
  });

  factory CodeContent.fromJson(Map<String, dynamic> json) {
    return CodeContent(
      code: json['code'] ?? '',
      language: json['language'],
      title: json['title'],
      executable: json['executable'] ?? false,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      if (language != null) 'language': language,
      if (title != null) 'title': title,
      'executable': executable,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// Inline code renderer for short code snippets within text
class InlineCodeRenderer extends StatelessWidget {
  final String code;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final EdgeInsets? padding;

  const InlineCodeRenderer({
    super.key,
    required this.code,
    this.textStyle,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        code,
        style: (textStyle ?? theme.textTheme.bodyMedium!).copyWith(
          fontFamily: 'Monaco',
          fontSize: 13,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
