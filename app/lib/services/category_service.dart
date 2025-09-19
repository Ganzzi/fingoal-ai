import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/category_models.dart';

/// Service for managing spending categories and budgets via n8n API
///
/// This service handles all API communication for category management,
/// including fetching, creating, and updating spending categories
/// and their associated budget allocations.
class CategoryService {
  static const String _baseUrl = 'http://localhost:5678/webhook';
  static const Duration _timeout = Duration(seconds: 30);

  /// Fetch all spending categories for the authenticated user
  ///
  /// Returns a [CategoriesResponse] containing the user's categories
  /// including both default (system-provided) and custom categories.
  /// Each category includes its allocated budget and spent amounts.
  Future<CategoriesResponse> getCategories({
    required String authToken,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/categories');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ).timeout(_timeout);

      final responseData = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return CategoriesResponse.fromJson(responseData);
      } else {
        throw CategoryServiceException(
          message: responseData['message'] as String? ??
              'Failed to fetch categories',
          statusCode: response.statusCode,
          type: CategoryServiceExceptionType.apiError,
        );
      }
    } on FormatException {
      throw const CategoryServiceException(
        message: 'Invalid response format from server',
        type: CategoryServiceExceptionType.parseError,
      );
    } on SocketException {
      throw const CategoryServiceException(
        message: 'No internet connection available',
        type: CategoryServiceExceptionType.networkError,
      );
    } on http.ClientException {
      throw const CategoryServiceException(
        message: 'Network request failed',
        type: CategoryServiceExceptionType.networkError,
      );
    } catch (e) {
      throw CategoryServiceException(
        message: e.toString(),
        type: CategoryServiceExceptionType.unknown,
      );
    }
  }

  /// Create a new spending category
  ///
  /// Takes a [CategoryRequest] with the category details and creates
  /// a new category for the authenticated user. Also creates or updates
  /// the associated budget allocation if specified.
  Future<CategoryOperationResponse> createCategory({
    required String authToken,
    required CategoryRequest categoryRequest,
  }) async {
    try {
      // Validate the request before sending
      final validationErrors = categoryRequest.validate();
      if (validationErrors.isNotEmpty) {
        throw CategoryServiceException(
          message: validationErrors.join(', '),
          type: CategoryServiceExceptionType.validationError,
        );
      }

      final uri = Uri.parse('$_baseUrl/categories');

      final requestBody = {
        'operation': 'create',
        'category': categoryRequest.toJson(),
      };

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
            body: json.encode(requestBody),
          )
          .timeout(_timeout);

      final responseData = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201) {
        return CategoryOperationResponse.fromJson(responseData);
      } else {
        throw CategoryServiceException(
          message: responseData['error']?['message'] as String? ??
              'Failed to create category',
          statusCode: response.statusCode,
          type: CategoryServiceExceptionType.apiError,
        );
      }
    } on FormatException {
      throw const CategoryServiceException(
        message: 'Invalid response format from server',
        type: CategoryServiceExceptionType.parseError,
      );
    } on SocketException {
      throw const CategoryServiceException(
        message: 'No internet connection available',
        type: CategoryServiceExceptionType.networkError,
      );
    } on http.ClientException {
      throw const CategoryServiceException(
        message: 'Network request failed',
        type: CategoryServiceExceptionType.networkError,
      );
    } catch (e) {
      if (e is CategoryServiceException) rethrow;
      throw CategoryServiceException(
        message: e.toString(),
        type: CategoryServiceExceptionType.unknown,
      );
    }
  }

  /// Update an existing spending category
  ///
  /// Takes a [CategoryRequest] with the updated category details.
  /// The request must include an ID to identify which category to update.
  /// Only non-default categories owned by the user can be updated.
  Future<CategoryOperationResponse> updateCategory({
    required String authToken,
    required CategoryRequest categoryRequest,
  }) async {
    try {
      // Validate the request before sending
      final validationErrors = categoryRequest.validate();
      if (validationErrors.isNotEmpty) {
        throw CategoryServiceException(
          message: validationErrors.join(', '),
          type: CategoryServiceExceptionType.validationError,
        );
      }

      if (categoryRequest.id == null) {
        throw const CategoryServiceException(
          message: 'Category ID is required for update operation',
          type: CategoryServiceExceptionType.validationError,
        );
      }

      final uri = Uri.parse('$_baseUrl/categories');

      final requestBody = {
        'operation': 'update',
        'category': categoryRequest.toJson(),
      };

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
            body: json.encode(requestBody),
          )
          .timeout(_timeout);

      final responseData = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return CategoryOperationResponse.fromJson(responseData);
      } else {
        throw CategoryServiceException(
          message: responseData['error']?['message'] as String? ??
              'Failed to update category',
          statusCode: response.statusCode,
          type: CategoryServiceExceptionType.apiError,
        );
      }
    } on FormatException {
      throw const CategoryServiceException(
        message: 'Invalid response format from server',
        type: CategoryServiceExceptionType.parseError,
      );
    } on SocketException {
      throw const CategoryServiceException(
        message: 'No internet connection available',
        type: CategoryServiceExceptionType.networkError,
      );
    } on http.ClientException {
      throw const CategoryServiceException(
        message: 'Network request failed',
        type: CategoryServiceExceptionType.networkError,
      );
    } catch (e) {
      if (e is CategoryServiceException) rethrow;
      throw CategoryServiceException(
        message: e.toString(),
        type: CategoryServiceExceptionType.unknown,
      );
    }
  }

  /// Delete a spending category
  ///
  /// Removes a category and its associated budget allocation.
  /// Only non-default categories owned by the user can be deleted.
  /// This operation cannot be undone.
  Future<CategoryOperationResponse> deleteCategory({
    required String authToken,
    required String categoryId,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/categories');

      final requestBody = {
        'operation': 'delete',
        'category': {'id': categoryId},
      };

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
            body: json.encode(requestBody),
          )
          .timeout(_timeout);

      final responseData = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return CategoryOperationResponse.fromJson(responseData);
      } else {
        throw CategoryServiceException(
          message: responseData['error']?['message'] as String? ??
              'Failed to delete category',
          statusCode: response.statusCode,
          type: CategoryServiceExceptionType.apiError,
        );
      }
    } on FormatException {
      throw const CategoryServiceException(
        message: 'Invalid response format from server',
        type: CategoryServiceExceptionType.parseError,
      );
    } on SocketException {
      throw const CategoryServiceException(
        message: 'No internet connection available',
        type: CategoryServiceExceptionType.networkError,
      );
    } on http.ClientException {
      throw const CategoryServiceException(
        message: 'Network request failed',
        type: CategoryServiceExceptionType.networkError,
      );
    } catch (e) {
      if (e is CategoryServiceException) rethrow;
      throw CategoryServiceException(
        message: e.toString(),
        type: CategoryServiceExceptionType.unknown,
      );
    }
  }
}

/// Exception types for category service operations
enum CategoryServiceExceptionType {
  networkError,
  apiError,
  parseError,
  validationError,
  unknown,
}

/// Custom exception for category service operations
class CategoryServiceException implements Exception {
  final String message;
  final int? statusCode;
  final CategoryServiceExceptionType type;

  const CategoryServiceException({
    required this.message,
    this.statusCode,
    required this.type,
  });

  @override
  String toString() {
    return 'CategoryServiceException(type: $type, message: $message, statusCode: $statusCode)';
  }

  /// Check if this is a network-related error
  bool get isNetworkError => type == CategoryServiceExceptionType.networkError;

  /// Check if this is a server/API error
  bool get isApiError => type == CategoryServiceExceptionType.apiError;

  /// Check if this is a validation error
  bool get isValidationError =>
      type == CategoryServiceExceptionType.validationError;

  /// Get user-friendly error message
  String get userFriendlyMessage {
    switch (type) {
      case CategoryServiceExceptionType.networkError:
        return 'Please check your internet connection and try again.';
      case CategoryServiceExceptionType.apiError:
        if (statusCode == 401) {
          return 'Please log in again to continue.';
        } else if (statusCode == 403) {
          return 'You do not have permission to perform this action.';
        } else if (statusCode == 404) {
          return 'The requested category was not found.';
        }
        return 'Server error occurred. Please try again later.';
      case CategoryServiceExceptionType.validationError:
        return message;
      case CategoryServiceExceptionType.parseError:
        return 'Invalid server response. Please try again.';
      case CategoryServiceExceptionType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
