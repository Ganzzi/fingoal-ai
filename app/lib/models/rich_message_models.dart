/// Models for Rich Message Composer and Dashboard Context
///
/// These models define the structure for dashboard items that can be
/// selected and included in chat messages for context-aware AI conversations.

import 'dashboard_models.dart';

/// Dashboard item types that can be added to chat messages
enum DashboardItemType {
  transaction,
  budget,
  account,
  goal,
  analysis;

  String get displayName {
    switch (this) {
      case DashboardItemType.transaction:
        return 'Transaction';
      case DashboardItemType.budget:
        return 'Budget';
      case DashboardItemType.account:
        return 'Account';
      case DashboardItemType.goal:
        return 'Goal';
      case DashboardItemType.analysis:
        return 'Analysis';
    }
  }

  String get iconName {
    switch (this) {
      case DashboardItemType.transaction:
        return 'receipt';
      case DashboardItemType.budget:
        return 'account_balance_wallet';
      case DashboardItemType.account:
        return 'account_balance';
      case DashboardItemType.goal:
        return 'flag';
      case DashboardItemType.analysis:
        return 'analytics';
    }
  }
}

/// Base class for dashboard items that can be included in chat messages
abstract class DashboardItem {
  final String id;
  final DashboardItemType type;
  final String title;
  final String subtitle;
  final String? iconName;
  final String? color;
  final Map<String, dynamic> data;

  const DashboardItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.iconName,
    this.color,
    required this.data,
  });

  /// Convert to JSON for API payload
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'iconName': iconName,
      'color': color,
      'data': data,
    };
  }

  /// Create dashboard item from JSON
  static DashboardItem fromJson(Map<String, dynamic> json) {
    final type = DashboardItemType.values.byName(json['type'] as String);

    switch (type) {
      case DashboardItemType.transaction:
        return TransactionDashboardItem.fromJson(json);
      case DashboardItemType.budget:
        return BudgetDashboardItem.fromJson(json);
      case DashboardItemType.account:
        return AccountDashboardItem.fromJson(json);
      case DashboardItemType.goal:
        return GoalDashboardItem.fromJson(json);
      case DashboardItemType.analysis:
        return AnalysisDashboardItem.fromJson(json);
    }
  }

  /// Get display chip content
  String get chipDisplayText => title;
}

/// Transaction dashboard item
class TransactionDashboardItem extends DashboardItem {
  final Transaction transaction;

  TransactionDashboardItem({
    required this.transaction,
    String? iconName,
    String? color,
  }) : super(
          id: transaction.id,
          type: DashboardItemType.transaction,
          title: transaction.displayDescription,
          subtitle:
              '${transaction.formattedAmount} • ${transaction.formattedDate}',
          iconName: iconName ?? transaction.displayCategoryIcon,
          color: color ?? transaction.categoryColor,
          data: {
            'amount': transaction.amount,
            'currency': transaction.currency,
            'date': transaction.date.toIso8601String(),
            'description': transaction.description,
            'category': transaction.category,
            'merchant': transaction.merchant,
            'type': transaction.type.value,
          },
        );

  factory TransactionDashboardItem.fromJson(Map<String, dynamic> json) {
    final transaction =
        Transaction.fromJson(json['data'] as Map<String, dynamic>);
    return TransactionDashboardItem(
      transaction: transaction,
      iconName: json['iconName'] as String?,
      color: json['color'] as String?,
    );
  }

  factory TransactionDashboardItem.fromTransaction(Transaction transaction) {
    return TransactionDashboardItem(
      transaction: transaction,
    );
  }

  @override
  String get chipDisplayText =>
      '${transaction.formattedAmount} ${transaction.displayDescription}';
}

/// Budget dashboard item
class BudgetDashboardItem extends DashboardItem {
  final Budget budget;

  BudgetDashboardItem({
    required this.budget,
    String? iconName,
    String? color,
  }) : super(
          id: budget.id,
          type: DashboardItemType.budget,
          title: budget.categoryName,
          subtitle:
              '${budget.formattedSpent} of ${budget.formattedAllocated} (${budget.percentageUsed.toInt()}%)',
          iconName: iconName ?? budget.categoryIcon,
          color: color ?? budget.color,
          data: {
            'categoryId': budget.categoryId,
            'categoryName': budget.categoryName,
            'allocated': budget.allocated,
            'spent': budget.spent,
            'remaining': budget.remaining,
            'percentageUsed': budget.percentageUsed,
            'currency': budget.currency,
            'period': budget.period,
            'status': budget.status.name,
          },
        );

  factory BudgetDashboardItem.fromJson(Map<String, dynamic> json) {
    final budget = Budget.fromJson(json['data'] as Map<String, dynamic>);
    return BudgetDashboardItem(
      budget: budget,
      iconName: json['iconName'] as String?,
      color: json['color'] as String?,
    );
  }

  factory BudgetDashboardItem.fromBudget(Budget budget) {
    return BudgetDashboardItem(
      budget: budget,
    );
  }

  @override
  String get chipDisplayText =>
      '${budget.categoryName} Budget (${budget.percentageUsed.toInt()}%)';
}

/// Account dashboard item
class AccountDashboardItem extends DashboardItem {
  final MoneyAccount account;

  AccountDashboardItem({
    required this.account,
    String? iconName,
    String? color,
  }) : super(
          id: account.id,
          type: DashboardItemType.account,
          title: account.name,
          subtitle: '${account.formattedBalance} • ${account.typeDisplayName}',
          iconName: iconName ?? account.iconName,
          color: color,
          data: {
            'name': account.name,
            'type': account.type.value,
            'balance': account.balance,
            'currency': account.currency,
            'institutionName': account.institutionName,
            'accountNumber': account.accountNumber,
            'isActive': account.isActive,
          },
        );

  factory AccountDashboardItem.fromJson(Map<String, dynamic> json) {
    final account = MoneyAccount.fromJson(json['data'] as Map<String, dynamic>);
    return AccountDashboardItem(
      account: account,
      iconName: json['iconName'] as String?,
      color: json['color'] as String?,
    );
  }

  factory AccountDashboardItem.fromAccount(MoneyAccount account) {
    return AccountDashboardItem(
      account: account,
    );
  }

  @override
  String get chipDisplayText => '${account.name} (${account.formattedBalance})';
}

/// Goal dashboard item (for future implementation)
class GoalDashboardItem extends DashboardItem {
  const GoalDashboardItem({
    required String id,
    required String title,
    required String subtitle,
    String? iconName,
    String? color,
    required Map<String, dynamic> data,
  }) : super(
          id: id,
          type: DashboardItemType.goal,
          title: title,
          subtitle: subtitle,
          iconName: iconName ?? 'flag',
          color: color,
          data: data,
        );

  factory GoalDashboardItem.fromJson(Map<String, dynamic> json) {
    return GoalDashboardItem(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      iconName: json['iconName'] as String?,
      color: json['color'] as String?,
      data: json['data'] as Map<String, dynamic>,
    );
  }

  @override
  String get chipDisplayText => title;
}

/// Analysis dashboard item (for future implementation)
class AnalysisDashboardItem extends DashboardItem {
  const AnalysisDashboardItem({
    required String id,
    required String title,
    required String subtitle,
    String? iconName,
    String? color,
    required Map<String, dynamic> data,
  }) : super(
          id: id,
          type: DashboardItemType.analysis,
          title: title,
          subtitle: subtitle,
          iconName: iconName ?? 'analytics',
          color: color,
          data: data,
        );

  factory AnalysisDashboardItem.fromJson(Map<String, dynamic> json) {
    return AnalysisDashboardItem(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      iconName: json['iconName'] as String?,
      color: json['color'] as String?,
      data: json['data'] as Map<String, dynamic>,
    );
  }

  @override
  String get chipDisplayText => title;
}

/// Rich message content that combines text and dashboard items
class RichMessageContent {
  final String? text;
  final List<DashboardItem> dashboardItems;
  final String? imagePath;
  final Map<String, dynamic>? metadata;

  const RichMessageContent({
    this.text,
    this.dashboardItems = const [],
    this.imagePath,
    this.metadata,
  });

  factory RichMessageContent.fromText(String text) {
    return RichMessageContent(text: text);
  }

  factory RichMessageContent.fromDashboardItem(DashboardItem item) {
    return RichMessageContent(dashboardItems: [item]);
  }

  factory RichMessageContent.fromTextAndItems(
    String text,
    List<DashboardItem> items,
  ) {
    return RichMessageContent(
      text: text,
      dashboardItems: items,
    );
  }

  /// Check if message has any content
  bool get hasContent =>
      (text?.isNotEmpty ?? false) ||
      dashboardItems.isNotEmpty ||
      (imagePath?.isNotEmpty ?? false);

  /// Check if message has dashboard items
  bool get hasDashboardItems => dashboardItems.isNotEmpty;

  /// Get total content count
  int get contentCount {
    int count = 0;
    if (text?.isNotEmpty ?? false) count++;
    if (dashboardItems.isNotEmpty) count += dashboardItems.length;
    if (imagePath?.isNotEmpty ?? false) count++;
    return count;
  }

  /// Convert to JSON for API payload
  Map<String, dynamic> toJson() {
    return {
      if (text?.isNotEmpty ?? false) 'text': text,
      if (dashboardItems.isNotEmpty)
        'dashboard_items': dashboardItems.map((item) => item.toJson()).toList(),
      if (imagePath?.isNotEmpty ?? false) 'image_path': imagePath,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Create from JSON
  factory RichMessageContent.fromJson(Map<String, dynamic> json) {
    return RichMessageContent(
      text: json['text'] as String?,
      dashboardItems: (json['dashboard_items'] as List? ?? [])
          .map((item) => DashboardItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      imagePath: json['image_path'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Create copy with additional dashboard item
  RichMessageContent copyWithAddedItem(DashboardItem item) {
    return RichMessageContent(
      text: text,
      dashboardItems: [...dashboardItems, item],
      imagePath: imagePath,
      metadata: metadata,
    );
  }

  /// Create copy with removed dashboard item
  RichMessageContent copyWithRemovedItem(String itemId) {
    return RichMessageContent(
      text: text,
      dashboardItems:
          dashboardItems.where((item) => item.id != itemId).toList(),
      imagePath: imagePath,
      metadata: metadata,
    );
  }

  /// Create copy with updated text
  RichMessageContent copyWithText(String? newText) {
    return RichMessageContent(
      text: newText,
      dashboardItems: dashboardItems,
      imagePath: imagePath,
      metadata: metadata,
    );
  }
}
