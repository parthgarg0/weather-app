/// Represents current atmospheric weather measurements at a specific location.
class CurrentWeather {
  /// Current temperature in either Celsius or Fahrenheit depending on request parameter.
  final double temperature;

  /// Relative humidity percentage (0 - 100%).
  final int relativeHumidity;

  /// WMO weather condition code (e.g., 0 for Clear sky, 61 for Slight rain).
  final int weatherCode;

  /// Surface wind speed measured at 10m height (km/h).
  final double windSpeed;

  /// Observation time reported by the API.
  final DateTime? time;

  const CurrentWeather({
    required this.temperature,
    required this.relativeHumidity,
    required this.weatherCode,
    required this.windSpeed,
    this.time,
  });

  /// Factory constructor to parse JSON from Open-Meteo's `current` response
  /// or from stored cache JSON.
  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    // Open-Meteo current endpoint returns keys with unit suffixes like `temperature_2m`.
    // We check both raw API keys and standard serialized keys to support cache round-tripping.
    final num tempValue = (json['temperature_2m'] ?? json['temperature']) as num;
    final num humidityValue =
        (json['relative_humidity_2m'] ?? json['relativeHumidity']) as num;
    final num codeValue = (json['weather_code'] ?? json['weatherCode']) as num;
    final num windValue =
        (json['wind_speed_10m'] ?? json['windSpeed']) as num;

    DateTime? parsedTime;
    if (json['time'] != null) {
      parsedTime = DateTime.tryParse(json['time'].toString());
    }

    return CurrentWeather(
      temperature: tempValue.toDouble(),
      relativeHumidity: humidityValue.toInt(),
      weatherCode: codeValue.toInt(),
      windSpeed: windValue.toDouble(),
      time: parsedTime,
    );
  }

  /// Converts the [CurrentWeather] to JSON for caching.
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'relativeHumidity': relativeHumidity,
      'weatherCode': weatherCode,
      'windSpeed': windSpeed,
      'time': time?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrentWeather &&
          runtimeType == other.runtimeType &&
          temperature == other.temperature &&
          relativeHumidity == other.relativeHumidity &&
          weatherCode == other.weatherCode &&
          windSpeed == other.windSpeed &&
          time == other.time;

  @override
  int get hashCode =>
      temperature.hashCode ^
      relativeHumidity.hashCode ^
      weatherCode.hashCode ^
      windSpeed.hashCode ^
      time.hashCode;

  @override
  String toString() =>
      'CurrentWeather(temperature: $temperature, humidity: $relativeHumidity%, code: $weatherCode, wind: $windSpeed km/h)';
}
