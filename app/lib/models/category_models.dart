/// Models for Spending Categories and Budget Management
///
/// These models define the data structures for spending categories
/// and budget allocations, supporting the Profile screen's category
/// management functionality.

class SpendingCategory {
  final String id;
  final String name;
  final String iconName;
  final String colorHex;
  final bool isDefault;
  final double allocatedAmount;
  final double spentAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SpendingCategory({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorHex,
    required this.isDefault,
    required this.allocatedAmount,
    required this.spentAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SpendingCategory.fromJson(Map<String, dynamic> json) {
    return SpendingCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      iconName: json['iconName'] as String? ?? 'category',
      colorHex: json['colorHex'] as String? ?? '#4CAF50',
      isDefault: json['isDefault'] as bool? ?? false,
      allocatedAmount: _parseDouble(json['allocatedAmount']),
      spentAmount: _parseDouble(json['spentAmount']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'colorHex': colorHex,
      'isDefault': isDefault,
      'allocatedAmount': allocatedAmount,
      'spentAmount': spentAmount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy of this category with updated values
  SpendingCategory copyWith({
    String? id,
    String? name,
    String? iconName,
    String? colorHex,
    bool? isDefault,
    double? allocatedAmount,
    double? spentAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SpendingCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      isDefault: isDefault ?? this.isDefault,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get the remaining budget amount
  double get remainingAmount => allocatedAmount - spentAmount;

  /// Get the budget utilization percentage (0-100)
  double get utilizationPercentage {
    if (allocatedAmount <= 0) return 0.0;
    return (spentAmount / allocatedAmount * 100).clamp(0.0, 100.0);
  }

  /// Check if the budget is over the allocated amount
  bool get isOverBudget => spentAmount > allocatedAmount;

  /// Check if the category is near budget limit (80% or more)
  bool get isNearBudgetLimit => utilizationPercentage >= 80.0;

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpendingCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SpendingCategory(id: $id, name: $name, allocated: $allocatedAmount, spent: $spentAmount)';
  }
}

/// Request model for creating or updating a spending category
class CategoryRequest {
  final String? id; // null for create, required for update
  final String name;
  final String? iconName;
  final String? colorHex;
  final double? allocatedAmount;

  const CategoryRequest({
    this.id,
    required this.name,
    this.iconName,
    this.colorHex,
    this.allocatedAmount,
  });

  factory CategoryRequest.create({
    required String name,
    String? iconName,
    String? colorHex,
    double? allocatedAmount,
  }) {
    return CategoryRequest(
      name: name,
      iconName: iconName,
      colorHex: colorHex,
      allocatedAmount: allocatedAmount,
    );
  }

  factory CategoryRequest.update({
    required String id,
    required String name,
    String? iconName,
    String? colorHex,
    double? allocatedAmount,
  }) {
    return CategoryRequest(
      id: id,
      name: name,
      iconName: iconName,
      colorHex: colorHex,
      allocatedAmount: allocatedAmount,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': name,
    };

    if (id != null) json['id'] = id;
    if (iconName != null) json['iconName'] = iconName;
    if (colorHex != null) json['colorHex'] = colorHex;
    if (allocatedAmount != null) json['allocatedAmount'] = allocatedAmount;

    return json;
  }

  /// Validate the category request
  List<String> validate() {
    final errors = <String>[];

    if (name.trim().isEmpty) {
      errors.add('Category name is required');
    }

    if (name.trim().length > 50) {
      errors.add('Category name must be 50 characters or less');
    }

    if (allocatedAmount != null && allocatedAmount! < 0) {
      errors.add('Allocated amount cannot be negative');
    }

    if (colorHex != null && !_isValidHexColor(colorHex!)) {
      errors.add('Invalid color format. Use hex format like #FF5722');
    }

    return errors;
  }

  bool _isValidHexColor(String hexColor) {
    final regex = RegExp(r'^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$');
    return regex.hasMatch(hexColor);
  }

  @override
  String toString() {
    return 'CategoryRequest(id: $id, name: $name, allocated: $allocatedAmount)';
  }
}

/// Response model for categories API
class CategoriesResponse {
  final bool success;
  final List<SpendingCategory> categories;
  final int totalCount;
  final int defaultCount;
  final int customCount;
  final String? error;

  const CategoriesResponse({
    required this.success,
    required this.categories,
    required this.totalCount,
    required this.defaultCount,
    required this.customCount,
    this.error,
  });

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) {
    if (json['success'] == true) {
      final data = json['data'] as Map<String, dynamic>;
      final categoriesJson = data['categories'] as List<dynamic>;

      return CategoriesResponse(
        success: true,
        categories: categoriesJson
            .map((category) =>
                SpendingCategory.fromJson(category as Map<String, dynamic>))
            .toList(),
        totalCount: data['totalCount'] as int? ?? 0,
        defaultCount: data['defaultCount'] as int? ?? 0,
        customCount: data['customCount'] as int? ?? 0,
      );
    } else {
      final error = json['error'] as Map<String, dynamic>?;
      return CategoriesResponse(
        success: false,
        categories: [],
        totalCount: 0,
        defaultCount: 0,
        customCount: 0,
        error: error?['message'] as String? ?? 'Unknown error',
      );
    }
  }

  /// Get categories separated by type
  List<SpendingCategory> get defaultCategories =>
      categories.where((category) => category.isDefault).toList();

  List<SpendingCategory> get customCategories =>
      categories.where((category) => !category.isDefault).toList();

  /// Calculate total allocated budget
  double get totalAllocatedBudget =>
      categories.fold(0.0, (sum, category) => sum + category.allocatedAmount);

  /// Calculate total spent amount
  double get totalSpentAmount =>
      categories.fold(0.0, (sum, category) => sum + category.spentAmount);

  /// Get overall budget utilization percentage
  double get overallUtilizationPercentage {
    if (totalAllocatedBudget <= 0) return 0.0;
    return (totalSpentAmount / totalAllocatedBudget * 100).clamp(0.0, 100.0);
  }

  @override
  String toString() {
    return 'CategoriesResponse(success: $success, count: $totalCount, error: $error)';
  }
}

/// Response model for category operations (create/update)
class CategoryOperationResponse {
  final bool success;
  final SpendingCategory? category;
  final String operation;
  final String? error;

  const CategoryOperationResponse({
    required this.success,
    this.category,
    required this.operation,
    this.error,
  });

  factory CategoryOperationResponse.fromJson(Map<String, dynamic> json) {
    if (json['success'] == true) {
      final data = json['data'] as Map<String, dynamic>;
      return CategoryOperationResponse(
        success: true,
        category:
            SpendingCategory.fromJson(data['category'] as Map<String, dynamic>),
        operation: data['operation'] as String,
      );
    } else {
      final error = json['error'] as Map<String, dynamic>?;
      return CategoryOperationResponse(
        success: false,
        operation: error?['operation'] as String? ?? 'unknown',
        error: error?['message'] as String? ?? 'Unknown error',
      );
    }
  }

  @override
  String toString() {
    return 'CategoryOperationResponse(success: $success, operation: $operation, error: $error)';
  }
}
