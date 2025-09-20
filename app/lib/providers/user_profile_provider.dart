import 'package:flutter/foundation.dart';
import '../models/user_profile_models.dart';
import '../services/user_profile_service.dart';

/// Provider for managing user profile state and operations
///
/// This provider handles the application state for user profile information,
/// including fetching from the API, local state management, and
/// coordinating updates between the UI and backend.
class UserProfileProvider with ChangeNotifier {
  final UserProfileService _userProfileService = UserProfileService();

  // State variables
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;
  bool _hasInitialized = false;

  // Getters
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasInitialized => _hasInitialized;
  bool get isLoggedIn => _userProfile != null;

  /// Get user's display name
  String get displayName => _userProfile?.displayName ?? 'User';

  /// Get user's initials for avatar
  String get userInitials => _userProfile?.initials ?? 'U';

  /// Get user's avatar URL or null if not set
  String? get avatarUrl => _userProfile?.avatarUrl;

  /// Load user profile from the API
  ///
  /// This method fetches the user's profile information from the n8n API endpoint.
  /// It handles loading states and error management.
  Future<void> loadUserProfile({required String authToken}) async {
    if (_isLoading) return; // Prevent multiple simultaneous requests

    _setLoading(true);
    _clearError();

    try {
      final response = await _userProfileService.getUserProfile(
        authToken: authToken,
      );

      if (response.success && response.user != null) {
        _userProfile = response.user;
        _hasInitialized = true;
        notifyListeners();
      } else {
        _setError(response.error?.userFriendlyMessage ??
            'Failed to load user profile');
      }
    } on UserProfileServiceException catch (e) {
      _setError(e.userFriendlyMessage);
    } catch (e) {
      _setError('An unexpected error occurred while loading user profile');
    } finally {
      _setLoading(false);
    }
  }

  /// Update user profile information
  ///
  /// Updates the user's profile via the API and refreshes the local state.
  /// Uses optimistic updates to provide immediate UI feedback.
  Future<bool> updateUserProfile({
    required String authToken,
    required ProfileUpdateRequest updateRequest,
  }) async {
    if (_isLoading || _userProfile == null) return false;

    // Store original profile for potential rollback
    final originalProfile = _userProfile!;

    // Optimistic update - update the UI immediately
    _userProfile = originalProfile.copyWith(
      name: updateRequest.name ?? originalProfile.name,
      avatarUrl: updateRequest.avatarUrl ?? originalProfile.avatarUrl,
      language: updateRequest.language ?? originalProfile.language,
      timezone: updateRequest.timezone ?? originalProfile.timezone,
      currency: updateRequest.currency ?? originalProfile.currency,
      updatedAt: DateTime.now(),
    );
    notifyListeners();

    try {
      final response = await _userProfileService.updateUserProfile(
        authToken: authToken,
        updateRequest: updateRequest,
      );

      if (response.success && response.user != null) {
        // Replace with the actual server response
        _userProfile = response.user;
        notifyListeners();
        return true;
      } else {
        // Revert optimistic update on failure
        _userProfile = originalProfile;
        _setError(response.error?.userFriendlyMessage ??
            'Failed to update user profile');
        notifyListeners();
        return false;
      }
    } on UserProfileServiceException catch (e) {
      // Revert optimistic update on error
      _userProfile = originalProfile;
      _setError(e.userFriendlyMessage);
      notifyListeners();
      return false;
    } catch (e) {
      // Revert optimistic update on error
      _userProfile = originalProfile;
      _setError('An unexpected error occurred while updating user profile');
      notifyListeners();
      return false;
    }
  }

  /// Update specific profile field
  ///
  /// Convenience method to update a single field of the user's profile.
  Future<bool> updateProfileField({
    required String authToken,
    String? name,
    String? avatarUrl,
    String? language,
    String? timezone,
    String? currency,
  }) async {
    final updateRequest = ProfileUpdateRequest(
      name: name,
      avatarUrl: avatarUrl,
      language: language,
      timezone: timezone,
      currency: currency,
    );

    return await updateUserProfile(
      authToken: authToken,
      updateRequest: updateRequest,
    );
  }

  /// Upload avatar image
  ///
  /// Uploads a new avatar image and updates the user's profile.
  Future<bool> uploadAvatar({
    required String authToken,
    required String imagePath,
  }) async {
    if (_isLoading) return false;

    _setLoading(true);
    _clearError();

    try {
      final response = await _userProfileService.uploadAvatar(
        authToken: authToken,
        imagePath: imagePath,
      );

      if (response.success && response.user != null) {
        _userProfile = response.user;
        notifyListeners();
        return true;
      } else {
        _setError(
            response.error?.userFriendlyMessage ?? 'Failed to upload avatar');
        return false;
      }
    } on UserProfileServiceException catch (e) {
      _setError(e.userFriendlyMessage);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred while uploading avatar');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh user profile by reloading from the API
  Future<void> refreshUserProfile({required String authToken}) async {
    await loadUserProfile(authToken: authToken);
  }

  /// Clear user profile (useful for logout)
  void clearUserProfile() {
    _userProfile = null;
    _hasInitialized = false;
    _clearError();
    notifyListeners();
  }

  /// Update user language preference
  ///
  /// Updates the user's language preference both locally and on the server.
  Future<bool> updateLanguage({
    required String authToken,
    required String language,
  }) async {
    return await updateProfileField(
      authToken: authToken,
      language: language,
    );
  }

  /// Update user timezone
  ///
  /// Updates the user's timezone both locally and on the server.
  Future<bool> updateTimezone({
    required String authToken,
    required String timezone,
  }) async {
    return await updateProfileField(
      authToken: authToken,
      timezone: timezone,
    );
  }

  /// Update user currency preference
  ///
  /// Updates the user's currency preference both locally and on the server.
  Future<bool> updateCurrency({
    required String authToken,
    required String currency,
  }) async {
    return await updateProfileField(
      authToken: authToken,
      currency: currency,
    );
  }

  /// Check if profile has all required basic information
  bool get hasCompleteProfile {
    if (_userProfile == null) return false;
    return _userProfile!.hasBasicInfo;
  }

  /// Get user's preferred language code
  String get preferredLanguage => _userProfile?.language ?? 'en';

  /// Get user's timezone
  String get userTimezone => _userProfile?.timezone ?? 'UTC';

  /// Get user's currency
  String get userCurrency => _userProfile?.currency ?? 'USD';

  // Private helper methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  @override
  String toString() {
    return 'UserProfileProvider(user: ${_userProfile?.name}, loading: $_isLoading, error: $_error)';
  }
}
