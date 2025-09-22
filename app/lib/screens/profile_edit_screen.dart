import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_profile_models.dart';

/// Profile Edit Screen
///
/// This screen allows users to edit their profile information including
/// name, language, timezone, and currency preferences.
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _avatarUrlController;

  String? _selectedLanguage;
  String? _selectedTimezone;
  String? _selectedCurrency;

  bool _isLoading = false;
  String? _error;

  // Supported languages
  static const List<MapEntry<String, String>> _supportedLanguages = [
    MapEntry('en', 'English'),
    MapEntry('vi', 'Vietnamese'),
    MapEntry('es', 'Spanish'),
    MapEntry('fr', 'French'),
    MapEntry('de', 'German'),
  ];

  // Common timezones
  static const List<MapEntry<String, String>> _commonTimezones = [
    MapEntry('UTC', 'UTC (Coordinated Universal Time)'),
    MapEntry('America/New_York', 'Eastern Time (ET)'),
    MapEntry('America/Chicago', 'Central Time (CT)'),
    MapEntry('America/Denver', 'Mountain Time (MT)'),
    MapEntry('America/Los_Angeles', 'Pacific Time (PT)'),
    MapEntry('Europe/London', 'British Time (GMT)'),
    MapEntry('Europe/Paris', 'Central European Time (CET)'),
    MapEntry('Asia/Tokyo', 'Japan Standard Time (JST)'),
    MapEntry('Asia/Shanghai', 'China Standard Time (CST)'),
    MapEntry('Asia/Ho_Chi_Minh', 'Vietnam Time (VET)'),
  ];

  // Supported currencies
  static const List<MapEntry<String, String>> _supportedCurrencies = [
    MapEntry('USD', 'US Dollar (USD)'),
    MapEntry('EUR', 'Euro (EUR)'),
    MapEntry('GBP', 'British Pound (GBP)'),
    MapEntry('JPY', 'Japanese Yen (JPY)'),
    MapEntry('VND', 'Vietnamese Dong (VND)'),
    MapEntry('CAD', 'Canadian Dollar (CAD)'),
    MapEntry('AUD', 'Australian Dollar (AUD)'),
  ];

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _nameController = TextEditingController();
    _avatarUrlController = TextEditingController();

    // Load current user data
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  /// Load current user data into the form
  void _loadUserData() {
    final userProfileProvider = context.read<UserProfileProvider>();
    final userProfile = userProfileProvider.userProfile;

    if (userProfile != null) {
      _nameController.text = userProfile.name;
      _avatarUrlController.text = userProfile.avatarUrl ?? '';
      _selectedLanguage = userProfile.language;
      _selectedTimezone = userProfile.timezone;
      _selectedCurrency = userProfile.currency;
      setState(() {});
    }
  }

  /// Save profile changes
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final userProfileProvider = context.read<UserProfileProvider>();

      // Get auth token
      final authToken = await authProvider.authService.getToken();
      if (authToken == null) {
        throw Exception('Authentication required. Please log in again.');
      }

      // Create update request
      final updateRequest = ProfileUpdateRequest(
        name: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : null,
        avatarUrl: _avatarUrlController.text.trim().isNotEmpty
            ? _avatarUrlController.text.trim()
            : null,
        language: _selectedLanguage,
        timezone: _selectedTimezone,
        currency: _selectedCurrency,
      );

      // Update profile
      final success = await userProfileProvider.updateUserProfile(
        authToken: authToken,
        updateRequest: updateRequest,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        setState(() {
          _error = userProfileProvider.error ?? 'Failed to update profile';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          'Edit Profile',
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
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveChanges,
            child: Text(
              'Save',
              style: TextStyle(
                color: _isLoading ? colorScheme.outline : colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Error message
              if (_error != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: colorScheme.onErrorContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Basic Information Section
              _buildSectionCard(
                colorScheme,
                textTheme,
                'Basic Information',
                [
                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor:
                          colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      if (value.trim().length > 100) {
                        return 'Name must be 100 characters or less';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 16),

                  // Avatar URL Field
                  TextFormField(
                    controller: _avatarUrlController,
                    decoration: InputDecoration(
                      labelText: 'Avatar URL (Optional)',
                      hintText: 'Enter image URL for your avatar',
                      prefixIcon: const Icon(Icons.image_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor:
                          colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    ),
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        try {
                          Uri.parse(value.trim());
                        } catch (e) {
                          return 'Please enter a valid URL';
                        }
                      }
                      return null;
                    },
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Preferences Section
              _buildSectionCard(
                colorScheme,
                textTheme,
                'Preferences',
                [
                  // Language Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    decoration: InputDecoration(
                      labelText: 'Language',
                      prefixIcon: const Icon(Icons.language_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor:
                          colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    ),
                    items: _supportedLanguages.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLanguage = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a language';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Timezone Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedTimezone,
                    decoration: InputDecoration(
                      labelText: 'Timezone',
                      prefixIcon: const Icon(Icons.schedule_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor:
                          colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    ),
                    items: _commonTimezones.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(
                          entry.value,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTimezone = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a timezone';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Currency Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCurrency,
                    decoration: InputDecoration(
                      labelText: 'Currency',
                      prefixIcon: const Icon(Icons.attach_money_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor:
                          colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    ),
                    items: _supportedCurrencies.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCurrency = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a currency';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed:
                      _isLoading ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a section card with title and content
  Widget _buildSectionCard(
    ColorScheme colorScheme,
    TextTheme textTheme,
    String title,
    List<Widget> children,
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
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
