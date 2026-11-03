import 'city.dart';
import 'current_weather.dart';
import 'daily_forecast.dart';

/// Aggregated weather information model combining the target city,
/// current atmospheric conditions, and the multi-day forecast.
/// 
/// Also tracks the temperature unit preference and the timestamp when
/// data was fetched, which enables cache age display during offline fallback.
class WeatherData {
  /// The city location for this weather report.
  final City city;

  /// Current weather conditions.
  final CurrentWeather current;

  /// List of daily forecasts (typically 5 days).
  final List<DailyForecast> daily;

  /// True if temperatures are in Fahrenheit; false if Celsius.
  final bool isFahrenheit;

  /// Timestamp when this data was fetched from the network.
  final DateTime? fetchedAt;

  const WeatherData({
    required this.city,
    required this.current,
    required this.daily,
    this.isFahrenheit = false,
    this.fetchedAt,
  });

  /// Factory constructor to reconstruct [WeatherData] from JSON (used for offline cache).
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      city: City.fromJson(json['city'] as Map<String, dynamic>),
      current: CurrentWeather.fromJson(json['current'] as Map<String, dynamic>),
      daily: (json['daily'] as List<dynamic>)
          .map((item) => DailyForecast.fromJson(item as Map<String, dynamic>))
          .toList(),
      isFahrenheit: json['isFahrenheit'] as bool? ?? false,
      fetchedAt: json['fetchedAt'] != null
          ? DateTime.tryParse(json['fetchedAt'] as String)
          : null,
    );
  }

  /// Serializes the entire weather report into a JSON Map for local storage.
  Map<String, dynamic> toJson() {
    return {
      'city': city.toJson(),
      'current': current.toJson(),
      'daily': daily.map((f) => f.toJson()).toList(),
      'isFahrenheit': isFahrenheit,
      'fetchedAt': fetchedAt?.toIso8601String(),
    };
  }

  /// Creates a copy of [WeatherData] with updated values.
  WeatherData copyWith({
    City? city,
    CurrentWeather? current,
    List<DailyForecast>? daily,
    bool? isFahrenheit,
    DateTime? fetchedAt,
  }) {
    return WeatherData(
      city: city ?? this.city,
      current: current ?? this.current,
      daily: daily ?? this.daily,
      isFahrenheit: isFahrenheit ?? this.isFahrenheit,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherData &&
          runtimeType == other.runtimeType &&
          city == other.city &&
          current == other.current &&
          isFahrenheit == other.isFahrenheit &&
          fetchedAt == other.fetchedAt;

  @override
  int get hashCode =>
      city.hashCode ^
      current.hashCode ^
      isFahrenheit.hashCode ^
      fetchedAt.hashCode;

  @override
  String toString() =>
      'WeatherData(city: ${city.name}, current: ${current.temperature}, days: ${daily.length})';
}
