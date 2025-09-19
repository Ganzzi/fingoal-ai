import 'package:flutter/material.dart';
import '../../models/dashboard_models.dart';
import '../../models/rich_message_models.dart';

/// Enhanced transaction list item with dashboard item selection capability
class SelectableTransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final bool isSelectable;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Function(Transaction)? onAddToChat;

  const SelectableTransactionListItem({
    super.key,
    required this.transaction,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

        // Selection indicator
        leading: isSelectable
            ? Checkbox(
                value: isSelected,
                onChanged: (_) => onTap?.call(),
                shape: const CircleBorder(),
              )
            : Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getCategoryColor(transaction.categoryColor)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(transaction.displayCategoryIcon),
                  color: _getCategoryColor(transaction.categoryColor),
                  size: 20,
                ),
              ),

        title: Text(
          transaction.displayDescription,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.category != null)
              Text(
                transaction.category!,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            Text(
              '${transaction.formattedDate} • ${transaction.account ?? 'Account'}',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Amount and type display
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  transaction.formattedAmount,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: transaction.isPositive
                        ? const Color(0xFF4CAF50)
                        : colorScheme.onSurface,
                  ),
                ),
                if (transaction.type != TransactionType.expense)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: transaction.type == TransactionType.income
                          ? const Color(0xFF4CAF50).withOpacity(0.1)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      transaction.type.value.toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        color: transaction.type == TransactionType.income
                            ? const Color(0xFF4CAF50)
                            : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),

            // Add to chat button (when not in selection mode)
            if (!isSelectable && onAddToChat != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => onAddToChat!(transaction),
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

  Color _getCategoryColor(String? colorHex) {
    if (colorHex == null) return const Color(0xFF6750A4);
    try {
      final hex = colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return const Color(0xFF6750A4);
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
        return Icons.receipt_long;
    }
  }
}

/// Enhanced transactions section with dashboard item selection support
class EnhancedTransactionsSection extends StatefulWidget {
  final List<Transaction> transactions;
  final VoidCallback? onViewAll;
  final Function(TransactionDashboardItem)? onAddTransactionToChat;

  const EnhancedTransactionsSection({
    super.key,
    required this.transactions,
    this.onViewAll,
    this.onAddTransactionToChat,
  });

  @override
  State<EnhancedTransactionsSection> createState() =>
      _EnhancedTransactionsSectionState();
}

class _EnhancedTransactionsSectionState
    extends State<EnhancedTransactionsSection> {
  bool _isSelectionMode = false;
  final Set<String> _selectedTransactionIds = <String>{};

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedTransactionIds.clear();
      }
    });
  }

  void _toggleTransactionSelection(String transactionId) {
    setState(() {
      if (_selectedTransactionIds.contains(transactionId)) {
        _selectedTransactionIds.remove(transactionId);
      } else {
        _selectedTransactionIds.add(transactionId);
      }
    });
  }

  void _addSelectedTransactionsToChat() {
    if (widget.onAddTransactionToChat == null) return;

    final selectedTransactions = widget.transactions
        .where((t) => _selectedTransactionIds.contains(t.id))
        .toList();

    for (final transaction in selectedTransactions) {
      final dashboardItem =
          TransactionDashboardItem.fromTransaction(transaction);
      widget.onAddTransactionToChat!(dashboardItem);
    }

    // Show confirmation and exit selection mode
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Added ${selectedTransactions.length} transaction(s) to chat'),
      ),
    );

    _toggleSelectionMode();
  }

  void _addSingleTransactionToChat(Transaction transaction) {
    if (widget.onAddTransactionToChat == null) return;

    final dashboardItem = TransactionDashboardItem.fromTransaction(transaction);
    widget.onAddTransactionToChat!(dashboardItem);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction added to chat'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.transactions.isEmpty) {
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
                  ? 'Select Transactions (${_selectedTransactionIds.length})'
                  : 'Recent Transactions',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                if (_isSelectionMode) ...[
                  // Add selected to chat button
                  if (_selectedTransactionIds.isNotEmpty)
                    IconButton(
                      onPressed: _addSelectedTransactionsToChat,
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
                  if (widget.onAddTransactionToChat != null)
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

        // Transactions list
        Card(
          elevation: 1,
          child: Column(
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.transactions.length > 5
                    ? 5
                    : widget.transactions.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final transaction = widget.transactions[index];

                  return SelectableTransactionListItem(
                    transaction: transaction,
                    isSelectable: _isSelectionMode,
                    isSelected:
                        _selectedTransactionIds.contains(transaction.id),
                    onTap: _isSelectionMode
                        ? () => _toggleTransactionSelection(transaction.id)
                        : null,
                    onLongPress:
                        !_isSelectionMode ? _toggleSelectionMode : null,
                    onAddToChat:
                        !_isSelectionMode ? _addSingleTransactionToChat : null,
                  );
                },
              ),

              // View all footer
              if (widget.transactions.length > 5 && widget.onViewAll != null)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: TextButton(
                    onPressed: widget.onViewAll,
                    style: TextButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                    ),
                    child: Text(
                        'View All ${widget.transactions.length} Transactions'),
                  ),
                ),
            ],
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
                Icons.receipt_long_outlined,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Recent Transactions',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your transaction history will appear here once you start recording your expenses',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to add transaction screen
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
