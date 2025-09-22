import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fingoal/widgets/dynamic_form_widget.dart';

void main() {
  group('DynamicFormWidget Tests', () {
    late Map<String, dynamic> validFormJson;
    late Map<String, String> capturedSubmission;

    setUp(() {
      validFormJson = {
        'sections': [
          {
            'id': 'money_accounts',
            'title': 'Money Accounts',
            'recommendedProperties': ['Bank Name', 'Account Type', 'Balance'],
            'inputType': 'text'
          },
          {
            'id': 'debts',
            'title': 'Debts',
            'recommendedProperties': ['Creditor', 'Amount Owed'],
            'inputType': 'text'
          }
        ]
      };
      capturedSubmission = {};
    });

    Widget createTestWidget(Map<String, dynamic> formJson) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: DynamicFormWidget(
              formJson: formJson,
              onFormSubmit: (data) {
                capturedSubmission = data;
              },
            ),
          ),
        ),
      );
    }

    testWidgets('should render form sections correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(validFormJson));

      // Check that section titles are displayed
      expect(find.text('Money Accounts'), findsOneWidget);
      expect(find.text('Debts'), findsOneWidget);

      // Check that recommended properties are displayed
      expect(find.text('Bank Name'), findsOneWidget);
      expect(find.text('Account Type'), findsOneWidget);
      expect(find.text('Balance'), findsOneWidget);
      expect(find.text('Creditor'), findsOneWidget);
      expect(find.text('Amount Owed'), findsOneWidget);

      // Check that text input fields are present
      expect(find.byType(TextField), findsNWidgets(2));

      // Check that submit button is present
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('should handle malformed JSON gracefully',
        (WidgetTester tester) async {
      final malformedJson = {'invalid': 'structure'};

      await tester.pumpWidget(createTestWidget(malformedJson));

      // Should display error message
      expect(find.text('Form Error'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should capture user input correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(validFormJson));

      // Enter text in the first input field
      final firstTextField = find.byType(TextField).first;
      await tester.enterText(firstTextField, 'Chase Bank, Checking, \$5000');

      // Enter text in the second input field
      final secondTextField = find.byType(TextField).last;
      await tester.enterText(secondTextField, 'Credit Card, \$2000');

      // Tap submit button (should be visible and tappable)
      await tester.tap(find.text('Submit'));
      await tester.pump();

      // Verify that form submission was captured
      expect(capturedSubmission.length, equals(2));
      expect(capturedSubmission['money_accounts'],
          equals('Chase Bank, Checking, \$5000'));
      expect(capturedSubmission['debts'], equals('Credit Card, \$2000'));
    });

    testWidgets('should show validation message for empty fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(validFormJson));

      // Try to submit without filling any fields
      await tester.tap(find.text('Submit'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Should show snackbar with validation message
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Please fill in all sections before submitting'),
          findsOneWidget);

      // Form submission should not have been called
      expect(capturedSubmission.isEmpty, isTrue);
    });

    testWidgets('should allow partial filling and then complete submission',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(validFormJson));

      // Fill only the first field
      final firstTextField = find.byType(TextField).first;
      await tester.enterText(firstTextField, 'Bank information');

      // Try to submit
      await tester.tap(find.text('Submit'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Should show validation message
      expect(find.byType(SnackBar), findsOneWidget);

      // Wait for snackbar to dismiss
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Fill the second field
      final secondTextField = find.byType(TextField).last;
      await tester.enterText(secondTextField, 'Debt information');

      // Now submit should work
      await tester.tap(find.text('Submit'));
      await tester.pump();

      // Verify successful submission
      expect(capturedSubmission.length, equals(2));
      expect(capturedSubmission['money_accounts'], equals('Bank information'));
      expect(capturedSubmission['debts'], equals('Debt information'));
    });

    testWidgets('should display suggested information correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(validFormJson));

      // Check that suggested information section is displayed
      expect(find.text('Suggested information to include:'), findsNWidgets(2));

      // Check for bullet points (using the bullet character)
      expect(find.textContaining('•'), findsWidgets);
    });

    testWidgets('should handle form with no recommended properties',
        (WidgetTester tester) async {
      final jsonWithoutProps = {
        'sections': [
          {
            'id': 'simple_section',
            'title': 'Simple Section',
            'recommendedProperties': <String>[],
            'inputType': 'text'
          }
        ]
      };

      await tester.pumpWidget(createTestWidget(jsonWithoutProps));

      // Should still render the section title and input field
      expect(find.text('Simple Section'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Should not show suggested information section
      expect(find.text('Suggested information to include:'), findsNothing);
    });

    testWidgets('should handle single section form',
        (WidgetTester tester) async {
      final singleSectionJson = {
        'sections': [
          {
            'id': 'single',
            'title': 'Single Section',
            'recommendedProperties': ['Property 1', 'Property 2'],
            'inputType': 'text'
          }
        ]
      };

      await tester.pumpWidget(createTestWidget(singleSectionJson));

      expect(find.text('Single Section'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Property 1'), findsOneWidget);
      expect(find.text('Property 2'), findsOneWidget);

      // Fill the field and submit
      await tester.enterText(find.byType(TextField), 'Test input');
      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(capturedSubmission.length, equals(1));
      expect(capturedSubmission['single'], equals('Test input'));
    });
  });
}
