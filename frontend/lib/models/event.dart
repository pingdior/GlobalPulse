import 'package:flutter/material.dart';

/// Event data model matching backend API
class Event {
  final String id;
  final String title;
  final String summary;
  final int heatScore;
  final String sentiment;
  final List<String> emotionTags;
  final String region;
  final List<EventSource> sources;
  final List<String> keywords;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.title,
    required this.summary,
    required this.heatScore,
    required this.sentiment,
    required this.emotionTags,
    required this.region,
    required this.sources,
    required this.keywords,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      heatScore: json['heat_score'] ?? 0,
      sentiment: json['sentiment'] ?? 'neutral',
      emotionTags: List<String>.from(json['emotion_tags'] ?? []),
      region: json['region'] ?? 'china',
      sources: (json['sources'] as List?)
          ?.map((s) => EventSource.fromJson(s))
          .toList() ?? [],
      keywords: List<String>.from(json['keywords'] ?? []),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  /// Get sentiment color
  Color get sentimentColor {
    switch (sentiment) {
      case 'positive':
        return const Color(0xFF4CAF50);
      case 'negative':
        return const Color(0xFFF44336);
      case 'mixed':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  /// Get sentiment label
  String get sentimentLabel {
    switch (sentiment) {
      case 'positive':
        return '正面';
      case 'negative':
        return '负面';
      case 'mixed':
        return '争议';
      default:
        return '中性';
    }
  }
}

class EventSource {
  final String platform;
  final String? url;
  final String? author;

  EventSource({
    required this.platform,
    this.url,
    this.author,
  });

  factory EventSource.fromJson(Map<String, dynamic> json) {
    return EventSource(
      platform: json['platform'] ?? '',
      url: json['url'],
      author: json['author'],
    );
  }
}

class EventList {
  final int total;
  final String region;
  final List<Event> events;

  EventList({
    required this.total,
    required this.region,
    required this.events,
  });

  factory EventList.fromJson(Map<String, dynamic> json) {
    return EventList(
      total: json['total'] ?? 0,
      region: json['region'] ?? 'china',
      events: (json['events'] as List?)
          ?.map((e) => Event.fromJson(e))
          .toList() ?? [],
    );
  }
}
