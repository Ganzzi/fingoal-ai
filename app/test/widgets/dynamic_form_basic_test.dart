import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fingoal/widgets/dynamic_form_widget.dart';

void main() {
  group('DynamicFormWidget Basic Tests', () {
    testWidgets('should render basic form structure',
        (WidgetTester tester) async {
      final formJson = {
        'sections': [
          {
            'id': 'test_section',
            'title': 'Test Section',
            'recommendedProperties': ['Property 1'],
            'inputType': 'text'
          }
        ]
      };

      Map<String, String> capturedData = {};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormWidget(
              formJson: formJson,
              onFormSubmit: (data) => capturedData = data,
            ),
          ),
        ),
      );

      // Check that the form renders basic elements
      expect(find.text('Test Section'), findsOneWidget);
      expect(find.text('Property 1'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('should handle malformed JSON', (WidgetTester tester) async {
      final malformedJson = {'invalid': 'structure'};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormWidget(
              formJson: malformedJson,
              onFormSubmit: (data) {},
            ),
          ),
        ),
      );

      // Should display error
      expect(find.text('Form Error'), findsOneWidget);
    });

    testWidgets('should capture user input', (WidgetTester tester) async {
      final formJson = {
        'sections': [
          {
            'id': 'simple',
            'title': 'Simple',
            'recommendedProperties': <String>[],
            'inputType': 'text'
          }
        ]
      };

      Map<String, String> capturedData = {};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicFormWidget(
              formJson: formJson,
              onFormSubmit: (data) => capturedData = data,
            ),
          ),
        ),
      );

      // Enter text and submit
      await tester.enterText(find.byType(TextField), 'Test input');
      await tester.tap(find.text('Submit'));
      await tester.pump();

      // Verify capture
      expect(capturedData['simple'], equals('Test input'));
    });
  });
}
