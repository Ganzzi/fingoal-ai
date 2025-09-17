import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language Provider
///
/// Manages the app's language state and persistence using SharedPreferences.
/// Provides methods to change language and notifies listeners of changes.
///
/// Features:
/// - Language persistence across app sessions
/// - Reactive language changes throughout the app
/// - Support for English (en) and Vietnamese (vi)
/// - Integration ready for API requests
class LanguageProvider with ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'en';

  Locale _currentLocale = const Locale(_defaultLanguage);
  SharedPreferences? _prefs;

  /// Current selected locale
  Locale get currentLocale => _currentLocale;

  /// Current language code (en, vi)
  String get currentLanguageCode => _currentLocale.languageCode;

  /// Check if current language is English
  bool get isEnglish => _currentLocale.languageCode == 'en';

  /// Check if current language is Vietnamese
  bool get isVietnamese => _currentLocale.languageCode == 'vi';

  /// Initialize the language provider and load saved language
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSavedLanguage();
  }

  /// Load saved language from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    final savedLanguage = _prefs?.getString(_languageKey) ?? _defaultLanguage;
    _currentLocale = Locale(savedLanguage);
    notifyListeners();
  }

  /// Change the app language
  Future<void> changeLanguage(String languageCode) async {
    if (languageCode != _currentLocale.languageCode) {
      _currentLocale = Locale(languageCode);
      await _saveLanguage(languageCode);
      notifyListeners();
    }
  }

  /// Save language preference to SharedPreferences
  Future<void> _saveLanguage(String languageCode) async {
    await _prefs?.setString(_languageKey, languageCode);
  }

  /// Get language name for display
  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'vi':
        return 'Tiếng Việt';
      default:
        return 'English';
    }
  }

  /// Get available languages
  List<String> get availableLanguages => ['en', 'vi'];

  /// Get language for API requests
  /// This method returns the current language code formatted for the Router Agent
  Map<String, dynamic> getLanguageForApiRequest() {
    return {
      'language': currentLanguageCode,
    };
  }
}
