import 'dart:convert';
import 'package:http/http.dart' as http;
import 'youtube_no_quota_scraper.dart';

/// Layer 3: Official YouTube Data API v3 & Web No-Quota Scraper Engine
///  - Primary: Uses Official YouTube Data API v3 if API key is provided
///  - Fallback: On API Quota Exhaustion (429) or no key, switches seamlessly
///    to YouTubeNoQuotaScraper without failing or throwing quota errors.
class YouTubeOfficialApiService {
  final YouTubeNoQuotaScraper _scraper = YouTubeNoQuotaScraper();

  // Optional Official YouTube Data API v3 Key (can be injected or set at runtime)
  static String? apiKey;

  Future<List<Map<String, String>>> fetchVideos({
    required String query,
    required String category,
    String language = 'English',
  }) async {
    // 1. Try Official YouTube Data API v3 if key is present
    if (apiKey != null && apiKey!.trim().isNotEmpty) {
      try {
        final officialResults = await fetchFromOfficialApi(query, category, language);
        if (officialResults.isNotEmpty) {
          return officialResults;
        }
      } catch (e) {
        // Quota exceeded or network error -> proceed to No-Quota Scraper
      }
    }

    // 2. Fallback to No-Quota Scraper Engine (Zero Quota Limit)
    return await _scraper.scrapeVideos(
      query: query,
      category: category,
      language: language,
    );
  }

  Future<List<Map<String, String>>> fetchFromOfficialApi(
    String query,
    String category,
    String language,
  ) async {
    final searchUrl = Uri.parse(
      'https://www.googleapis.com/youtube/v3/search?'
      'part=snippet&maxResults=20&type=video&q=${Uri.encodeComponent(query)}&key=$apiKey',
    );

    final response = await http.get(searchUrl).timeout(const Duration(seconds: 5));

    if (response.statusCode == 429 || response.body.contains('quotaExceeded')) {
      throw Exception('YouTube API Quota Exhausted');
    }

    if (response.statusCode != 200) {
      throw Exception('Official API returned ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final items = data['items'] as List<dynamic>? ?? [];

    List<Map<String, String>> videos = [];
    for (var item in items) {
      final id = item['id']?['videoId'];
      final snippet = item['snippet'];
      if (id != null && snippet != null) {
        videos.add({
          'videoId': id.toString(),
          'title': snippet['title']?.toString() ?? 'Educational Video',
          'channel': snippet['channelTitle']?.toString() ?? 'YouTube Channel',
          'category': category,
          'thumbnail': snippet['thumbnails']?['high']?['url']?.toString() ??
              'https://img.youtube.com/vi/$id/hqdefault.jpg',
          'duration': '12:00',
        });
      }
    }

    return videos;
  }
}
