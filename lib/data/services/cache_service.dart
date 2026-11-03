import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../models/weather_data.dart';

/// Local storage service managing offline cache, recent search history,
/// and user preferences via [SharedPreferences].
class CacheService {
  final SharedPreferences _prefs;

  CacheService(this._prefs);

  /// Helper factory to initialize [CacheService] with the platform's default preferences.
  static Future<CacheService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return CacheService(prefs);
  }

  // ---------------------------------------------------------------------------
  // Weather Data & Timestamp Caching
  // ---------------------------------------------------------------------------

  /// Persists the last successful [WeatherData] and records the current timestamp.
  Future<bool> saveWeatherData(WeatherData data) async {
    final jsonString = jsonEncode(data.toJson());
    final timestamp = (data.fetchedAt ?? DateTime.now()).toIso8601String();

    final savedData = await _prefs.setString(
      AppConstants.keyCachedWeatherData,
      jsonString,
    );
    final savedTime = await _prefs.setString(
      AppConstants.keyCachedTimestamp,
      timestamp,
    );

    return savedData && savedTime;
  }

  /// Retrieves the cached [WeatherData] if available, or returns null.
  WeatherData? getCachedWeatherData() {
    final jsonString = _prefs.getString(AppConstants.keyCachedWeatherData);
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    try {
      final Map<String, dynamic> map =
          jsonDecode(jsonString) as Map<String, dynamic>;
      return WeatherData.fromJson(map);
    } catch (_) {
      // In case of corrupt or outdated schema, gracefully return null.
      return null;
    }
  }

  /// Retrieves the timestamp when weather data was last cached.
  DateTime? getCachedTimestamp() {
    final timestampStr = _prefs.getString(AppConstants.keyCachedTimestamp);
    if (timestampStr == null) return null;
    return DateTime.tryParse(timestampStr);
  }

  /// Whether valid cached weather data is stored locally.
  bool get hasCachedData {
    return _prefs.containsKey(AppConstants.keyCachedWeatherData);
  }

  // ---------------------------------------------------------------------------
  // Search History Management
  // ---------------------------------------------------------------------------

  /// Retrieves the list of up to 5 most recent search queries.
  List<String> getSearchHistory() {
    return _prefs.getStringList(AppConstants.keySearchHistory) ?? [];
  }

  /// Adds a new city query to the front of recent search history, removing duplicates
  /// and capping at [AppConstants.maxSearchHistoryItems] (5).
  Future<bool> addSearchQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return false;

    final history = getSearchHistory();

    // Remove any previous instance of the same city (case-insensitive)
    history.removeWhere((item) => item.toLowerCase() == trimmed.toLowerCase());

    // Insert at the front (most recent)
    history.insert(0, trimmed);

    // Keep only the most recent N items
    if (history.length > AppConstants.maxSearchHistoryItems) {
      history.removeRange(
        AppConstants.maxSearchHistoryItems,
        history.length,
      );
    }

    return _prefs.setStringList(AppConstants.keySearchHistory, history);
  }

  /// Clears search history.
  Future<bool> clearSearchHistory() {
    return _prefs.remove(AppConstants.keySearchHistory);
  }

  // ---------------------------------------------------------------------------
  // Temperature Unit Preference
  // ---------------------------------------------------------------------------

  /// Saves the user's temperature unit preference (true for Fahrenheit, false for Celsius).
  Future<bool> saveIsFahrenheit(bool isFahrenheit) {
    return _prefs.setBool(AppConstants.keyIsFahrenheit, isFahrenheit);
  }

  /// Retrieves the saved unit preference; defaults to false (Celsius).
  bool getIsFahrenheit() {
    return _prefs.getBool(AppConstants.keyIsFahrenheit) ?? false;
  }
}
