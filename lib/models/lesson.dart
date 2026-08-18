import 'package:flutter/material.dart';

// A simple model representing one football lesson shown on the Learn
// Screen and Lesson Details Screen. Lessons are stored locally (see
// lib/constants/lessons_data.dart) - there is no API for this data.
class Lesson {
  final String id;
  final String title;
  final String description;
  final String readTime;
  final String category;
  final IconData icon;
  final List<String> content;
  final List<String> tips;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.readTime,
    required this.category,
    required this.icon,
    required this.content,
    required this.tips,
  });
}
