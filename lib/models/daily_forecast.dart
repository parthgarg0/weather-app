/// Represents a daily weather forecast entry for a single day.
class DailyForecast {
  /// Date of the forecast.
  final DateTime date;

  /// Predominant WMO weather code predicted for the day.
  final int weatherCode;

  /// Maximum anticipated temperature for the day.
  final double maxTemperature;

  /// Minimum anticipated temperature for the day.
  final double minTemperature;

  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.maxTemperature,
    required this.minTemperature,
  });

  /// Factory constructor to parse an individual day forecast from JSON.
  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.parse(json['date'] as String),
      weatherCode: (json['weatherCode'] as num).toInt(),
      maxTemperature: (json['maxTemperature'] as num).toDouble(),
      minTemperature: (json['minTemperature'] as num).toDouble(),
    );
  }

  /// Converts the forecast item to a JSON Map for caching.
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'weatherCode': weatherCode,
      'maxTemperature': maxTemperature,
      'minTemperature': minTemperature,
    };
  }

  /// Parses Open-Meteo's `daily` parallel array structure into a List of [DailyForecast].
  /// 
  /// Open-Meteo returns daily forecasts as parallel arrays:
  /// ```json
  /// "daily": {
  ///   "time": ["2026-11-03", "2026-11-04"],
  ///   "weather_code": [0, 2],
  ///   "temperature_2m_max": [15.2, 14.1],
  ///   "temperature_2m_min": [6.3, 5.0]
  /// }
  /// ```
  /// This helper zips those arrays into structured model objects.
  static List<DailyForecast> fromDailyArrays(Map<String, dynamic> dailyJson) {
    final times = (dailyJson['time'] as List<dynamic>?)?.cast<String>() ?? [];
    final codes = (dailyJson['weather_code'] as List<dynamic>?) ?? [];
    final maxTemps = (dailyJson['temperature_2m_max'] as List<dynamic>?) ?? [];
    final minTemps = (dailyJson['temperature_2m_min'] as List<dynamic>?) ?? [];

    final int count = times.length;
    final List<DailyForecast> forecasts = [];

    for (int i = 0; i < count; i++) {
      if (i < codes.length && i < maxTemps.length && i < minTemps.length) {
        forecasts.add(
          DailyForecast(
            date: DateTime.parse(times[i]),
            weatherCode: (codes[i] as num).toInt(),
            maxTemperature: (maxTemps[i] as num).toDouble(),
            minTemperature: (minTemps[i] as num).toDouble(),
          ),
        );
      }
    }

    return forecasts;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyForecast &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          weatherCode == other.weatherCode &&
          maxTemperature == other.maxTemperature &&
          minTemperature == other.minTemperature;

  @override
  int get hashCode =>
      date.hashCode ^
      weatherCode.hashCode ^
      maxTemperature.hashCode ^
      minTemperature.hashCode;

  @override
  String toString() =>
      'DailyForecast(date: $date, code: $weatherCode, max: $maxTemperature, min: $minTemperature)';
}
