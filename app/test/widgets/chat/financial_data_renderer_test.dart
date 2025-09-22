import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fingoal/widgets/chat/financial_data_renderer.dart';

void main() {
  group('FinancialDataRenderer Tests', () {
    testWidgets('renders currency value correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialDataRenderer(
              value: 1234.56,
              type: FinancialDataType.currency,
              currency: 'USD',
            ),
          ),
        ),
      );

      expect(find.textContaining('\$1,234.56'), findsOneWidget);
    });

    testWidgets('renders percentage value correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialDataRenderer(
              value: 15.5,
              type: FinancialDataType.percentage,
            ),
          ),
        ),
      );

      expect(find.text('15.5%'), findsOneWidget);
    });

    testWidgets('renders VND currency without decimals',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialDataRenderer(
              value: 50000,
              type: FinancialDataType.currency,
              currency: 'VND',
            ),
          ),
        ),
      );

      expect(find.textContaining('₫50,000'), findsOneWidget);
    });

    testWidgets('renders compact currency format', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialDataRenderer(
              value: 1500000,
              type: FinancialDataType.currency,
              currency: 'USD',
              compact: true,
            ),
          ),
        ),
      );

      expect(find.text('\$1.5M'), findsOneWidget);
    });

    testWidgets('shows trend indicator when comparison value provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialDataRenderer(
              value: 1200,
              type: FinancialDataType.currency,
              currency: 'USD',
              comparisonValue: 1000,
              showTrend: true,
            ),
          ),
        ),
      );

      expect(find.textContaining('\$1,200'), findsOneWidget);
      expect(find.textContaining('20.0%'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('shows negative trend correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialDataRenderer(
              value: 800,
              type: FinancialDataType.currency,
              currency: 'USD',
              comparisonValue: 1000,
              showTrend: true,
            ),
          ),
        ),
      );

      expect(find.textContaining('\$800'), findsOneWidget);
      expect(find.textContaining('20.0%'), findsOneWidget);
      expect(find.byIcon(Icons.trending_down), findsOneWidget);
    });

    testWidgets('handles zero change correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialDataRenderer(
              value: 1000,
              type: FinancialDataType.currency,
              currency: 'USD',
              comparisonValue: 1000,
              showTrend: true,
            ),
          ),
        ),
      );

      expect(find.textContaining('\$1,000'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
    });

    testWidgets('renders change type correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialDataRenderer(
              value: 5.25,
              type: FinancialDataType.change,
            ),
          ),
        ),
      );

      expect(find.textContaining('+'), findsOneWidget);
      expect(find.textContaining('5.25'), findsOneWidget);
    });

    testWidgets('renders large numbers correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialDataRenderer(
              value: 1234567,
              type: FinancialDataType.number,
            ),
          ),
        ),
      );

      expect(find.textContaining('1,234,567'), findsOneWidget);
    });
  });

  group('FinancialDataContent Model Tests', () {
    test('creates FinancialDataContent from JSON correctly', () {
      final json = {
        'value': 1500.50,
        'type': 'currency',
        'currency': 'USD',
        'label': 'Monthly Budget',
        'comparison_value': 1400.00,
        'metadata': {'category': 'budget'},
      };

      final content = FinancialDataContent.fromJson(json);

      expect(content.value, equals(1500.50));
      expect(content.type, equals(FinancialDataType.currency));
      expect(content.currency, equals('USD'));
      expect(content.label, equals('Monthly Budget'));
      expect(content.comparisonValue, equals(1400.00));
      expect(content.metadata?['category'], equals('budget'));
    });

    test('converts FinancialDataContent to JSON correctly', () {
      const content = FinancialDataContent(
        value: 1500.50,
        type: FinancialDataType.currency,
        currency: 'USD',
        label: 'Monthly Budget',
        comparisonValue: 1400.00,
        metadata: {'category': 'budget'},
      );

      final json = content.toJson();

      expect(json['value'], equals(1500.50));
      expect(json['type'], equals('currency'));
      expect(json['currency'], equals('USD'));
      expect(json['label'], equals('Monthly Budget'));
      expect(json['comparison_value'], equals(1400.00));
      expect(json['metadata']['category'], equals('budget'));
    });

    test('handles unknown type correctly', () {
      final json = {
        'value': 100,
        'type': 'unknown_type',
      };

      final content = FinancialDataContent.fromJson(json);

      expect(content.value, equals(100));
      expect(content.type, equals(FinancialDataType.number));
    });
  });

  group('FinancialProgressIndicator Tests', () {
    testWidgets('renders progress indicator correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialProgressIndicator(
              currentValue: 750,
              targetValue: 1000,
              label: 'Savings Goal',
              showPercentage: true,
            ),
          ),
        ),
      );

      expect(find.text('Savings Goal'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('handles over 100% progress correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialProgressIndicator(
              currentValue: 1200,
              targetValue: 1000,
              label: 'Over Target',
              showPercentage: true,
            ),
          ),
        ),
      );

      expect(find.text('Over Target'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('handles zero target correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialProgressIndicator(
              currentValue: 500,
              targetValue: 0,
              label: 'Zero Target',
              showPercentage: true,
            ),
          ),
        ),
      );

      expect(find.text('Zero Target'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('hides percentage when showPercentage is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialProgressIndicator(
              currentValue: 500,
              targetValue: 1000,
              label: 'No Percentage',
              showPercentage: false,
            ),
          ),
        ),
      );

      expect(find.text('No Percentage'), findsOneWidget);
      expect(find.text('50%'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('works without label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialProgressIndicator(
              currentValue: 300,
              targetValue: 1000,
              showPercentage: true,
            ),
          ),
        ),
      );

      expect(find.text('30%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
