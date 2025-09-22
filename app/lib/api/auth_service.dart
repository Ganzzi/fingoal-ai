import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Authentication service for handling login, registration, and token management
class AuthService {
  static const String _baseUrl = 'http://localhost:5678'; // n8n instance URL
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // API endpoints
  static const String _authEndpoint = '/webhook/auth';
  static const String _refreshEndpoint = '/webhook/refresh';

  /// Register a new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_authEndpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'action': 'register',
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Store token and user data
        await _storeAuthData(data['token'], data['user']);
        return {
          'success': true,
          'user': data['user'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Login with email and password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_authEndpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'action': 'login',
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Store token and user data
        await _storeAuthData(data['token'], data['user']);
        return {
          'success': true,
          'user': data['user'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Logout user
  Future<Map<String, dynamic>> logout() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not logged in'};
      }

      final response = await http.post(
        Uri.parse('$_baseUrl$_authEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'action': 'logout',
        }),
      );

      final data = jsonDecode(response.body);

      // Clear local storage regardless of server response
      await clearAuthData();

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        // Still return success since local data is cleared
        return {
          'success': true,
          'message': 'Logged out locally',
        };
      }
    } catch (e) {
      // Clear local storage on error
      await clearAuthData();
      return {
        'success': true,
        'message': 'Logged out locally due to error',
      };
    }
  }

  /// Refresh authentication token
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'No token to refresh'};
      }

      final response = await http.post(
        Uri.parse('$_baseUrl$_refreshEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Store new token and user data
        await _storeAuthData(data['token'], data['user']);
        return {
          'success': true,
          'user': data['user'],
          'message': data['message'],
        };
      } else {
        // Clear invalid token
        await clearAuthData();
        return {
          'success': false,
          'error': data['error'] ?? 'Token refresh failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Get stored authentication token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Get stored user data
  Future<Map<String, dynamic>?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      if (userData != null) {
        return jsonDecode(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Store authentication data locally
  Future<void> _storeAuthData(String token, Map<String, dynamic> user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, jsonEncode(user));
    } catch (e) {
      // Handle storage error
      print('Error storing auth data: $e');
    }
  }

  /// Clear all authentication data
  Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (e) {
      // Handle storage error
      print('Error clearing auth data: $e');
    }
  }

  /// Make authenticated HTTP request
  Future<http.Response> authenticatedRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      ...?additionalHeaders,
    };

    final uri = Uri.parse('$_baseUrl$endpoint');

    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(uri, headers: headers);
      case 'POST':
        return await http.post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'PUT':
        return await http.put(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'DELETE':
        return await http.delete(uri, headers: headers);
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }
}
