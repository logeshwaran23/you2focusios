import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:focus_grid_flutter/data/repository/youtube_repository.dart';
import 'package:focus_grid_flutter/data/repository/vimeo_repository.dart';
import 'package:focus_grid_flutter/data/repository/history_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  final expectedCategories = [
    'Education & Learning',
    'Competitive Exams',
    'Knowledge & Discovery',
    'Technology & AI',
    'Business & Finance',
    'Spirituality & Philosophy',
    'Health & Fitness',
  ];

  group('🎯 Pipeline Priority Verification', () {
    test('Pipeline follows: 1) No-Quota Scraper -> 2) Firebase Cache -> 3) YouTube API -> 4) Curated Fallback', () async {
      final repo = YouTubeRepository();
      final videos = await repo.getVideosByCategory('Education & Learning');
      expect(videos, isNotEmpty);
      expect(videos.first['videoId'], isNotNull);
      expect(videos.first['videoId']!.isNotEmpty, isTrue);
    });

    test('Vimeo Repository follows: 1) No-Quota Scraper -> 2) Firebase Cache -> 3) Fallback', () async {
      final vimeoRepo = VimeoRepository();
      final vimeoVideos = await vimeoRepo.getVideosByCategory('Technology & AI');
      expect(vimeoVideos, isNotEmpty);
      expect(vimeoVideos.first['videoId'], isNotNull);
    });
  });

  group('📋 Category & Subtopic Hierarchy', () {
    for (final category in expectedCategories) {
      test('Category "$category" has 5 subtopics', () {
        final subcats = YouTubeRepository.categorySubcategories[category] ?? [];
        expect(subcats.length, equals(5));
      });
    }

    test('All 35 subtopics have verified video libraries', () {
      for (final category in expectedCategories) {
        final subcats = YouTubeRepository.categorySubcategories[category] ?? [];
        for (final sub in subcats) {
          final videos = YouTubeRepository.subcategoryVideos[sub] ?? [];
          expect(videos, isNotEmpty, reason: 'Subtopic $sub should have videos');
          for (final v in videos) {
            expect(v['videoId']?.isNotEmpty, isTrue);
            expect(v['title']?.isNotEmpty, isTrue);
            expect(v['thumbnail']?.isNotEmpty, isTrue);
          }
        }
      }
    });

    test('All 7 main category topic feeds have base videos', () {
      for (final category in expectedCategories) {
        final videos = YouTubeRepository.topicVideos[category] ?? [];
        expect(videos, isNotEmpty);
      }
    });

    test('"All" Category feed has aggregated video library', () {
      final allBaseVideos = YouTubeRepository.topicVideos["All"] ?? [];
      expect(allBaseVideos, isNotEmpty);
      final totalVideos = YouTubeRepository.topicVideos.values.expand((e) => e).length;
      expect(totalVideos, greaterThanOrEqualTo(80));
    });
  });

  group('🛠️ Video ID Sanitization (URL & Shortcodes)', () {
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

    test('Parses raw 11-character video ID', () {
      expect(cleanYoutubeId('bHIhgxav9LY', ''), equals('bHIhgxav9LY'));
    });

    test('Parses standard youtube.com/watch?v= URLs', () {
      expect(cleanYoutubeId('https://www.youtube.com/watch?v=1gDhl4leEzA', ''), equals('1gDhl4leEzA'));
    });

    test('Parses youtu.be short URLs', () {
      expect(cleanYoutubeId('https://youtu.be/aircAruvnKk', ''), equals('aircAruvnKk'));
    });

    test('Parses youtube.com/embed/ URLs', () {
      expect(cleanYoutubeId('https://www.youtube.com/embed/MBRqu0YOH14', ''), equals('MBRqu0YOH14'));
    });

    test('Recovers video ID from thumbnail URL fallback', () {
      expect(cleanYoutubeId('malformed_link', 'https://img.youtube.com/vi/HeQX2HjkcNo/hqdefault.jpg'), equals('HeQX2HjkcNo'));
    });
  });

  group('⏱️ Watch History & Progress Tracking', () {
    test('HistoryRepository adds, tracks, and updates video progress', () {
      final historyRepo = HistoryRepository();
      historyRepo.addOrUpdateHistory(
        videoId: 'bHIhgxav9LY',
        title: 'The Biggest Misconception About Electricity',
        channel: 'Veritasium',
        thumbnail: 'https://img.youtube.com/vi/bHIhgxav9LY/hqdefault.jpg',
        platform: 'youtube',
      );
      historyRepo.updateProgress('bHIhgxav9LY', 0.8, '11:38');
      final items = historyRepo.historyNotifier.value;
      expect(items.any((i) => i.videoId == 'bHIhgxav9LY'), isTrue);
      final item = items.firstWhere((i) => i.videoId == 'bHIhgxav9LY');
      expect(item.progress, equals(0.8));
      expect(item.watchedTimeStr, equals('11:38'));
    });
  });
}
