import 'package:flutter/foundation.dart';
import '../models/category_models.dart';
import '../services/category_service.dart';

/// Provider for managing spending categories and budget state
///
/// This provider handles the application state for spending categories,
/// including fetching from the API, local state management, and
/// coordinating updates between the UI and backend.
class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  // State variables
  List<SpendingCategory> _categories = [];
  bool _isLoading = false;
  String? _error;
  bool _hasInitialized = false;

  // Getters
  List<SpendingCategory> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasInitialized => _hasInitialized;

  /// Get categories separated by type
  List<SpendingCategory> get defaultCategories =>
      _categories.where((category) => category.isDefault).toList();

  List<SpendingCategory> get customCategories =>
      _categories.where((category) => !category.isDefault).toList();

  /// Calculate total allocated budget across all categories
  double get totalAllocatedBudget =>
      _categories.fold(0.0, (sum, category) => sum + category.allocatedAmount);

  /// Calculate total spent amount across all categories
  double get totalSpentAmount =>
      _categories.fold(0.0, (sum, category) => sum + category.spentAmount);

  /// Get overall budget utilization percentage
  double get overallUtilizationPercentage {
    if (totalAllocatedBudget <= 0) return 0.0;
    return (totalSpentAmount / totalAllocatedBudget * 100).clamp(0.0, 100.0);
  }

  /// Check if any category is over budget
  bool get hasOverBudgetCategories =>
      _categories.any((category) => category.isOverBudget);

  /// Get categories that are near budget limit (80% or more)
  List<SpendingCategory> get nearBudgetLimitCategories =>
      _categories.where((category) => category.isNearBudgetLimit).toList();

  /// Load categories from the API
  ///
  /// This method fetches all spending categories for the authenticated user
  /// from the n8n API endpoint. It handles loading states and error management.
  Future<void> loadCategories({required String authToken}) async {
    if (_isLoading) return; // Prevent multiple simultaneous requests

    _setLoading(true);
    _clearError();

    try {
      final response = await _categoryService.getCategories(
        authToken: authToken,
      );

      if (response.success) {
        _categories = response.categories;
        _hasInitialized = true;
        notifyListeners();
      } else {
        _setError(response.error ?? 'Failed to load categories');
      }
    } on CategoryServiceException catch (e) {
      _setError(e.userFriendlyMessage);
    } catch (e) {
      _setError('An unexpected error occurred while loading categories');
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new spending category
  ///
  /// Adds a new category via the API and updates the local state
  /// with optimistic updates for better user experience.
  Future<bool> createCategory({
    required String authToken,
    required CategoryRequest categoryRequest,
  }) async {
    if (_isLoading) return false;

    _setLoading(true);
    _clearError();

    try {
      final response = await _categoryService.createCategory(
        authToken: authToken,
        categoryRequest: categoryRequest,
      );

      if (response.success && response.category != null) {
        // Add the new category to the local list
        _categories.add(response.category!);
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to create category');
        return false;
      }
    } on CategoryServiceException catch (e) {
      _setError(e.userFriendlyMessage);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred while creating the category');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing spending category
  ///
  /// Updates a category via the API and refreshes the local state.
  /// Uses optimistic updates to provide immediate UI feedback.
  Future<bool> updateCategory({
    required String authToken,
    required CategoryRequest categoryRequest,
  }) async {
    if (_isLoading || categoryRequest.id == null) return false;

    // Find the existing category for optimistic update
    final existingCategoryIndex = _categories.indexWhere(
      (category) => category.id == categoryRequest.id,
    );

    if (existingCategoryIndex == -1) {
      _setError('Category not found');
      return false;
    }

    final originalCategory = _categories[existingCategoryIndex];

    // Optimistic update - update the UI immediately
    final optimisticCategory = originalCategory.copyWith(
      name: categoryRequest.name,
      iconName: categoryRequest.iconName ?? originalCategory.iconName,
      colorHex: categoryRequest.colorHex ?? originalCategory.colorHex,
      allocatedAmount:
          categoryRequest.allocatedAmount ?? originalCategory.allocatedAmount,
      updatedAt: DateTime.now(),
    );

    _categories[existingCategoryIndex] = optimisticCategory;
    notifyListeners();

    try {
      final response = await _categoryService.updateCategory(
        authToken: authToken,
        categoryRequest: categoryRequest,
      );

      if (response.success && response.category != null) {
        // Replace with the actual server response
        _categories[existingCategoryIndex] = response.category!;
        notifyListeners();
        return true;
      } else {
        // Revert optimistic update on failure
        _categories[existingCategoryIndex] = originalCategory;
        _setError(response.error ?? 'Failed to update category');
        notifyListeners();
        return false;
      }
    } on CategoryServiceException catch (e) {
      // Revert optimistic update on error
      _categories[existingCategoryIndex] = originalCategory;
      _setError(e.userFriendlyMessage);
      notifyListeners();
      return false;
    } catch (e) {
      // Revert optimistic update on error
      _categories[existingCategoryIndex] = originalCategory;
      _setError('An unexpected error occurred while updating the category');
      notifyListeners();
      return false;
    }
  }

  /// Delete a spending category
  ///
  /// Removes a category via the API and updates the local state.
  /// Only custom (non-default) categories can be deleted.
  Future<bool> deleteCategory({
    required String authToken,
    required String categoryId,
  }) async {
    if (_isLoading) return false;

    // Find the category to delete
    final categoryIndex = _categories.indexWhere(
      (category) => category.id == categoryId,
    );

    if (categoryIndex == -1) {
      _setError('Category not found');
      return false;
    }

    final categoryToDelete = _categories[categoryIndex];

    // Check if it's a default category (cannot be deleted)
    if (categoryToDelete.isDefault) {
      _setError('Default categories cannot be deleted');
      return false;
    }

    // Optimistic update - remove from UI immediately
    _categories.removeAt(categoryIndex);
    notifyListeners();

    try {
      final response = await _categoryService.deleteCategory(
        authToken: authToken,
        categoryId: categoryId,
      );

      if (response.success) {
        // Deletion successful, no need to update UI (already removed)
        return true;
      } else {
        // Revert optimistic update on failure
        _categories.insert(categoryIndex, categoryToDelete);
        _setError(response.error ?? 'Failed to delete category');
        notifyListeners();
        return false;
      }
    } on CategoryServiceException catch (e) {
      // Revert optimistic update on error
      _categories.insert(categoryIndex, categoryToDelete);
      _setError(e.userFriendlyMessage);
      notifyListeners();
      return false;
    } catch (e) {
      // Revert optimistic update on error
      _categories.insert(categoryIndex, categoryToDelete);
      _setError('An unexpected error occurred while deleting the category');
      notifyListeners();
      return false;
    }
  }

  /// Find a category by ID
  SpendingCategory? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  /// Check if a category name already exists (case-insensitive)
  bool isCategoryNameTaken(String name, {String? excludeId}) {
    return _categories.any((category) =>
        category.name.toLowerCase() == name.toLowerCase() &&
        category.id != excludeId);
  }

  /// Refresh categories by reloading from the API
  Future<void> refreshCategories({required String authToken}) async {
    await loadCategories(authToken: authToken);
  }

  /// Clear all categories (useful for logout)
  void clearCategories() {
    _categories.clear();
    _hasInitialized = false;
    _clearError();
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  @override
  String toString() {
    return 'CategoryProvider(categories: ${_categories.length}, loading: $_isLoading, error: $_error)';
  }
}
