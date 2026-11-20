/// Holds the human-readable description and emoji icon for a weather condition.
class WeatherCondition {
  /// Description of the condition (e.g. "Clear sky", "Partly cloudy").
  final String description;

  /// Visual emoji representing the weather condition (e.g. "☀️", "🌧️").
  final String icon;

  const WeatherCondition({
    required this.description,
    required this.icon,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherCondition &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          icon == other.icon;

  @override
  int get hashCode => description.hashCode ^ icon.hashCode;

  @override
  String toString() => '$icon $description';
}

/// Utility for translating World Meteorological Organization (WMO) weather interpretation codes
/// to human-readable descriptions and emoji icons.
///
/// Open-Meteo uses standard WMO codes:
/// https://open-meteo.com/en/docs
class WeatherCodeMapper {
  WeatherCodeMapper._();

  /// Default fallback condition returned for any unrecognized WMO weather code.
  static const WeatherCondition unknownCondition = WeatherCondition(
    description: 'Unknown',
    icon: '❓',
  );

  /// Translates a WMO numeric [code] to its corresponding [WeatherCondition].
  ///
  /// Any code not explicitly defined in the WMO specification gracefully falls back
  /// to [unknownCondition].
  static WeatherCondition map(int code) {
    switch (code) {
      case 0:
        return const WeatherCondition(description: 'Clear sky', icon: '☀️');
      case 1:
        return const WeatherCondition(description: 'Mainly clear', icon: '🌤️');
      case 2:
        return const WeatherCondition(description: 'Partly cloudy', icon: '⛅');
      case 3:
        return const WeatherCondition(description: 'Overcast', icon: '☁️');
      case 45:
      case 48:
        return const WeatherCondition(description: 'Fog', icon: '🌫️');
      case 51:
        return const WeatherCondition(description: 'Light drizzle', icon: '🌦️');
      case 53:
        return const WeatherCondition(description: 'Moderate drizzle', icon: '🌧️');
      case 55:
        return const WeatherCondition(description: 'Dense drizzle', icon: '🌧️');
      case 61:
        return const WeatherCondition(description: 'Slight rain', icon: '🌦️');
      case 63:
        return const WeatherCondition(description: 'Moderate rain', icon: '🌧️');
      case 65:
        return const WeatherCondition(description: 'Heavy rain', icon: '🌧️');
      case 71:
        return const WeatherCondition(description: 'Slight snow', icon: '🌨️');
      case 73:
        return const WeatherCondition(description: 'Moderate snow', icon: '❄️');
      case 75:
        return const WeatherCondition(description: 'Heavy snow', icon: '❄️');
      case 80:
      case 81:
      case 82:
        return const WeatherCondition(description: 'Rain showers', icon: '🌦️');
      case 95:
        return const WeatherCondition(description: 'Thunderstorm', icon: '⛈️');
      case 96:
      case 99:
        return const WeatherCondition(
          description: 'Thunderstorm with hail',
          icon: '⛈️',
        );
      default:
        // Graceful fallback for unexpected or missing codes ensures UI never breaks.
        return unknownCondition;
    }
  }

  /// Convenience helper to directly retrieve the condition description.
  static String getDescription(int code) => map(code).description;

  /// Convenience helper to directly retrieve the emoji icon.
  static String getIcon(int code) => map(code).icon;
}
