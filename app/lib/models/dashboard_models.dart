/// Models for Dashboard Data
///
/// These models define the structure for dashboard financial data
/// that will be consumed from the Dashboard API n8n workflow.
/// Matches the API response structure from Story 5.1.

import 'package:intl/intl.dart';

/// Main dashboard data container
class DashboardData {
  final List<MoneyAccount> moneyAccounts;
  final List<Budget> budgets;
  final List<Transaction> recentTransactions;
  final FinancialOverview financialOverview;
  final Map<String, dynamic> structuredData;
  final List<Alert> alerts;
  final DashboardSummary summary;
  final DashboardMetadata metadata;

  const DashboardData({
    required this.moneyAccounts,
    required this.budgets,
    required this.recentTransactions,
    required this.financialOverview,
    required this.structuredData,
    required this.alerts,
    required this.summary,
    required this.metadata,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    // Extract data and meta from API response
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final meta = json['meta'] as Map<String, dynamic>? ?? {};

    return DashboardData(
      moneyAccounts: (data['accounts'] as List? ?? [])
          .map((account) =>
              MoneyAccount.fromJson(account as Map<String, dynamic>))
          .toList(),
      budgets: (data['budgets'] as List? ?? [])
          .map((budget) => Budget.fromJson(budget as Map<String, dynamic>))
          .toList(),
      recentTransactions: (data['transactions'] as List? ?? [])
          .map((transaction) =>
              Transaction.fromJson(transaction as Map<String, dynamic>))
          .toList(),
      financialOverview: FinancialOverview.fromJson(
        data['overview'] as Map<String, dynamic>? ?? {},
      ),
      structuredData: data['structuredData'] as Map<String, dynamic>? ?? {},
      alerts: (data['alerts'] as List? ?? [])
          .map((alert) => Alert.fromJson(alert as Map<String, dynamic>))
          .toList(),
      summary: DashboardSummary.fromJson(
        data['summary'] as Map<String, dynamic>? ?? {},
      ),
      metadata: DashboardMetadata.fromJson(meta),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': true,
      'data': {
        'accounts': moneyAccounts.map((account) => account.toJson()).toList(),
        'budgets': budgets.map((budget) => budget.toJson()).toList(),
        'transactions': recentTransactions
            .map((transaction) => transaction.toJson())
            .toList(),
        'overview': financialOverview.toJson(),
        'structuredData': structuredData,
        'alerts': alerts.map((alert) => alert.toJson()).toList(),
        'summary': summary.toJson(),
      },
      'meta': metadata.toJson(),
    };
  }

  /// Check if this is an empty state (new user with no data)
  bool get isEmpty =>
      summary.totalAccounts == 0 &&
      summary.totalTransactions == 0 &&
      summary.totalBudgets == 0;

  /// Get total number of financial entities
  int get totalItemsCount =>
      moneyAccounts.length + budgets.length + recentTransactions.length;
}

/// Money account model (bank accounts, credit cards, investments, etc.)
class MoneyAccount {
  final String id;
  final String name;
  final AccountType type;
  final String? institutionName;
  final String? accountNumber;
  final double balance;
  final String currency;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MoneyAccount({
    required this.id,
    required this.name,
    required this.type,
    this.institutionName,
    this.accountNumber,
    required this.balance,
    required this.currency,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory MoneyAccount.fromJson(Map<String, dynamic> json) {
    return MoneyAccount(
      id: json['id'] as String,
      name: json['name'] as String,
      type: AccountType.fromString(json['accountType'] as String? ?? 'bank'),
      institutionName: json['institutionName'] as String?,
      accountNumber: json['accountNumber'] as String?,
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'accountType': type.value,
      'institutionName': institutionName,
      'accountNumber': accountNumber,
      'balance': balance,
      'currency': currency,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
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
  final double netWorth;
  final double monthlyCashFlow;
  final double monthlyIncome;
  final double monthlyExpenses;
  final double totalAssets;
  final double totalDebts;
  final double savingsRate;
  final Map<String, double> accountTotals;

  const FinancialOverview({
    required this.netWorth,
    required this.monthlyCashFlow,
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.totalAssets,
    required this.totalDebts,
    required this.savingsRate,
    required this.accountTotals,
  });

  factory FinancialOverview.fromJson(Map<String, dynamic> json) {
    final accountTotalsJson =
        json['accountTotals'] as Map<String, dynamic>? ?? {};
    final accountTotals = accountTotalsJson.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    return FinancialOverview(
      netWorth: (json['netWorth'] as num?)?.toDouble() ?? 0.0,
      monthlyCashFlow: (json['monthlyCashFlow'] as num?)?.toDouble() ?? 0.0,
      monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble() ?? 0.0,
      monthlyExpenses: (json['monthlyExpenses'] as num?)?.toDouble() ?? 0.0,
      totalAssets: (json['totalAssets'] as num?)?.toDouble() ?? 0.0,
      totalDebts: (json['totalDebts'] as num?)?.toDouble() ?? 0.0,
      savingsRate: (json['savingsRate'] as num?)?.toDouble() ?? 0.0,
      accountTotals: accountTotals,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'netWorth': netWorth,
      'monthlyCashFlow': monthlyCashFlow,
      'monthlyIncome': monthlyIncome,
      'monthlyExpenses': monthlyExpenses,
      'totalAssets': totalAssets,
      'totalDebts': totalDebts,
      'savingsRate': savingsRate,
      'accountTotals': accountTotals,
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

  /// Get formatted monthly cash flow
  String get formattedMonthlyCashFlow {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    return formatter.format(monthlyCashFlow);
  }

  /// Check if monthly cash flow is positive
  bool get hasPositiveCashFlow => monthlyCashFlow > 0;
}

/// Dashboard metadata model from API meta section
class DashboardMetadata {
  final DateTime timestamp;
  final String version;
  final String endpoint;
  final String? userId;
  final String? cacheStatus;

  const DashboardMetadata({
    required this.timestamp,
    required this.version,
    required this.endpoint,
    this.userId,
    this.cacheStatus,
  });

  factory DashboardMetadata.fromJson(Map<String, dynamic> json) {
    return DashboardMetadata(
      timestamp: DateTime.parse(json['timestamp'] as String),
      version: json['version'] as String? ?? '1.0.0',
      endpoint: json['endpoint'] as String? ?? 'GET /dashboard',
      userId: json['userId'] as String?,
      cacheStatus: json['cacheStatus'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'version': version,
      'endpoint': endpoint,
      if (userId != null) 'userId': userId,
      if (cacheStatus != null) 'cacheStatus': cacheStatus,
    };
  }

  /// Check if data is from cache
  bool get isCached => cacheStatus == 'cached';

  /// Check if data is fresh
  bool get isFresh => cacheStatus == 'fresh';
}

/// Dashboard summary model from API summary section
class DashboardSummary {
  final int totalAccounts;
  final int totalTransactions;
  final int totalBudgets;
  final int totalAlerts;
  final List<String> dataTypes;
  final int totalStructuredItems;

  const DashboardSummary({
    required this.totalAccounts,
    required this.totalTransactions,
    required this.totalBudgets,
    required this.totalAlerts,
    required this.dataTypes,
    required this.totalStructuredItems,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalAccounts: json['totalAccounts'] as int? ?? 0,
      totalTransactions: json['totalTransactions'] as int? ?? 0,
      totalBudgets: json['totalBudgets'] as int? ?? 0,
      totalAlerts: json['totalAlerts'] as int? ?? 0,
      dataTypes: List<String>.from(json['dataTypes'] as List? ?? []),
      totalStructuredItems: json['totalStructuredItems'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAccounts': totalAccounts,
      'totalTransactions': totalTransactions,
      'totalBudgets': totalBudgets,
      'totalAlerts': totalAlerts,
      'dataTypes': dataTypes,
      'totalStructuredItems': totalStructuredItems,
    };
  }

  /// Check if dashboard is empty
  bool get isEmpty =>
      totalAccounts == 0 && totalTransactions == 0 && totalBudgets == 0;

  /// Get total items count
  int get totalItems =>
      totalAccounts + totalTransactions + totalBudgets + totalAlerts;
}

/// Alert model for dashboard notifications
class Alert {
  final String id;
  final String type;
  final String title;
  final String message;
  final String severity;
  final Map<String, dynamic>? data;
  final bool isRead;
  final String? actionUrl;
  final DateTime? expiresAt;
  final DateTime createdAt;

  const Alert({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.severity,
    this.data,
    required this.isRead,
    this.actionUrl,
    this.expiresAt,
    required this.createdAt,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      severity: json['severity'] as String,
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool? ?? false,
      actionUrl: json['actionUrl'] as String?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'severity': severity,
      if (data != null) 'data': data,
      'isRead': isRead,
      if (actionUrl != null) 'actionUrl': actionUrl,
      if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Get severity color
  String get severityColor {
    switch (severity.toLowerCase()) {
      case 'error':
        return '#F44336';
      case 'warning':
        return '#FF9800';
      case 'info':
        return '#2196F3';
      case 'success':
        return '#4CAF50';
      default:
        return '#9E9E9E';
    }
  }

  /// Check if alert is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
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
