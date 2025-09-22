import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user_profile_models.dart';

/// Service for managing user profile information via n8n API
///
/// This service handles all API communication for user profile management,
/// including fetching and updating user profile information, preferences,
/// and account settings.
class UserProfileService {
  static const String _baseUrl = 'http://localhost:5678/webhook';
  static const Duration _timeout = Duration(seconds: 30);

  /// Fetch the authenticated user's profile information
  ///
  /// Returns a [UserProfileResponse] containing the user's profile data
  /// including personal details, preferences, and account status.
  Future<UserProfileResponse> getUserProfile({
    required String authToken,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/user/profile');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ).timeout(_timeout);

      final responseData = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return UserProfileResponse.fromJson(responseData);
      } else {
        throw UserProfileServiceException(
          message: responseData['error']?['message'] as String? ??
              'Failed to fetch user profile',
          statusCode: response.statusCode,
          type: UserProfileServiceExceptionType.apiError,
        );
      }
    } on FormatException {
      throw const UserProfileServiceException(
        message: 'Invalid response format from server',
        type: UserProfileServiceExceptionType.parseError,
      );
    } on SocketException {
      throw const UserProfileServiceException(
        message: 'No internet connection available',
        type: UserProfileServiceExceptionType.networkError,
      );
    } on http.ClientException {
      throw const UserProfileServiceException(
        message: 'Network request failed',
        type: UserProfileServiceExceptionType.networkError,
      );
    } catch (e) {
      if (e is UserProfileServiceException) rethrow;
      throw UserProfileServiceException(
        message: e.toString(),
        type: UserProfileServiceExceptionType.unknown,
      );
    }
  }

  /// Update the authenticated user's profile information
  ///
  /// Takes a [ProfileUpdateRequest] with the updated profile details.
  /// Only provided fields will be updated, others remain unchanged.
  Future<UserProfileResponse> updateUserProfile({
    required String authToken,
    required ProfileUpdateRequest updateRequest,
  }) async {
    try {
      // Validate the request before sending
      final validationErrors = updateRequest.validate();
      if (validationErrors.isNotEmpty) {
        throw UserProfileServiceException(
          message: validationErrors.join(', '),
          type: UserProfileServiceExceptionType.validationError,
        );
      }

      // Check if there are any fields to update
      if (!updateRequest.hasUpdates) {
        throw const UserProfileServiceException(
          message: 'No valid fields provided for update',
          type: UserProfileServiceExceptionType.validationError,
        );
      }

      final uri = Uri.parse('$_baseUrl/user/profile');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
            body: json.encode(updateRequest.toJson()),
          )
          .timeout(_timeout);

      final responseData = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return UserProfileResponse.fromJson(responseData);
      } else {
        throw UserProfileServiceException(
          message: responseData['error']?['message'] as String? ??
              'Failed to update user profile',
          statusCode: response.statusCode,
          type: UserProfileServiceExceptionType.apiError,
        );
      }
    } on FormatException {
      throw const UserProfileServiceException(
        message: 'Invalid response format from server',
        type: UserProfileServiceExceptionType.parseError,
      );
    } on SocketException {
      throw const UserProfileServiceException(
        message: 'No internet connection available',
        type: UserProfileServiceExceptionType.networkError,
      );
    } on http.ClientException {
      throw const UserProfileServiceException(
        message: 'Network request failed',
        type: UserProfileServiceExceptionType.networkError,
      );
    } catch (e) {
      if (e is UserProfileServiceException) rethrow;
      throw UserProfileServiceException(
        message: e.toString(),
        type: UserProfileServiceExceptionType.unknown,
      );
    }
  }

  /// Upload user avatar image
  ///
  /// Uploads an avatar image file and updates the user's profile with the new avatar URL.
  /// Returns the updated user profile with the new avatar URL.
  Future<UserProfileResponse> uploadAvatar({
    required String authToken,
    required String imagePath,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/user/avatar');

      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        'Authorization': 'Bearer $authToken',
      });

      // Add the image file
      final file = File(imagePath);
      if (!await file.exists()) {
        throw const UserProfileServiceException(
          message: 'Image file not found',
          type: UserProfileServiceExceptionType.validationError,
        );
      }

      request.files.add(
        await http.MultipartFile.fromPath('avatar', imagePath),
      );

      final response = await request.send().timeout(_timeout);
      final responseBody = await response.stream.bytesToString();
      final responseData = json.decode(responseBody) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return UserProfileResponse.fromJson(responseData);
      } else {
        throw UserProfileServiceException(
          message: responseData['error']?['message'] as String? ??
              'Failed to upload avatar',
          statusCode: response.statusCode,
          type: UserProfileServiceExceptionType.apiError,
        );
      }
    } on FormatException {
      throw const UserProfileServiceException(
        message: 'Invalid response format from server',
        type: UserProfileServiceExceptionType.parseError,
      );
    } on SocketException {
      throw const UserProfileServiceException(
        message: 'No internet connection available',
        type: UserProfileServiceExceptionType.networkError,
      );
    } on http.ClientException {
      throw const UserProfileServiceException(
        message: 'Network request failed',
        type: UserProfileServiceExceptionType.networkError,
      );
    } catch (e) {
      if (e is UserProfileServiceException) rethrow;
      throw UserProfileServiceException(
        message: e.toString(),
        type: UserProfileServiceExceptionType.unknown,
      );
    }
  }
}

/// Exception types for user profile service operations
enum UserProfileServiceExceptionType {
  networkError,
  apiError,
  parseError,
  validationError,
  unknown,
}

/// Custom exception for user profile service operations
class UserProfileServiceException implements Exception {
  final String message;
  final int? statusCode;
  final UserProfileServiceExceptionType type;

  const UserProfileServiceException({
    required this.message,
    this.statusCode,
    required this.type,
  });

  @override
  String toString() {
    return 'UserProfileServiceException(type: $type, message: $message, statusCode: $statusCode)';
  }

  /// Check if this is a network-related error
  bool get isNetworkError =>
      type == UserProfileServiceExceptionType.networkError;

  /// Check if this is a server/API error
  bool get isApiError => type == UserProfileServiceExceptionType.apiError;

  /// Check if this is a validation error
  bool get isValidationError =>
      type == UserProfileServiceExceptionType.validationError;

  /// Get user-friendly error message
  String get userFriendlyMessage {
    switch (type) {
      case UserProfileServiceExceptionType.networkError:
        return 'Please check your internet connection and try again.';
      case UserProfileServiceExceptionType.apiError:
        if (statusCode == 401) {
          return 'Please log in again to continue.';
        } else if (statusCode == 403) {
          return 'You do not have permission to perform this action.';
        } else if (statusCode == 400) {
          return 'Invalid profile data. Please check your inputs and try again.';
        }
        return 'Server error occurred. Please try again later.';
      case UserProfileServiceExceptionType.validationError:
        return message;
      case UserProfileServiceExceptionType.parseError:
        return 'Invalid server response. Please try again.';
      case UserProfileServiceExceptionType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
