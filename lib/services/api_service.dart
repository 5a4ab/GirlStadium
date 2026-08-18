import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Broad categories of API failure. Screens use this to choose an
// appropriate user-facing message without needing to know any
// technical details about what actually went wrong.
enum ApiErrorType {
  missingConfiguration,
  network,
  planRestriction,
  rateLimit,
  invalidRequest,
  apiError,
}

// A simple exception used when an API call fails. Carries a broad
// [type] so the UI layer can choose an appropriate message, and an
// internal [message] for debugging only - never the API key or a raw
// stack trace, and never shown to the user directly.
class ApiException implements Exception {
  final String message;
  final ApiErrorType type;
  final int? statusCode;

  ApiException(
    this.message, {
    this.type = ApiErrorType.apiError,
    this.statusCode,
  });

  @override
  String toString() => 'ApiException: $message';
}

// Maps a caught error to a simple, user-friendly message. Network and
// rate-limit wording stays consistent across the app; [planMessage]
// and [genericMessage] let each screen describe what specifically
// failed to load. Never surfaces raw API/technical details.
String apiErrorMessage(
  Object error, {
  required String planMessage,
  required String genericMessage,
}) {
  if (error is ApiException) {
    switch (error.type) {
      case ApiErrorType.planRestriction:
        return planMessage;
      case ApiErrorType.rateLimit:
        return 'Too many requests right now. Please try again later.';
      case ApiErrorType.network:
        return "Couldn't connect to the football service. Check your "
            'internet connection.';
      case ApiErrorType.missingConfiguration:
      case ApiErrorType.invalidRequest:
      case ApiErrorType.apiError:
        return genericMessage;
    }
  }
  return genericMessage;
}

// A general-purpose HTTP client for talking to the football API.
// This class does NOT know anything about football (no fixtures,
// standings, etc). It only knows how to make GET requests, attach
// the API key, and decode JSON responses. Football-specific calls
// live in football_service.dart.
class ApiService {
  // The base URL and API key are NEVER written directly in this file.
  // They are read from the local .env file (loaded once in main.dart
  // before the app starts), so the real key never lives in the
  // source code or in Git.
  String get _baseUrl => dotenv.env['API_BASE_URL'] ?? '';
  String get _apiKey => dotenv.env['API_SPORTS_KEY'] ?? '';

  // Performs a GET request to the given endpoint (e.g. "/status") and
  // returns the decoded JSON response as a Map.
  //
  // Optional query parameters can be passed, e.g.
  // {'league': '39', 'season': '2024'}.
  //
  // Throws an [ApiException] for missing configuration, network
  // failures, non-2xx HTTP responses, or a successful HTTP response
  // that nonetheless contains a meaningful API-Football "errors"
  // object (e.g. a plan restriction or rate limit). A genuinely
  // successful response with an empty "errors" object is returned
  // normally, even when "response" is empty - that is not an error.
  Future<Map<String, dynamic>> get(
      String endpoint, {
        Map<String, String>? queryParams,
      }) async {
    if (_baseUrl.isEmpty) {
      throw ApiException(
        'Missing API_BASE_URL. Make sure it is set in the .env file.',
        type: ApiErrorType.missingConfiguration,
      );
    }

    if (_apiKey.isEmpty) {
      throw ApiException(
        'Missing API_SPORTS_KEY. Make sure it is set in the .env file.',
        type: ApiErrorType.missingConfiguration,
      );
    }

    final uri = Uri.parse('$_baseUrl$endpoint').replace(
      queryParameters: queryParams,
    );

    final httpClient = HttpClient();

    try {
      // Open the GET request and attach the required auth header.
      final request = await httpClient.getUrl(uri);
      request.headers.set('x-apisports-key', _apiKey);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      // Handle non-successful HTTP responses.
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          'Request to $endpoint failed with status ${response.statusCode}.',
          type: _classifyHttpStatus(response.statusCode),
          statusCode: response.statusCode,
        );
      }

      // Decode the JSON response body into a Dart Map.
      final decoded = jsonDecode(responseBody);

      if (decoded is! Map<String, dynamic>) {
        throw ApiException('Unexpected response format from $endpoint.');
      }

      // API-Football can respond with HTTP 200 but a non-empty
      // "errors" object (e.g. a Free-plan restriction or a rate
      // limit) instead of a non-2xx status code. Treat that as a
      // failure rather than a successful empty response.
      final errors = decoded['errors'];
      if (_hasApiFootballErrors(errors)) {
        throw ApiException(
          'API-Football reported an error for $endpoint: '
          '${_flattenApiFootballErrors(errors)}',
          type: _classifyApiFootballErrors(errors),
        );
      }

      return decoded;
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException(
        'Could not reach the football service.',
        type: ApiErrorType.network,
      );
    } on HttpException {
      throw ApiException(
        'Could not reach the football service.',
        type: ApiErrorType.network,
      );
    } catch (error) {
      throw ApiException('Failed to reach $endpoint.');
    } finally {
      httpClient.close();
    }
  }
}

// Classifies a non-2xx HTTP status code into a broad error type.
ApiErrorType _classifyHttpStatus(int statusCode) {
  if (statusCode == 429) return ApiErrorType.rateLimit;
  if (statusCode == 401 || statusCode == 403) {
    return ApiErrorType.planRestriction;
  }
  if (statusCode == 400 || statusCode == 404 || statusCode == 422) {
    return ApiErrorType.invalidRequest;
  }
  return ApiErrorType.apiError;
}

// True when API-Football's "errors" field describes an actual
// problem. An empty map/list (or a missing field) means the request
// succeeded normally, even when "response" is empty.
bool _hasApiFootballErrors(dynamic errors) {
  if (errors == null) return false;
  if (errors is Map) return errors.isNotEmpty;
  if (errors is List) return errors.isNotEmpty;
  return false;
}

// Flattens API-Football's "errors" field (a Map or a List, depending
// on the endpoint) into a single lowercase string used for keyword
// classification below.
String _flattenApiFootballErrors(dynamic errors) {
  if (errors is Map) return errors.values.map((v) => v.toString()).join(' ');
  if (errors is List) return errors.map((v) => v.toString()).join(' ');
  return errors.toString();
}

// Classifies API-Football's "errors" field into a broad error type by
// looking for common keywords, rather than matching one specific
// hardcoded error message - this keeps it reusable across whichever
// Free-plan restriction the API happens to report.
ApiErrorType _classifyApiFootballErrors(dynamic errors) {
  final text = _flattenApiFootballErrors(errors).toLowerCase();

  if (text.contains('rate limit') ||
      text.contains('too many requests') ||
      text.contains('requests per minute') ||
      text.contains('requests per day')) {
    return ApiErrorType.rateLimit;
  }

  if (text.contains('plan') ||
      text.contains('subscription') ||
      text.contains('subscribed') ||
      text.contains('access')) {
    return ApiErrorType.planRestriction;
  }

  if (text.contains('season') ||
      text.contains('invalid') ||
      text.contains('parameter') ||
      text.contains('required')) {
    return ApiErrorType.invalidRequest;
  }

  return ApiErrorType.apiError;
}
