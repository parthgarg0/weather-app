/// API constants for Open-Meteo services.
/// 
/// Open-Meteo provides free weather and geocoding endpoints without requiring an API key.
/// Centralizing all endpoints, query parameters, and timeout durations prevents magic
/// strings and makes testing/updating endpoints effortless.
class ApiConstants {
  // Private constructor to prevent instantiation of utility class.
  ApiConstants._();

  /// Geocoding API base URL (Open-Meteo geocoding service).
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

  /// Fahrenheit parameter value when toggled.
  static const String unitFahrenheit = 'fahrenheit';

  /// HTTP request timeout duration (10 seconds as specified).
  static const Duration requestTimeout = Duration(seconds: 10);
}
