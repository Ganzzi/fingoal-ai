import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/auth_provider.dart';
import '../models/category_models.dart';

/// Category Edit Screen
///
/// This screen allows users to edit existing spending categories,
/// including updating name, icon, color, and budget allocation.
class CategoryEditScreen extends StatefulWidget {
  final SpendingCategory category;

  const CategoryEditScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryEditScreen> createState() => _CategoryEditScreenState();
}

class _CategoryEditScreenState extends State<CategoryEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();

  String _selectedIcon = '';
  String _selectedColor = '';
  bool _isLoading = false;

  // Available icons for categories
  static const List<Map<String, dynamic>> _availableIcons = [
    {'name': 'restaurant', 'icon': Icons.restaurant_outlined},
    {'name': 'directions_car', 'icon': Icons.directions_car_outlined},
    {'name': 'shopping_bag', 'icon': Icons.shopping_bag_outlined},
    {'name': 'movie', 'icon': Icons.movie_outlined},
    {'name': 'lightbulb', 'icon': Icons.lightbulb_outlined},
    {'name': 'medical_services', 'icon': Icons.medical_services_outlined},
    {'name': 'school', 'icon': Icons.school_outlined},
    {'name': 'home', 'icon': Icons.home_outlined},
    {'name': 'work', 'icon': Icons.work_outlined},
    {'name': 'fitness_center', 'icon': Icons.fitness_center_outlined},
    {'name': 'travel_explore', 'icon': Icons.travel_explore_outlined},
    {'name': 'pets', 'icon': Icons.pets_outlined},
    {'name': 'phone', 'icon': Icons.phone_outlined},
    {'name': 'savings', 'icon': Icons.savings_outlined},
    {'name': 'celebration', 'icon': Icons.celebration_outlined},
  ];

  // Available colors for categories
  static const List<String> _availableColors = [
    '#F44336', // Red
    '#E91E63', // Pink
    '#9C27B0', // Purple
    '#673AB7', // Deep Purple
    '#3F51B5', // Indigo
    '#2196F3', // Blue
    '#03A9F4', // Light Blue
    '#00BCD4', // Cyan
    '#009688', // Teal
    '#4CAF50', // Green
    '#8BC34A', // Light Green
    '#CDDC39', // Lime
    '#FFEB3B', // Yellow
    '#FFC107', // Amber
    '#FF9800', // Orange
    '#FF5722', // Deep Orange
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  /// Initialize form fields with current category data
  void _initializeFields() {
    _nameController.text = widget.category.name;
    _budgetController.text = widget.category.allocatedAmount.toStringAsFixed(2);
    _selectedIcon = widget.category.iconName;
    _selectedColor = widget.category.colorHex;
  }

  /// Parse color from hex string
  Color _parseColor(String colorHex) {
    try {
      String hex = colorHex.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex'; // Add alpha channel
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.blue; // Default color
    }
  }

  /// Get IconData from icon name
  IconData _getIconFromName(String iconName) {
    final iconData = _availableIcons.firstWhere(
      (icon) => icon['name'] == iconName,
      orElse: () => _availableIcons[0],
    )['icon'] as IconData;
    return iconData;
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

  /// Validate and save category changes
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final categoryProvider = context.read<CategoryProvider>();

      final authToken = await authProvider.authService.getToken();
      if (authToken == null) {
        _showSnackBar('Please log in again to save changes', isError: true);
        return;
      }

      // Check if name already exists (excluding current category)
      if (categoryProvider.isCategoryNameTaken(
        _nameController.text.trim(),
        excludeId: widget.category.id,
      )) {
        _showSnackBar('Category name already exists', isError: true);
        return;
      }

      final categoryRequest = CategoryRequest.update(
        id: widget.category.id,
        name: _nameController.text.trim(),
        iconName: _selectedIcon,
        colorHex: _selectedColor,
        allocatedAmount: double.tryParse(_budgetController.text) ?? 0.0,
      );

      final success = await categoryProvider.updateCategory(
        authToken: authToken,
        categoryRequest: categoryRequest,
      );

      if (success) {
        _showSnackBar('Category updated successfully');
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        _showSnackBar(
          categoryProvider.error ?? 'Failed to update category',
          isError: true,
        );
      }
    } catch (e) {
      print('Error updating category: $e');
      _showSnackBar('Failed to update category', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Show icon picker dialog
  Future<void> _showIconPicker() async {
    final selectedIcon = await showDialog<String>(
      context: context,
      builder: (context) => _IconPickerDialog(
        currentIcon: _selectedIcon,
        availableIcons: _availableIcons,
      ),
    );

    if (selectedIcon != null && selectedIcon != _selectedIcon) {
      setState(() {
        _selectedIcon = selectedIcon;
      });
    }
  }

  /// Show color picker dialog
  Future<void> _showColorPicker() async {
    final selectedColor = await showDialog<String>(
      context: context,
      builder: (context) => _ColorPickerDialog(
        currentColor: _selectedColor,
        availableColors: _availableColors,
      ),
    );

    if (selectedColor != null && selectedColor != _selectedColor) {
      setState(() {
        _selectedColor = selectedColor;
      });
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
          'Edit Category',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: colorScheme.onSurfaceVariant,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveChanges,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview section
              _buildPreviewSection(colorScheme, textTheme),

              const SizedBox(height: 32),

              // Category Name
              _buildNameField(colorScheme, textTheme),

              const SizedBox(height: 24),

              // Icon Selection
              _buildIconSelection(colorScheme, textTheme),

              const SizedBox(height: 24),

              // Color Selection
              _buildColorSelection(colorScheme, textTheme),

              const SizedBox(height: 24),

              // Budget Allocation
              _buildBudgetField(colorScheme, textTheme),

              const SizedBox(height: 32),

              // Current Category Info
              _buildCurrentInfo(colorScheme, textTheme),
            ],
          ),
        ),
      ),
    );
  }

  /// Build preview section
  Widget _buildPreviewSection(ColorScheme colorScheme, TextTheme textTheme) {
    final previewColor = _parseColor(_selectedColor);
    final previewIcon = _getIconFromName(_selectedIcon);

    return Card(
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
              'Preview',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: previewColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  previewIcon,
                  color: previewColor,
                  size: 24,
                ),
              ),
              title: Text(
                _nameController.text.isEmpty
                    ? 'Category Name'
                    : _nameController.text,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'Budget: \$${_budgetController.text.isEmpty ? "0.00" : _budgetController.text}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build name field
  Widget _buildNameField(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category Name',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Enter category name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.edit_outlined),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a category name';
            }
            if (value.trim().length < 2) {
              return 'Category name must be at least 2 characters';
            }
            return null;
          },
          onChanged: (_) => setState(() {}), // Update preview
        ),
      ],
    );
  }

  /// Build icon selection
  Widget _buildIconSelection(ColorScheme colorScheme, TextTheme textTheme) {
    final selectedIconData = _getIconFromName(_selectedIcon);
    final selectedColor = _parseColor(_selectedColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Icon',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _showIconPicker,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: selectedColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    selectedIconData,
                    color: selectedColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Tap to select icon',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build color selection
  Widget _buildColorSelection(ColorScheme colorScheme, TextTheme textTheme) {
    final selectedColor = _parseColor(_selectedColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _showColorPicker,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: selectedColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _selectedColor.toUpperCase(),
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build budget field
  Widget _buildBudgetField(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Budget',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _budgetController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
          ],
          decoration: InputDecoration(
            hintText: '0.00',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.attach_money),
            suffixText: 'USD',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a budget amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount < 0) {
              return 'Please enter a valid amount';
            }
            return null;
          },
          onChanged: (_) => setState(() {}), // Update preview
        ),
      ],
    );
  }

  /// Build current category info
  Widget _buildCurrentInfo(ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Spending',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '\$${widget.category.spentAmount.toStringAsFixed(2)}',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: widget.category.isOverBudget
                              ? colorScheme.error
                              : colorScheme.secondary,
                        ),
                      ),
                      Text(
                        'Spent This Month',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${widget.category.utilizationPercentage.toStringAsFixed(1)}%',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: widget.category.isOverBudget
                              ? colorScheme.error
                              : colorScheme.primary,
                        ),
                      ),
                      Text(
                        'Budget Used',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.category.isDefault) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'This is a default category',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Icon Picker Dialog
class _IconPickerDialog extends StatelessWidget {
  final String currentIcon;
  final List<Map<String, dynamic>> availableIcons;

  const _IconPickerDialog({
    required this.currentIcon,
    required this.availableIcons,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: Text(
        'Select Icon',
        style: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: availableIcons.length,
          itemBuilder: (context, index) {
            final icon = availableIcons[index];
            final isSelected = icon['name'] == currentIcon;

            return InkWell(
              onTap: () => Navigator.of(context).pop(icon['name'] as String),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withOpacity(0.1)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outline.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon['icon'] as IconData,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  size: 28,
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// Color Picker Dialog
class _ColorPickerDialog extends StatelessWidget {
  final String currentColor;
  final List<String> availableColors;

  const _ColorPickerDialog({
    required this.currentColor,
    required this.availableColors,
  });

  Color _parseColor(String colorHex) {
    try {
      String hex = colorHex.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: Text(
        'Select Color',
        style: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: availableColors.length,
          itemBuilder: (context, index) {
            final colorHex = availableColors[index];
            final color = _parseColor(colorHex);
            final isSelected = colorHex == currentColor;

            return InkWell(
              onTap: () => Navigator.of(context).pop(colorHex),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(
                    color:
                        isSelected ? colorScheme.onSurface : Colors.transparent,
                    width: isSelected ? 3 : 0,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24,
                      )
                    : null,
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
