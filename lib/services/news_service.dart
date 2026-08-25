import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/article.dart';

// Broad categories of News-service failure, used by NewsScreen to
// choose an appropriate user-facing message. This mirrors the same
// pattern used for the football API in api_service.dart, but is kept
// separate on purpose - GNews has a different base URL and a
// different auth scheme, so it isn't routed through ApiService.
enum NewsErrorType {
  missingConfiguration,
  network,
  unauthorized,
  quotaExceeded,
  rateLimit,
  apiError,
}

// A simple exception used when a News request fails. Carries a broad
// [type] so the UI layer can choose an appropriate message. The
// [message] is for debugging only - never the API key, and never
// shown to the user directly.
class NewsException implements Exception {
  final String message;
  final NewsErrorType type;

  NewsException(this.message, {this.type = NewsErrorType.apiError});

  @override
  String toString() => 'NewsException: $message';
}

// Maps a caught error to a simple, user-friendly message. Never
// surfaces raw API/technical details.
String newsErrorMessage(Object error) {
  if (error is NewsException) {
    switch (error.type) {
      case NewsErrorType.missingConfiguration:
        return "News service isn't configured.";
      case NewsErrorType.unauthorized:
        return "Couldn't authenticate with the news service.";
      case NewsErrorType.quotaExceeded:
        return "Today's news request limit has been reached.";
      case NewsErrorType.rateLimit:
        return 'Too many news requests right now. Please try again later.';
      case NewsErrorType.network:
        return "Couldn't connect to the news service. Check your "
            'internet connection.';
      case NewsErrorType.apiError:
        return "Couldn't load news.";
    }
  }
  return "Couldn't load news.";
}

// Talks to the GNews Search API (https://gnews.io/api/v4/search) to
// retrieve English-language football news.
//
// Implemented directly with dart:io HttpClient (matching the coding
// style already used in ApiService) rather than reusing ApiService,
// because ApiService is tightly coupled to API-Football's base URL
// and its header-based "x-apisports-key" authentication - GNews uses
// a different base URL and a query-parameter API key instead.
class NewsService {
  static const String _baseUrl = 'https://gnews.io/api/v4';

  // A simple in-memory cache shared by every NewsService instance
  // (static), so Home and NewsScreen never make two independent GNews
  // requests for the same data. Only ever holds a *successful* result -
  // a failed request is never cached, so a later call can try again.
  // Cleared only by process restart; there is no timer/expiry.
  static List<Article>? _cachedArticles;

  // Tracks a request already in progress, so a second caller that asks
  // while one is still running awaits the same Future instead of
  // starting a duplicate GNews call.
  static Future<List<Article>>? _inFlightRequest;

  // Returns a list of football news articles from GNews.
  //
  // Prefers the shared cache when available. When [forceRefresh] is
  // true (used by explicit Retry taps), the cache is bypassed and
  // exactly one fresh request is made, replacing the cache on success.
  //
  // Throws a [NewsException] if the API key is missing, the request
  // fails, or the response can't be parsed. Never falls back to the
  // local static articles automatically - a failed request stays
  // visibly failed so it can be diagnosed.
  Future<List<Article>> getArticles({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cachedArticles;
      if (cached != null) return cached;

      final inFlight = _inFlightRequest;
      if (inFlight != null) return inFlight;
    }

    final request = _fetchArticles();
    _inFlightRequest = request;

    try {
      final result = await request;
      _cachedArticles = result;
      return result;
    } finally {
      // Only clear the slot if it's still our own request - a
      // concurrent forceRefresh call may have already replaced it with
      // a newer one.
      if (identical(_inFlightRequest, request)) {
        _inFlightRequest = null;
      }
    }
  }

  // Makes the actual GNews request. Exactly one network request per
  // call - only ever called from [getArticles] above.
  Future<List<Article>> _fetchArticles() async {
    // The API key is read from .env (loaded via flutter_dotenv in
    // main.dart) and is never written directly in source code.
    final apiKey = dotenv.env['GNEWS_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw NewsException(
        'Missing GNEWS_API_KEY. Make sure it is set in the .env file.',
        type: NewsErrorType.missingConfiguration,
      );
    }

    final uri = Uri.parse('$_baseUrl/search').replace(
      queryParameters: {
        'q': 'football',
        'lang': 'en',
        'max': '10',
        'apikey': apiKey,
      },
    );

    final httpClient = HttpClient();

    try {
      final request = await httpClient.getUrl(uri);
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 401) {
        throw NewsException(
          'GNews request failed with status 401.',
          type: NewsErrorType.unauthorized,
        );
      }

      if (response.statusCode == 403) {
        throw NewsException(
          'GNews request failed with status 403.',
          type: NewsErrorType.quotaExceeded,
        );
      }

      if (response.statusCode == 429) {
        throw NewsException(
          'GNews request failed with status 429.',
          type: NewsErrorType.rateLimit,
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw NewsException(
          'GNews request failed with status ${response.statusCode}.',
        );
      }

      final decoded = jsonDecode(responseBody);

      if (decoded is! Map<String, dynamic>) {
        throw NewsException('Unexpected response format from GNews.');
      }

      final articlesJson = decoded['articles'] as List<dynamic>? ?? [];

      return articlesJson
          .map((item) => Article.fromGNewsJson(item as Map<String, dynamic>))
          .toList();
    } on NewsException {
      rethrow;
    } on SocketException {
      throw NewsException(
        'Could not reach the news service.',
        type: NewsErrorType.network,
      );
    } on HttpException {
      throw NewsException(
        'Could not reach the news service.',
        type: NewsErrorType.network,
      );
    } catch (error) {
      throw NewsException('Failed to reach GNews.');
    } finally {
      httpClient.close();
    }
  }
}
