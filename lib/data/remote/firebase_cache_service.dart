import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Layer 2: Firebase Firestore & Local Disk Cache Service
/// Stores and retrieves video search results and metadata from:
///  1) Local Device Storage (SharedPreferences - 0ms Disk Cache)
///  2) Firebase Cloud Firestore REST API (Project: focus-grid-app)
class FirebaseCacheService {
  static const String _firebaseProjectId = "focus-grid-app";
  static const String _firestoreBaseUrl =
      "https://firestore.googleapis.com/v1/projects/$_firebaseProjectId/databases/(default)/documents/video_cache";

  /// Retrieve cached videos from Local Disk or Firebase Firestore
  Future<List<Map<String, String>>?> getCachedVideos(String cacheKey) async {
    final cleanKey = _sanitizeKey(cacheKey);

    // 1. Try Local SharedPreferences Disk Cache first (0ms)
    try {
      final prefs = await SharedPreferences.getInstance();
      final localJson = prefs.getString("fb_cache_$cleanKey");
      if (localJson != null && localJson.isNotEmpty) {
        final List<dynamic> list = jsonDecode(localJson);
        final List<Map<String, String>> result = list.map((e) => Map<String, String>.from(e)).toList();
        if (result.isNotEmpty) {
          return result;
        }
      }
    } catch (_) {}

    // 2. Try Firebase Cloud Firestore REST Cache
    try {
      final url = Uri.parse("$_firestoreBaseUrl/$cleanKey");
      final response = await http.get(url).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fields = data['fields'];
        if (fields != null && fields['payload'] != null && fields['payload']['stringValue'] != null) {
          final jsonString = fields['payload']['stringValue'] as String;
          final List<dynamic> list = jsonDecode(jsonString);
          final List<Map<String, String>> result = list.map((e) => Map<String, String>.from(e)).toList();
          if (result.isNotEmpty) {
            // Populate local cache for instant future loads
            _saveToLocalCache(cleanKey, jsonString);
            return result;
          }
        }
      }
    } catch (_) {}

    return null;
  }

  /// Save video results to both Local Disk and Firebase Cloud Firestore
  Future<void> saveCachedVideos(String cacheKey, List<Map<String, String>> videos) async {
    if (videos.isEmpty) return;
    final cleanKey = _sanitizeKey(cacheKey);
    final jsonString = jsonEncode(videos);

    // 1. Save to Local Disk (0ms Disk Cache)
    await _saveToLocalCache(cleanKey, jsonString);

    // 2. Save to Firebase Cloud Firestore via REST API
    try {
      final url = Uri.parse("$_firestoreBaseUrl/$cleanKey");
      final body = jsonEncode({
        "fields": {
          "payload": {"stringValue": jsonString},
          "updatedAt": {"timestampValue": DateTime.now().toUtc().toIso8601String()},
          "videoCount": {"integerValue": videos.length.toString()}
        }
      });
      await http.patch(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      ).timeout(const Duration(seconds: 4));
    } catch (_) {}
  }

  Future<void> _saveToLocalCache(String cleanKey, String jsonString) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("fb_cache_$cleanKey", jsonString);
    } catch (_) {}
  }

  String _sanitizeKey(String key) {
    return key
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')
        .toLowerCase();
  }
}
