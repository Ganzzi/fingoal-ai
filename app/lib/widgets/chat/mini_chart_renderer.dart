import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Mini chart renderer widget for displaying embedded data visualizations
///
/// Supports:
/// - Simple bar charts for spending categories
/// - Pie charts for budget breakdowns
/// - Progress bars for financial goals
/// - Trend indicators and sparklines
/// - Compact design suitable for chat messages
/// - Material 3 theming integration
class MiniChartRenderer extends StatelessWidget {
  final ChartData chartData;
  final ChartType chartType;
  final double? width;
  final double? height;
  final bool showLabels;
  final bool showValues;
  final Color? primaryColor;
  final List<Color>? colorPalette;

  const MiniChartRenderer({
    super.key,
    required this.chartData,
    required this.chartType,
    this.width,
    this.height,
    this.showLabels = true,
    this.showValues = false,
    this.primaryColor,
    this.colorPalette,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultWidth = width ?? 200;
    final defaultHeight = height ?? 120;

    return Container(
      width: defaultWidth,
      height: defaultHeight,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: _buildChart(context, theme),
    );
  }

  /// Build chart based on type
  Widget _buildChart(BuildContext context, ThemeData theme) {
    switch (chartType) {
      case ChartType.bar:
        return _buildBarChart(theme);
      case ChartType.pie:
        return _buildPieChart(theme);
      case ChartType.progress:
        return _buildProgressChart(theme);
      case ChartType.sparkline:
        return _buildSparklineChart(theme);
    }
  }

  /// Build simple bar chart
  Widget _buildBarChart(ThemeData theme) {
    if (chartData.dataPoints.isEmpty) return const SizedBox.shrink();

    final maxValue = chartData.dataPoints.map((d) => d.value).reduce(math.max);
    final colors = _getColorPalette(theme);

    return Column(
      children: [
        if (chartData.title?.isNotEmpty == true) ...[
          Text(
            chartData.title!,
            style: theme.textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: chartData.dataPoints.asMap().entries.map((entry) {
              final index = entry.key;
              final dataPoint = entry.value;
              final barHeight =
                  maxValue > 0 ? (dataPoint.value / maxValue * 60) : 0.0;
              final color = colors[index % colors.length];

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (showValues) ...[
                        Text(
                          dataPoint.value.toStringAsFixed(0),
                          style: theme.textTheme.labelSmall,
                        ),
                        const SizedBox(height: 2),
                      ],
                      Container(
                        width: double.infinity,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(2),
                          ),
                        ),
                      ),
                      if (showLabels) ...[
                        const SizedBox(height: 4),
                        Text(
                          dataPoint.label,
                          style: theme.textTheme.labelSmall,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Build simple pie chart
  Widget _buildPieChart(ThemeData theme) {
    if (chartData.dataPoints.isEmpty) return const SizedBox.shrink();

    final total =
        chartData.dataPoints.map((d) => d.value).reduce((a, b) => a + b);
    final colors = _getColorPalette(theme);

    return Column(
      children: [
        if (chartData.title?.isNotEmpty == true) ...[
          Text(
            chartData.title!,
            style: theme.textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
        Expanded(
          child: Row(
            children: [
              // Pie chart
              Expanded(
                flex: 2,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CustomPaint(
                    painter: PieChartPainter(
                      dataPoints: chartData.dataPoints,
                      colors: colors,
                      total: total,
                    ),
                  ),
                ),
              ),
              // Legend
              if (showLabels) ...[
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: chartData.dataPoints.asMap().entries.map((entry) {
                      final index = entry.key;
                      final dataPoint = entry.value;
                      final color = colors[index % colors.length];
                      final percentage =
                          total > 0 ? (dataPoint.value / total * 100) : 0.0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                showValues
                                    ? '${dataPoint.label} (${percentage.toStringAsFixed(0)}%)'
                                    : dataPoint.label,
                                style: theme.textTheme.labelSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Build progress chart
  Widget _buildProgressChart(ThemeData theme) {
    if (chartData.dataPoints.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (chartData.title?.isNotEmpty == true) ...[
          Text(
            chartData.title!,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
        ],
        Expanded(
          child: Column(
            children: chartData.dataPoints.map((dataPoint) {
              final progress = (dataPoint.maxValue ?? 0) > 0
                  ? (dataPoint.value / dataPoint.maxValue!).clamp(0.0, 1.0)
                  : 0.0;
              final percentage = (progress * 100).toStringAsFixed(0);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showLabels) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dataPoint.label,
                            style: theme.textTheme.bodySmall,
                          ),
                          if (showValues)
                            Text(
                              '$percentage%',
                              style: theme.textTheme.bodySmall!.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                    ],
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      color: primaryColor ?? theme.colorScheme.primary,
                      minHeight: 6,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Build sparkline chart for trends
  Widget _buildSparklineChart(ThemeData theme) {
    if (chartData.dataPoints.isEmpty) return const SizedBox.shrink();

    final color = primaryColor ?? theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (chartData.title?.isNotEmpty == true) ...[
          Text(
            chartData.title!,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
        ],
        Expanded(
          child: CustomPaint(
            painter: SparklinePainter(
              dataPoints: chartData.dataPoints,
              color: color,
              strokeWidth: 2,
            ),
            child: const SizedBox(
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ],
    );
  }

  /// Get color palette for charts
  List<Color> _getColorPalette(ThemeData theme) {
    if (colorPalette != null) return colorPalette!;

    return [
      primaryColor ?? theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.primaryContainer,
      theme.colorScheme.secondaryContainer,
      theme.colorScheme.tertiaryContainer,
    ];
  }
}

/// Custom painter for pie charts
class PieChartPainter extends CustomPainter {
  final List<ChartDataPoint> dataPoints;
  final List<Color> colors;
  final double total;

  PieChartPainter({
    required this.dataPoints,
    required this.colors,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;

    double startAngle = -math.pi / 2; // Start from top

    for (int i = 0; i < dataPoints.length; i++) {
      final dataPoint = dataPoints[i];
      final sweepAngle =
          total > 0 ? (dataPoint.value / total) * 2 * math.pi : 0.0;
      final color = colors[i % colors.length];

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Custom painter for sparkline charts
class SparklinePainter extends CustomPainter {
  final List<ChartDataPoint> dataPoints;
  final Color color;
  final double strokeWidth;

  SparklinePainter({
    required this.dataPoints,
    required this.color,
    this.strokeWidth = 2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final maxValue = dataPoints.map((d) => d.value).reduce(math.max);
    final minValue = dataPoints.map((d) => d.value).reduce(math.min);
    final valueRange = maxValue - minValue;

    final path = Path();

    for (int i = 0; i < dataPoints.length; i++) {
      final x = (i / (dataPoints.length - 1)) * size.width;
      final normalizedValue =
          valueRange > 0 ? (dataPoints[i].value - minValue) / valueRange : 0.5;
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Chart types supported by MiniChartRenderer
enum ChartType {
  bar,
  pie,
  progress,
  sparkline,
}

/// Chart data model
class ChartData {
  final String? title;
  final List<ChartDataPoint> dataPoints;
  final String? unit;
  final Map<String, dynamic>? metadata;

  const ChartData({
    this.title,
    required this.dataPoints,
    this.unit,
    this.metadata,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      title: json['title'],
      dataPoints: (json['data_points'] as List<dynamic>?)
              ?.map((point) => ChartDataPoint.fromJson(point))
              .toList() ??
          [],
      unit: json['unit'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      'data_points': dataPoints.map((point) => point.toJson()).toList(),
      if (unit != null) 'unit': unit,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// Individual data point for charts
class ChartDataPoint {
  final String label;
  final double value;
  final double? maxValue; // For progress charts
  final Color? color;
  final Map<String, dynamic>? metadata;

  const ChartDataPoint({
    required this.label,
    required this.value,
    this.maxValue,
    this.color,
    this.metadata,
  });

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      label: json['label'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      maxValue: json['max_value']?.toDouble(),
      color: json['color'] != null ? Color(json['color']) : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      if (maxValue != null) 'max_value': maxValue,
      if (color != null) 'color': color!.value,
      if (metadata != null) 'metadata': metadata,
    };
  }
}
