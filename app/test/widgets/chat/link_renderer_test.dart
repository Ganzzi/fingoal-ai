import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fingoal/widgets/chat/link_renderer.dart';

void main() {
  group('LinkRenderer Tests', () {
    testWidgets('renders plain text without links',
        (WidgetTester tester) async {
      const plainText = 'This is plain text without any links.';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkRenderer(text: plainText),
          ),
        ),
      );

      expect(find.byType(RichText), findsOneWidget);

      final richTextWidget = tester.widget<RichText>(find.byType(RichText));
      final textSpan = richTextWidget.text as TextSpan;
      expect(textSpan.text, contains('This is plain text'));
    });

    testWidgets('detects and renders URL links', (WidgetTester tester) async {
      const textWithUrl = 'Visit https://google.com for search.';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkRenderer(text: textWithUrl),
          ),
        ),
      );

      expect(find.byType(RichText), findsOneWidget);

      final richTextWidget = tester.widget<RichText>(find.byType(RichText));
      final textSpan = richTextWidget.text as TextSpan;
      expect(textSpan.children, isNotNull);
      expect(textSpan.children!.length, greaterThan(1));
    });

    testWidgets('renders markdown links', (WidgetTester tester) async {
      const markdownLink = 'Check out [Google](https://google.com) here.';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkRenderer(text: markdownLink),
          ),
        ),
      );

      expect(find.byType(RichText), findsOneWidget);

      final richTextWidget = tester.widget<RichText>(find.byType(RichText));
      final textSpan = richTextWidget.text as TextSpan;
      expect(textSpan.children, isNotNull);
      expect(textSpan.children!.length, greaterThan(1));
    });

    testWidgets('handles multiple links in text', (WidgetTester tester) async {
      const multipleLinks =
          'Visit https://google.com and [GitHub](https://github.com).';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkRenderer(text: multipleLinks),
          ),
        ),
      );

      expect(find.byType(RichText), findsOneWidget);

      final richTextWidget = tester.widget<RichText>(find.byType(RichText));
      final textSpan = richTextWidget.text as TextSpan;
      expect(textSpan.children, isNotNull);
      expect(textSpan.children!.length,
          greaterThan(3)); // Multiple spans for links
    });

    testWidgets('applies custom text style', (WidgetTester tester) async {
      const textWithLink = 'Visit https://google.com';
      const customStyle = TextStyle(fontSize: 18, color: Colors.blue);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkRenderer(
              text: textWithLink,
              textStyle: customStyle,
            ),
          ),
        ),
      );

      expect(find.byType(RichText), findsOneWidget);

      final richTextWidget = tester.widget<RichText>(find.byType(RichText));
      final textSpan = richTextWidget.text as TextSpan;
      expect(textSpan.style?.fontSize, equals(18));
    });
  });

  group('LinkRendererWithPreview Tests', () {
    testWidgets('renders content with preview support',
        (WidgetTester tester) async {
      const content = 'Check https://google.com';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkRendererWithPreview(text: content),
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('shows preview card when enabled', (WidgetTester tester) async {
      const content = 'Visit https://example.com';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkRendererWithPreview(
              text: content,
              showPreview: true,
            ),
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('hides preview when disabled', (WidgetTester tester) async {
      const content = 'Visit https://example.com';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkRendererWithPreview(
              text: content,
              showPreview: false,
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsNothing);
    });
  });

  group('LinkContent Model Tests', () {
    test('creates LinkContent correctly', () {
      const content = LinkContent(
        type: 'link',
        url: 'https://google.com',
        displayText: 'Google',
        preview: true,
      );

      expect(content.type, equals('link'));
      expect(content.url, equals('https://google.com'));
      expect(content.displayText, equals('Google'));
      expect(content.preview, isTrue);
    });

    test('handles optional fields', () {
      const content = LinkContent(
        type: 'link',
        url: 'https://google.com',
      );

      expect(content.displayText, isNull);
      expect(content.preview, isFalse);
    });

    test('converts to/from JSON correctly', () {
      const original = LinkContent(
        type: 'link',
        url: 'https://google.com',
        displayText: 'Google',
        preview: true,
      );

      final json = original.toJson();
      final restored = LinkContent.fromJson(json);

      expect(restored.type, equals(original.type));
      expect(restored.url, equals(original.url));
      expect(restored.displayText, equals(original.displayText));
      expect(restored.preview, equals(original.preview));
    });

    test('handles missing attributes in JSON', () {
      final json = <String, dynamic>{
        'type': 'link',
        'url': 'https://example.com',
        // Missing displayText and preview
      };

      final content = LinkContent.fromJson(json);
      expect(content.type, equals('link'));
      expect(content.url, equals('https://example.com'));
      expect(content.displayText, isNull);
      expect(content.preview, isFalse);
    });
  });
}

/// Model class for link content data
class LinkContent {
  final String type;
  final String url;
  final String? displayText;
  final bool preview;

  const LinkContent({
    required this.type,
    required this.url,
    this.displayText,
    this.preview = false,
  });

  factory LinkContent.fromJson(Map<String, dynamic> json) {
    return LinkContent(
      type: json['type'] ?? '',
      url: json['url'] ?? '',
      displayText: json['displayText'],
      preview: json['preview'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'url': url,
      'displayText': displayText,
      'preview': preview,
    };
  }
}
