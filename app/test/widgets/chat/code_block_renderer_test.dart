import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fingoal/widgets/chat/code_block_renderer.dart';

void main() {
  group('CodeBlockRenderer Tests', () {
    testWidgets('renders simple code block', (WidgetTester tester) async {
      const code = 'print("Hello, World!")';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CodeBlockRenderer(
              code: code,
              language: 'python',
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(RichText), findsOneWidget);

      // Check that code content is displayed
      final richTextWidget = tester.widget<RichText>(find.byType(RichText));
      final textSpan = richTextWidget.text as TextSpan;
      expect(textSpan.text, contains('print'));
    });

    testWidgets('renders JSON with syntax highlighting',
        (WidgetTester tester) async {
      const jsonCode = '{"name": "John", "age": 30}';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CodeBlockRenderer(
              code: jsonCode,
              language: 'json',
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(RichText), findsOneWidget);

      final richTextWidget = tester.widget<RichText>(find.byType(RichText));
      final textSpan = richTextWidget.text as TextSpan;
      expect(textSpan.children, isNotNull);
    });

    testWidgets('renders SQL with syntax highlighting',
        (WidgetTester tester) async {
      const sqlCode = 'SELECT * FROM users WHERE age > 25';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CodeBlockRenderer(
              code: sqlCode,
              language: 'sql',
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(RichText), findsOneWidget);

      final richTextWidget = tester.widget<RichText>(find.byType(RichText));
      final textSpan = richTextWidget.text as TextSpan;
      expect(textSpan.children, isNotNull);
    });

    testWidgets('shows copy button when enabled', (WidgetTester tester) async {
      const code = 'const x = 42;';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CodeBlockRenderer(
              code: code,
              language: 'javascript',
              showCopyButton: true,
            ),
          ),
        ),
      );

      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('hides copy button when disabled', (WidgetTester tester) async {
      const code = 'const x = 42;';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CodeBlockRenderer(
              code: code,
              language: 'javascript',
              showCopyButton: false,
            ),
          ),
        ),
      );

      expect(find.byType(IconButton), findsNothing);
      expect(find.byIcon(Icons.copy), findsNothing);
    });

    testWidgets('shows language label when provided',
        (WidgetTester tester) async {
      const code = 'print("test")';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CodeBlockRenderer(
              code: code,
              language: 'python',
              showLanguageLabel: true,
            ),
          ),
        ),
      );

      expect(find.text('python'), findsOneWidget);
    });

    testWidgets('handles Dart code highlighting', (WidgetTester tester) async {
      const dartCode = '''void main() {
  print('Hello Dart');
}''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CodeBlockRenderer(
              code: dartCode,
              language: 'dart',
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(RichText), findsOneWidget);

      final richTextWidget = tester.widget<RichText>(find.byType(RichText));
      final textSpan = richTextWidget.text as TextSpan;
      expect(textSpan.children, isNotNull);
    });

    testWidgets('handles line numbers when enabled',
        (WidgetTester tester) async {
      const multiLineCode = '''line 1
line 2
line 3''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CodeBlockRenderer(
              code: multiLineCode,
              language: 'text',
              showLineNumbers: true,
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(Row), findsOneWidget); // Line numbers + code
    });

    testWidgets('applies custom theme', (WidgetTester tester) async {
      const code = 'test code';

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: CodeBlockRenderer(
              code: code,
              language: 'text',
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, isNotNull);
    });
  });

  group('CodeBlockContent Model Tests', () {
    test('creates CodeBlockContent correctly', () {
      const content = CodeBlockContent(
        type: 'code_block',
        code: 'print("hello")',
        language: 'python',
        showLineNumbers: true,
      );

      expect(content.type, equals('code_block'));
      expect(content.code, equals('print("hello")'));
      expect(content.language, equals('python'));
      expect(content.showLineNumbers, isTrue);
    });

    test('handles optional fields', () {
      const content = CodeBlockContent(
        type: 'code_block',
        code: 'test code',
      );

      expect(content.language, isNull);
      expect(content.showLineNumbers, isFalse);
    });

    test('converts to/from JSON correctly', () {
      const original = CodeBlockContent(
        type: 'code_block',
        code: 'const x = 1;',
        language: 'javascript',
        showLineNumbers: true,
      );

      final json = original.toJson();
      final restored = CodeBlockContent.fromJson(json);

      expect(restored.type, equals(original.type));
      expect(restored.code, equals(original.code));
      expect(restored.language, equals(original.language));
      expect(restored.showLineNumbers, equals(original.showLineNumbers));
    });

    test('handles missing attributes in JSON', () {
      final json = <String, dynamic>{
        'type': 'code_block',
        'code': 'test code',
        // Missing language and showLineNumbers
      };

      final content = CodeBlockContent.fromJson(json);
      expect(content.type, equals('code_block'));
      expect(content.code, equals('test code'));
      expect(content.language, isNull);
      expect(content.showLineNumbers, isFalse);
    });

    test('handles different languages', () {
      final languages = ['json', 'sql', 'javascript', 'dart', 'python'];

      for (final lang in languages) {
        final content = CodeBlockContent(
          type: 'code_block',
          code: 'test',
          language: lang,
        );

        expect(content.language, equals(lang));
      }
    });
  });
}

/// Model class for code block content data
class CodeBlockContent {
  final String type;
  final String code;
  final String? language;
  final bool showLineNumbers;

  const CodeBlockContent({
    required this.type,
    required this.code,
    this.language,
    this.showLineNumbers = false,
  });

  factory CodeBlockContent.fromJson(Map<String, dynamic> json) {
    return CodeBlockContent(
      type: json['type'] ?? '',
      code: json['code'] ?? '',
      language: json['language'],
      showLineNumbers: json['showLineNumbers'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'code': code,
      'language': language,
      'showLineNumbers': showLineNumbers,
    };
  }
}
