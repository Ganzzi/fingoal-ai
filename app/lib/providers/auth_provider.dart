import 'package:flutter/foundation.dart';
import '../api/auth_service.dart';

/// Authentication Provider
///
/// Manages the global authentication state and provides methods
/// for authentication operations throughout the app.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  Map<String, dynamic>? _user;
  String? _error;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;

  /// Initialize authentication state
  Future<void> initialize() async {
    _setLoading(true);

    try {
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        // Try to get user data and refresh token
        _user = await _authService.getUser();

        // Attempt token refresh to validate
        final refreshResult = await _authService.refreshToken();

        if (refreshResult['success'] == true) {
          _isAuthenticated = true;
          _user = refreshResult['user'];
        } else {
          // Token invalid, clear data
          await _authService.clearAuthData();
          _isAuthenticated = false;
          _user = null;
        }
      } else {
        _isAuthenticated = false;
        _user = null;
      }
    } catch (e) {
      _setError('Authentication check failed: $e');
      _isAuthenticated = false;
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  /// Login user
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.login(email: email, password: password);

      if (result['success'] == true) {
        _isAuthenticated = true;
        _user = result['user'];
        notifyListeners();
        return true;
      } else {
        _setError(result['error'] ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _setError('Login error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Register user
  Future<bool> register(String email, String password, String name) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.register(
        email: email,
        password: password,
        name: name,
      );

      if (result['success'] == true) {
        _isAuthenticated = true;
        _user = result['user'];
        notifyListeners();
        return true;
      } else {
        _setError(result['error'] ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      _setError('Registration error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout user
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
    } catch (e) {
      // Continue with logout even if server call fails
      if (kDebugMode) {
        print('Logout error (continuing anyway): $e');
      }
    }

    // Clear local state regardless of server response
    _isAuthenticated = false;
    _user = null;
    _setLoading(false);
    notifyListeners();
  }

  /// Refresh authentication token
  Future<bool> refreshToken() async {
    try {
      final result = await _authService.refreshToken();

      if (result['success'] == true) {
        _user = result['user'];
        notifyListeners();
        return true;
      } else {
        // Token refresh failed, logout user
        await logout();
        return false;
      }
    } catch (e) {
      // On error, logout user
      await logout();
      return false;
    }
  }

  /// Get authentication service for making authenticated requests
  AuthService get authService => _authService;

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _error = null;
  }
}
