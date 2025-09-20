import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/auth_provider.dart';
import '../models/category_models.dart';
import 'category_edit_screen.dart';

/// Category Management Screen
///
/// This screen allows users to view, add, edit, and delete their
/// spending categories with budget allocation management.
/// Edit functionality updated!
class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh categories when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshCategories();
    });
  }

  /// Refresh categories from API
  Future<void> _refreshCategories() async {
    final authProvider = context.read<AuthProvider>();
    final categoryProvider = context.read<CategoryProvider>();

    try {
      final authToken = await authProvider.authService.getToken();
      if (authToken == null) {
        _showSnackBar('Please log in again to refresh categories',
            isError: true);
        return;
      }

      await categoryProvider.refreshCategories(authToken: authToken);
    } catch (e) {
      print('Error refreshing categories: $e');
      _showSnackBar('Failed to refresh categories', isError: true);
    }
  }

  /// Show snack bar message
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Navigate to add new category
  void _addCategory() {
    _showSnackBar('Add category functionality coming soon');
  }

  /// Navigate to edit existing category
  Future<void> _editCategory(SpendingCategory category) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => CategoryEditScreen(category: category),
      ),
    );

    // Refresh categories if the edit was successful
    if (result == true) {
      await _refreshCategories();
    }
  }

  /// Delete category with confirmation
  Future<void> _deleteCategory(SpendingCategory category) async {
    if (category.isDefault) {
      _showSnackBar('Default categories cannot be deleted', isError: true);
      return;
    }

    final confirmed = await _showDeleteConfirmation(category);
    if (!confirmed) return;

    final authProvider = context.read<AuthProvider>();
    final categoryProvider = context.read<CategoryProvider>();

    try {
      final authToken = await authProvider.authService.getToken();
      if (authToken == null) {
        _showSnackBar('Please log in again to delete categories',
            isError: true);
        return;
      }

      final success = await categoryProvider.deleteCategory(
        authToken: authToken,
        categoryId: category.id,
      );

      if (success) {
        _showSnackBar('Category deleted successfully');
      } else {
        _showSnackBar(
          categoryProvider.error ?? 'Failed to delete category',
          isError: true,
        );
      }
    } catch (e) {
      print('Error deleting category: $e');
      _showSnackBar('Failed to delete category', isError: true);
    }
  }

  /// Show delete confirmation dialog
  Future<bool> _showDeleteConfirmation(SpendingCategory category) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Category'),
            content: Text(
              'Are you sure you want to delete "${category.name}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Parse color from hex string
  Color _parseColor(String colorHex) {
    try {
      return Color(int.parse(colorHex, radix: 16));
    } catch (e) {
      return Colors.blue; // Default color
    }
  }

  /// Map Material icon name to IconData
  IconData _getCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'restaurant':
      case 'restaurant_outlined':
        return Icons.restaurant_outlined;
      case 'directions_car':
      case 'directions_car_outlined':
        return Icons.directions_car_outlined;
      case 'shopping_bag':
      case 'shopping_bag_outlined':
        return Icons.shopping_bag_outlined;
      case 'movie':
      case 'movie_outlined':
        return Icons.movie_outlined;
      case 'lightbulb':
      case 'lightbulb_outlined':
        return Icons.lightbulb_outlined;
      case 'medical_services':
      case 'medical_services_outlined':
        return Icons.medical_services_outlined;
      case 'school':
      case 'school_outlined':
        return Icons.school_outlined;
      case 'home':
      case 'home_outlined':
        return Icons.home_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Manage Categories',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.onSurfaceVariant,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          return RefreshIndicator(
            onRefresh: _refreshCategories,
            child: CustomScrollView(
              slivers: [
                // Summary section
                SliverToBoxAdapter(
                  child: _buildSummarySection(
                    colorScheme,
                    textTheme,
                    categoryProvider,
                  ),
                ),

                // Categories list
                if (categoryProvider.isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (categoryProvider.error != null)
                  SliverFillRemaining(
                    child: _buildErrorState(
                      colorScheme,
                      textTheme,
                      categoryProvider.error!,
                    ),
                  )
                else if (categoryProvider.categories.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(colorScheme, textTheme),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final category = categoryProvider.categories[index];
                          return _buildCategoryTile(
                            colorScheme,
                            textTheme,
                            category,
                          );
                        },
                        childCount: categoryProvider.categories.length,
                      ),
                    ),
                  ),

                // Bottom spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Build summary section
  Widget _buildSummarySection(
    ColorScheme colorScheme,
    TextTheme textTheme,
    CategoryProvider categoryProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Budget Overview',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '\$${categoryProvider.totalAllocatedBudget.toStringAsFixed(2)}',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Total Budget',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '\$${categoryProvider.totalSpentAmount.toStringAsFixed(2)}',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: categoryProvider.hasOverBudgetCategories
                                ? colorScheme.error
                                : colorScheme.secondary,
                          ),
                        ),
                        Text(
                          'Total Spent',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${categoryProvider.categories.length}',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.tertiary,
                          ),
                        ),
                        Text(
                          'Categories',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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

  /// Build category tile
  Widget _buildCategoryTile(
    ColorScheme colorScheme,
    TextTheme textTheme,
    SpendingCategory category,
  ) {
    final categoryColor = _parseColor(category.colorHex);
    final categoryIcon = _getCategoryIcon(category.iconName);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            categoryIcon,
            color: categoryColor,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                category.name,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            if (category.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Default',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Budget: \$${category.allocatedAmount.toStringAsFixed(2)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Spent: \$${category.spentAmount.toStringAsFixed(2)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: category.isOverBudget
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: category.utilizationPercentage / 100,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                category.isOverBudget
                    ? colorScheme.error
                    : category.isNearBudgetLimit
                        ? Colors.orange
                        : categoryColor,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editCategory(category);
                break;
              case 'delete':
                if (!category.isDefault) {
                  _deleteCategory(category);
                }
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text('Edit'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            if (!category.isDefault)
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
        onTap: () => _editCategory(category),
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(
    ColorScheme colorScheme,
    TextTheme textTheme,
    String error,
  ) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
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
            'Error Loading Categories',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refreshCategories,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No Categories Yet',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first spending category to start tracking your budget.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addCategory,
            icon: const Icon(Icons.add),
            label: const Text('Add Category'),
          ),
        ],
      ),
    );
  }
}
