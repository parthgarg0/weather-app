import 'dart:async' as async;
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/city.dart';

/// Service responsible for querying the Open-Meteo Geocoding API.
///
/// Converts a text query (e.g., "Berlin") into a list of geographic [City] matches
/// with exact latitude and longitude coordinates.
class GeocodingService {
  final http.Client _client;

  /// Injects an [http.Client] to facilitate straightforward unit testing with mocks.
  GeocodingService({http.Client? client}) : _client = client ?? http.Client();

  /// Searches for cities matching the provided [query].
  ///
  /// Throws [CityNotFoundException] if the API returns no results or if "results" key is absent.
  /// Throws [NoInternetException] on connection failure or socket error.
  /// Throws [TimeoutException] if the request exceeds 10 seconds.
  /// Throws [ApiException] if the server returns a non-200 status code.
  Future<List<City>> searchCities(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      throw const CityNotFoundException();
    }

    final uri = Uri.parse(
      '${ApiConstants.geocodingBaseUrl}${ApiConstants.geocodingSearchPath}',
    ).replace(
      queryParameters: {
        'name': trimmedQuery,
        'count': ApiConstants.defaultGeocodingCount.toString(),
      },
    );

    try {
      final response = await _client.get(uri).timeout(ApiConstants.requestTimeout);

      if (response.statusCode != 200) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Geocoding service returned status ${response.statusCode}',
        );
      }

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      // Open-Meteo omits the "results" key entirely when no match is found.
      if (!data.containsKey('results') || data['results'] == null) {
        throw const CityNotFoundException();
      }

      final List<dynamic> results = data['results'] as List<dynamic>;
      if (results.isEmpty) {
        throw const CityNotFoundException();
      }

      return results
          .map((item) => City.fromJson(item as Map<String, dynamic>))
          .toList();
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
