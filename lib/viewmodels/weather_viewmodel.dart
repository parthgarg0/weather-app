import 'package:flutter/foundation.dart';

import '../core/constants/app_strings.dart';
import '../core/errors/app_exception.dart';
import '../data/models/city.dart';
import '../data/models/weather_data.dart';
import '../data/repositories/weather_repository.dart';

/// ViewModel managing state for the Weather application following the MVVM pattern.
///
/// Implements [ChangeNotifier] so views can observe and rebuild reactively.
/// Manages asynchronous network states, stale request discarding, offline caching fallback,
/// temperature unit toggling, and input validation.
class WeatherViewModel extends ChangeNotifier {
  final WeatherRepository _repository;

  WeatherViewModel({required WeatherRepository repository})
      : _repository = repository;

  // ---------------------------------------------------------------------------
  // Internal State
  // ---------------------------------------------------------------------------

  WeatherData? _weatherData;
  City? _lastSearchedCity;
  List<City> _matchedCities = [];
  List<String> _searchHistory = [];

  bool _isLoading = false;
  bool _isOffline = false;
  String? _errorMessage;
  String? _validationError;
  bool _isFahrenheit = false;

  /// Request counter to cancel/ignore stale responses when a user triggers
  /// multiple searches in rapid succession.
  int _activeRequestId = 0;

  // ---------------------------------------------------------------------------
  // Public Getters
  // ---------------------------------------------------------------------------

  WeatherData? get weatherData => _weatherData;
  City? get lastSearchedCity => _lastSearchedCity;
  List<City> get matchedCities => List.unmodifiable(_matchedCities);
  List<String> get searchHistory => List.unmodifiable(_searchHistory);

  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  String? get errorMessage => _errorMessage;
  String? get validationError => _validationError;
  bool get isFahrenheit => _isFahrenheit;

  /// Whether the app is in the initial empty state before any search is conducted.
  bool get isEmpty =>
      _weatherData == null && !_isLoading && _errorMessage == null && _matchedCities.isEmpty;

  /// Timestamp when currently displayed data was cached.
  DateTime? get cachedTimestamp =>
      _weatherData?.fetchedAt ?? _repository.getCachedTimestamp();

  // ---------------------------------------------------------------------------
  // Lifecycle Initialization
  // ---------------------------------------------------------------------------

  /// Initializes persisted settings, search history, and loads cached weather data
  /// on application startup, followed by a background refresh attempt.
  Future<void> initialize() async {
    _isFahrenheit = _repository.getIsFahrenheit();
    _searchHistory = _repository.getSearchHistory();

    final cached = _repository.getCachedWeather();
    if (cached != null) {
      _weatherData = cached.copyWith(isFromCache: true);
      _lastSearchedCity = cached.city;
      _isOffline = false;
      notifyListeners();

      // Attempt to silently refresh with live data if network allows
      await refreshWeather();
    } else {
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Search & City Selection Flow
  // ---------------------------------------------------------------------------

  /// Initiates a city search with input validation and stale response protection.
  ///
  /// If geocoding finds multiple cities, sets [matchedCities] so the UI can present
  /// a bottom sheet picker. If only 1 city matches, selects it directly.
  Future<void> searchCity(String rawQuery) async {
    final trimmed = rawQuery.trim();

    // 1. Validation check
    if (trimmed.isEmpty) {
      _validationError = AppStrings.validationEmptyCity;
      notifyListeners();
      return;
    }

    // Require at least one letter and forbid pure special character gibberish
    final hasLetter = RegExp(r'[\p{L}]', unicode: true).hasMatch(trimmed);
    final isAllowedChars =
        RegExp(r"^[\p{L}\s\-'.]+$", unicode: true).hasMatch(trimmed);

    if (!hasLetter || !isAllowedChars) {
      _validationError = AppStrings.validationInvalidCity;
      notifyListeners();
      return;
    }

    // Clear previous validation error and errors
    _validationError = null;
    _errorMessage = null;
    _matchedCities = [];

    // Increment request ID to invalidate any in-flight requests
    final int currentRequestId = ++_activeRequestId;

    _setLoading(true);

    try {
      final cities = await _repository.searchCities(trimmed);

      // Discard response if a newer request was initiated while waiting
      if (currentRequestId != _activeRequestId) return;

      if (cities.length == 1) {
        // Only one city found -> proceed directly to fetch weather
        await selectCity(cities.first, requestId: currentRequestId);
      } else {
        // Multiple cities found -> surface matched cities for bottom sheet picker
        _matchedCities = cities;
        _setLoading(false);
      }
    } on AppException catch (e) {
      if (currentRequestId != _activeRequestId) return;
      _handleSearchError(e);
    } catch (e) {
      if (currentRequestId != _activeRequestId) return;
      _handleSearchError(const ApiException(message: AppStrings.errorUnexpected));
    }
  }

  /// Selects a specific [City] (e.g. from the picker sheet or direct match)
  /// and fetches its weather.
  Future<void> selectCity(City city, {int? requestId}) async {
    final int currentRequestId = requestId ?? ++_activeRequestId;

    _matchedCities = [];
    _lastSearchedCity = city;
    _errorMessage = null;
    _setLoading(true);

    try {
      final liveWeather = await _repository.fetchWeather(
        city: city,
        isFahrenheit: _isFahrenheit,
      );

      if (currentRequestId != _activeRequestId) return;

      _weatherData = liveWeather.copyWith(isFromCache: false);
      _isOffline = false;
      _errorMessage = null;
      _searchHistory = _repository.getSearchHistory();
    } on AppException catch (e) {
      if (currentRequestId != _activeRequestId) return;
      _handleWeatherFetchError(e);
    } catch (e) {
      if (currentRequestId != _activeRequestId) return;
      _handleWeatherFetchError(
        const ApiException(message: AppStrings.errorUnexpected),
      );
    } finally {
      if (currentRequestId == _activeRequestId) {
        _setLoading(false);
      }
    }
  }

  /// Pull-to-refresh or retry for the current city.
  Future<void> refreshWeather() async {
    if (_lastSearchedCity == null) return;
    await selectCity(_lastSearchedCity!);
  }

  /// Retries the last attempted search or refresh.
  Future<void> retryLastAction() async {
    if (_lastSearchedCity != null) {
      await refreshWeather();
    } else {
      _errorMessage = null;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Unit Toggle (°C / °F)
  // ---------------------------------------------------------------------------

  /// Toggles between Celsius and Fahrenheit, persists the choice,
  /// and re-fetches the current city's weather in the selected unit.
  Future<void> toggleTemperatureUnit() async {
    _isFahrenheit = !_isFahrenheit;
    await _repository.saveIsFahrenheit(_isFahrenheit);
    notifyListeners();

    if (_lastSearchedCity != null) {
      await refreshWeather();
    }
  }

  // ---------------------------------------------------------------------------
  // Search History Management
  // ---------------------------------------------------------------------------

  /// Clears recent search history chips.
  Future<void> clearHistory() async {
    await _repository.clearSearchHistory();
    _searchHistory = [];
    notifyListeners();
  }

  /// Clears active validation error when user begins editing text.
  void clearValidationError() {
    if (_validationError != null) {
      _validationError = null;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Private Error Handlers
  // ---------------------------------------------------------------------------

  void _handleSearchError(AppException error) {
    _isLoading = false;

    // Check if network error and cached data exists
    if ((error is NoInternetException || error is TimeoutException) &&
        _repository.hasCachedData) {
      final cached = _repository.getCachedWeather();
      if (cached != null) {
        _weatherData = cached.copyWith(isFromCache: true);
        _isOffline = true;
        _errorMessage = null;
        notifyListeners();
        return;
      }
    }

    _errorMessage = error.message;
    notifyListeners();
  }

  void _handleWeatherFetchError(AppException error) {
    // If network failed but we have a cache available, fallback to cached data with offline banner
    if ((error is NoInternetException || error is TimeoutException) &&
        _repository.hasCachedData) {
      final cached = _repository.getCachedWeather();
      if (cached != null) {
        _weatherData = cached.copyWith(isFromCache: true);
        _isOffline = true;
        _errorMessage = null;
        return;
      }
    }

    _errorMessage = error.message;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
