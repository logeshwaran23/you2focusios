import 'package:flutter/foundation.dart';

class WatchHistoryItem {
  final String id;
  final String videoId;
  final String title;
  final String channel;
  final String thumbnail;
  final String platform; // 'youtube' or 'vimeo'
  final String duration;
  final String watchedTimeStr;
  final double progress; // 0.0 to 1.0
  final DateTime watchedAt;

  WatchHistoryItem({
    required this.id,
    required this.videoId,
    required this.title,
    required this.channel,
    required this.thumbnail,
    required this.platform,
    required this.duration,
    required this.watchedTimeStr,
    required this.progress,
    required this.watchedAt,
  });
}

class HistoryRepository {
  static final HistoryRepository _instance = HistoryRepository._internal();
  factory HistoryRepository() => _instance;
  HistoryRepository._internal() {
    _initDefaults();
  }

  final ValueNotifier<List<WatchHistoryItem>> historyNotifier = ValueNotifier([]);

  void _initDefaults() {
    historyNotifier.value = [
      WatchHistoryItem(
        id: "yt1",
        videoId: "u94ECE910Lw",
        title: "How Did A Few Great Minds Change How We See Reality?",
        channel: "Science Today",
        thumbnail: "https://img.youtube.com/vi/u94ECE910Lw/hqdefault.jpg",
        platform: "youtube",
        duration: "4:15",
        watchedTimeStr: "1:25",
        progress: 0.34,
        watchedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      WatchHistoryItem(
        id: "yt2",
        videoId: "GwIo3gDZCVQ",
        title: "Deep Dive: Why Isaac Newton Couldn't Solve Three Body",
        channel: "Physics Podcast",
        thumbnail: "https://img.youtube.com/vi/GwIo3gDZCVQ/hqdefault.jpg",
        platform: "youtube",
        duration: "6:00",
        watchedTimeStr: "3:00",
        progress: 0.50,
        watchedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      WatchHistoryItem(
        id: "yt3",
        videoId: "dQw4w9WgXcQ",
        title: "Quantum Physics & Relativity Masterclass",
        channel: "MIT OpenCourseWare",
        thumbnail: "https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
        platform: "youtube",
        duration: "10:00",
        watchedTimeStr: "8:20",
        progress: 0.83,
        watchedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      WatchHistoryItem(
        id: "yt4",
        videoId: "k2qgadSvNyU",
        title: "Machine Learning Foundations for Beginners",
        channel: "FreeCodeCamp",
        thumbnail: "https://img.youtube.com/vi/k2qgadSvNyU/hqdefault.jpg",
        platform: "youtube",
        duration: "15:00",
        watchedTimeStr: "5:30",
        progress: 0.36,
        watchedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      WatchHistoryItem(
        id: "yt5",
        videoId: "L_LUpnjgPso",
        title: "Calculus Visualized: Derivatives and Integrals",
        channel: "3Blue1Brown",
        thumbnail: "https://img.youtube.com/vi/L_LUpnjgPso/hqdefault.jpg",
        platform: "youtube",
        duration: "12:45",
        watchedTimeStr: "12:45",
        progress: 1.0,
        watchedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      WatchHistoryItem(
        id: "yt6",
        videoId: "aircAruvnKk",
        title: "Neural Networks & Deep Learning Essentials",
        channel: "DeepLearningAI",
        thumbnail: "https://img.youtube.com/vi/aircAruvnKk/hqdefault.jpg",
        platform: "youtube",
        duration: "8:30",
        watchedTimeStr: "4:15",
        progress: 0.50,
        watchedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      ),
      WatchHistoryItem(
        id: "yt7",
        videoId: "8hly31xKLI0",
        title: "Algorithms & Data Structures Crash Course",
        channel: "CS Dojo",
        thumbnail: "https://img.youtube.com/vi/8hly31xKLI0/hqdefault.jpg",
        platform: "youtube",
        duration: "20:00",
        watchedTimeStr: "14:10",
        progress: 0.70,
        watchedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      WatchHistoryItem(
        id: "yt8",
        videoId: "rfscVS0vtbw",
        title: "Python Programming Full Course 2026",
        channel: "Tech With Tim",
        thumbnail: "https://img.youtube.com/vi/rfscVS0vtbw/hqdefault.jpg",
        platform: "youtube",
        duration: "30:00",
        watchedTimeStr: "10:00",
        progress: 0.33,
        watchedAt: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
      ),
      WatchHistoryItem(
        id: "yt9",
        videoId: "UB1O30fR-EE",
        title: "HTML & CSS Responsive Web Design",
        channel: "Traversy Media",
        thumbnail: "https://img.youtube.com/vi/UB1O30fR-EE/hqdefault.jpg",
        platform: "youtube",
        duration: "18:20",
        watchedTimeStr: "9:10",
        progress: 0.50,
        watchedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      WatchHistoryItem(
        id: "yt10",
        videoId: "W6NZfCO5SIk",
        title: "JavaScript Async Await & Promises Tutorial",
        channel: "Fireship",
        thumbnail: "https://img.youtube.com/vi/W6NZfCO5SIk/hqdefault.jpg",
        platform: "youtube",
        duration: "5:12",
        watchedTimeStr: "5:12",
        progress: 1.0,
        watchedAt: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
      ),
      WatchHistoryItem(
        id: "yt11",
        videoId: "Z1RJmh_OqeA",
        title: "React Native vs Flutter Comparison",
        channel: "Academind",
        thumbnail: "https://img.youtube.com/vi/Z1RJmh_OqeA/hqdefault.jpg",
        platform: "youtube",
        duration: "14:00",
        watchedTimeStr: "7:00",
        progress: 0.50,
        watchedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      WatchHistoryItem(
        id: "yt12",
        videoId: "T1-BwGg4wEU",
        title: "Docker & Kubernetes Architecture",
        channel: "NetworkChuck",
        thumbnail: "https://img.youtube.com/vi/T1-BwGg4wEU/hqdefault.jpg",
        platform: "youtube",
        duration: "22:15",
        watchedTimeStr: "11:00",
        progress: 0.49,
        watchedAt: DateTime.now().subtract(const Duration(days: 4, hours: 3)),
      ),
      WatchHistoryItem(
        id: "yt13",
        videoId: "9emXNzqCKyg",
        title: "System Design Essentials for Senior Engineers",
        channel: "ByteByteGo",
        thumbnail: "https://img.youtube.com/vi/9emXNzqCKyg/hqdefault.jpg",
        platform: "youtube",
        duration: "16:00",
        watchedTimeStr: "12:00",
        progress: 0.75,
        watchedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      WatchHistoryItem(
        id: "yt14",
        videoId: "SqcY0GlETPk",
        title: "Cyber Security Fundamentals & Hacking Risks",
        channel: "Simply Learn",
        thumbnail: "https://img.youtube.com/vi/SqcY0GlETPk/hqdefault.jpg",
        platform: "youtube",
        duration: "11:30",
        watchedTimeStr: "3:45",
        progress: 0.32,
        watchedAt: DateTime.now().subtract(const Duration(days: 5, hours: 4)),
      ),
      WatchHistoryItem(
        id: "yt15",
        videoId: "pTFZFxd4hOI",
        title: "Artificial Intelligence in 2026 Overview",
        channel: "Two Minute Papers",
        thumbnail: "https://img.youtube.com/vi/pTFZFxd4hOI/hqdefault.jpg",
        platform: "youtube",
        duration: "7:40",
        watchedTimeStr: "4:00",
        progress: 0.52,
        watchedAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
    ];
  }

  void addOrUpdateHistory({
    required String videoId,
    required String title,
    required String channel,
    required String thumbnail,
    required String platform,
    String duration = "10:00",
    String watchedTimeStr = "1:00",
    double progress = 0.25,
  }) {
    final currentList = List<WatchHistoryItem>.from(historyNotifier.value);
    
    // Remove if already exists (so latest watched video moves to top)
    currentList.removeWhere((item) => item.videoId == videoId);

    // Compute default thumbnail if missing
    String finalThumbnail = thumbnail;
    if (finalThumbnail.isEmpty) {
      if (platform.toLowerCase() == 'youtube') {
        finalThumbnail = "https://img.youtube.com/vi/$videoId/hqdefault.jpg";
      } else {
        final cleanId = videoId.replaceAll("vimeo_", "").replaceAll("vm_", "");
        finalThumbnail = "https://vumbnail.com/$cleanId.jpg";
      }
    }

    final newItem = WatchHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      videoId: videoId,
      title: title,
      channel: channel,
      thumbnail: finalThumbnail,
      platform: platform.toLowerCase(),
      duration: duration,
      watchedTimeStr: watchedTimeStr,
      progress: progress.clamp(0.0, 1.0),
      watchedAt: DateTime.now(),
    );

    // Insert at beginning of list (most recent first)
    currentList.insert(0, newItem);
    historyNotifier.value = currentList;
  }

  void updateProgress(String videoId, double progress, String watchedTimeStr) {
    final currentList = List<WatchHistoryItem>.from(historyNotifier.value);
    final index = currentList.indexWhere((item) => item.videoId == videoId);
    if (index != -1) {
      final old = currentList[index];
      currentList[index] = WatchHistoryItem(
        id: old.id,
        videoId: old.videoId,
        title: old.title,
        channel: old.channel,
        thumbnail: old.thumbnail,
        platform: old.platform,
        duration: old.duration,
        watchedTimeStr: watchedTimeStr,
        progress: progress.clamp(0.0, 1.0),
        watchedAt: DateTime.now(),
      );
      historyNotifier.value = currentList;
    }
  }

  void removeItem(String id) {
    final currentList = List<WatchHistoryItem>.from(historyNotifier.value);
    currentList.removeWhere((item) => item.id == id);
    historyNotifier.value = currentList;
  }

  void clearAll() {
    historyNotifier.value = [];
  }
}
