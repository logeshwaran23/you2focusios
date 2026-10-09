import 'package:flutter_test/flutter_test.dart';
import 'package:focus_grid_flutter/data/repository/youtube_repository.dart';

void main() {
  group('You2Focus Comprehensive Feature Verification', () {
    final expectedCategories = [
      'Education & Learning',
      'Competitive Exams',
      'Knowledge & Discovery',
      'Technology & AI',
      'Business & Finance',
      'Spirituality & Philosophy',
      'Health & Fitness',
    ];

    test('All 7 main categories registered with exactly 5 subtopics each', () {
      for (final category in expectedCategories) {
        final subcats = YouTubeRepository.categorySubcategories[category] ?? [];
        expect(subcats.length, 5,
            reason: '$category must have exactly 5 subtopics');
      }
    });

    test('All 35 subtopics have valid video libraries with non-empty metadata', () {
      for (final category in expectedCategories) {
        final subcats = YouTubeRepository.categorySubcategories[category] ?? [];
        for (final sub in subcats) {
          final videos = YouTubeRepository.subcategoryVideos[sub] ?? [];
          expect(videos.isNotEmpty, true,
              reason: 'Subtopic "$sub" under $category must have videos');
          for (final v in videos) {
            expect(v['videoId']?.isNotEmpty, true,
                reason: 'Video ID must not be empty in $sub');
            expect(v['title']?.isNotEmpty, true,
                reason: 'Title must not be empty in $sub');
            expect(v['channel']?.isNotEmpty, true,
                reason: 'Channel must not be empty in $sub');
            expect(v['thumbnail']?.isNotEmpty, true,
                reason: 'Thumbnail must not be empty in $sub');
          }
        }
      }
    });

    test('All 7 main category topic feeds have non-empty video pools', () {
      for (final category in expectedCategories) {
        final videos = YouTubeRepository.topicVideos[category] ?? [];
        expect(videos.isNotEmpty, true,
            reason: 'Category "$category" must have base videos');
      }
    });

    test('"All" Category feed aggregated pool is populated', () {
      final allBaseVideos = YouTubeRepository.topicVideos["All"] ?? [];
      final totalVideosAcrossTopics =
          YouTubeRepository.topicVideos.values.expand((e) => e).length;
      expect(allBaseVideos.isNotEmpty, true);
      expect(totalVideosAcrossTopics >= 80, true);
    });
  });
}
