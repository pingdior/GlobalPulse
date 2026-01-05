import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';

class ApiService {
  // 开发环境使用本地地址
  // iOS 模拟器使用 localhost
  // Android 模拟器使用 10.0.2.2
  static const String baseUrl = 'http://localhost:8000';
  
  final http.Client _client = http.Client();

  /// Fetch hot events from API
  Future<EventList> getEvents({
    String region = 'china',
    int limit = 20,
    bool enrich = false,
    String source = 'weibo',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/events').replace(
        queryParameters: {
          'region': region,
          'limit': limit.toString(),
          'enrich': enrich.toString(),
          'source': source,
        },
      );

      final response = await _client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return EventList.fromJson(data);
      } else {
        throw ApiException('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// Fetch single event detail
  Future<Event> getEventDetail(String eventId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/events/$eventId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return Event.fromJson(data);
      } else {
        throw ApiException('Event not found');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// Enrich event with LLM
  Future<Event> enrichEvent(String eventId) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/events/$eventId/enrich'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return Event.fromJson(data);
      } else {
        throw ApiException('Failed to enrich event');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// Compare perspective with International views
  Future<Map<String, dynamic>> compareEvent(String title, String summary) async {
    try {
      final uri = Uri.parse('$baseUrl/api/events/compare').replace(
        queryParameters: {
          'title': title,
          'summary': summary,
        },
      );
      
      final response = await _client.get(
        uri, 
        headers: {'Content-Type': 'application/json'}
      ).timeout(const Duration(seconds: 45));
      
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw ApiException('Failed to compare event');
      }
    } catch (e) {
      throw ApiException('Comparison failed: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
