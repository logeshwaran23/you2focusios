import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class VimeoNoQuotaScraper {
  static const String _tag = "VimeoNoQuotaScraper";
  static const String _clientId = "a24645a1cbd4b776ec9720c3dc92904a9e72f69c";
  static const String _clientSecret =
      "6mSo2Wvd09WrytbvnDPI6HfCXoYcKsX7OfPrxcihMIv4IoBA9NV8Q1CHLHbrPHfciDAtG86XI8LejFrMHu1y/nRu/0Lm0+0FFNLCQoOKBZtYy+cxufUJfGfVZVD4JArD";

  String? _accessToken;
  DateTime? _tokenExpiry;

  Future<String?> _getAccessToken() async {
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken;
    }

    try {
      final credentials = base64Encode(utf8.encode('$_clientId:$_clientSecret'));
      final response = await http.post(
        Uri.parse('https://api.vimeo.com/oauth/authorize/client'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'client_credentials',
          'scope': 'public',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        _tokenExpiry = DateTime.now().add(const Duration(days: 30));
        return _accessToken;
      }
    } catch (e) {
      debugPrint("[$_tag] Error fetching Vimeo token: $e");
    }
    return null;
  }

  Future<List<Map<String, String>>> scrapeVideos({
    required String query,
    required String category,
  }) async {
    // 1. Try official Vimeo API
    final token = await _getAccessToken();
    if (token != null) {
      final apiVideos = await _fetchFromVimeoApi(query, category, token);
      if (apiVideos.isNotEmpty) {
        return apiVideos;
      }
    }

    // 2. Fallback to web search scraping if API fails
    final searchVideos = await _scrapeSingleQuery(query, category);
    if (searchVideos.isNotEmpty) {
      return searchVideos;
    }

    return [];
  }

  Future<List<Map<String, String>>> _fetchFromVimeoApi(
      String query, String category, String token) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse(
          'https://api.vimeo.com/videos?query=$encodedQuery&per_page=15&fields=uri,name,description,duration,pictures,user');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List items = data['data'] ?? [];

        List<Map<String, String>> result = [];
        for (var item in items) {
          final uri = item['uri'] as String? ?? '';
          final match = RegExp(r'(\d{6,12})').firstMatch(uri);
          final rawId = match != null ? match.group(1)! : '';
          if (rawId.isEmpty) continue;

          final name = item['name'] as String? ?? 'Educational Video';
          final user = item['user']?['name'] as String? ?? 'Vimeo Creator';
          final durationSec = item['duration'] as int? ?? 240;

          String thumbnail = 'https://vumbnail.com/$rawId.jpg';
          final sizes = item['pictures']?['sizes'] as List?;
          if (sizes != null && sizes.isNotEmpty) {
            final lastSize = sizes.last;
            if (lastSize['link'] != null) {
              thumbnail = lastSize['link'];
            }
          }

          result.add({
            'title': name,
            'channel': user,
            'category': category,
            'thumbnail': thumbnail,
            'duration': _formatDuration(durationSec),
            'bannerBg': '0xFF1E293B',
            'videoId': rawId,
          });
        }
        return result;
      }
    } catch (e) {
      debugPrint("[$_tag] Error in _fetchFromVimeoApi: $e");
    }
    return [];
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return "4:15";
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "$m:${s.toString().padLeft(2, '0')}";
  }

  Future<List<Map<String, String>>> _scrapeSingleQuery(
      String fullQuery, String category) async {
    final encodedQuery = Uri.encodeComponent(fullQuery);
    final url = Uri.parse("https://vimeo.com/search?q=$encodedQuery");

    try {
      final response = await http.get(
        url,
        headers: {
          "User-Agent":
              "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        },
      );

      if (response.statusCode != 200) {
        return [];
      }

      final html = response.body;
      final RegExp videoIdRegex = RegExp(r'vimeo\.com/(\d{6,12})');
      final matches = videoIdRegex.allMatches(html);

      final List<String> rawIds = matches
          .map((m) => m.group(1)!)
          .toSet()
          .take(15)
          .toList();

      int idx = 1;
      final List<Map<String, String>> videos = rawIds.map((rawId) {
        final title = "${_capitalize(fullQuery)} - Module ${idx++}";
        return {
          'title': title,
          'channel': 'Vimeo Educational',
          'category': category,
          'thumbnail': 'https://vumbnail.com/$rawId.jpg',
          'duration': '${(idx * 8) % 40 + 8}:${(idx * 13) % 50 + 10}',
          'bannerBg': '0xFF1E293B',
          'videoId': rawId,
        };
      }).toList();

      return videos;
    } catch (e) {
      return [];
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

