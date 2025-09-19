import 'package:flutter/material.dart';
import '../../models/dashboard_models.dart';

/// Individual money account card widget
class AccountCard extends StatelessWidget {
  final MoneyAccount account;
  final VoidCallback? onTap;

  const AccountCard({
    super.key,
    required this.account,
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
              // Account type icon and name
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getAccountIcon(account.type),
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.name,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (account.institution != null)
                          Text(
                            account.institution!,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Balance and account type
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Balance',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        account.formattedBalance,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: account.balance >= 0
                              ? colorScheme.primary
                              : colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      account.typeDisplayName,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getAccountIcon(AccountType type) {
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

/// Money accounts section widget
class MoneyAccountsSection extends StatelessWidget {
  final List<MoneyAccount> accounts;
  final VoidCallback? onViewAll;

  const MoneyAccountsSection({
    super.key,
    required this.accounts,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (accounts.isEmpty) {
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
              'Money Accounts',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (accounts.length > 2 && onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                child: const Text('View All'),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Accounts grid
        if (accounts.length == 1)
          AccountCard(account: accounts.first)
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: accounts.length > 4 ? 4 : accounts.length,
            itemBuilder: (context, index) {
              return AccountCard(account: accounts[index]);
            },
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
              'No Money Accounts',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first account to start tracking your finances',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to add account screen
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Account'),
            ),
          ],
        ),
      ),
    );
  }
}
