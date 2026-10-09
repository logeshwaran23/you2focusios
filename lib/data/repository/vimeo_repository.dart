import '../remote/firebase_cache_service.dart';
import '../remote/vimeo_no_quota_scraper.dart';

class VimeoRepository {
  final VimeoNoQuotaScraper _scraper = VimeoNoQuotaScraper();
  final FirebaseCacheService _firebaseCache = FirebaseCacheService();

  static final Map<String, List<Map<String, String>>> _categoryCache = {};

  static const Map<String, List<Map<String, String>>> fallbackCategoryVideos = {
    "Education & Learning": [
      {
        "title": "The Art of Creative Photography & Visual Science",
        "channel": "Visual Science Studio",
        "category": "Education & Learning",
        "thumbnail": "https://vumbnail.com/76979871.jpg",
        "duration": "4:32",
        "videoId": "76979871",
      },
      {
        "title": "Deep Space Astronomy & Cosmic Physics",
        "channel": "Cosmic Science Hub",
        "duration": "6:40",
        "thumbnail": "https://vumbnail.com/23534361.jpg",
        "videoId": "23534361",
        "category": "Education & Learning"
      },
      {
        "title": "3D Graphics & Computational Physics Masterclass",
        "channel": "Blender Institute",
        "duration": "9:56",
        "thumbnail": "https://vumbnail.com/1084537.jpg",
        "videoId": "1084537",
        "category": "Education & Learning"
      },
      {
        "title": "Nature, Climate Science & Earth Systems",
        "channel": "Earth & Environmental Sciences",
        "duration": "5:12",
        "thumbnail": "https://vumbnail.com/143003055.jpg",
        "videoId": "143003055",
        "category": "Education & Learning"
      },
    ],
    "Competitive Exams": [
      {
        "title": "Mastering Competitive Exam Strategy & Study Focus",
        "channel": "Study With Me",
        "category": "Competitive Exams",
        "thumbnail": "https://vumbnail.com/76979871.jpg",
        "duration": "12:00",
        "videoId": "76979871",
      },
      {
        "title": "Memory Techniques & High Focus for Exam Success",
        "channel": "Mind Academy",
        "duration": "8:45",
        "thumbnail": "https://vumbnail.com/178711416.jpg",
        "videoId": "178711416",
        "category": "Competitive Exams"
      },
    ],
    "Business & Finance": [
      {
        "title": "Entrepreneurship & Modern Business Innovation",
        "channel": "Stanford eCorner",
        "duration": "14:20",
        "thumbnail": "https://vumbnail.com/178711416.jpg",
        "videoId": "178711416",
        "category": "Business & Finance"
      },
      {
        "title": "Architectural Design & Modern Engineering Strategy",
        "channel": "Design & Build Studio",
        "duration": "7:45",
        "thumbnail": "https://vumbnail.com/60733737.jpg",
        "videoId": "60733737",
        "category": "Business & Finance"
      },
    ],
    "Technology & AI": [
      {
        "title": "Software Architecture & Modern Design Thinking",
        "channel": "Tech & Design Academy",
        "duration": "8:15",
        "thumbnail": "https://vumbnail.com/178711416.jpg",
        "videoId": "178711416",
        "category": "Technology & AI"
      },
      {
        "title": "Deep Space & Quantum Computational Physics",
        "channel": "Physics Frontiers",
        "duration": "6:40",
        "thumbnail": "https://vumbnail.com/23534361.jpg",
        "videoId": "23534361",
        "category": "Technology & AI"
      },
      {
        "title": "3D Interactive Media & Digital Engineering",
        "channel": "Interactive Web Lab",
        "duration": "9:56",
        "thumbnail": "https://vumbnail.com/1084537.jpg",
        "videoId": "1084537",
        "category": "Technology & AI"
      },
    ],
    "Health & Fitness": [
      {
        "title": "Mindfulness Practice & Neuroscience of Focus",
        "channel": "Neuroscience Institute",
        "duration": "4:32",
        "thumbnail": "https://vumbnail.com/76979871.jpg",
        "videoId": "76979871",
        "category": "Health & Fitness"
      },
      {
        "title": "Restorative Ocean Landscapes & Mind Relaxation",
        "channel": "Wellness & Mind Hub",
        "duration": "5:12",
        "thumbnail": "https://vumbnail.com/143003055.jpg",
        "videoId": "143003055",
        "category": "Health & Fitness"
      },
    ],
    "Spirituality & Philosophy": [
      {
        "title": "Stoic Philosophy & Cognitive Psychology Principles",
        "channel": "Wisdom Academy",
        "duration": "9:56",
        "thumbnail": "https://vumbnail.com/1084537.jpg",
        "videoId": "1084537",
        "category": "Spirituality & Philosophy"
      },
      {
        "title": "Cosmic Science & Human Philosophical Exploration",
        "channel": "Cosmic Science Hub",
        "duration": "6:40",
        "thumbnail": "https://vumbnail.com/23534361.jpg",
        "videoId": "23534361",
        "category": "Spirituality & Philosophy"
      },
    ],
    "Knowledge & Discovery": [
      {
        "title": "Creative Art, Design & Photography Techniques",
        "channel": "Creative Studio",
        "duration": "4:32",
        "thumbnail": "https://vumbnail.com/76979871.jpg",
        "videoId": "76979871",
        "category": "Knowledge & Discovery"
      },
      {
        "title": "Modern Motion Design & Creative Craft Skills",
        "channel": "Motion Design Academy",
        "duration": "7:45",
        "thumbnail": "https://vumbnail.com/60733737.jpg",
        "videoId": "60733737",
        "category": "Knowledge & Discovery"
      },
    ]
  };

  static const Map<String, List<String>> queryPool = {
    "Education & Learning": [
      "computer science university lecture",
      "mathematics physics deep dive lecture",
      "world history civilization documentary"
    ],
    "Competitive Exams": [
      "competitive exam preparation strategy tips",
      "UPSC IAS study technique topper"
    ],
    "Business & Finance": [
      "entrepreneurship startup success guide",
      "business management strategy leadership"
    ],
    "Technology & AI": [
      "software engineering tutorial",
      "machine learning artificial intelligence"
    ],
    "Health & Fitness": [
      "yoga wellness tutorial",
      "meditation mindfulness guide"
    ],
    "Spirituality & Philosophy": [
      "philosophy stoicism Eastern thought lecture"
    ],
    "Knowledge & Discovery": [
      "self improvement personal development masterclass"
    ],
    "All": [
      "technology science documentary",
      "history world events explained"
    ]
  };

  Future<List<Map<String, String>>> getVideosByCategory(String category, {bool forceRefresh = false}) async {
    final cacheKey = "vimeo_$category";

    if (forceRefresh) {
      _categoryCache.remove(category);
    }

    if (!forceRefresh && _categoryCache.containsKey(category) && _categoryCache[category]!.isNotEmpty) {
      return List<Map<String, String>>.from(_categoryCache[category]!);
    }

    final queries = queryPool[category] ?? queryPool["All"]!;
    final query = queries.first;

    // ──────── 1. NO-QUOTA SCRAPER (FIRST PRIORITY) ────────
    try {
      final scraped = await _scraper.scrapeVideos(query: query, category: category);
      if (scraped.isNotEmpty) {
        _setCategoryCache(category, scraped);
        _firebaseCache.saveCachedVideos(cacheKey, scraped);
        return List<Map<String, String>>.from(_categoryCache[category]!);
      }
    } catch (_) {}

    // ──────── 2. FIREBASE CACHE (SECOND PRIORITY) ────────
    try {
      final cached = await _firebaseCache.getCachedVideos(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        _setCategoryCache(category, cached);
        return List<Map<String, String>>.from(_categoryCache[category]!);
      }
    } catch (_) {}

    // ──────── 3. CURATED STATIC FALLBACK (OFFLINE ONLY) ────────
    List<Map<String, String>> fallbacks = (category == "All")
        ? fallbackCategoryVideos.values.expand((e) => e).toList()
        : (fallbackCategoryVideos[category] ?? fallbackCategoryVideos["Education & Learning"]!);

    _setCategoryCache(category, fallbacks);
    return List<Map<String, String>>.from(_categoryCache[category]!);
  }

  void _setCategoryCache(String category, List<Map<String, String>> videos) {
    final uniqueMap = <String, Map<String, String>>{};
    for (var v in videos) {
      final id = v['videoId'] ?? '';
      if (id.isNotEmpty) uniqueMap[id] = v;
    }
    _categoryCache[category] = uniqueMap.values.toList();
  }
}
