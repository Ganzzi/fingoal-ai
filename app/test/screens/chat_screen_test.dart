import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fingoal/screens/chat_screen.dart';
import 'package:fingoal/providers/chat_provider.dart';

void main() {
  group('ChatScreen Integration Tests', () {
    testWidgets('should display chat interface', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => ChatProvider(),
            child: const ChatScreen(),
          ),
        ),
      );

      // Wait for initial load and initialization
      await tester.pump();
      await tester.pump(); // Additional pump for provider initialization

      // Verify basic chat interface elements
      expect(find.text('AI Financial Assistant'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should display messages and forms',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => ChatProvider(),
            child: const ChatScreen(),
          ),
        ),
      );

      // Wait for initial load and messages to appear
      await tester.pump();
      await tester.pump(); // Additional pump for provider initialization

      // Should find welcome message
      expect(find.textContaining('Hello! I\'m your AI financial assistant'),
          findsOneWidget);

      // Should find quick action button (icon button with analytics icon)
      expect(find.byIcon(Icons.analytics), findsOneWidget);

      // Should find message input field
      expect(find.byType(TextField), findsOneWidget);

      // Should find input hint text
      expect(find.text('Ask me about your finances...'), findsOneWidget);
    });
  });
}
