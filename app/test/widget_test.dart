// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:fingoal/main.dart';
import 'package:fingoal/providers/language_provider.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Initialize language provider for testing
    final languageProvider = LanguageProvider();
    await languageProvider.initialize();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(languageProvider: languageProvider));

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify that the login screen loads with localized content
    // Look for email field instead of app title since it should be visible
    expect(find.byType(TextFormField),
        findsAtLeast(2)); // Email and password fields

    // Verify we can find the sign in button
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
