import 'package:flutter/material.dart';
import '../../models/dashboard_models.dart';
import '../../models/rich_message_models.dart';

/// Enhanced account list item with dashboard item selection capability
class SelectableAccountListItem extends StatelessWidget {
  final MoneyAccount account;
  final bool isSelectable;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Function(MoneyAccount)? onAddToChat;

  const SelectableAccountListItem({
    super.key,
    required this.account,
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
        contentPadding: const EdgeInsets.all(16),

        // Selection indicator or account type icon
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
                  color: _getAccountTypeColor(account.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getAccountTypeIcon(account.type),
                  color: _getAccountTypeColor(account.type),
                  size: 24,
                ),
              ),

        title: Text(
          account.name,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              account.typeDisplayName,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (account.institutionName != null) ...[
              const SizedBox(height: 4),
              Text(
                account.institutionName!,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Balance display
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  account.formattedBalance,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: account.balance >= 0
                        ? colorScheme.onSurface
                        : const Color(0xFFF44336), // Red for negative balance
                  ),
                ),
                Text(
                  account.currency,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            // Add to chat button (when not in selection mode)
            if (!isSelectable && onAddToChat != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => onAddToChat!(account),
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

  Color _getAccountTypeColor(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return const Color(0xFF2196F3); // Blue
      case AccountType.creditCard:
        return const Color(0xFFFF5722); // Deep Orange
      case AccountType.cash:
        return const Color(0xFF4CAF50); // Green
      case AccountType.investment:
        return const Color(0xFF9C27B0); // Purple
    }
  }

  IconData _getAccountTypeIcon(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return Icons.account_balance;
      case AccountType.creditCard:
        return Icons.credit_card;
      case AccountType.cash:
        return Icons.account_balance_wallet;
      case AccountType.investment:
        return Icons.trending_up;
    }
  }
}

/// Enhanced money accounts section with dashboard item selection support
class EnhancedMoneyAccountsSection extends StatefulWidget {
  final List<MoneyAccount> accounts;
  final VoidCallback? onViewAll;
  final Function(AccountDashboardItem)? onAddAccountToChat;

  const EnhancedMoneyAccountsSection({
    super.key,
    required this.accounts,
    this.onViewAll,
    this.onAddAccountToChat,
  });

  @override
  State<EnhancedMoneyAccountsSection> createState() =>
      _EnhancedMoneyAccountsSectionState();
}

class _EnhancedMoneyAccountsSectionState
    extends State<EnhancedMoneyAccountsSection> {
  bool _isSelectionMode = false;
  final Set<String> _selectedAccountIds = <String>{};

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedAccountIds.clear();
      }
    });
  }

  void _toggleAccountSelection(String accountId) {
    setState(() {
      if (_selectedAccountIds.contains(accountId)) {
        _selectedAccountIds.remove(accountId);
      } else {
        _selectedAccountIds.add(accountId);
      }
    });
  }

  void _addSelectedAccountsToChat() {
    if (widget.onAddAccountToChat == null) return;

    final selectedAccounts = widget.accounts
        .where((a) => _selectedAccountIds.contains(a.id))
        .toList();

    for (final account in selectedAccounts) {
      final dashboardItem = AccountDashboardItem.fromAccount(account);
      widget.onAddAccountToChat!(dashboardItem);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${selectedAccounts.length} account(s) to chat'),
      ),
    );

    _toggleSelectionMode();
  }

  void _addSingleAccountToChat(MoneyAccount account) {
    if (widget.onAddAccountToChat == null) return;

    final dashboardItem = AccountDashboardItem.fromAccount(account);
    widget.onAddAccountToChat!(dashboardItem);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account added to chat'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.accounts.isEmpty) {
      return _buildEmptyState(context);
    }

    // Calculate total balance
    final totalBalance = widget.accounts
        .where((account) => account.isActive)
        .fold<double>(0.0, (sum, account) => sum + account.balance);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with selection controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isSelectionMode
                  ? 'Select Accounts (${_selectedAccountIds.length})'
                  : 'Money Accounts',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                if (_isSelectionMode) ...[
                  // Add selected to chat button
                  if (_selectedAccountIds.isNotEmpty)
                    IconButton(
                      onPressed: _addSelectedAccountsToChat,
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
                  if (widget.onAddAccountToChat != null)
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

        // Total balance card (when not in selection mode)
        if (!_isSelectionMode) ...[
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: colorScheme.onPrimaryContainer,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Balance',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatBalance(totalBalance),
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: totalBalance >= 0
                                ? colorScheme.onSurface
                                : const Color(0xFFF44336),
                          ),
                          overflow: TextOverflow.visible,
                          softWrap: true,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.accounts.length} account${widget.accounts.length != 1 ? 's' : ''}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Accounts list
        Card(
          elevation: 1,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.accounts.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final account = widget.accounts[index];

              return SelectableAccountListItem(
                account: account,
                isSelectable: _isSelectionMode,
                isSelected: _selectedAccountIds.contains(account.id),
                onTap: _isSelectionMode
                    ? () => _toggleAccountSelection(account.id)
                    : null,
                onLongPress: !_isSelectionMode ? _toggleSelectionMode : null,
                onAddToChat: !_isSelectionMode ? _addSingleAccountToChat : null,
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
                Icons.account_balance_outlined,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Accounts Connected',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connect your bank accounts, credit cards, and other financial accounts to get started',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to connect account screen
              },
              icon: const Icon(Icons.add),
              label: const Text('Connect Account'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBalance(double balance) {
    if (balance.abs() >= 1000000) {
      return '\$${(balance / 1000000).toStringAsFixed(1)}M';
    } else if (balance.abs() >= 1000) {
      return '\$${(balance / 1000).toStringAsFixed(1)}K';
    } else {
      return '\$${balance.toStringAsFixed(2)}';
    }
  }
}
