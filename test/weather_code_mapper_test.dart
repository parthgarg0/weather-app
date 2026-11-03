import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/core/utils/weather_code_mapper.dart';

void main() {
  group('WeatherCodeMapper Tests', () {
    test('maps 0 to Clear sky with sun icon', () {
      final condition = WeatherCodeMapper.map(0);
      expect(condition.description, 'Clear sky');
      expect(condition.icon, '☀️');
    });

    test('maps 1 to Mainly clear', () {
      final condition = WeatherCodeMapper.map(1);
      expect(condition.description, 'Mainly clear');
      expect(condition.icon, '🌤️');
    });

    test('maps 2 to Partly cloudy', () {
      final condition = WeatherCodeMapper.map(2);
      expect(condition.description, 'Partly cloudy');
      expect(condition.icon, '⛅');
    });

    test('maps 3 to Overcast', () {
      final condition = WeatherCodeMapper.map(3);
      expect(condition.description, 'Overcast');
      expect(condition.icon, '☁️');
    });

    test('maps 45 and 48 to Fog', () {
      expect(WeatherCodeMapper.getDescription(45), 'Fog');
      expect(WeatherCodeMapper.getIcon(45), '🌫️');
      expect(WeatherCodeMapper.getDescription(48), 'Fog');
      expect(WeatherCodeMapper.getIcon(48), '🌫️');
    });

    test('maps drizzle codes 51, 53, 55', () {
      expect(WeatherCodeMapper.getDescription(51), 'Light drizzle');
      expect(WeatherCodeMapper.getDescription(53), 'Moderate drizzle');
      expect(WeatherCodeMapper.getDescription(55), 'Dense drizzle');
    });

    test('maps rain codes 61, 63, 65', () {
      expect(WeatherCodeMapper.getDescription(61), 'Slight rain');
      expect(WeatherCodeMapper.getDescription(63), 'Moderate rain');
      expect(WeatherCodeMapper.getDescription(65), 'Heavy rain');
    });

    test('maps snow codes 71, 73, 75', () {
      expect(WeatherCodeMapper.getDescription(71), 'Slight snow');
      expect(WeatherCodeMapper.getDescription(73), 'Moderate snow');
      expect(WeatherCodeMapper.getDescription(75), 'Heavy snow');
    });

    test('maps rain shower codes 80, 81, 82', () {
      expect(WeatherCodeMapper.getDescription(80), 'Rain showers');
      expect(WeatherCodeMapper.getDescription(81), 'Rain showers');
      expect(WeatherCodeMapper.getDescription(82), 'Rain showers');
    });

    test('maps thunderstorm codes 95, 96, 99', () {
      expect(WeatherCodeMapper.getDescription(95), 'Thunderstorm');
      expect(WeatherCodeMapper.getDescription(96), 'Thunderstorm with hail');
      expect(WeatherCodeMapper.getDescription(99), 'Thunderstorm with hail');
    });

    test('unknown codes fall back to Unknown and question mark icon', () {
      final negativeCode = WeatherCodeMapper.map(-1);
      expect(negativeCode.description, 'Unknown');
      expect(negativeCode.icon, '❓');

      final arbitraryCode = WeatherCodeMapper.map(999);
      expect(arbitraryCode.description, 'Unknown');
      expect(arbitraryCode.icon, '❓');

      final unhandledCode = WeatherCodeMapper.map(42);
      expect(unhandledCode.description, 'Unknown');
      expect(unhandledCode.icon, '❓');
    });
  });
}
