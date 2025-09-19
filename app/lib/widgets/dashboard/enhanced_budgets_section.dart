import 'package:flutter/material.dart';
import '../../models/dashboard_models.dart';
import '../../models/rich_message_models.dart';

/// Enhanced budget list item with dashboard item selection capability
class SelectableBudgetListItem extends StatelessWidget {
  final Budget budget;
  final bool isSelectable;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Function(Budget)? onAddToChat;

  const SelectableBudgetListItem({
    super.key,
    required this.budget,
    this.isSelectable = false,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
    this.onAddToChat,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Get status color
    final statusColor = _getStatusColor(budget.status);
    final progressColor = statusColor.withOpacity(0.8);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color:
            isSelected ? colorScheme.primaryContainer.withOpacity(0.3) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        contentPadding: const EdgeInsets.all(16),

        // Selection indicator or category icon
        leading: isSelectable
            ? Checkbox(
                value: isSelected,
                onChanged: (_) => onTap?.call(),
                shape: const CircleBorder(),
              )
            : Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(budget.categoryIcon),
                  color: progressColor,
                  size: 24,
                ),
              ),

        title: Text(
          budget.categoryName,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Progress bar
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (budget.percentageUsed / 100).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Amount details
            Text(
              '${budget.formattedSpent} of ${budget.formattedAllocated}',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status and percentage
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${budget.percentageUsed.toInt()}%',
                    style: textTheme.labelMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  budget.status.displayName,
                  style: textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            // Add to chat button (when not in selection mode)
            if (!isSelectable && onAddToChat != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => onAddToChat!(budget),
                icon: const Icon(Icons.chat_bubble_outline),
                tooltip: 'Add to Chat',
                iconSize: 20,
                visualDensity: VisualDensity.compact,
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainer,
                  foregroundColor: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
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
        return Icons.account_balance_wallet;
    }
  }
}

/// Enhanced budgets section with dashboard item selection support
class EnhancedBudgetsSection extends StatefulWidget {
  final List<Budget> budgets;
  final VoidCallback? onViewAll;
  final Function(BudgetDashboardItem)? onAddBudgetToChat;

  const EnhancedBudgetsSection({
    super.key,
    required this.budgets,
    this.onViewAll,
    this.onAddBudgetToChat,
  });

  @override
  State<EnhancedBudgetsSection> createState() => _EnhancedBudgetsSectionState();
}

class _EnhancedBudgetsSectionState extends State<EnhancedBudgetsSection> {
  bool _isSelectionMode = false;
  final Set<String> _selectedBudgetIds = <String>{};

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedBudgetIds.clear();
      }
    });
  }

  void _toggleBudgetSelection(String budgetId) {
    setState(() {
      if (_selectedBudgetIds.contains(budgetId)) {
        _selectedBudgetIds.remove(budgetId);
      } else {
        _selectedBudgetIds.add(budgetId);
      }
    });
  }

  void _addSelectedBudgetsToChat() {
    if (widget.onAddBudgetToChat == null) return;

    final selectedBudgets =
        widget.budgets.where((b) => _selectedBudgetIds.contains(b.id)).toList();

    for (final budget in selectedBudgets) {
      final dashboardItem = BudgetDashboardItem.fromBudget(budget);
      widget.onAddBudgetToChat!(dashboardItem);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${selectedBudgets.length} budget(s) to chat'),
      ),
    );

    _toggleSelectionMode();
  }

  void _addSingleBudgetToChat(Budget budget) {
    if (widget.onAddBudgetToChat == null) return;

    final dashboardItem = BudgetDashboardItem.fromBudget(budget);
    widget.onAddBudgetToChat!(dashboardItem);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Budget added to chat'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.budgets.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with selection controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isSelectionMode
                  ? 'Select Budgets (${_selectedBudgetIds.length})'
                  : 'Budget Overview',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                if (_isSelectionMode) ...[
                  // Add selected to chat button
                  if (_selectedBudgetIds.isNotEmpty)
                    IconButton(
                      onPressed: _addSelectedBudgetsToChat,
                      icon: const Icon(Icons.chat_bubble),
                      tooltip: 'Add to Chat',
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.primaryContainer,
                        foregroundColor: colorScheme.onPrimaryContainer,
                      ),
                    ),

                  // Cancel selection button
                  IconButton(
                    onPressed: _toggleSelectionMode,
                    icon: const Icon(Icons.close),
                    tooltip: 'Cancel Selection',
                  ),
                ] else ...[
                  // Selection mode toggle button
                  if (widget.onAddBudgetToChat != null)
                    IconButton(
                      onPressed: _toggleSelectionMode,
                      icon: const Icon(Icons.checklist),
                      tooltip: 'Select Multiple',
                    ),

                  // View all button
                  if (widget.onViewAll != null)
                    TextButton(
                      onPressed: widget.onViewAll,
                      child: const Text('View All'),
                    ),
                ],
              ],
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Budgets list
        Card(
          elevation: 1,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.budgets.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final budget = widget.budgets[index];

              return SelectableBudgetListItem(
                budget: budget,
                isSelectable: _isSelectionMode,
                isSelected: _selectedBudgetIds.contains(budget.id),
                onTap: _isSelectionMode
                    ? () => _toggleBudgetSelection(budget.id)
                    : null,
                onLongPress: !_isSelectionMode ? _toggleSelectionMode : null,
                onAddToChat: !_isSelectionMode ? _addSingleBudgetToChat : null,
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
                Icons.account_balance_wallet_outlined,
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
              'Create budgets to track your spending in different categories',
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
