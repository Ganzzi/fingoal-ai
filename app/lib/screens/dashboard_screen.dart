import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard/enhanced_accounts_section.dart';
import '../widgets/dashboard/enhanced_budgets_section.dart';
import '../widgets/dashboard/enhanced_transactions_section.dart';
import '../widgets/dashboard/financial_overview_section.dart';

/// Financial Dashboard Screen
///
/// Displays comprehensive financial overview including:
/// - Financial overview with key metrics
/// - Money accounts and balances
/// - Budget tracking and progress
/// - Recent transactions
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Use the working JWT token from API tests
  final String _authToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHBpcmVzSW4iOiIyNGgiLCJ1c2VySWQiOiJiMTQ0YjY3MC02NTY5LTRiNjMtOTNlYS1mMWJkOGExODA0MWIiLCJlbWFpbCI6InRlc3R1c2VyMTIzQGV4YW1wbGUuY29tIiwiaWF0IjoxNzU4NTMxNTYyfQ.PKoZzwChAGwONSVcJJc67xta6BTYiBwvt-S35-bovv0';

  @override
  void initState() {
    super.initState();
    // Initialize provider and load dashboard data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DashboardProvider>();

      // Initialize provider first
      provider.initialize().then((_) {
        // If no cached data, fetch from API
        if (!provider.hasData) {
          provider.fetchDashboardData(authToken: _authToken);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.financialDashboard),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          Consumer<DashboardProvider>(
            builder: (context, provider, _) {
              return IconButton(
                onPressed: provider.isLoading
                    ? null
                    : () =>
                        provider.refreshDashboardData(authToken: _authToken),
                icon: provider.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      )
                    : const Icon(Icons.refresh),
                tooltip: 'Refresh',
              );
            },
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.dashboardData == null) {
            // Initial loading state
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your financial data...',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.error != null) {
            // Error state
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Unable to load dashboard',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error?.message ?? 'Unknown error occurred',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () =>
                          provider.refreshDashboardData(authToken: _authToken),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = provider.dashboardData;
          if (data == null) {
            // No data state (shouldn't happen, but defensive)
            return const Center(
              child: Text('No dashboard data available'),
            );
          }

          // Main dashboard content
          return RefreshIndicator(
            onRefresh: () =>
                provider.refreshDashboardData(authToken: _authToken),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Financial Overview Section
                  FinancialOverviewSection(overview: data.financialOverview),

                  const SizedBox(height: 24),

                  // Money Accounts Section - Enhanced with Chat Integration
                  EnhancedMoneyAccountsSection(accounts: data.moneyAccounts),

                  const SizedBox(height: 24),

                  // Budgets Section - Enhanced with Chat Integration
                  EnhancedBudgetsSection(budgets: data.budgets),

                  const SizedBox(height: 24),

                  // Recent Transactions Section - Enhanced with Chat Integration
                  EnhancedTransactionsSection(
                    transactions: data.recentTransactions,
                    onViewAll: () {
                      // TODO: Navigate to full transactions list
                    },
                  ),

                  // Bottom padding for navigation bar
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
