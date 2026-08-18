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

  // Returns a list of football news articles from GNews. Makes
  // exactly one network request.
  //
  // Throws a [NewsException] if the API key is missing, the request
  // fails, or the response can't be parsed. Never falls back to the
  // local static articles automatically - a failed request stays
  // visibly failed so it can be diagnosed.
  Future<List<Article>> getArticles() async {
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
