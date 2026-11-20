/// Application-wide constants including API endpoints, configuration limits,
/// SharedPreferences cache keys, and user-facing UI strings.
///
/// Consolidating these constants into a single file avoids scattered values,
/// eliminates magic strings, and makes the project easy to navigate and explain.
library;

/// Open-Meteo API endpoints and request parameters.
class ApiConstants {
  ApiConstants._();

  /// Geocoding API base URL (converts city names to latitude/longitude coordinates).
  static const String geocodingBaseUrl = 'https://geocoding-api.open-meteo.com/v1';

  /// Weather forecast API base URL.
  static const String weatherBaseUrl = 'https://api.open-meteo.com/v1';

  /// Geocoding search endpoint path.
  static const String geocodingSearchPath = '/search';

  /// Weather forecast endpoint path.
  static const String forecastPath = '/forecast';

  /// Maximum number of search results to request from geocoding.
  static const int defaultGeocodingCount = 5;

  /// Number of forecast days to request from Open-Meteo.
  static const int defaultForecastDays = 5;

  /// Comma-separated list of current weather fields required.
  static const String currentWeatherFields =
      'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m';

  /// Comma-separated list of daily forecast fields required.
  static const String dailyWeatherFields =
      'weather_code,temperature_2m_max,temperature_2m_min';

  /// Timezone parameter value so the API aligns daily data with local city time.
  static const String timezoneAuto = 'auto';

  /// Query parameter value when requesting temperature in Fahrenheit.
  static const String unitFahrenheit = 'fahrenheit';

  /// HTTP request timeout duration (10 seconds).
  static const Duration requestTimeout = Duration(seconds: 10);
}

/// SharedPreferences keys and numerical configuration limits.
class AppConstants {
  AppConstants._();

  // SharedPreferences Keys
  static const String keyCachedWeatherData = 'cached_weather_data_json';
  static const String keyCachedTimestamp = 'cached_weather_timestamp';
  static const String keySearchHistory = 'cached_search_history_list';
  static const String keyIsFahrenheit = 'cached_temp_unit_is_fahrenheit';
  static const String keyIsDarkMode = 'cached_theme_is_dark';

  // Configuration values
  /// Maximum number of recent search history items retained.
  static const int maxSearchHistoryItems = 5;

  /// Default number of forecast days displayed.
  static const int forecastDaysCount = 5;

  /// Network timeout in seconds.
  static const int networkTimeoutSeconds = 10;
}

/// User-facing copy, labels, and error messages.
class AppStrings {
  AppStrings._();

  // App & Screen titles
  static const String appTitle = 'Weather App';
  static const String searchPrompt = 'Search city (e.g. Berlin, Tokyo)...';
  static const String forecastTitle = '5-Day Forecast';
  static const String recentSearchesTitle = 'Recent Searches';

  // Validation messages
  static const String validationEmptyCity = 'Please enter a city name to search.';
  static const String validationInvalidCity =
      'Please enter a valid city name (letters, spaces, and hyphens only).';

  // State messages
  static const String emptyStateMessage = 'Search for a city to see its weather';
  static const String loadingMessage = 'Fetching weather data...';
  static const String retryButton = 'Retry';
  static const String clearHistory = 'Clear';

  // Error messages
  static const String errorCityNotFound =
      'City not found. Please verify the spelling and try again.';
  static const String errorNoInternet =
      'No internet connection. Please check your network settings.';
  static const String errorTimeout =
      'The connection timed out after 10 seconds. Please try again.';
  static const String errorGenericApi =
      'Unable to retrieve weather data from Open-Meteo. Please try again.';
  static const String errorUnexpected =
      'An unexpected error occurred. Please try again.';

  // Offline banner text generator
  static String offlineBannerText(String savedTime) =>
      "You're offline. Showing saved data from $savedTime, it may be outdated.";

  // Weather metrics
  static const String humidityLabel = 'Humidity';
  static const String windSpeedLabel = 'Wind Speed';
  static const String unitKmH = 'km/h';
  static const String unitCelsius = '°C';
  static const String unitFahrenheit = '°F';

  // Bottom Sheet
  static const String pickerTitle = 'Select Location';
  static const String pickerSubtitle =
      'Multiple cities match your search. Choose your preferred location:';
  static const String pickerUnknownRegion = 'Unknown region';
}
