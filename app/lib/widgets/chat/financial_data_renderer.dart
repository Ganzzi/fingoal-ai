import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Financial data renderer widget for displaying currency, percentages, and financial metrics
///
/// Provides locale-aware formatting for:
/// - Currency values (USD, VND, EUR, etc.)
/// - Percentages with precision control
/// - Financial trends with color indicators
/// - Large numbers with thousand separators
/// - Comparison values and changes
///
/// Integrates with Material 3 design system and supports responsive layouts
class FinancialDataRenderer extends StatelessWidget {
  final double value;
  final FinancialDataType type;
  final String? currency;
  final String? locale;
  final int? decimalPlaces;
  final double? comparisonValue;
  final bool showTrend;
  final bool compact;
  final TextStyle? textStyle;
  final Color? positiveColor;
  final Color? negativeColor;

  const FinancialDataRenderer({
    super.key,
    required this.value,
    required this.type,
    this.currency = 'USD',
    this.locale = 'en_US',
    this.decimalPlaces,
    this.comparisonValue,
    this.showTrend = false,
    this.compact = false,
    this.textStyle,
    this.positiveColor,
    this.negativeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultTextStyle = textStyle ?? theme.textTheme.bodyLarge!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMainValue(context, defaultTextStyle),
        if (showTrend && comparisonValue != null) ...[
          const SizedBox(width: 8),
          _buildTrendIndicator(context),
        ],
      ],
    );
  }

  /// Build the main financial value display
  Widget _buildMainValue(BuildContext context, TextStyle style) {
    final theme = Theme.of(context);
    String formattedValue;
    Color? valueColor;

    switch (type) {
      case FinancialDataType.currency:
        formattedValue = _formatCurrency(value);
        break;
      case FinancialDataType.percentage:
        formattedValue = _formatPercentage(value);
        valueColor = _getPercentageColor(value, theme);
        break;
      case FinancialDataType.number:
        formattedValue = _formatNumber(value);
        break;
      case FinancialDataType.change:
        formattedValue = _formatChange(value);
        valueColor = _getChangeColor(value, theme);
        break;
    }

    return Text(
      formattedValue,
      style: style.copyWith(
        color: valueColor,
        fontWeight: FontWeight.w600,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  /// Build trend indicator with arrow and comparison
  Widget _buildTrendIndicator(BuildContext context) {
    if (comparisonValue == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final change = value - comparisonValue!;
    final isPositive = change > 0;

    if (change == 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.remove,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 2),
          Text(
            '0%',
            style: theme.textTheme.bodySmall!.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    final trendColor = isPositive
        ? (positiveColor ?? theme.colorScheme.primary)
        : (negativeColor ?? theme.colorScheme.error);

    final trendIcon = isPositive ? Icons.trending_up : Icons.trending_down;
    final percentChange = ((change / comparisonValue!.abs()) * 100).abs();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          trendIcon,
          size: 16,
          color: trendColor,
        ),
        const SizedBox(width: 2),
        Text(
          '${percentChange.toStringAsFixed(1)}%',
          style: theme.textTheme.bodySmall!.copyWith(
            color: trendColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Format currency value with proper locale and symbol
  String _formatCurrency(double value) {
    try {
      final formatter = NumberFormat.currency(
        locale: locale,
        symbol: _getCurrencySymbol(currency ?? 'USD'),
        decimalDigits:
            decimalPlaces ?? _getDefaultDecimalPlaces(currency ?? 'USD'),
      );

      if (compact && value.abs() >= 1000) {
        return _formatCompactCurrency(value);
      }

      return formatter.format(value);
    } catch (e) {
      // Fallback formatting
      return '${_getCurrencySymbol(currency ?? 'USD')}${value.toStringAsFixed(decimalPlaces ?? 2)}';
    }
  }

  /// Format percentage with proper precision
  String _formatPercentage(double value) {
    final precision = decimalPlaces ?? 1;
    return '${value.toStringAsFixed(precision)}%';
  }

  /// Format large numbers with thousand separators
  String _formatNumber(double value) {
    try {
      final formatter = NumberFormat('#,##0', locale);

      if (compact && value.abs() >= 1000) {
        return _formatCompactNumber(value);
      }

      return formatter.format(value);
    } catch (e) {
      return value.toStringAsFixed(decimalPlaces ?? 0);
    }
  }

  /// Format change value with proper sign
  String _formatChange(double value) {
    final sign = value >= 0 ? '+' : '';

    if (type == FinancialDataType.percentage) {
      return '$sign${_formatPercentage(value)}';
    } else {
      return '$sign${_formatCurrency(value)}';
    }
  }

  /// Format compact currency for large values
  String _formatCompactCurrency(double value) {
    final symbol = _getCurrencySymbol(currency ?? 'USD');

    if (value.abs() >= 1000000) {
      return '$symbol${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value.abs() >= 1000) {
      return '$symbol${(value / 1000).toStringAsFixed(1)}K';
    }

    return _formatCurrency(value);
  }

  /// Format compact numbers for large values
  String _formatCompactNumber(double value) {
    if (value.abs() >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value.abs() >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    return value.toStringAsFixed(0);
  }

  /// Get currency symbol for given currency code
  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'VND':
        return '₫';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'CNY':
        return '¥';
      default:
        return currencyCode;
    }
  }

  /// Get default decimal places for currency
  int _getDefaultDecimalPlaces(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'VND':
      case 'JPY':
        return 0;
      default:
        return 2;
    }
  }

  /// Get color for percentage values
  Color? _getPercentageColor(double value, ThemeData theme) {
    if (value > 0) {
      return positiveColor ?? theme.colorScheme.primary;
    } else if (value < 0) {
      return negativeColor ?? theme.colorScheme.error;
    }
    return null;
  }

  /// Get color for change values
  Color? _getChangeColor(double value, ThemeData theme) {
    if (value > 0) {
      return positiveColor ?? theme.colorScheme.primary;
    } else if (value < 0) {
      return negativeColor ?? theme.colorScheme.error;
    }
    return theme.colorScheme.onSurfaceVariant;
  }
}

/// Types of financial data for appropriate formatting
enum FinancialDataType {
  currency,
  percentage,
  number,
  change,
}

/// Financial data content model for structured financial information
class FinancialDataContent {
  final double value;
  final FinancialDataType type;
  final String? currency;
  final String? label;
  final double? comparisonValue;
  final Map<String, dynamic>? metadata;

  const FinancialDataContent({
    required this.value,
    required this.type,
    this.currency,
    this.label,
    this.comparisonValue,
    this.metadata,
  });

  factory FinancialDataContent.fromJson(Map<String, dynamic> json) {
    return FinancialDataContent(
      value: (json['value'] ?? 0).toDouble(),
      type: FinancialDataType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => FinancialDataType.number,
      ),
      currency: json['currency'],
      label: json['label'],
      comparisonValue: json['comparison_value']?.toDouble(),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'type': type.name,
      if (currency != null) 'currency': currency,
      if (label != null) 'label': label,
      if (comparisonValue != null) 'comparison_value': comparisonValue,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// Financial progress indicator widget
class FinancialProgressIndicator extends StatelessWidget {
  final double currentValue;
  final double targetValue;
  final String? label;
  final Color? progressColor;
  final Color? backgroundColor;
  final bool showPercentage;

  const FinancialProgressIndicator({
    super.key,
    required this.currentValue,
    required this.targetValue,
    this.label,
    this.progressColor,
    this.backgroundColor,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress =
        targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.bodySmall!.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor:
                    backgroundColor ?? theme.colorScheme.surfaceVariant,
                color: progressColor ?? theme.colorScheme.primary,
                minHeight: 8,
              ),
            ),
            if (showPercentage) ...[
              const SizedBox(width: 8),
              Text(
                '$percentage%',
                style: theme.textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
