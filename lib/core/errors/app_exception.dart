import '../constants/app_strings.dart';

/// Base class for all application-specific exceptions.
///
/// Every custom exception provides a user-friendly [message] suitable
/// for display directly in the UI error state.
abstract class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

/// Thrown when the geocoding API returns no matching results for a city query.
class CityNotFoundException extends AppException {
  const CityNotFoundException([String message = AppStrings.errorCityNotFound])
      : super(message);
}

/// Thrown when there is no active internet connection or DNS lookup fails.
class NoInternetException extends AppException {
  const NoInternetException([String message = AppStrings.errorNoInternet])
      : super(message);
}

/// Thrown when a network request exceeds the 10-second timeout threshold.
///
/// Named [TimeoutException] as requested by project specification.
class TimeoutException extends AppException {
  const TimeoutException([String message = AppStrings.errorTimeout])
      : super(message);
}

/// Thrown when an HTTP request fails with a non-200 status code or malformed payload.
class ApiException extends AppException {
  final int? statusCode;

  const ApiException({
    String message = AppStrings.errorGenericApi,
    this.statusCode,
  }) : super(message);

  @override
  String toString() =>
      statusCode != null ? '$message (Status: $statusCode)' : message;
}
