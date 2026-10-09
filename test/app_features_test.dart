import 'package:flutter_test/flutter_test.dart';
import 'package:focus_grid_flutter/data/repository/youtube_repository.dart';

void main() {
  group('You2Focus - 7 Topics & 35 Subtopics Feature Verification', () {
    late YouTubeRepository repository;

    setUp(() {
      repository = YouTubeRepository();
    });

    final expectedCategories = [
      'Education & Learning',
      'Competitive Exams',
      'Knowledge & Discovery',
      'Technology & AI',
      'Business & Finance',
      'Spirituality & Philosophy',
      'Health & Fitness',
    ];

    test('All 7 main categories are registered with exactly 5 subtopics each', () {
      for (final category in expectedCategories) {
        final subcats = repository.getSubcategories(category);
        expect(subcats.length, 5, reason: '$category should have exactly 5 subtopics');
      }
    });

    test('Education & Learning subtopics and video libraries are valid', () {
      const subtopics = [
        'Study Strategies & Learning Science',
        'Academic Mastery',
        'Skills & Career Learning',
        'Self-Directed Learning',
        'Critical Thinking & Problem Solving',
      ];
      for (final sub in subtopics) {
        final videos = YouTubeRepository.subcategoryVideos[sub] ?? [];
        expect(videos.isNotEmpty, true, reason: '$sub should contain videos');
        for (final v in videos) {
          expect(v['videoId']?.isNotEmpty, true);
          expect(v['title']?.isNotEmpty, true);
          expect(v['channel']?.isNotEmpty, true);
        }
      }
    });

    test('Competitive Exams subtopics and video libraries are valid', () {
      const subtopics = [
        'Quantitative Aptitude & Mathematics',
        'Logical Reasoning & Mental Ability',
        'Verbal Ability & Language',
        'General Awareness & Current Affairs',
        'Exam Strategy & Performance',
      ];
      for (final sub in subtopics) {
        final videos = YouTubeRepository.subcategoryVideos[sub] ?? [];
        expect(videos.isNotEmpty, true, reason: '$sub should contain videos');
        for (final v in videos) {
          expect(v['videoId']?.isNotEmpty, true);
          expect(v['title']?.isNotEmpty, true);
          expect(v['channel']?.isNotEmpty, true);
        }
      }
    });

    test('Knowledge & Discovery subtopics and video libraries are valid', () {
      const subtopics = [
        'Science & the Universe',
        'History & Civilizations',
        'Geography & Our Planet',
        'Human Behavior & Society',
        'Curiosities & Hidden Knowledge',
      ];
      for (final sub in subtopics) {
        final videos = YouTubeRepository.subcategoryVideos[sub] ?? [];
        expect(videos.isNotEmpty, true, reason: '$sub should contain videos');
        for (final v in videos) {
          expect(v['videoId']?.isNotEmpty, true);
          expect(v['title']?.isNotEmpty, true);
          expect(v['channel']?.isNotEmpty, true);
        }
      }
    });

    test('Technology & AI subtopics and video libraries are valid', () {
      const subtopics = [
        'Artificial Intelligence & Generative AI',
        'Software Development & Engineering',
        'Emerging Technologies',
        'Cybersecurity & Digital Safety',
        'Future of Technology',
      ];
      for (final sub in subtopics) {
        final videos = YouTubeRepository.subcategoryVideos[sub] ?? [];
        expect(videos.isNotEmpty, true, reason: '$sub should contain videos');
        for (final v in videos) {
          expect(v['videoId']?.isNotEmpty, true);
          expect(v['title']?.isNotEmpty, true);
          expect(v['channel']?.isNotEmpty, true);
        }
      }
    });

    test('Business & Finance subtopics and video libraries are valid', () {
      const subtopics = [
        'Personal Finance & Wealth Building',
        'Investing & Markets',
        'Entrepreneurship & Startups',
        'Business Strategy & Leadership',
        'Economics & Financial Intelligence',
      ];
      for (final sub in subtopics) {
        final videos = YouTubeRepository.subcategoryVideos[sub] ?? [];
        expect(videos.isNotEmpty, true, reason: '$sub should contain videos');
        for (final v in videos) {
          expect(v['videoId']?.isNotEmpty, true);
          expect(v['title']?.isNotEmpty, true);
          expect(v['channel']?.isNotEmpty, true);
        }
      }
    });

    test('Spirituality & Philosophy subtopics and video libraries are valid', () {
      const subtopics = [
        'Indian Wisdom & Vedanta',
        'Meditation & Inner Awareness',
        'Philosophy & Meaning',
        'World Wisdom Traditions',
        'Purpose, Values & Self-Mastery',
      ];
      for (final sub in subtopics) {
        final videos = YouTubeRepository.subcategoryVideos[sub] ?? [];
        expect(videos.isNotEmpty, true, reason: '$sub should contain videos');
        for (final v in videos) {
          expect(v['videoId']?.isNotEmpty, true);
          expect(v['title']?.isNotEmpty, true);
          expect(v['channel']?.isNotEmpty, true);
        }
      }
    });

    test('Health & Fitness subtopics and video libraries are valid', () {
      const subtopics = [
        'Exercise & Physical Performance',
        'Nutrition & Healthy Eating',
        'Sleep & Recovery',
        'Mental Wellbeing & Stress Management',
        'Healthy Lifestyle & Longevity',
      ];
      for (final sub in subtopics) {
        final videos = YouTubeRepository.subcategoryVideos[sub] ?? [];
        expect(videos.isNotEmpty, true, reason: '$sub should contain videos');
        for (final v in videos) {
          expect(v['videoId']?.isNotEmpty, true);
          expect(v['title']?.isNotEmpty, true);
          expect(v['channel']?.isNotEmpty, true);
        }
      }
    });

    test('"All" category returns a rich pool of verified videos', () {
      final allVideos = YouTubeRepository.topicVideos['All'] ?? [];
      expect(allVideos.length, greaterThanOrEqualTo(10));
    });
  });
}
