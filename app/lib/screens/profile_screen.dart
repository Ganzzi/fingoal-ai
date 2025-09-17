import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

/// Profile Screen UI Shell
///
/// This screen provides a static profile interface for the FinGoal AI app.
/// It displays placeholder content for user profile information and spending
/// categories without any data persistence or loading functionality.
///
/// Features:
/// - User Profile section with avatar and contact information
/// - Spending Categories section with common expense categories
/// - Material Design 3 theming throughout
/// - Responsive design for different screen sizes
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Static spending categories for placeholder UI
  static const List<SpendingCategory> _spendingCategories = [
    SpendingCategory(
      icon: Icons.restaurant_outlined,
      name: 'Food & Dining',
      color: Colors.orange,
    ),
    SpendingCategory(
      icon: Icons.directions_car_outlined,
      name: 'Transportation',
      color: Colors.blue,
    ),
    SpendingCategory(
      icon: Icons.shopping_bag_outlined,
      name: 'Shopping',
      color: Colors.purple,
    ),
    SpendingCategory(
      icon: Icons.movie_outlined,
      name: 'Entertainment',
      color: Colors.red,
    ),
    SpendingCategory(
      icon: Icons.lightbulb_outlined,
      name: 'Utilities',
      color: Colors.green,
    ),
    SpendingCategory(
      icon: Icons.medical_services_outlined,
      name: 'Healthcare',
      color: Colors.teal,
    ),
    SpendingCategory(
      icon: Icons.school_outlined,
      name: 'Education',
      color: Colors.indigo,
    ),
    SpendingCategory(
      icon: Icons.home_outlined,
      name: 'Housing',
      color: Colors.brown,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l10n.profile,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            _buildUserProfileSection(context, colorScheme, textTheme, l10n),

            const SizedBox(height: 24),

            // Spending Categories Section
            _buildSpendingCategoriesSection(
                context, colorScheme, textTheme, l10n),

            const SizedBox(height: 24),

            // Language Settings Section
            _buildLanguageSection(context, colorScheme, textTheme, l10n),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Get localized category name
  String _getLocalizedCategoryName(AppLocalizations l10n, String categoryKey) {
    switch (categoryKey) {
      case 'Food & Dining':
        return l10n.foodDining;
      case 'Transportation':
        return l10n.transportation;
      case 'Shopping':
        return l10n.shopping;
      case 'Entertainment':
        return l10n.entertainment;
      case 'Utilities':
        return l10n.utilities;
      case 'Healthcare':
        return l10n.healthcare;
      case 'Education':
        return l10n.education;
      case 'Housing':
        return l10n.housing;
      default:
        return categoryKey;
    }
  }

  /// Build Language Settings section
  Widget _buildLanguageSection(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    AppLocalizations l10n,
  ) {
    final languageProvider = Provider.of<LanguageProvider>(context);

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
              l10n.language,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: languageProvider.currentLanguageCode,
              decoration: InputDecoration(
                labelText: l10n.selectLanguage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ),
              items: [
                DropdownMenuItem(
                  value: 'en',
                  child: Text(l10n.english),
                ),
                DropdownMenuItem(
                  value: 'vi',
                  child: Text(l10n.vietnamese),
                ),
              ],
              onChanged: (String? newLanguage) {
                if (newLanguage != null) {
                  languageProvider.changeLanguage(newLanguage);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.languageChanged),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build User Profile section with avatar and user information
  Widget _buildUserProfileSection(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar and Edit Button Row
            Row(
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),

                const SizedBox(width: 16),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'John Doe',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'FinGoal AI User',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Edit Button (placeholder)
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edit profile coming in future updates'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(l10n.edit),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Contact Information
            Column(
              children: [
                _buildInfoTile(
                  context,
                  colorScheme,
                  textTheme,
                  Icons.email_outlined,
                  'Email',
                  'john.doe@example.com',
                ),
                const SizedBox(height: 12),
                _buildInfoTile(
                  context,
                  colorScheme,
                  textTheme,
                  Icons.phone_outlined,
                  'Phone',
                  '+1 (555) 123-4567',
                ),
                const SizedBox(height: 12),
                _buildInfoTile(
                  context,
                  colorScheme,
                  textTheme,
                  Icons.location_on_outlined,
                  'Location',
                  'New York, NY',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual info tile for contact information
  Widget _buildInfoTile(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build Spending Categories section with category list
  Widget _buildSpendingCategoriesSection(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.spendingCategories,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Category management coming in future updates'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text(l10n.manage),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Categories Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Build category tiles
              for (int i = 0; i < _spendingCategories.length; i++) ...[
                _buildCategoryTile(
                  context,
                  colorScheme,
                  textTheme,
                  l10n,
                  _spendingCategories[i],
                ),
                if (i < _spendingCategories.length - 1)
                  Divider(
                    height: 1,
                    indent: 72,
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Build individual category tile
  Widget _buildCategoryTile(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    AppLocalizations l10n,
    SpendingCategory category,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: category.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          category.icon,
          color: category.color,
          size: 24,
        ),
      ),
      title: Text(
        _getLocalizedCategoryName(l10n, category.name),
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        l10n.tapToManageCategory,
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${category.name} management coming soon'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }
}

/// Spending Category data class
class SpendingCategory {
  const SpendingCategory({
    required this.icon,
    required this.name,
    required this.color,
  });

  final IconData icon;
  final String name;
  final Color color;
}
