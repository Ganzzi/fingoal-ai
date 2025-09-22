import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fingoal/widgets/chat/rich_text_renderer.dart';

void main() {
  group('RichTextRenderer Tests', () {
    testWidgets('renders plain text correctly', (WidgetTester tester) async {
      const plainText = 'Hello, this is plain text.';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RichTextRenderer(
              content: plainText,
            ),
          ),
        ),
      );

      // RichTextRenderer returns a Column, check for the structure
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(RichText), findsOneWidget);

      // Check the actual text content in RichText
      final richTextWidget = tester.widget<RichText>(find.byType(RichText));
      final textSpan = richTextWidget.text as TextSpan;
      expect(textSpan.text, contains('Hello, this is plain text.'));
    });

    testWidgets('renders bold text correctly', (WidgetTester tester) async {
      const boldText = 'This is **bold** text.';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RichTextRenderer(
              content: boldText,
            ),
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(RichText), findsOneWidget);

      // Check that RichText has formatted content with children
      final richTextWidget = tester.widget<RichText>(find.byType(RichText));
      final textSpan = richTextWidget.text as TextSpan;
      expect(textSpan.children, isNotNull);
      expect(textSpan.children!.length, greaterThan(1));
    });

    testWidgets('renders italic text correctly', (WidgetTester tester) async {
      const italicText = 'This is *italic* text.';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RichTextRenderer(
              content: italicText,
            ),
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(RichText), findsOneWidget);

      final richTextWidget = tester.widget<RichText>(find.byType(RichText));
      final textSpan = richTextWidget.text as TextSpan;
      expect(textSpan.children, isNotNull);
      expect(textSpan.children!.length, greaterThan(1));
    });

    testWidgets('renders headings correctly', (WidgetTester tester) async {
      const headingText = '''# Main Heading
## Sub Heading
Regular text''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RichTextRenderer(
              content: headingText,
            ),
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      // Should have Text widgets for headings
      expect(find.text('Main Heading'), findsOneWidget);
      expect(find.text('Sub Heading'), findsOneWidget);
      // And RichText for regular content
      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('renders bullet points correctly', (WidgetTester tester) async {
      const bulletText = '''- First item
- Second item
- Third item''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RichTextRenderer(
              content: bulletText,
            ),
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      // Each bullet point creates a Row
      expect(find.byType(Row), findsNWidgets(3));
      // Check for bullet characters
      expect(find.text('• '), findsNWidgets(3));
    });

    testWidgets('renders numbered lists correctly',
        (WidgetTester tester) async {
      const numberedText = '''1. First step
2. Second step
3. Third step''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RichTextRenderer(
              content: numberedText,
            ),
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      // Each numbered item creates a Row
      expect(find.byType(Row), findsNWidgets(3));
    });

    testWidgets('renders links correctly', (WidgetTester tester) async {
      const linkText = 'Visit [Google](https://google.com) for search.';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RichTextRenderer(
              content: linkText,
            ),
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(RichText), findsOneWidget);

      // Check that RichText has clickable content
      final richTextWidget = tester.widget<RichText>(find.byType(RichText));
      final textSpan = richTextWidget.text as TextSpan;
      expect(textSpan.children, isNotNull);
      expect(textSpan.children!.length, greaterThan(1));
    });

    testWidgets('handles mixed formatting correctly',
        (WidgetTester tester) async {
      const mixedText = '''# Heading
This is **bold** and *italic* text.
- Bullet point
1. Numbered item''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RichTextRenderer(
              content: mixedText,
            ),
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      // Should have heading Text, paragraph RichText, bullet Row, numbered Row
      expect(find.text('Heading'), findsOneWidget);
      expect(find.byType(RichText), findsOneWidget);
      expect(find.byType(Row), findsNWidgets(2));
      expect(find.text('• '), findsOneWidget);
    });

    testWidgets('applies custom text style', (WidgetTester tester) async {
      const customText = 'Custom styled text';
      const customStyle = TextStyle(
        fontSize: 20,
        color: Colors.red,
        fontWeight: FontWeight.bold,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RichTextRenderer(
              content: customText,
              baseStyle: customStyle,
            ),
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(RichText), findsOneWidget);

      final richTextWidget = tester.widget<RichText>(find.byType(RichText));
      final textSpan = richTextWidget.text as TextSpan;
      expect(textSpan.style?.fontSize, equals(20));
      expect(textSpan.style?.color, equals(Colors.red));
      expect(textSpan.style?.fontWeight, equals(FontWeight.bold));
    });
  });

  group('RichTextContent Model Tests', () {
    test('creates RichTextContent correctly', () {
      const content = RichTextContent(
        type: 'rich_text',
        text: 'Test content',
        formatting: ['bold', 'italic'],
      );

      expect(content.type, equals('rich_text'));
      expect(content.text, equals('Test content'));
      expect(content.formatting, contains('bold'));
      expect(content.formatting, contains('italic'));
    });

    test('handles null formatting', () {
      const content = RichTextContent(
        type: 'rich_text',
        text: 'Test content',
      );

      expect(content.formatting, isEmpty);
    });

    test('converts to/from JSON correctly', () {
      const original = RichTextContent(
        type: 'rich_text',
        text: 'Test content',
        formatting: ['bold'],
      );

      final json = original.toJson();
      final restored = RichTextContent.fromJson(json);

      expect(restored.type, equals(original.type));
      expect(restored.text, equals(original.text));
      expect(restored.formatting, equals(original.formatting));
    });

    test('handles missing attributes correctly', () {
      final json = <String, dynamic>{
        'type': 'rich_text',
        'text': 'Test content',
        // Missing formatting attribute
      };

      final content = RichTextContent.fromJson(json);
      expect(content.type, equals('rich_text'));
      expect(content.text, equals('Test content'));
      expect(content.formatting, isEmpty);
    });

    test('handles unknown type correctly', () {
      final json = <String, dynamic>{
        'type': 'unknown_type',
        'text': 'Test content',
        'formatting': ['bold'],
      };

      final content = RichTextContent.fromJson(json);
      expect(content.type, equals('unknown_type'));
      expect(content.text, equals('Test content'));
      expect(content.formatting, contains('bold'));
    });
  });
}

/// Model class for rich text content data
class RichTextContent {
  final String type;
  final String text;
  final List<String> formatting;

  const RichTextContent({
    required this.type,
    required this.text,
    this.formatting = const [],
  });

  factory RichTextContent.fromJson(Map<String, dynamic> json) {
    return RichTextContent(
      type: json['type'] ?? '',
      text: json['text'] ?? '',
      formatting: List<String>.from(json['formatting'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'text': text,
      'formatting': formatting,
    };
  }
}
