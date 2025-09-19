/// Models for Dashboard Data
///
/// These models define the structure for dashboard financial data
/// that will be consumed from the Dashboard Agent n8n workflow.

import 'package:intl/intl.dart';

/// Main dashboard data container
class DashboardData {
  final List<MoneyAccount> moneyAccounts;
  final List<Budget> budgets;
  final List<Transaction> recentTransactions;
  final FinancialOverview financialOverview;
  final Map<String, dynamic> otherData;
  final DashboardMetadata metadata;
  final EmptyState? emptyState;

  const DashboardData({
    required this.moneyAccounts,
    required this.budgets,
    required this.recentTransactions,
    required this.financialOverview,
    required this.otherData,
    required this.metadata,
    this.emptyState,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      moneyAccounts: (json['moneyAccounts'] as List? ?? [])
          .map((account) =>
              MoneyAccount.fromJson(account as Map<String, dynamic>))
          .toList(),
      budgets: (json['budgets'] as List? ?? [])
          .map((budget) => Budget.fromJson(budget as Map<String, dynamic>))
          .toList(),
      recentTransactions: (json['recentTransactions'] as List? ?? [])
          .map((transaction) =>
              Transaction.fromJson(transaction as Map<String, dynamic>))
          .toList(),
      financialOverview: FinancialOverview.fromJson(
        json['financialOverview'] as Map<String, dynamic>? ?? {},
      ),
      otherData: json['otherData'] as Map<String, dynamic>? ?? {},
      metadata: DashboardMetadata.fromJson(
        json['metadata'] as Map<String, dynamic>? ?? {},
      ),
      emptyState: json['emptyState'] != null
          ? EmptyState.fromJson(json['emptyState'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moneyAccounts':
          moneyAccounts.map((account) => account.toJson()).toList(),
      'budgets': budgets.map((budget) => budget.toJson()).toList(),
      'recentTransactions': recentTransactions
          .map((transaction) => transaction.toJson())
          .toList(),
      'financialOverview': financialOverview.toJson(),
      'otherData': otherData,
      'metadata': metadata.toJson(),
      if (emptyState != null) 'emptyState': emptyState!.toJson(),
    };
  }

  /// Check if this is an empty state (new user with no data)
  bool get isEmpty => metadata.isEmpty == true || emptyState != null;

  /// Get total number of financial entities
  int get totalItemsCount =>
      moneyAccounts.length + budgets.length + recentTransactions.length;
}

/// Money account model (bank accounts, credit cards, investments, etc.)
class MoneyAccount {
  final String id;
  final String name;
  final AccountType type;
  final String? institution;
  final double balance;
  final String currency;
  final bool isActive;

  const MoneyAccount({
    required this.id,
    required this.name,
    required this.type,
    this.institution,
    required this.balance,
    required this.currency,
    required this.isActive,
  });

  factory MoneyAccount.fromJson(Map<String, dynamic> json) {
    return MoneyAccount(
      id: json['id'] as String,
      name: json['name'] as String,
      type: AccountType.fromString(json['type'] as String),
      institution: json['institution'] as String?,
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.value,
      'institution': institution,
      'balance': balance,
      'currency': currency,
      'isActive': isActive,
    };
  }

  /// Get formatted balance string
  String get formattedBalance {
    final formatter = NumberFormat.currency(
      symbol: _getCurrencySymbol(currency),
      decimalDigits: 2,
    );
    return formatter.format(balance);
  }

  /// Get account type icon
  String get iconName {
    switch (type) {
      case AccountType.bank:
        return 'account_balance';
      case AccountType.creditCard:
        return 'credit_card';
      case AccountType.cash:
        return 'account_balance_wallet';
      case AccountType.investment:
        return 'trending_up';
    }
  }

  /// Get account type display name
  String get typeDisplayName {
    switch (type) {
      case AccountType.bank:
        return 'Bank Account';
      case AccountType.creditCard:
        return 'Credit Card';
      case AccountType.cash:
        return 'Cash';
      case AccountType.investment:
        return 'Investment';
    }
  }
}

/// Account type enumeration
enum AccountType {
  bank('bank'),
  creditCard('credit_card'),
  cash('cash'),
  investment('investment');

  const AccountType(this.value);
  final String value;

  static AccountType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'bank':
        return AccountType.bank;
      case 'credit_card':
        return AccountType.creditCard;
      case 'cash':
        return AccountType.cash;
      case 'investment':
        return AccountType.investment;
      default:
        return AccountType.bank;
    }
  }
}

/// Budget model with spending calculations
class Budget {
  final String id;
  final String categoryId;
  final String categoryName;
  final String budgetName;
  final double allocated;
  final double spent;
  final double remaining;
  final double percentageUsed;
  final String currency;
  final String period;
  final String? color;
  final String? icon;
  final bool isActive;

  const Budget({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.budgetName,
    required this.allocated,
    required this.spent,
    required this.remaining,
    required this.percentageUsed,
    required this.currency,
    required this.period,
    this.color,
    this.icon,
    required this.isActive,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      budgetName: json['budgetName'] as String,
      allocated: (json['allocated'] as num).toDouble(),
      spent: (json['spent'] as num).toDouble(),
      remaining: (json['remaining'] as num).toDouble(),
      percentageUsed: (json['percentageUsed'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      period: json['period'] as String? ?? 'monthly',
      color: json['color'] as String?,
      icon: json['icon'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'budgetName': budgetName,
      'allocated': allocated,
      'spent': spent,
      'remaining': remaining,
      'percentageUsed': percentageUsed,
      'currency': currency,
      'period': period,
      'color': color,
      'icon': icon,
      'isActive': isActive,
    };
  }

  /// Get formatted allocated amount
  String get formattedAllocated {
    final formatter = NumberFormat.currency(
      symbol: _getCurrencySymbol(currency),
      decimalDigits: 2,
    );
    return formatter.format(allocated);
  }

  /// Get formatted spent amount
  String get formattedSpent {
    final formatter = NumberFormat.currency(
      symbol: _getCurrencySymbol(currency),
      decimalDigits: 2,
    );
    return formatter.format(spent);
  }

  /// Get formatted remaining amount
  String get formattedRemaining {
    final formatter = NumberFormat.currency(
      symbol: _getCurrencySymbol(currency),
      decimalDigits: 2,
    );
    return formatter.format(remaining);
  }

  /// Get budget status based on percentage used
  BudgetStatus get status {
    if (percentageUsed >= 100) {
      return BudgetStatus.overBudget;
    } else if (percentageUsed >= 80) {
      return BudgetStatus.nearLimit;
    } else {
      return BudgetStatus.onTrack;
    }
  }

  /// Get category icon name (fallback to default if null)
  String get categoryIcon => icon ?? 'category';
}

/// Budget status enumeration
enum BudgetStatus {
  onTrack,
  nearLimit,
  overBudget;

  /// Get status color hex value
  String get colorHex {
    switch (this) {
      case BudgetStatus.onTrack:
        return '#4CAF50'; // Green
      case BudgetStatus.nearLimit:
        return '#FF9800'; // Orange
      case BudgetStatus.overBudget:
        return '#F44336'; // Red
    }
  }

  /// Get status display name
  String get displayName {
    switch (this) {
      case BudgetStatus.onTrack:
        return 'On Track';
      case BudgetStatus.nearLimit:
        return 'Near Limit';
      case BudgetStatus.overBudget:
        return 'Over Budget';
    }
  }
}

/// Transaction model
class Transaction {
  final String id;
  final DateTime date;
  final String description;
  final double amount;
  final String currency;
  final TransactionType type;
  final String? category;
  final String? categoryColor;
  final String? categoryIcon;
  final String? account;
  final String? accountType;
  final String? merchant;
  final String? notes;

  const Transaction({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.currency,
    required this.type,
    this.category,
    this.categoryColor,
    this.categoryIcon,
    this.account,
    this.accountType,
    this.merchant,
    this.notes,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      type: TransactionType.fromString(json['type'] as String),
      category: json['category'] as String?,
      categoryColor: json['categoryColor'] as String?,
      categoryIcon: json['categoryIcon'] as String?,
      account: json['account'] as String?,
      accountType: json['accountType'] as String?,
      merchant: json['merchant'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'description': description,
      'amount': amount,
      'currency': currency,
      'type': type.value,
      'category': category,
      'categoryColor': categoryColor,
      'categoryIcon': categoryIcon,
      'account': account,
      'accountType': accountType,
      'merchant': merchant,
      'notes': notes,
    };
  }

  /// Get formatted amount string
  String get formattedAmount {
    final formatter = NumberFormat.currency(
      symbol: _getCurrencySymbol(currency),
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Get formatted date string
  String get formattedDate {
    return DateFormat.MMMd().format(date);
  }

  /// Get formatted full date string
  String get formattedFullDate {
    return DateFormat.yMMMd().format(date);
  }

  /// Check if transaction is positive (income)
  bool get isPositive => amount > 0 || type == TransactionType.income;

  /// Get display description (fallback order: description, merchant, default)
  String get displayDescription {
    if (description.isNotEmpty) return description;
    if (merchant != null && merchant!.isNotEmpty) return merchant!;
    return 'Transaction';
  }

  /// Get category icon (fallback to default if null)
  String get displayCategoryIcon => categoryIcon ?? 'category';
}

/// Transaction type enumeration
enum TransactionType {
  income('income'),
  expense('expense'),
  transfer('transfer');

  const TransactionType(this.value);
  final String value;

  static TransactionType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      case 'transfer':
        return TransactionType.transfer;
      default:
        return TransactionType.expense;
    }
  }
}

/// Financial overview model with calculated metrics
class FinancialOverview {
  final double totalAssets;
  final double totalDebts;
  final double netWorth;
  final double monthlyIncome;
  final double monthlyExpenses;
  final int savingsRate;

  const FinancialOverview({
    required this.totalAssets,
    required this.totalDebts,
    required this.netWorth,
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.savingsRate,
  });

  factory FinancialOverview.fromJson(Map<String, dynamic> json) {
    return FinancialOverview(
      totalAssets: (json['totalAssets'] as num?)?.toDouble() ?? 0.0,
      totalDebts: (json['totalDebts'] as num?)?.toDouble() ?? 0.0,
      netWorth: (json['netWorth'] as num?)?.toDouble() ?? 0.0,
      monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble() ?? 0.0,
      monthlyExpenses: (json['monthlyExpenses'] as num?)?.toDouble() ?? 0.0,
      savingsRate: (json['savingsRate'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAssets': totalAssets,
      'totalDebts': totalDebts,
      'netWorth': netWorth,
      'monthlyIncome': monthlyIncome,
      'monthlyExpenses': monthlyExpenses,
      'savingsRate': savingsRate,
    };
  }

  /// Get formatted total assets string
  String get formattedTotalAssets {
    return _formatLargeAmount(totalAssets);
  }

  /// Get formatted total debts string
  String get formattedTotalDebts {
    return _formatLargeAmount(totalDebts);
  }

  /// Get formatted net worth string
  String get formattedNetWorth {
    return _formatLargeAmount(netWorth);
  }

  /// Get formatted monthly income string
  String get formattedMonthlyIncome {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    return formatter.format(monthlyIncome);
  }

  /// Get formatted monthly expenses string
  String get formattedMonthlyExpenses {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    return formatter.format(monthlyExpenses);
  }

  /// Get savings rate with percentage sign
  String get formattedSavingsRate => '$savingsRate%';

  /// Check if net worth is positive
  bool get hasPositiveNetWorth => netWorth > 0;

  /// Get monthly cash flow (income - expenses)
  double get monthlyCashFlow => monthlyIncome - monthlyExpenses;

  /// Get formatted monthly cash flow
  String get formattedMonthlyCashFlow {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    return formatter.format(monthlyCashFlow);
  }

  /// Check if monthly cash flow is positive
  bool get hasPositiveCashFlow => monthlyCashFlow > 0;
}

/// Dashboard metadata model
class DashboardMetadata {
  final DateTime generatedAt;
  final int accountsCount;
  final int budgetsCount;
  final int transactionsCount;
  final int dataTypesCount;
  final bool? isEmpty;

  const DashboardMetadata({
    required this.generatedAt,
    required this.accountsCount,
    required this.budgetsCount,
    required this.transactionsCount,
    required this.dataTypesCount,
    this.isEmpty,
  });

  factory DashboardMetadata.fromJson(Map<String, dynamic> json) {
    return DashboardMetadata(
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      accountsCount: json['accountsCount'] as int? ?? 0,
      budgetsCount: json['budgetsCount'] as int? ?? 0,
      transactionsCount: json['transactionsCount'] as int? ?? 0,
      dataTypesCount: json['dataTypesCount'] as int? ?? 0,
      isEmpty: json['isEmpty'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'generatedAt': generatedAt.toIso8601String(),
      'accountsCount': accountsCount,
      'budgetsCount': budgetsCount,
      'transactionsCount': transactionsCount,
      'dataTypesCount': dataTypesCount,
      if (isEmpty != null) 'isEmpty': isEmpty,
    };
  }

  /// Get total count of all items
  int get totalItemsCount => accountsCount + budgetsCount + transactionsCount;
}

/// Empty state model for new users
class EmptyState {
  final String title;
  final String message;
  final List<String> suggestions;

  const EmptyState({
    required this.title,
    required this.message,
    required this.suggestions,
  });

  factory EmptyState.fromJson(Map<String, dynamic> json) {
    return EmptyState(
      title: json['title'] as String,
      message: json['message'] as String,
      suggestions: List<String>.from(json['suggestions'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'suggestions': suggestions,
    };
  }
}

/// Helper function to get currency symbol
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
    default:
      return currencyCode;
  }
}

/// Helper function to format large amounts with K/M abbreviations
String _formatLargeAmount(double amount) {
  final absAmount = amount.abs();
  final isNegative = amount < 0;
  final prefix = isNegative ? '-' : '';

  if (absAmount >= 1000000) {
    final millions = absAmount / 1000000;
    return '$prefix\$${millions.toStringAsFixed(1)}M';
  } else if (absAmount >= 1000) {
    final thousands = absAmount / 1000;
    return '$prefix\$${thousands.toStringAsFixed(1)}K';
  } else {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    return formatter.format(amount);
  }
}
