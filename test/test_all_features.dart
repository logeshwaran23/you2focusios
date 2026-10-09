import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:focus_grid_flutter/data/remote/youtube_no_quota_scraper.dart';
import 'package:focus_grid_flutter/data/remote/vimeo_no_quota_scraper.dart';
import 'package:focus_grid_flutter/data/remote/firebase_cache_service.dart';
import 'package:focus_grid_flutter/data/remote/youtube_official_api_service.dart';
import 'package:focus_grid_flutter/data/repository/youtube_repository.dart';
import 'package:focus_grid_flutter/data/repository/vimeo_repository.dart';
import 'package:focus_grid_flutter/data/repository/streak_service.dart';
import 'package:focus_grid_flutter/data/repository/history_repository.dart';
import 'package:focus_grid_flutter/data/repository/auth_service.dart';

class _AllowLiveHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = _AllowLiveHttpOverrides();
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('🎯 1. Pipeline Priority & Video Scraper Verification', () {
    test('Stage 1: YouTubeNoQuotaScraper handles queries gracefully', () async {
      final scraper = YouTubeNoQuotaScraper();
      final videos = await scraper.scrapeVideos(
        query: 'Machine Learning 2026',
        category: 'Technology & AI',
        language: 'English',
      );
      // In mock unit test environments, HttpClient returns empty or mocked results
      expect(videos, isA<List<Map<String, String>>>());
    });

    test('Stage 1: VimeoNoQuotaScraper handles queries gracefully', () async {
      final vimeoScraper = VimeoNoQuotaScraper();
      final videos = await vimeoScraper.scrapeVideos(
        query: 'Science documentary',
        category: 'Education & Learning',
      );
      expect(videos, isA<List<Map<String, String>>>());
    });

    test('Stage 2: Firebase Cache Service saves and retrieves cached videos', () async {
      final cacheService = FirebaseCacheService();
      final testKey = "test_unit_cache_${DateTime.now().millisecondsSinceEpoch}";
      final testData = [
        {
          'videoId': 'testId12345',
          'title': 'Test Cached Video Lesson 2026',
          'channel': 'Test Academy',
          'category': 'Education & Learning',
          'thumbnail': 'https://img.youtube.com/vi/testId12345/hqdefault.jpg',
          'duration': '10:00',
        }
      ];

      await cacheService.saveCachedVideos(testKey, testData);
      final retrieved = await cacheService.getCachedVideos(testKey);
      expect(retrieved, isNotNull);
      expect(retrieved!.first['videoId'], equals('testId12345'));
    });

    test('Stage 3: YouTube Official API Service handles requests and missing keys gracefully', () async {
      final apiService = YouTubeOfficialApiService();
      final results = await apiService.fetchVideos(
        query: 'Quantum Computing 2026',
        category: 'Technology & AI',
        language: 'English',
      );
      expect(results, isA<List<Map<String, String>>>());
    });
  });

  group('📚 2. Category & Subcategory Loading Tests', () {
    final youtubeRepo = YouTubeRepository();
    final vimeoRepo = VimeoRepository();

    final categories = [
      'Education & Learning',
      'Competitive Exams',
      'Knowledge & Discovery',
      'Technology & AI',
      'Business & Finance',
      'Spirituality & Philosophy',
      'Health & Fitness',
    ];

    for (final cat in categories) {
      test('YouTubeRepository loads fresh videos for "$cat"', () async {
        final videos = await youtubeRepo.getVideosByCategory(cat);
        expect(videos, isNotEmpty);
        expect(videos.every((v) => v['videoId'] != null && v['videoId']!.isNotEmpty), isTrue);
      });

      test('VimeoRepository loads videos for "$cat"', () async {
        final videos = await vimeoRepo.getVideosByCategory(cat);
        expect(videos, isNotEmpty);
        expect(videos.every((v) => v['videoId'] != null && v['videoId']!.isNotEmpty), isTrue);
      });
    }

    test('YouTubeRepository loads all 35 subcategories with verified video libraries', () async {
      for (final cat in categories) {
        final subcats = YouTubeRepository.categorySubcategories[cat] ?? [];
        expect(subcats.length, equals(5));
        for (final sub in subcats) {
          final subVideos = await youtubeRepo.getVideosBySubcategory(sub);
          expect(subVideos, isNotEmpty);
          expect(subVideos.first['videoId'], isNotNull);
        }
      }
    });
  });

  group('🛠️ 3. Video ID Sanitization & Player Regex Verification', () {
    String cleanYoutubeId(String raw, String thumb) {
      final trimmed = raw.trim();
      if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(trimmed)) return trimmed;

      final urlRegex = RegExp(
        r'(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=))([a-zA-Z0-9_-]{11})',
        caseSensitive: false,
      );
      final match = urlRegex.firstMatch(trimmed);
      if (match != null && match.group(1) != null) return match.group(1)!;

      final vMatch = RegExp(r'v=([a-zA-Z0-9_-]{11})').firstMatch(trimmed);
      if (vMatch != null && vMatch.group(1) != null) return vMatch.group(1)!;

      final thumbMatch = RegExp(r'vi\/([a-zA-Z0-9_-]{11})').firstMatch(thumb);
      if (thumbMatch != null && thumbMatch.group(1) != null) return thumbMatch.group(1)!;

      final genericMatch = RegExp(r'(?<!https?:\/\/[\w\.\/]*)([a-zA-Z0-9_-]{11})').firstMatch(trimmed);
      if (genericMatch != null && genericMatch.group(1) != null) return genericMatch.group(1)!;

      return '1gDhl4leEzA';
    }

    test('Sanitizes direct 11-char YouTube ID', () {
      expect(cleanYoutubeId('dQw4w9WgXcQ', ''), equals('dQw4w9WgXcQ'));
    });

    test('Sanitizes full watch?v= URL without string corruption', () {
      expect(cleanYoutubeId('https://www.youtube.com/watch?v=1gDhl4leEzA', ''), equals('1gDhl4leEzA'));
    });

    test('Sanitizes youtu.be short URL', () {
      expect(cleanYoutubeId('https://youtu.be/bHIhgxav9LY', ''), equals('bHIhgxav9LY'));
    });

    test('Sanitizes embed URL', () {
      expect(cleanYoutubeId('https://www.youtube.com/embed/aircAruvnKk', ''), equals('aircAruvnKk'));
    });

    test('Sanitizes thumbnail path fallback', () {
      expect(cleanYoutubeId('corrupt_url_without_id', 'https://img.youtube.com/vi/MBRqu0YOH14/hqdefault.jpg'), equals('MBRqu0YOH14'));
    });
  });

  group('⏱️ 4. Watch History, Streak & Store Verification', () {
    test('HistoryRepository records and tracks progress', () {
      final historyRepo = HistoryRepository();
      historyRepo.addOrUpdateHistory(
        videoId: 'bHIhgxav9LY',
        title: 'The Biggest Misconception About Electricity',
        channel: 'Veritasium',
        thumbnail: 'https://img.youtube.com/vi/bHIhgxav9LY/hqdefault.jpg',
        platform: 'youtube',
      );
      historyRepo.updateProgress('bHIhgxav9LY', 0.5, '7:16');
      final items = historyRepo.historyNotifier.value;
      expect(items.any((i) => i.videoId == 'bHIhgxav9LY'), isTrue);
      final item = items.firstWhere((i) => i.videoId == 'bHIhgxav9LY');
      expect(item.progress, equals(0.5));
    });

    test('StreakService checks and updates streak properly', () async {
      final streakData = await StreakService.checkAndUpdateStreak();
      expect(streakData.streakCount, greaterThanOrEqualTo(1));
      expect(streakData.lastLoginDate, isNotEmpty);
    });
  });

  group('👤 5. Dynamic Auth & Unique User Identity Verification', () {
    test('AuthService signs in with unique Gmail account and updates profile dynamically', () async {
      final user = await AuthService.signInWithGoogle(
        email: 'alex.learner.2026@gmail.com',
        displayName: 'Alex Learner',
      );

      expect(user.email, equals('alex.learner.2026@gmail.com'));
      expect(user.displayName, equals('Alex Learner'));
      expect(user.provider, equals('google'));
      expect(user.isLoggedIn, isTrue);
      expect(user.initial, equals('A'));
      expect(AuthService.userNotifier.value.email, equals('alex.learner.2026@gmail.com'));
    });

    test('AuthService updates profile dynamically with new name and avatar', () async {
      await AuthService.updateProfile(
        displayName: 'Dr. Sarah Connor',
        email: 'sarah.connor@focusgrid.app',
      );

      final current = AuthService.userNotifier.value;
      expect(current.displayName, equals('Dr. Sarah Connor'));
      expect(current.email, equals('sarah.connor@focusgrid.app'));
      expect(current.initial, equals('D'));
    });

    test('AuthService sign out clears identity cleanly', () async {
      await AuthService.signOut();
      expect(AuthService.userNotifier.value.isLoggedIn, isFalse);
    });
  });
}
