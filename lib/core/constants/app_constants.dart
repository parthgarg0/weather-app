/// Application-wide constants including cache keys and configuration limits.
class AppConstants {
  // Private constructor to prevent instantiation.
  AppConstants._();

  // SharedPreferences Keys
  /// Key for storing cached weather data JSON string.
  static const String keyCachedWeatherData = 'cached_weather_data_json';

  /// Key for storing the ISO8601 timestamp string when data was last cached.
  static const String keyCachedTimestamp = 'cached_weather_timestamp';

  /// Key for storing the recent search history string list.
  static const String keySearchHistory = 'cached_search_history_list';

  /// Key for storing boolean flag for Fahrenheit temperature unit preference.
  static const String keyIsFahrenheit = 'cached_temp_unit_is_fahrenheit';

  /// Key for storing boolean flag for Dark Mode preference.
  static const String keyIsDarkMode = 'cached_theme_is_dark';

  // Configuration values
  /// Maximum number of search history items to retain.
  static const int maxSearchHistoryItems = 5;

  /// Default number of forecast days displayed.
  static const int forecastDaysCount = 5;

  /// Network timeout in seconds.
  static const int networkTimeoutSeconds = 10;
}
