/// Represents a geographic city returned from the geocoding service.
class City {
  /// Name of the city (e.g. "Berlin").
  final String name;

  /// Latitude coordinate in decimal degrees.
  final double latitude;

  /// Longitude coordinate in decimal degrees.
  final double longitude;

  /// Country name (e.g. "Germany").
  final String country;

  /// Administrative area, state, or region (e.g. "Land Berlin" or "California").
  /// Can be null if the API does not provide a subdivision for the city.
  final String? admin1;

  const City({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    this.admin1,
  });

  /// Factory constructor to create a [City] instance from geocoding API JSON.
  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: json['country'] as String? ?? '',
      admin1: json['admin1'] as String?,
    );
  }

  /// Converts the [City] instance to a JSON Map for persistent caching.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'admin1': admin1,
    };
  }

  /// User-friendly label for displaying the administrative region and country.
  /// Example: "California, United States" or simply "Germany" if admin1 is null.
  String get locationDetails {
    if (admin1 != null && admin1!.trim().isNotEmpty) {
      if (country.trim().isNotEmpty) {
        return '$admin1, $country';
      }
      return admin1!;
    }
    return country;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is City &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          country == other.country &&
          admin1 == other.admin1;

  @override
  int get hashCode =>
      name.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      country.hashCode ^
      admin1.hashCode;

  @override
  String toString() =>
      'City(name: $name, lat: $latitude, lon: $longitude, country: $country, admin1: $admin1)';
}
