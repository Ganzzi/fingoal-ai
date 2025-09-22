/// Models for User Profile Management
///
/// These models define the data structures for user profile information
/// and updates, supporting the Profile screen's user management functionality.

class UserProfile {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final String language;
  final String timezone;
  final String currency;
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.language,
    required this.timezone,
    required this.currency,
    required this.isActive,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? 'unknown',
      email: json['email'] as String? ?? 'unknown@example.com',
      name: json['name'] as String? ?? 'User',
      avatarUrl: json['avatarUrl'] as String?,
      language: json['language'] as String? ?? 'en',
      timezone: json['timezone'] as String? ?? 'UTC',
      currency: json['currency'] as String? ?? 'USD',
      isActive: json['isActive'] as bool? ?? true,
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'language': language,
      'timezone': timezone,
      'currency': currency,
      'isActive': isActive,
      'lastLogin': lastLogin?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy of this profile with updated values
  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    String? language,
    String? timezone,
    String? currency,
    bool? isActive,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get display name (prioritizes name over email)
  String get displayName => name.isNotEmpty ? name : email;

  /// Get initials for avatar placeholder
  String get initials {
    if (name.isNotEmpty) {
      final nameParts = name.trim().split(RegExp(r'\s+'));
      if (nameParts.length >= 2) {
        return '${nameParts.first.substring(0, 1).toUpperCase()}${nameParts.last.substring(0, 1).toUpperCase()}';
      } else if (nameParts.isNotEmpty) {
        return nameParts.first.substring(0, 1).toUpperCase();
      }
    }
    return email.substring(0, 1).toUpperCase();
  }

  /// Check if profile has basic information
  bool get hasBasicInfo => name.isNotEmpty && email.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, email: $email, language: $language)';
  }
}

/// Request model for updating user profile
class ProfileUpdateRequest {
  final String? name;
  final String? avatarUrl;
  final String? language;
  final String? timezone;
  final String? currency;

  const ProfileUpdateRequest({
    this.name,
    this.avatarUrl,
    this.language,
    this.timezone,
    this.currency,
  });

  factory ProfileUpdateRequest.fromProfile(UserProfile profile) {
    return ProfileUpdateRequest(
      name: profile.name,
      avatarUrl: profile.avatarUrl,
      language: profile.language,
      timezone: profile.timezone,
      currency: profile.currency,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (name != null) json['name'] = name;
    if (avatarUrl != null) json['avatarUrl'] = avatarUrl;
    if (language != null) json['language'] = language;
    if (timezone != null) json['timezone'] = timezone;
    if (currency != null) json['currency'] = currency;

    return json;
  }

  /// Check if the update request has any fields to update
  bool get hasUpdates =>
      name != null ||
      avatarUrl != null ||
      language != null ||
      timezone != null ||
      currency != null;

  /// Validate the profile update request
  List<String> validate() {
    final errors = <String>[];

    if (name != null && name!.trim().isEmpty) {
      errors.add('Name cannot be empty');
    }

    if (name != null && name!.trim().length > 100) {
      errors.add('Name must be 100 characters or less');
    }

    if (language != null && !_isValidLanguageCode(language!)) {
      errors.add(
          'Invalid language code. Use ISO 639-1 format (e.g., en, es, fr)');
    }

    if (currency != null && !_isValidCurrencyCode(currency!)) {
      errors.add(
          'Invalid currency code. Use ISO 4217 format (e.g., USD, EUR, GBP)');
    }

    return errors;
  }

  bool _isValidLanguageCode(String code) {
    // Basic validation for ISO 639-1 language codes
    final regex = RegExp(r'^[a-z]{2}$');
    return regex.hasMatch(code.toLowerCase());
  }

  bool _isValidCurrencyCode(String code) {
    // Basic validation for ISO 4217 currency codes
    final regex = RegExp(r'^[A-Z]{3}$');
    return regex.hasMatch(code.toUpperCase());
  }

  @override
  String toString() {
    return 'ProfileUpdateRequest(name: $name, language: $language, timezone: $timezone, currency: $currency)';
  }
}

/// Response model for user profile API
class UserProfileResponse {
  final bool success;
  final UserProfile? user;
  final ApiResponseMeta? meta;
  final ApiError? error;

  const UserProfileResponse({
    required this.success,
    this.user,
    this.meta,
    this.error,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    if (json['success'] == true) {
      final data = json['data'] as Map<String, dynamic>?;
      final meta = json['meta'] as Map<String, dynamic>?;

      return UserProfileResponse(
        success: true,
        user: data != null
            ? UserProfile.fromJson(data['user'] as Map<String, dynamic>)
            : null,
        meta: meta != null ? ApiResponseMeta.fromJson(meta) : null,
      );
    } else {
      final error = json['error'] as Map<String, dynamic>?;
      return UserProfileResponse(
        success: false,
        error: error != null
            ? ApiError.fromJson(error)
            : const ApiError(
                type: 'unknown_error',
                message: 'Unknown error occurred',
                timestamp: '',
              ),
      );
    }
  }

  @override
  String toString() {
    return 'UserProfileResponse(success: $success, user: ${user?.name}, error: ${error?.message})';
  }
}

/// Metadata included in API responses
class ApiResponseMeta {
  final String timestamp;
  final String version;
  final String endpoint;

  const ApiResponseMeta({
    required this.timestamp,
    required this.version,
    required this.endpoint,
  });

  factory ApiResponseMeta.fromJson(Map<String, dynamic> json) {
    return ApiResponseMeta(
      timestamp: json['timestamp'] as String,
      version: json['version'] as String? ?? '1.0.0',
      endpoint: json['endpoint'] as String,
    );
  }

  @override
  String toString() {
    return 'ApiResponseMeta(endpoint: $endpoint, version: $version, timestamp: $timestamp)';
  }
}

/// Error information from API responses
class ApiError {
  final String type;
  final String message;
  final String? details;
  final String timestamp;

  const ApiError({
    required this.type,
    required this.message,
    this.details,
    required this.timestamp,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      type: json['type'] as String,
      message: json['message'] as String,
      details: json['details'] as String?,
      timestamp: json['timestamp'] as String,
    );
  }

  /// Get user-friendly error message
  String get userFriendlyMessage {
    switch (type) {
      case 'authentication_error':
      case 'unauthorized':
        return 'Please log in again to continue.';
      case 'validation_error':
        return message;
      case 'network_error':
        return 'Please check your internet connection and try again.';
      case 'server_error':
        return 'Server error occurred. Please try again later.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  @override
  String toString() {
    return 'ApiError(type: $type, message: $message, details: $details)';
  }
}
