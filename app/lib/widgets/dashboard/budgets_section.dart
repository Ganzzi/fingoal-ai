import 'package:flutter/material.dart';
import '../../models/dashboard_models.dart';

/// Individual budget progress card widget
class BudgetProgressCard extends StatelessWidget {
  final Budget budget;
  final VoidCallback? onTap;

  const BudgetProgressCard({
    super.key,
    required this.budget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category name and icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getColorFromHex(budget.color ?? '#6750A4')
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(budget.categoryIcon),
                      color: _getColorFromHex(budget.color ?? '#6750A4'),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      budget.categoryName,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Status indicator
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getStatusColor(budget.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Spent: ${budget.formattedSpent}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${budget.percentageUsed.toStringAsFixed(0)}%',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: budget.percentageUsed / 100,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getStatusColor(budget.status),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Budget amounts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Budget',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        budget.formattedAllocated,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Remaining',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        budget.formattedRemaining,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: budget.remaining > 0
                              ? colorScheme.primary
                              : colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorFromHex(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return const Color(0xFF6750A4); // Default Material 3 primary
    }
  }

  Color _getStatusColor(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.onTrack:
        return const Color(0xFF4CAF50); // Green
      case BudgetStatus.nearLimit:
        return const Color(0xFFFF9800); // Orange
      case BudgetStatus.overBudget:
        return const Color(0xFFF44336); // Red
    }
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'home':
        return Icons.home;
      case 'bolt':
        return Icons.bolt;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'movie':
        return Icons.movie;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'school':
        return Icons.school;
      case 'flight':
        return Icons.flight;
      case 'security':
        return Icons.security;
      case 'savings':
        return Icons.savings;
      default:
        return Icons.category;
    }
  }
}

/// Budgets section widget
class BudgetsSection extends StatelessWidget {
  final List<Budget> budgets;
  final VoidCallback? onViewAll;

  const BudgetsSection({
    super.key,
    required this.budgets,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (budgets.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Budgets',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (budgets.length > 3 && onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                child: const Text('View All'),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Budgets horizontal list
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: budgets.length > 5 ? 5 : budgets.length,
            itemBuilder: (context, index) {
              return Container(
                width: 280,
                margin: EdgeInsets.only(
                  right: index < budgets.length - 1 ? 12 : 0,
                ),
                child: BudgetProgressCard(
                  budget: budgets[index],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
                Icons.pie_chart_outline,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Budgets Set',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create budgets for your spending categories to track your expenses',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to create budget screen
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Budget'),
            ),
          ],
        ),
      ),
    );
  }
}
