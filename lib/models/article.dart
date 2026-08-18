import 'package:flutter/material.dart';

// A simple model representing one football news article. Articles
// can come from local static data (see lib/constants/news_data.dart)
// or from the real GNews API (see lib/services/news_service.dart).
class Article {
  final String id;
  final String title;
  final String description;
  final String category;
  final IconData icon;
  final String timeAgo;
  final List<String> content;

  // Fields only populated for real GNews articles. Null (or false)
  // for the local static articles.
  final String? imageUrl;
  final String? sourceName;
  final DateTime? publishedAt;
  final String? articleUrl;

  // True when GNews only provided a truncated excerpt of this
  // article's content (i.e. it originally carried a "[XXXX chars]"
  // marker before cleaning). Used to show a small "read the full
  // story" notice without displaying the marker itself.
  final bool isTruncated;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.timeAgo,
    required this.content,
    this.imageUrl,
    this.sourceName,
    this.publishedAt,
    this.articleUrl,
    this.isTruncated = false,
  });

  // Builds an Article from one item in the GNews /search response's
  // "articles" array. Assigns one of GirlStadium's existing News
  // categories locally via keyword matching, since GNews doesn't
  // return our categories directly. Never crashes on missing/null
  // GNews fields.
  factory Article.fromGNewsJson(Map<String, dynamic> json) {
    final title = json['title'] as String? ?? 'Untitled';
    final description = json['description'] as String? ?? '';
    final rawContent = json['content'] as String?;
    final url = json['url'] as String?;
    final image = json['image'] as String?;
    final publishedAtString = json['publishedAt'] as String?;
    final sourceJson = json['source'] as Map<String, dynamic>?;

    final publishedAt = publishedAtString != null
        ? DateTime.tryParse(publishedAtString)
        : null;

    final combinedText = '$title $description ${rawContent ?? ''}'
        .toLowerCase();

    // GNews's Free plan truncates full article bodies and appends a
    // "[XXXX chars]" marker (e.g. "...ANI report. [2042 chars]").
    // That marker is not real article content, so it's stripped
    // before display.
    final cleanedContent =
        rawContent != null ? _cleanGNewsText(rawContent) : '';
    final cleanedDescription = _cleanGNewsText(description);
    final hasTruncationMarker = rawContent != null &&
        RegExp(r'\[\d+\s*chars\]\s*$').hasMatch(rawContent.trim());

    final List<String> content;
    if (cleanedContent.isNotEmpty) {
      content = [cleanedContent];
    } else if (cleanedDescription.isNotEmpty) {
      content = [cleanedDescription];
    } else {
      content = ['No further details are available for this article.'];
    }

    return Article(
      // GNews doesn't provide a stable article ID - the article URL
      // is unique and stable enough to use as one.
      id: url ?? title,
      title: title,
      description: cleanedDescription,
      category: _categoryFor(combinedText),
      icon: Icons.article_outlined,
      timeAgo: _formatTimeAgo(publishedAt),
      content: content,
      imageUrl: image,
      sourceName: sourceJson?['name'] as String?,
      publishedAt: publishedAt,
      articleUrl: url,
      isTruncated: hasTruncationMarker,
    );
  }
}

// Assigns one of GirlStadium's existing News categories using simple
// keyword matching. Falls back to 'Players' when nothing confidently
// matches. Order matters: earlier categories take priority when an
// article's text matches more than one.
String _categoryFor(String text) {
  if (_containsAny(text, [
    'transfer',
    'transfers',
    'signing',
    'signed',
    'bid',
    'deal',
    'joins',
  ])) {
    return 'Transfers';
  }

  if (_containsAny(text, [
    'premier league',
    'arsenal',
    'liverpool',
    'chelsea',
    'manchester city',
    'manchester united',
    'tottenham',
    'newcastle',
    'aston villa',
  ])) {
    return 'Premier League';
  }

  if (_containsAny(text, [
    'champions league',
    'uefa champions league',
    'ucl',
  ])) {
    return 'Champions League';
  }

  if (_containsAny(text, [
    'la liga',
    'barcelona',
    'real madrid',
    'atletico madrid',
  ])) {
    return 'La Liga';
  }

  if (_containsAny(text, [
    'player',
    'striker',
    'midfielder',
    'goalkeeper',
    'injury',
    'goal scorer',
  ])) {
    return 'Players';
  }

  return 'Players';
}

bool _containsAny(String text, List<String> keywords) {
  for (final keyword in keywords) {
    if (text.contains(keyword)) return true;
  }
  return false;
}

// Strips GNews's trailing "[XXXX chars]" truncation marker (with any
// amount of surrounding whitespace) and trims the result. Only ever
// removes the marker actually appended by GNews - never invents or
// removes real article text.
String _cleanGNewsText(String raw) {
  return raw.replaceAll(RegExp(r'\s*\[\d+\s*chars\]\s*$'), '').trim();
}

// Formats how long ago an article was published as a short string
// (e.g. "5 min ago", "3 hours ago", "2 days ago"). Falls back to a
// neutral label when the date is missing or unparseable.
String _formatTimeAgo(DateTime? publishedAt) {
  if (publishedAt == null) return 'Recently';

  final difference = DateTime.now().toUtc().difference(publishedAt.toUtc());

  if (difference.inMinutes < 1) return 'Just now';
  if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
  if (difference.inHours < 24) return '${difference.inHours} hours ago';
  return '${difference.inDays} days ago';
}
