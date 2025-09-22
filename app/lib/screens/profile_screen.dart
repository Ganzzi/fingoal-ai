import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/category_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/auth_provider.dart';
import '../models/category_models.dart';
import '../models/user_profile_models.dart';
import '../widgets/notification_widgets.dart';
import 'profile_edit_screen.dart';
import 'category_management_screen.dart';
import 'category_edit_screen.dart';

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
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Static spending categories for fallback UI if API fails
  static const List<_StaticSpendingCategory> _fallbackCategories = [
    _StaticSpendingCategory(
      icon: Icons.restaurant_outlined,
      name: 'Food & Dining',
      color: Colors.orange,
    ),
    _StaticSpendingCategory(
      icon: Icons.directions_car_outlined,
      name: 'Transportation',
      color: Colors.blue,
    ),
    _StaticSpendingCategory(
      icon: Icons.shopping_bag_outlined,
      name: 'Shopping',
      color: Colors.purple,
    ),
    _StaticSpendingCategory(
      icon: Icons.movie_outlined,
      name: 'Entertainment',
      color: Colors.red,
    ),
    _StaticSpendingCategory(
      icon: Icons.lightbulb_outlined,
      name: 'Utilities',
      color: Colors.green,
    ),
    _StaticSpendingCategory(
      icon: Icons.medical_services_outlined,
      name: 'Healthcare',
      color: Colors.teal,
    ),
    _StaticSpendingCategory(
      icon: Icons.school_outlined,
      name: 'Education',
      color: Colors.indigo,
    ),
    _StaticSpendingCategory(
      icon: Icons.home_outlined,
      name: 'Housing',
      color: Colors.brown,
    ),
  ];

  /// Map Material icon name to IconData for dynamic categories
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

  /// Parse color from hex string
  Color _parseColor(String colorHex) {
    try {
      return Color(int.parse(colorHex, radix: 16));
    } catch (e) {
      return Colors.blue; // Default color
    }
  }

  @override
  void initState() {
    super.initState();
    // Load user profile and categories when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  /// Load user profile and categories from the API
  Future<void> _loadProfileData() async {
    final authProvider = context.read<AuthProvider>();
    final userProfileProvider = context.read<UserProfileProvider>();
    final categoryProvider = context.read<CategoryProvider>();

    try {
      // Get auth token
      final authToken = await authProvider.authService.getToken();
      if (authToken == null) {
        // If no token, user should be redirected to login
        return;
      }

      // Load user profile if not already loaded
      if (!userProfileProvider.hasInitialized) {
        await userProfileProvider.loadUserProfile(authToken: authToken);
      }

      // Load categories if not already loaded
      if (!categoryProvider.hasInitialized) {
        await categoryProvider.loadCategories(authToken: authToken);
      }
    } catch (e) {
      print('Error loading profile data: $e');
      // Handle error gracefully - the UI will show fallback content
    }
  }

  /// Refresh both user profile and categories by pulling from API
  Future<void> _refreshProfileData() async {
    final authProvider = context.read<AuthProvider>();
    final userProfileProvider = context.read<UserProfileProvider>();
    final categoryProvider = context.read<CategoryProvider>();

    try {
      // Get auth token
      final authToken = await authProvider.authService.getToken();
      if (authToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in again to refresh data'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // Refresh both user profile and categories
      await Future.wait([
        userProfileProvider.refreshUserProfile(authToken: authToken),
        categoryProvider.refreshCategories(authToken: authToken),
      ]);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile data refreshed successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error refreshing profile data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to refresh profile data'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

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
      body: RefreshIndicator(
        onRefresh: _refreshProfileData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(),
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

              const SizedBox(height: 24),

              // Notification Settings Section
              _buildNotificationSettingsSection(
                  context, colorScheme, textTheme, l10n),

              const SizedBox(height: 32),
            ],
          ),
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

  /// Build Notification Settings section
  Widget _buildNotificationSettingsSection(
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            const NotificationSettingsScreen(),
                      ),
                    );
                  },
                  child: const Text('Settings'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  size: 20,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              title: const Text('Push Notifications'),
              subtitle: const Text('Manage your notification preferences'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NotificationSettingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.history,
                  size: 20,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              title: const Text('Notification History'),
              subtitle: const Text('View past notifications'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NotificationHistoryScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
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
    return Consumer<UserProfileProvider>(
      builder: (context, userProfileProvider, child) {
        // Loading state
        if (userProfileProvider.isLoading) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        // Error state
        if (userProfileProvider.error != null) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading profile',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userProfileProvider.error!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshProfileData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final userProfile = userProfileProvider.userProfile;

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
                    _buildUserAvatar(
                      userProfile,
                      colorScheme,
                      userProfileProvider.userInitials,
                    ),

                    const SizedBox(width: 16),

                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userProfile?.name ?? 'Loading...',
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
                          if (userProfile?.isActive == false)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Inactive',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Edit Button
                    OutlinedButton(
                      onPressed: userProfile != null
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ProfileEditScreen(),
                                ),
                              );
                            }
                          : null,
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
                      userProfile?.email ?? 'Not available',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoTile(
                      context,
                      colorScheme,
                      textTheme,
                      Icons.language_outlined,
                      'Language',
                      _getLanguageDisplayName(userProfile?.language ?? 'en'),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoTile(
                      context,
                      colorScheme,
                      textTheme,
                      Icons.schedule_outlined,
                      'Timezone',
                      userProfile?.timezone ?? 'UTC',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoTile(
                      context,
                      colorScheme,
                      textTheme,
                      Icons.attach_money_outlined,
                      'Currency',
                      userProfile?.currency ?? 'USD',
                    ),
                    if (userProfile?.lastLogin != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoTile(
                        context,
                        colorScheme,
                        textTheme,
                        Icons.login_outlined,
                        'Last Login',
                        _formatDateTime(userProfile!.lastLogin!),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build user avatar widget
  Widget _buildUserAvatar(
    UserProfile? userProfile,
    ColorScheme colorScheme,
    String initials,
  ) {
    if (userProfile?.avatarUrl != null && userProfile!.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(userProfile.avatarUrl!),
        onBackgroundImageError: (exception, stackTrace) {
          // Fallback to initials if image fails to load
        },
        child: userProfile.avatarUrl!.isEmpty
            ? Text(
                initials,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              )
            : null,
      );
    } else {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            initials,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      );
    }
  }

  /// Get display name for language code
  String _getLanguageDisplayName(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'en':
        return 'English';
      case 'vi':
        return 'Vietnamese';
      case 'es':
        return 'Spanish';
      case 'fr':
        return 'French';
      case 'de':
        return 'German';
      case 'ja':
        return 'Japanese';
      case 'ko':
        return 'Korean';
      case 'zh':
        return 'Chinese';
      default:
        return languageCode.toUpperCase();
    }
  }

  /// Format DateTime for display
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
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
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CategoryManagementScreen(),
                      ),
                    );
                  },
                  child: Text(l10n.manage),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Loading State
            if (categoryProvider.isLoading)
              const Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            // Error State
            else if (categoryProvider.error != null)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading categories',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        categoryProvider.error!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshProfileData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            // Categories List
            else
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Dynamic categories from API
                    if (categoryProvider.categories.isNotEmpty) ...[
                      for (int i = 0;
                          i < categoryProvider.categories.length;
                          i++) ...[
                        _buildDynamicCategoryTile(
                          context,
                          colorScheme,
                          textTheme,
                          l10n,
                          categoryProvider.categories[i],
                        ),
                        if (i < categoryProvider.categories.length - 1)
                          Divider(
                            height: 1,
                            indent: 72,
                            color: colorScheme.outline.withOpacity(0.2),
                          ),
                      ],
                    ]
                    // Fallback to static categories if no data
                    else if (_fallbackCategories.isNotEmpty) ...[
                      for (int i = 0; i < _fallbackCategories.length; i++) ...[
                        _buildStaticCategoryTile(
                          context,
                          colorScheme,
                          textTheme,
                          l10n,
                          _fallbackCategories[i],
                        ),
                        if (i < _fallbackCategories.length - 1)
                          Divider(
                            height: 1,
                            indent: 72,
                            color: colorScheme.outline.withOpacity(0.2),
                          ),
                      ],
                    ]
                    // Empty state
                    else
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 48,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No categories found',
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add some spending categories to get started',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  /// Build individual dynamic category tile from API data
  Widget _buildDynamicCategoryTile(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    AppLocalizations l10n,
    SpendingCategory category,
  ) {
    final categoryColor = _parseColor(category.colorHex);
    final categoryIcon = _getCategoryIcon(category.iconName);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
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
      title: Text(
        category.name,
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget: \$${category.allocatedAmount.toStringAsFixed(2)}',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
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
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (category.isOverBudget)
            Icon(
              Icons.warning,
              color: colorScheme.error,
              size: 16,
            )
          else if (category.isNearBudgetLimit)
            Icon(
              Icons.warning_amber,
              color: colorScheme.primary,
              size: 16,
            ),
          const SizedBox(height: 4),
          Icon(
            Icons.chevron_right,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
      onTap: () async {
        final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (context) => CategoryEditScreen(category: category),
          ),
        );

        // Refresh categories if the edit was successful
        if (result == true) {
          await _refreshProfileData();
        }
      },
    );
  }

  /// Build individual static category tile (fallback)
  Widget _buildStaticCategoryTile(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    AppLocalizations l10n,
    _StaticSpendingCategory category,
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
            content: Text(
                '${category.name} is a default category and cannot be edited'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }
}

/// Static Spending Category data class for fallback UI
class _StaticSpendingCategory {
  const _StaticSpendingCategory({
    required this.icon,
    required this.name,
    required this.color,
  });

  final IconData icon;
  final String name;
  final Color color;
}
