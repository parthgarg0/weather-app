import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_app/core/constants/app_strings.dart';
import 'package:weather_app/core/errors/app_exception.dart';
import 'package:weather_app/data/models/city.dart';
import 'package:weather_app/data/models/current_weather.dart';
import 'package:weather_app/data/models/daily_forecast.dart';
import 'package:weather_app/data/models/weather_data.dart';
import 'package:weather_app/data/repositories/weather_repository.dart';
import 'package:weather_app/viewmodels/weather_viewmodel.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  late MockWeatherRepository mockRepository;
  late WeatherViewModel viewModel;

  const sampleCity = City(
    name: 'Berlin',
    latitude: 52.52,
    longitude: 13.41,
    country: 'Germany',
    admin1: 'Land Berlin',
  );

  const sampleCity2 = City(
    name: 'Springfield',
    latitude: 39.78,
    longitude: -89.65,
    country: 'United States',
    admin1: 'Illinois',
  );

  const sampleCity3 = City(
    name: 'Springfield',
    latitude: 44.05,
    longitude: -123.02,
    country: 'United States',
    admin1: 'Oregon',
  );

  final sampleWeatherData = WeatherData(
    city: sampleCity,
    current: const CurrentWeather(
      temperature: 15.0,
      relativeHumidity: 65,
      weatherCode: 1,
      windSpeed: 10.0,
    ),
    daily: [
      DailyForecast(
        date: DateTime.parse('2026-11-03'),
        weatherCode: 1,
        maxTemperature: 18.0,
        minTemperature: 8.0,
      ),
    ],
    isFahrenheit: false,
    isFromCache: false,
  );

  setUpAll(() {
    registerFallbackValue(sampleCity);
  });

  setUp(() {
    mockRepository = MockWeatherRepository();

    // Default setup for basic repository queries
    when(() => mockRepository.getIsFahrenheit()).thenReturn(false);
    when(() => mockRepository.getIsDarkMode()).thenReturn(false);
    when(() => mockRepository.getSearchHistory()).thenReturn([]);
    when(() => mockRepository.getCachedWeather()).thenReturn(null);
    when(() => mockRepository.getCachedTimestamp()).thenReturn(null);
    when(() => mockRepository.hasCachedData).thenReturn(false);

    viewModel = WeatherViewModel(repository: mockRepository);
  });

  group('WeatherViewModel Initialization', () {
    test('initial state is empty when no cache is stored', () async {
      await viewModel.initialize();

      expect(viewModel.isEmpty, isTrue);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.weatherData, isNull);
      expect(viewModel.isOffline, isFalse);
    });

    test('initial state populates cached weather when available on startup', () async {
      when(() => mockRepository.getCachedWeather()).thenReturn(sampleWeatherData);
      when(() => mockRepository.fetchWeather(
            city: any(named: 'city'),
            isFahrenheit: any(named: 'isFahrenheit'),
          )).thenAnswer((_) async => sampleWeatherData);

      await viewModel.initialize();

      expect(viewModel.weatherData, isNotNull);
      expect(viewModel.weatherData?.city.name, 'Berlin');
      expect(viewModel.lastSearchedCity?.name, 'Berlin');
    });
  });

  group('Input Validation Tests', () {
    test('empty or whitespace input does NOT call repository and shows gentle message', () async {
      await viewModel.searchCity('   ');

      expect(viewModel.validationError, AppStrings.validationEmptyCity);
      expect(viewModel.isLoading, isFalse);
      verifyNever(() => mockRepository.searchCities(any()));
    });

    test('special characters only input does NOT call repository and shows gentle message', () async {
      await viewModel.searchCity('!@#\$%^&*()');

      expect(viewModel.validationError, AppStrings.validationInvalidCity);
      expect(viewModel.isLoading, isFalse);
      verifyNever(() => mockRepository.searchCities(any()));
    });

    test('clearValidationError resets the validation error message', () async {
      await viewModel.searchCity(' ');
      expect(viewModel.validationError, isNotNull);

      viewModel.clearValidationError();
      expect(viewModel.validationError, isNull);
    });
  });

  group('Search & Weather Fetch Flow', () {
    test('successful single city search fetches weather and updates state', () async {
      when(() => mockRepository.searchCities('Berlin'))
          .thenAnswer((_) async => [sampleCity]);
      when(() => mockRepository.fetchWeather(
            city: sampleCity,
            isFahrenheit: false,
          )).thenAnswer((_) async => sampleWeatherData);

      await viewModel.searchCity('Berlin');

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.weatherData, equals(sampleWeatherData));
      expect(viewModel.isOffline, isFalse);
      verify(() => mockRepository.searchCities('Berlin')).called(1);
      verify(() => mockRepository.fetchWeather(
            city: sampleCity,
            isFahrenheit: false,
          )).called(1);
    });

    test('search returning multiple cities populates matchedCities for bottom sheet picker', () async {
      when(() => mockRepository.searchCities('Springfield'))
          .thenAnswer((_) async => [sampleCity2, sampleCity3]);

      await viewModel.searchCity('Springfield');

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.matchedCities.length, 2);
      expect(viewModel.weatherData, isNull);
      // Weather should NOT be fetched until the user picks one
      verifyNever(() => mockRepository.fetchWeather(
            city: any(named: 'city'),
            isFahrenheit: any(named: 'isFahrenheit'),
          ));
    });

    test('selectCity executes fetch for chosen city and clears matchedCities', () async {
      when(() => mockRepository.fetchWeather(
            city: sampleCity2,
            isFahrenheit: false,
          )).thenAnswer((_) async => sampleWeatherData.copyWith(city: sampleCity2));

      await viewModel.selectCity(sampleCity2);

      expect(viewModel.matchedCities, isEmpty);
      expect(viewModel.weatherData?.city.name, 'Springfield');
      expect(viewModel.lastSearchedCity?.name, 'Springfield');
    });

    test('city not found sets user-friendly error message', () async {
      when(() => mockRepository.searchCities('asdfghjkl'))
          .thenThrow(const CityNotFoundException());

      await viewModel.searchCity('asdfghjkl');

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, AppStrings.errorCityNotFound);
      expect(viewModel.weatherData, isNull);
    });
  });

  group('Offline Support & Fallback Tests', () {
    test('offline with cache: displays cached data and activates offline banner', () async {
      // Setup: cache exists in repository
      when(() => mockRepository.hasCachedData).thenReturn(true);
      when(() => mockRepository.getCachedWeather()).thenReturn(sampleWeatherData);
      when(() => mockRepository.searchCities('Berlin'))
          .thenAnswer((_) async => [sampleCity]);
      // Weather fetch throws NoInternetException
      when(() => mockRepository.fetchWeather(
            city: sampleCity,
            isFahrenheit: false,
          )).thenThrow(const NoInternetException());

      await viewModel.searchCity('Berlin');

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.isOffline, isTrue);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.weatherData, isNotNull);
      expect(viewModel.weatherData?.city.name, 'Berlin');
      expect(viewModel.weatherData?.isFromCache, isTrue);
    });

    test('offline with NO cache: displays no internet error state', () async {
      when(() => mockRepository.hasCachedData).thenReturn(false);
      when(() => mockRepository.searchCities('Rome'))
          .thenThrow(const NoInternetException());

      await viewModel.searchCity('Rome');

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.isOffline, isFalse);
      expect(viewModel.weatherData, isNull);
      expect(viewModel.errorMessage, AppStrings.errorNoInternet);
    });
  });

  group('Bonus Features: Unit Toggle & Search History', () {
    test('toggleTemperatureUnit inverts unit, saves preference, and refetches active city', () async {
      when(() => mockRepository.saveIsFahrenheit(true)).thenAnswer((_) async => true);
      when(() => mockRepository.searchCities('Berlin'))
          .thenAnswer((_) async => [sampleCity]);
      when(() => mockRepository.fetchWeather(
            city: sampleCity,
            isFahrenheit: false,
          )).thenAnswer((_) async => sampleWeatherData);
      when(() => mockRepository.fetchWeather(
            city: sampleCity,
            isFahrenheit: true,
          )).thenAnswer((_) async => sampleWeatherData.copyWith(isFahrenheit: true));

      await viewModel.searchCity('Berlin');
      expect(viewModel.isFahrenheit, isFalse);

      await viewModel.toggleTemperatureUnit();

      expect(viewModel.isFahrenheit, isTrue);
      verify(() => mockRepository.saveIsFahrenheit(true)).called(1);
      verify(() => mockRepository.fetchWeather(
            city: sampleCity,
            isFahrenheit: true,
          )).called(1);
    });

    test('clearHistory clears history list in ViewModel and repository', () async {
      when(() => mockRepository.clearSearchHistory()).thenAnswer((_) async => true);

      await viewModel.clearHistory();

      expect(viewModel.searchHistory, isEmpty);
      verify(() => mockRepository.clearSearchHistory()).called(1);
    });

    test('toggleThemeMode inverts theme mode and saves preference', () async {
      when(() => mockRepository.saveIsDarkMode(true)).thenAnswer((_) async => true);

      expect(viewModel.isDarkMode, isFalse);
      await viewModel.toggleThemeMode();

      expect(viewModel.isDarkMode, isTrue);
      verify(() => mockRepository.saveIsDarkMode(true)).called(1);
    });
  });
}
