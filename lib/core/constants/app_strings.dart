/// Centralized user-facing UI strings for the entire application.
/// 
/// Storing all user-visible text in one place guarantees consistency, prevents
/// hardcoded typos across widgets, and simplifies future internationalization (i18n).
class AppStrings {
  // Private constructor to prevent instantiation.
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

  // Offline banner
  /// Formats the offline warning banner with the provided formatted date/time string.
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
