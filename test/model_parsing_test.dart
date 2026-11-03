import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:weather_app/core/errors/app_exception.dart';
import 'package:weather_app/data/models/city.dart';
import 'package:weather_app/data/models/current_weather.dart';
import 'package:weather_app/data/models/daily_forecast.dart';
import 'package:weather_app/data/models/weather_data.dart';
import 'package:weather_app/data/services/geocoding_service.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  group('City Model Parsing Tests', () {
    test('parses full city JSON successfully', () {
      final json = {
        'name': 'Berlin',
        'latitude': 52.52437,
        'longitude': 13.41053,
        'country': 'Germany',
        'admin1': 'Land Berlin',
      };

      final city = City.fromJson(json);

      expect(city.name, 'Berlin');
      expect(city.latitude, 52.52437);
      expect(city.longitude, 13.41053);
      expect(city.country, 'Germany');
      expect(city.admin1, 'Land Berlin');
      expect(city.locationDetails, 'Land Berlin, Germany');
    });

    test('parses city JSON when admin1 is null or empty', () {
      final json = {
        'name': 'Monaco',
        'latitude': 43.73333,
        'longitude': 7.41667,
        'country': 'Monaco',
        'admin1': null,
      };

      final city = City.fromJson(json);

      expect(city.name, 'Monaco');
      expect(city.admin1, isNull);
      expect(city.locationDetails, 'Monaco');
    });

    test('serializes to JSON and roundtrips correctly', () {
      const city = City(
        name: 'Tokyo',
        latitude: 35.6895,
        longitude: 139.69171,
        country: 'Japan',
        admin1: 'Tokyo Prefecture',
      );

      final map = city.toJson();
      final reconstructed = City.fromJson(map);

      expect(reconstructed, equals(city));
    });
  });

  group('Geocoding Missing Results Handling', () {
    late MockHttpClient mockClient;
    late GeocodingService geocodingService;

    setUp(() {
      mockClient = MockHttpClient();
      geocodingService = GeocodingService(client: mockClient);
    });

    test('throws CityNotFoundException when results key is missing from JSON', () async {
      when(() => mockClient.get(any())).thenAnswer(
        (_) async => http.Response(jsonEncode({'generationtime_ms': 0.12}), 200),
      );

      expect(
        () => geocodingService.searchCities('unknownplacexyz'),
        throwsA(isA<CityNotFoundException>()),
      );
    });

    test('throws CityNotFoundException when results array is empty', () async {
      when(() => mockClient.get(any())).thenAnswer(
        (_) async => http.Response(jsonEncode({'results': []}), 200),
      );

      expect(
        () => geocodingService.searchCities('nonexistentcity12345'),
        throwsA(isA<CityNotFoundException>()),
      );
    });
  });

  group('CurrentWeather Model Parsing Tests', () {
    test('parses Open-Meteo raw API current JSON correctly', () {
      final apiJson = {
        'time': '2026-11-03T07:15',
        'interval': 900,
        'temperature_2m': 16.4,
        'relative_humidity_2m': 58,
        'weather_code': 2,
        'wind_speed_10m': 12.5,
      };

      final current = CurrentWeather.fromJson(apiJson);

      expect(current.temperature, 16.4);
      expect(current.relativeHumidity, 58);
      expect(current.weatherCode, 2);
      expect(current.windSpeed, 12.5);
      expect(current.time, DateTime.parse('2026-11-03T07:15'));
    });

    test('serializes and deserializes CurrentWeather cache JSON roundtrip', () {
      final original = CurrentWeather(
        temperature: 22.0,
        relativeHumidity: 45,
        weatherCode: 0,
        windSpeed: 8.5,
        time: DateTime.parse('2026-11-03T12:00:00'),
      );

      final json = original.toJson();
      final roundtrip = CurrentWeather.fromJson(json);

      expect(roundtrip, equals(original));
    });
  });

  group('DailyForecast Model Parsing Tests', () {
    test('zips Open-Meteo parallel arrays into List of DailyForecast', () {
      final dailyJson = {
        'time': ['2026-11-03', '2026-11-04', '2026-11-05'],
        'weather_code': [0, 61, 2],
        'temperature_2m_max': [18.2, 14.5, 16.0],
        'temperature_2m_min': [8.1, 9.3, 7.0],
      };

      final list = DailyForecast.fromDailyArrays(dailyJson);

      expect(list.length, 3);
      expect(list[0].date, DateTime.parse('2026-11-03'));
      expect(list[0].weatherCode, 0);
      expect(list[0].maxTemperature, 18.2);
      expect(list[0].minTemperature, 8.1);

      expect(list[1].weatherCode, 61);
      expect(list[2].maxTemperature, 16.0);
    });

    test('serializes DailyForecast to JSON and roundtrips', () {
      final forecast = DailyForecast(
        date: DateTime.parse('2026-11-03'),
        weatherCode: 3,
        maxTemperature: 15.0,
        minTemperature: 6.5,
      );

      final json = forecast.toJson();
      final parsed = DailyForecast.fromJson(json);

      expect(parsed, equals(forecast));
    });
  });

  group('WeatherData Model Parsing Tests', () {
    test('roundtrips WeatherData through toJson and fromJson', () {
      const city = City(
        name: 'Paris',
        latitude: 48.85341,
        longitude: 2.3488,
        country: 'France',
        admin1: 'Île-de-France',
      );

      final current = CurrentWeather(
        temperature: 15.0,
        relativeHumidity: 60,
        weatherCode: 1,
        windSpeed: 10.0,
        time: DateTime.parse('2026-11-03T10:00:00'),
      );

      final daily = [
        DailyForecast(
          date: DateTime.parse('2026-11-03'),
          weatherCode: 1,
          maxTemperature: 17.0,
          minTemperature: 8.0,
        ),
      ];

      final data = WeatherData(
        city: city,
        current: current,
        daily: daily,
        isFahrenheit: false,
        fetchedAt: DateTime.parse('2026-11-03T10:00:00'),
        isFromCache: true,
      );

      final json = data.toJson();
      final deserialized = WeatherData.fromJson(json);

      expect(deserialized.city.name, 'Paris');
      expect(deserialized.current.temperature, 15.0);
      expect(deserialized.daily.length, 1);
      expect(deserialized.isFahrenheit, isFalse);
      expect(deserialized.isFromCache, isTrue);
    });

    test('copyWith properly overrides fields', () {
      const city = City(
        name: 'London',
        latitude: 51.50853,
        longitude: -0.12574,
        country: 'United Kingdom',
      );

      final current = CurrentWeather(
        temperature: 10.0,
        relativeHumidity: 80,
        weatherCode: 3,
        windSpeed: 15.0,
      );

      final data = WeatherData(
        city: city,
        current: current,
        daily: const [],
        isFahrenheit: false,
      );

      final modified = data.copyWith(isFahrenheit: true, isFromCache: true);

      expect(modified.isFahrenheit, isTrue);
      expect(modified.isFromCache, isTrue);
      expect(modified.city.name, 'London');
    });
  });
}
