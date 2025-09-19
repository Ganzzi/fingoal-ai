import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Login Screen
///
/// This screen serves as the entry point for the FinGoal AI application.
/// It provides a clean, professional login interface with non-functional
/// input fields and navigation to the main application shell.
///
/// Features:
/// - Material Design 3 theming throughout
/// - Username/email and password input fields
/// - Password visibility toggle
/// - Responsive design for different screen sizes
/// - Clean navigation to main app after login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isRegisterMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Handle login/register submission
  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = context.read<AuthProvider>();
      bool success = false;

      try {
        if (_isRegisterMode) {
          success = await authProvider.register(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
          );
        } else {
          success = await authProvider.login(
            _emailController.text.trim(),
            _passwordController.text,
          );
        }

        if (mounted && !success) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Authentication failed'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        // No need to navigate - AuthWrapper will handle this automatically
        // based on the authentication state change
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  /// Toggle between login and register modes
  void _toggleMode() {
    setState(() {
      _isRegisterMode = !_isRegisterMode;
      _formKey.currentState?.reset();
    });
  }

  /// Validate email field
  String? _validateEmail(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.pleaseEnterEmail;
    }
    if (!value.contains('@')) {
      return l10n.pleaseEnterValidEmail;
    }
    return null;
  }

  /// Validate password field
  String? _validatePassword(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.pleaseEnterPassword;
    }
    if (_isRegisterMode && value.length < 8) {
      return 'Password must be at least 8 characters long';
    } else if (!_isRegisterMode && value.length < 6) {
      return l10n.passwordTooShort;
    }
    if (_isRegisterMode &&
        !RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, and number';
    }
    return null;
  }

  /// Validate name field
  String? _validateName(String? value) {
    if (_isRegisterMode && (value == null || value.trim().isEmpty)) {
      return 'Please enter your name';
    }
    return null;
  }

  /// Validate confirm password field
  String? _validateConfirmPassword(String? value) {
    if (_isRegisterMode && value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - MediaQuery.of(context).padding.top - 48,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),

                  // App Logo and Branding
                  Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          size: 50,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.appTitle,
                        style: textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.appTagline,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Welcome Text
                  Text(
                    _isRegisterMode ? 'Create Account' : l10n.welcomeBack,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _isRegisterMode
                        ? 'Join FinGoal AI today'
                        : l10n.signInToContinue,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Login Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Name Field (only for registration)
                        if (_isRegisterMode) ...[
                          TextFormField(
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            validator: _validateName,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: const Icon(Icons.person_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: colorScheme.surfaceContainerHighest
                                  .withOpacity(0.3),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: _validateEmail,
                          decoration: InputDecoration(
                            labelText: l10n.email,
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          textInputAction: _isRegisterMode
                              ? TextInputAction.next
                              : TextInputAction.done,
                          validator: _validatePassword,
                          onFieldSubmitted:
                              _isRegisterMode ? null : (_) => _handleSubmit(),
                          decoration: InputDecoration(
                            labelText: l10n.password,
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                          ),
                        ),

                        // Confirm Password Field (only for registration)
                        if (_isRegisterMode) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            textInputAction: TextInputAction.done,
                            validator: _validateConfirmPassword,
                            onFieldSubmitted: (_) => _handleSubmit(),
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: colorScheme.surfaceContainerHighest
                                  .withOpacity(0.3),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        colorScheme.onPrimary,
                                      ),
                                    ),
                                  )
                                : Text(
                                    _isRegisterMode
                                        ? 'Create Account'
                                        : l10n.signIn,
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Toggle Mode Button
                        TextButton(
                          onPressed: _isLoading ? null : _toggleMode,
                          child: Text(
                            _isRegisterMode
                                ? 'Already have an account? Sign In'
                                : 'Don\'t have an account? Register',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Footer Note
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: Column(
                      children: [
                        Text(
                          l10n.demoMode,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.demoModeDescription,
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
            ),
          ),
        ),
      ),
    );
  }
}
