import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fingoal/widgets/chat/mini_chart_renderer.dart';

void main() {
  group('MiniChartRenderer Tests', () {
    testWidgets('renders bar chart correctly', (WidgetTester tester) async {
      final chartData = ChartData(
        title: 'Monthly Expenses',
        dataPoints: [
          ChartDataPoint(label: 'Jan', value: 1200),
          ChartDataPoint(label: 'Feb', value: 1500),
          ChartDataPoint(label: 'Mar', value: 1100),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MiniChartRenderer(
              chartData: chartData,
              chartType: ChartType.bar,
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(CustomPaint), findsOneWidget);
      expect(find.text('Monthly Expenses'), findsOneWidget);
    });

    testWidgets('renders pie chart correctly', (WidgetTester tester) async {
      final chartData = ChartData(
        title: 'Budget Allocation',
        dataPoints: [
          ChartDataPoint(label: 'Housing', value: 40),
          ChartDataPoint(label: 'Food', value: 25),
          ChartDataPoint(label: 'Transport', value: 15),
          ChartDataPoint(label: 'Entertainment', value: 20),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MiniChartRenderer(
              chartData: chartData,
              chartType: ChartType.pie,
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(CustomPaint), findsOneWidget);
      expect(find.text('Budget Allocation'), findsOneWidget);
    });

    testWidgets('renders progress chart correctly',
        (WidgetTester tester) async {
      final chartData = ChartData(
        title: 'Savings Goal',
        dataPoints: [
          ChartDataPoint(label: 'Progress', value: 75, maxValue: 100),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MiniChartRenderer(
              chartData: chartData,
              chartType: ChartType.progress,
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.text('Savings Goal'), findsOneWidget);
    });

    testWidgets('renders sparkline chart correctly',
        (WidgetTester tester) async {
      final chartData = ChartData(
        title: 'Stock Trend',
        dataPoints: [
          ChartDataPoint(label: 'Day 1', value: 100),
          ChartDataPoint(label: 'Day 2', value: 105),
          ChartDataPoint(label: 'Day 3', value: 98),
          ChartDataPoint(label: 'Day 4', value: 110),
          ChartDataPoint(label: 'Day 5', value: 115),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MiniChartRenderer(
              chartData: chartData,
              chartType: ChartType.sparkline,
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(CustomPaint), findsOneWidget);
      expect(find.text('Stock Trend'), findsOneWidget);
    });

    testWidgets('applies custom width and height', (WidgetTester tester) async {
      final chartData = ChartData(
        title: 'Test Chart',
        dataPoints: [ChartDataPoint(label: 'A', value: 10)],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MiniChartRenderer(
              chartData: chartData,
              chartType: ChartType.bar,
              width: 300,
              height: 200,
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, equals(300));
    });

    testWidgets('handles empty data gracefully', (WidgetTester tester) async {
      final chartData = ChartData(
        title: 'Empty Chart',
        dataPoints: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MiniChartRenderer(
              chartData: chartData,
              chartType: ChartType.bar,
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.text('Empty Chart'), findsOneWidget);
    });

    testWidgets('shows labels when enabled', (WidgetTester tester) async {
      final chartData = ChartData(
        title: 'Label Test',
        dataPoints: [
          ChartDataPoint(label: 'A', value: 30),
          ChartDataPoint(label: 'B', value: 70),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MiniChartRenderer(
              chartData: chartData,
              chartType: ChartType.pie,
              showLabels: true,
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.text('Label Test'), findsOneWidget);
    });

    testWidgets('hides labels when disabled', (WidgetTester tester) async {
      final chartData = ChartData(
        title: 'No Labels Test',
        dataPoints: [
          ChartDataPoint(label: 'A', value: 30),
          ChartDataPoint(label: 'B', value: 70),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MiniChartRenderer(
              chartData: chartData,
              chartType: ChartType.pie,
              showLabels: false,
            ),
          ),
        ),
      );

      expect(find.text('No Labels Test'), findsOneWidget);
    });

    testWidgets('applies Material 3 theming', (WidgetTester tester) async {
      final chartData = ChartData(
        title: 'Themed Chart',
        dataPoints: [ChartDataPoint(label: 'Test', value: 50)],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: MiniChartRenderer(
              chartData: chartData,
              chartType: ChartType.bar,
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.color, isNotNull);
    });
  });

  group('ChartData Model Tests', () {
    test('creates ChartData correctly', () {
      final data = ChartData(
        title: 'Test Chart',
        dataPoints: [
          ChartDataPoint(label: 'A', value: 10),
          ChartDataPoint(label: 'B', value: 20),
        ],
      );

      expect(data.title, equals('Test Chart'));
      expect(data.dataPoints.length, equals(2));
      expect(data.dataPoints[0].label, equals('A'));
      expect(data.dataPoints[0].value, equals(10));
    });

    test('converts to/from JSON correctly', () {
      final original = ChartData(
        title: 'Pie Chart',
        dataPoints: [
          ChartDataPoint(label: 'X', value: 15),
          ChartDataPoint(label: 'Y', value: 25),
        ],
      );

      final json = original.toJson();
      final restored = ChartData.fromJson(json);

      expect(restored.title, equals(original.title));
      expect(restored.dataPoints.length, equals(original.dataPoints.length));
      expect(
          restored.dataPoints[0].label, equals(original.dataPoints[0].label));
      expect(
          restored.dataPoints[0].value, equals(original.dataPoints[0].value));
    });

    test('handles empty data list', () {
      final data = ChartData(
        title: 'Empty',
        dataPoints: [],
      );

      expect(data.dataPoints, isEmpty);
    });

    test('handles null title', () {
      final data = ChartData(
        dataPoints: [ChartDataPoint(label: 'Test', value: 1)],
      );

      expect(data.title, isNull);
      expect(data.dataPoints.length, equals(1));
    });
  });

  group('ChartDataPoint Model Tests', () {
    test('creates ChartDataPoint correctly', () {
      const point = ChartDataPoint(
        label: 'Test Label',
        value: 42.5,
        color: Colors.blue,
      );

      expect(point.label, equals('Test Label'));
      expect(point.value, equals(42.5));
      expect(point.color, equals(Colors.blue));
    });

    test('handles optional color and maxValue', () {
      const point = ChartDataPoint(
        label: 'No Color',
        value: 10,
      );

      expect(point.label, equals('No Color'));
      expect(point.value, equals(10));
      expect(point.color, isNull);
      expect(point.maxValue, isNull);
    });

    test('converts to/from JSON correctly', () {
      const original = ChartDataPoint(
        label: 'JSON Test',
        value: 99.9,
      );

      final json = original.toJson();
      final restored = ChartDataPoint.fromJson(json);

      expect(restored.label, equals(original.label));
      expect(restored.value, equals(original.value));
    });

    test('handles zero and negative values', () {
      const zeroPoint = ChartDataPoint(label: 'Zero', value: 0);
      const negativePoint = ChartDataPoint(label: 'Negative', value: -5);

      expect(zeroPoint.value, equals(0));
      expect(negativePoint.value, equals(-5));
    });

    test('handles maxValue for progress charts', () {
      const progressPoint = ChartDataPoint(
        label: 'Progress',
        value: 75,
        maxValue: 100,
      );

      expect(progressPoint.value, equals(75));
      expect(progressPoint.maxValue, equals(100));
    });
  });

  group('ChartType Enum Tests', () {
    test('contains all expected chart types', () {
      final types = ChartType.values;

      expect(types, contains(ChartType.bar));
      expect(types, contains(ChartType.pie));
      expect(types, contains(ChartType.progress));
      expect(types, contains(ChartType.sparkline));
      expect(types.length, equals(4));
    });
  });
}
