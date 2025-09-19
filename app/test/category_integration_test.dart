import 'package:flutter_test/flutter_test.dart';
import 'package:fingoal/models/category_models.dart';
import 'package:fingoal/services/category_service.dart';

void main() {
  group('Category Models Tests', () {
    test('SpendingCategory should be created correctly', () {
      final category = SpendingCategory(
        id: '1',
        name: 'Food & Dining',
        iconName: 'restaurant',
        colorHex: 'FF4CAF50',
        allocatedAmount: 800.0,
        spentAmount: 650.0,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(category.id, '1');
      expect(category.name, 'Food & Dining');
      expect(category.iconName, 'restaurant');
      expect(category.colorHex, 'FF4CAF50');
      expect(category.allocatedAmount, 800.0);
      expect(category.spentAmount, 650.0);
      expect(category.isDefault, true);
    });

    test('SpendingCategory utility methods should work correctly', () {
      final category = SpendingCategory(
        id: '1',
        name: 'Food & Dining',
        iconName: 'restaurant',
        colorHex: 'FF4CAF50',
        allocatedAmount: 800.0,
        spentAmount: 650.0,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Test budget utilization
      expect(category.utilizationPercentage, 81.25);
      expect(category.remainingAmount, 150.0);
      expect(category.isOverBudget, false);
      expect(category.isNearBudgetLimit, true); // >80%
    });

    test('SpendingCategory over budget scenario', () {
      final category = SpendingCategory(
        id: '1',
        name: 'Food & Dining',
        iconName: 'restaurant',
        colorHex: 'FF4CAF50',
        allocatedAmount: 800.0,
        spentAmount: 850.0, // Over budget
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(category.utilizationPercentage, 100.0); // Clamped to 100%
      expect(category.remainingAmount, -50.0);
      expect(category.isOverBudget, true);
      expect(category.isNearBudgetLimit, true);
    });

    test('CategoryRequest should be created correctly', () {
      const request = CategoryRequest(
        name: 'New Category',
        iconName: 'shopping_bag',
        colorHex: 'FFFF9800',
        allocatedAmount: 500.0,
      );

      expect(request.name, 'New Category');
      expect(request.iconName, 'shopping_bag');
      expect(request.colorHex, 'FFFF9800');
      expect(request.allocatedAmount, 500.0);
      expect(request.id, null);
    });

    test('CategoryRequest allows empty name and negative amounts', () {
      // The model itself doesn't validate - validation happens in the service layer
      const request1 = CategoryRequest(name: '', allocatedAmount: 100.0);
      const request2 = CategoryRequest(name: 'Valid', allocatedAmount: -10.0);

      expect(request1.name, '');
      expect(request1.allocatedAmount, 100.0);
      expect(request2.name, 'Valid');
      expect(request2.allocatedAmount, -10.0);
    });

    test('CategoriesResponse should be created correctly', () {
      final categories = [
        SpendingCategory(
          id: '1',
          name: 'Food',
          iconName: 'restaurant',
          colorHex: 'FF4CAF50',
          allocatedAmount: 800.0,
          spentAmount: 650.0,
          isDefault: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final response = CategoriesResponse(
        success: true,
        categories: categories,
        totalCount: 1,
        defaultCount: 1,
        customCount: 0,
      );

      expect(response.success, true);
      expect(response.categories.length, 1);
      expect(response.categories.first.name, 'Food');
      expect(response.error, null);
    });

    test('CategoryOperationResponse should handle success correctly', () {
      final category = SpendingCategory(
        id: '1',
        name: 'Food',
        iconName: 'restaurant',
        colorHex: 'FF4CAF50',
        allocatedAmount: 800.0,
        spentAmount: 650.0,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final response = CategoryOperationResponse(
        success: true,
        operation: 'create',
        category: category,
      );

      expect(response.success, true);
      expect(response.category, isNotNull);
      expect(response.category!.name, 'Food');
      expect(response.error, null);
    });

    test('CategoryOperationResponse should handle error correctly', () {
      const response = CategoryOperationResponse(
        success: false,
        operation: 'create',
        error: 'Failed to create category',
      );

      expect(response.success, false);
      expect(response.category, null);
      expect(response.error, 'Failed to create category');
    });

    test('SpendingCategory copyWith should work correctly', () {
      final original = SpendingCategory(
        id: '1',
        name: 'Food',
        iconName: 'restaurant',
        colorHex: 'FF4CAF50',
        allocatedAmount: 800.0,
        spentAmount: 650.0,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = original.copyWith(
        name: 'Food & Dining',
        allocatedAmount: 900.0,
      );

      expect(updated.id, original.id);
      expect(updated.name, 'Food & Dining');
      expect(updated.allocatedAmount, 900.0);
      expect(updated.spentAmount, original.spentAmount);
      expect(updated.iconName, original.iconName);
    });
  });

  group('CategoryService Tests', () {
    test('CategoryServiceException should be created correctly', () {
      const exception = CategoryServiceException(
        message: 'Network error',
        type: CategoryServiceExceptionType.networkError,
      );

      expect(exception.message, 'Network error');
      expect(exception.type, CategoryServiceExceptionType.networkError);
      expect(exception.toString(), contains('Network error'));
    });

    test('CategoryServiceException should have user friendly message', () {
      const exception = CategoryServiceException(
        message: 'Technical error',
        type: CategoryServiceExceptionType.unknown,
      );

      expect(exception.message, 'Technical error');
      expect(exception.type, CategoryServiceExceptionType.unknown);
      expect(exception.userFriendlyMessage, contains('error occurred'));
    });
  });
}
