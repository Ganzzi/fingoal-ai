import 'package:flutter/material.dart';
import '../../models/dashboard_models.dart';

/// Individual overview card widget for key metrics
class OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const OverviewCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cardColor = color ?? colorScheme.primary;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      icon,
                      color: cardColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  value,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cardColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    subtitle!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Financial overview section widget
class FinancialOverviewSection extends StatelessWidget {
  final FinancialOverview overview;

  const FinancialOverviewSection({
    super.key,
    required this.overview,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Text(
          'Financial Overview',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        // Net worth highlight card
        Card(
          elevation: 3,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.primaryContainer.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      overview.hasPositiveNetWorth
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: colorScheme.onPrimaryContainer,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Net Worth',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  overview.formattedNetWorth,
                  style: textTheme.headlineLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Assets: ${overview.formattedTotalAssets} • Debts: ${overview.formattedTotalDebts}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Overview metrics grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            OverviewCard(
              title: 'Monthly Income',
              value: overview.formattedMonthlyIncome,
              icon: Icons.arrow_downward,
              color: const Color(0xFF4CAF50), // Green
            ),
            OverviewCard(
              title: 'Monthly Expenses',
              value: overview.formattedMonthlyExpenses,
              icon: Icons.arrow_upward,
              color: const Color(0xFFFF5722), // Red
            ),
            OverviewCard(
              title: 'Cash Flow',
              value: overview.formattedMonthlyCashFlow,
              subtitle: overview.hasPositiveCashFlow ? 'Positive' : 'Negative',
              icon: overview.hasPositiveCashFlow
                  ? Icons.trending_up
                  : Icons.trending_down,
              color: overview.hasPositiveCashFlow
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFFF5722),
            ),
            OverviewCard(
              title: 'Savings Rate',
              value: overview.formattedSavingsRate,
              subtitle:
                  _getSavingsRateDescription(overview.savingsRate.toInt()),
              icon: Icons.savings,
              color: _getSavingsRateColor(overview.savingsRate.toInt()),
            ),
          ],
        ),
      ],
    );
  }

  String _getSavingsRateDescription(int savingsRate) {
    if (savingsRate >= 20) {
      return 'Excellent';
    } else if (savingsRate >= 10) {
      return 'Good';
    } else if (savingsRate >= 5) {
      return 'Fair';
    } else if (savingsRate > 0) {
      return 'Low';
    } else {
      return 'Spending more';
    }
  }

  Color _getSavingsRateColor(int savingsRate) {
    if (savingsRate >= 20) {
      return const Color(0xFF4CAF50); // Green
    } else if (savingsRate >= 10) {
      return const Color(0xFF8BC34A); // Light green
    } else if (savingsRate >= 5) {
      return const Color(0xFFFF9800); // Orange
    } else {
      return const Color(0xFFFF5722); // Red
    }
  }
}

/// Empty financial overview widget
class EmptyFinancialOverview extends StatelessWidget {
  const EmptyFinancialOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Financial Data',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add accounts and transactions to see your financial overview',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to getting started guide
              },
              icon: const Icon(Icons.auto_graph),
              label: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
