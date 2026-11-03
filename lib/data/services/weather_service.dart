import 'dart:async' as async;
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/city.dart';
import '../models/current_weather.dart';
import '../models/daily_forecast.dart';
import '../models/weather_data.dart';

/// Service responsible for fetching weather forecast data from the Open-Meteo Weather API.
class WeatherService {
  final http.Client _client;

  /// Injects an [http.Client] to support mock testing.
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches current weather and 5-day daily forecast for the provided [city].
  ///
  /// Appends `temperature_unit=fahrenheit` when [isFahrenheit] is true.
  /// Throws [TimeoutException] if the request exceeds 10 seconds.
  /// Throws [NoInternetException] on network or socket disconnect.
  /// Throws [ApiException] on non-200 responses or parsing failures.
  Future<WeatherData> fetchWeather({
    required City city,
    bool isFahrenheit = false,
  }) async {
    final queryParams = <String, String>{
      'latitude': city.latitude.toString(),
      'longitude': city.longitude.toString(),
      'current': ApiConstants.currentWeatherFields,
      'daily': ApiConstants.dailyWeatherFields,
      'forecast_days': ApiConstants.defaultForecastDays.toString(),
      'timezone': ApiConstants.timezoneAuto,
    };

    if (isFahrenheit) {
      queryParams['temperature_unit'] = ApiConstants.unitFahrenheit;
    }

    final uri = Uri.parse(
      '${ApiConstants.weatherBaseUrl}${ApiConstants.forecastPath}',
    ).replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri).timeout(ApiConstants.requestTimeout);

      if (response.statusCode != 200) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Weather service returned status code ${response.statusCode}',
        );
      }

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (!data.containsKey('current') || !data.containsKey('daily')) {
        throw const ApiException(
          message: 'Weather API response missing current or daily forecast data.',
        );
      }

      final currentWeather = CurrentWeather.fromJson(
        data['current'] as Map<String, dynamic>,
      );

      final dailyForecasts = DailyForecast.fromDailyArrays(
        data['daily'] as Map<String, dynamic>,
      );

      return WeatherData(
        city: city,
        current: currentWeather,
        daily: dailyForecasts,
        isFahrenheit: isFahrenheit,
        fetchedAt: DateTime.now(),
      );
    } on async.TimeoutException {
      throw const TimeoutException();
    } on SocketException {
      throw const NoInternetException();
    } on http.ClientException {
      throw const NoInternetException();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}
