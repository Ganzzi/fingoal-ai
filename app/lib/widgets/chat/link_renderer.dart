import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

/// Link renderer widget for handling clickable URLs and references in chat messages
///
/// Supports:
/// - URL detection and parsing
/// - External link opening in browser
/// - Internal reference handling
/// - Link preview capabilities
/// - Custom styling with Material 3 theming
/// - Accessibility support
class LinkRenderer extends StatelessWidget {
  final String text;
  final Function(String)? onLinkTap;
  final Function(String)? onInternalLinkTap;
  final TextStyle? textStyle;
  final Color? linkColor;
  final bool showLinkPreviews;
  final bool underlineLinks;

  const LinkRenderer({
    super.key,
    required this.text,
    this.onLinkTap,
    this.onInternalLinkTap,
    this.textStyle,
    this.linkColor,
    this.showLinkPreviews = false,
    this.underlineLinks = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = textStyle ?? theme.textTheme.bodyMedium!;

    return RichText(
      text: TextSpan(
        children: _parseTextWithLinks(text, defaultStyle, theme),
      ),
    );
  }

  /// Parse text and identify links for appropriate rendering
  List<TextSpan> _parseTextWithLinks(
      String text, TextStyle baseStyle, ThemeData theme) {
    final spans = <TextSpan>[];

    // Combined regex for different link types
    final linkRegex = RegExp(
      r'(\[([^\]]+)\]\(([^)]+)\))|(https?://[^\s]+)|(www\.[^\s]+)|(@[a-zA-Z0-9_]+)|(#[a-zA-Z0-9_]+)',
      caseSensitive: false,
    );

    int lastEnd = 0;

    for (final match in linkRegex.allMatches(text)) {
      // Add text before link
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }

      // Process different link types
      if (match.group(1) != null) {
        // Markdown link [text](url)
        final linkText = match.group(2)!;
        final linkUrl = match.group(3)!;
        spans.add(_createLinkSpan(
            linkText, linkUrl, baseStyle, theme, LinkType.markdown));
      } else if (match.group(4) != null) {
        // HTTP/HTTPS URL
        final url = match.group(4)!;
        spans.add(_createLinkSpan(url, url, baseStyle, theme, LinkType.url));
      } else if (match.group(5) != null) {
        // www URL
        final wwwUrl = match.group(5)!;
        final fullUrl = 'https://$wwwUrl';
        spans.add(
            _createLinkSpan(wwwUrl, fullUrl, baseStyle, theme, LinkType.url));
      } else if (match.group(6) != null) {
        // Username mention
        final mention = match.group(6)!;
        spans.add(_createLinkSpan(
            mention, mention, baseStyle, theme, LinkType.mention));
      } else if (match.group(7) != null) {
        // Hashtag
        final hashtag = match.group(7)!;
        spans.add(_createLinkSpan(
            hashtag, hashtag, baseStyle, theme, LinkType.hashtag));
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

    return spans.isEmpty ? [TextSpan(text: text, style: baseStyle)] : spans;
  }

  /// Create a clickable link span
  TextSpan _createLinkSpan(
    String displayText,
    String linkUrl,
    TextStyle baseStyle,
    ThemeData theme,
    LinkType linkType,
  ) {
    Color? linkTextColor;

    switch (linkType) {
      case LinkType.url:
      case LinkType.markdown:
        linkTextColor = linkColor ?? theme.colorScheme.primary;
        break;
      case LinkType.mention:
        linkTextColor = theme.colorScheme.secondary;
        break;
      case LinkType.hashtag:
        linkTextColor = theme.colorScheme.tertiary;
        break;
    }

    return TextSpan(
      text: displayText,
      style: baseStyle.copyWith(
        color: linkTextColor,
        decoration: underlineLinks ? TextDecoration.underline : null,
        decorationColor: linkTextColor,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () => _handleLinkTap(linkUrl, linkType),
    );
  }

  /// Handle different types of link taps
  void _handleLinkTap(String link, LinkType linkType) {
    switch (linkType) {
      case LinkType.url:
      case LinkType.markdown:
        _openUrl(link);
        break;
      case LinkType.mention:
      case LinkType.hashtag:
        onInternalLinkTap?.call(link);
        break;
    }

    // Also call general link tap handler
    onLinkTap?.call(link);
  }

  /// Open URL in external browser
  void _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint('Failed to launch URL: $url, Error: $e');
    }
  }
}

/// Enhanced link renderer with preview capabilities
class LinkRendererWithPreview extends StatefulWidget {
  final String text;
  final Function(String)? onLinkTap;
  final TextStyle? textStyle;
  final Color? linkColor;
  final bool showPreviews;

  const LinkRendererWithPreview({
    super.key,
    required this.text,
    this.onLinkTap,
    this.textStyle,
    this.linkColor,
    this.showPreviews = true,
  });

  @override
  State<LinkRendererWithPreview> createState() =>
      _LinkRendererWithPreviewState();
}

class _LinkRendererWithPreviewState extends State<LinkRendererWithPreview> {
  final Map<String, LinkPreviewData> _linkPreviews = {};
  final Set<String> _loadingPreviews = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final links = _extractLinks(widget.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinkRenderer(
          text: widget.text,
          onLinkTap: widget.onLinkTap,
          textStyle: widget.textStyle,
          linkColor: widget.linkColor,
        ),
        if (widget.showPreviews) ...[
          ...links.map((link) => _buildLinkPreview(link, theme)),
        ],
      ],
    );
  }

  /// Extract all URLs from text
  List<String> _extractLinks(String text) {
    final urlRegex = RegExp(r'https?://[^\s]+', caseSensitive: false);
    return urlRegex.allMatches(text).map((match) => match.group(0)!).toList();
  }

  /// Build link preview widget
  Widget _buildLinkPreview(String url, ThemeData theme) {
    if (_loadingPreviews.contains(url)) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: LinearProgressIndicator(),
      );
    }

    final preview = _linkPreviews[url];
    if (preview == null) {
      // Start loading preview
      _loadLinkPreview(url);
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Card(
        child: InkWell(
          onTap: () => widget.onLinkTap?.call(url),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (preview.title.isNotEmpty) ...[
                  Text(
                    preview.title,
                    style: theme.textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                ],
                if (preview.description.isNotEmpty) ...[
                  Text(
                    preview.description,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  preview.domain,
                  style: theme.textTheme.labelSmall!.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Load link preview data (simplified implementation)
  void _loadLinkPreview(String url) {
    if (_loadingPreviews.contains(url) || _linkPreviews.containsKey(url)) {
      return;
    }

    setState(() {
      _loadingPreviews.add(url);
    });

    // Simulate preview loading with timeout
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _loadingPreviews.remove(url);

          // Create mock preview data
          final uri = Uri.tryParse(url);
          final domain = uri?.host ?? 'Unknown';

          _linkPreviews[url] = LinkPreviewData(
            title: 'Link Preview',
            description: 'Click to visit this link',
            domain: domain,
            imageUrl: null,
          );
        });
      }
    });
  }
}

/// Types of links for different handling
enum LinkType {
  url,
  markdown,
  mention,
  hashtag,
}

/// Link preview data model
class LinkPreviewData {
  final String title;
  final String description;
  final String domain;
  final String? imageUrl;

  const LinkPreviewData({
    required this.title,
    required this.description,
    required this.domain,
    this.imageUrl,
  });
}

/// Link content model for structured link information
class LinkContent {
  final String url;
  final String displayText;
  final LinkType type;
  final Map<String, dynamic>? metadata;

  const LinkContent({
    required this.url,
    required this.displayText,
    required this.type,
    this.metadata,
  });

  factory LinkContent.fromJson(Map<String, dynamic> json) {
    return LinkContent(
      url: json['url'] ?? '',
      displayText: json['display_text'] ?? json['url'] ?? '',
      type: LinkType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => LinkType.url,
      ),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'display_text': displayText,
      'type': type.name,
      if (metadata != null) 'metadata': metadata,
    };
  }
}
