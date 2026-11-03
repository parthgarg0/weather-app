import '../models/city.dart';
import '../models/weather_data.dart';
import '../services/cache_service.dart';
import '../services/geocoding_service.dart';
import '../services/weather_service.dart';

/// Repository that acts as the single source of truth for weather and geocoding operations.
///
/// Orchestrates requests between [GeocodingService], [WeatherService], and [CacheService],
/// insulating viewmodels from the details of remote APIs and local storage.
class WeatherRepository {
  final GeocodingService _geocodingService;
  final WeatherService _weatherService;
  final CacheService _cacheService;

  WeatherRepository({
    GeocodingService? geocodingService,
    WeatherService? weatherService,
    required CacheService cacheService,
  })  : _geocodingService = geocodingService ?? GeocodingService(),
        _weatherService = weatherService ?? WeatherService(),
        _cacheService = cacheService;

  /// Searches for matching cities using the geocoding service.
  ///
  /// Throws [CityNotFoundException] if query matches no cities.
  /// Throws [NoInternetException] or [TimeoutException] on connection issues.
  Future<List<City>> searchCities(String query) {
    return _geocodingService.searchCities(query);
  }

  /// Fetches fresh weather data from the remote API for [city].
  ///
  /// Upon successful receipt, caches the result locally and records the city
  /// in search history.
  Future<WeatherData> fetchWeather({
    required City city,
    bool isFahrenheit = false,
  }) async {
    final weatherData = await _weatherService.fetchWeather(
      city: city,
      isFahrenheit: isFahrenheit,
    );

    // Save successful response locally for offline capability
    await _cacheService.saveWeatherData(weatherData);

    // Add city to recent search history
    await _cacheService.addSearchQuery(city.name);

    return weatherData;
  }

  /// Retrieves the locally cached weather data, if present.
  WeatherData? getCachedWeather() {
    return _cacheService.getCachedWeatherData();
  }

  /// Retrieves the timestamp when weather was last saved.
  DateTime? getCachedTimestamp() {
    return _cacheService.getCachedTimestamp();
  }

  /// Whether offline weather cache exists.
  bool get hasCachedData => _cacheService.hasCachedData;

  /// Retrieves recent search history strings (up to 5 items).
  List<String> getSearchHistory() {
    return _cacheService.getSearchHistory();
  }

  /// Clears search history.
  Future<bool> clearSearchHistory() {
    return _cacheService.clearSearchHistory();
  }

  /// Retrieves the persisted temperature unit preference.
  bool getIsFahrenheit() {
    return _cacheService.getIsFahrenheit();
  }

  /// Persists the temperature unit preference.
  Future<bool> saveIsFahrenheit(bool isFahrenheit) {
    return _cacheService.saveIsFahrenheit(isFahrenheit);
  }
}
