import 'package:flutter/material.dart';
import '../data/remote/youtube_no_quota_scraper.dart';
import '../data/remote/firebase_cache_service.dart';
import '../data/remote/youtube_official_api_service.dart';
import '../data/repository/youtube_repository.dart';
import 'video_player_screen.dart'; // For VideoPlayerScreen

class SearchScreen extends StatefulWidget {
  final bool isDarkMode;

  const SearchScreen({super.key, required this.isDarkMode});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final YouTubeNoQuotaScraper _scraper = YouTubeNoQuotaScraper();
  final FirebaseCacheService _firebaseCache = FirebaseCacheService();
  final YouTubeOfficialApiService _officialApiService = YouTubeOfficialApiService();
  
  List<Map<String, String>> _searchResults = [];
  final List<String> _recentSearches = [
    "Flutter Tutorial 2026",
    "Computer Science Lecture",
    "Machine Learning Guide",
    "Quantum Physics Explained",
  ];
  
  bool _isSearching = false;
  bool _hasSearched = false;

  Future<void> _performSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    if (!_recentSearches.contains(trimmed)) {
      _recentSearches.insert(0, trimmed);
      if (_recentSearches.length > 8) {
        _recentSearches.removeLast();
      }
    }

    final cacheKey = "search_${trimmed.toLowerCase()}";

    // 1. No-Quota Scraper (High Priority)
    try {
      final results = await _scraper.scrapeVideos(query: trimmed, category: "Search");
      if (results.isNotEmpty) {
        _firebaseCache.saveCachedVideos(cacheKey, results);
        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        }
        return;
      }
    } catch (_) {}

    // 2. Firebase Cache
    try {
      final cached = await _firebaseCache.getCachedVideos(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        if (mounted) {
          setState(() {
            _searchResults = cached;
            _isSearching = false;
          });
        }
        return;
      }
    } catch (_) {}

    // 3. Official YouTube API
    if (YouTubeOfficialApiService.apiKey != null && YouTubeOfficialApiService.apiKey!.isNotEmpty) {
      try {
        final apiResults = await _officialApiService.fetchFromOfficialApi(trimmed, "Search", "English");
        if (apiResults.isNotEmpty) {
          _firebaseCache.saveCachedVideos(cacheKey, apiResults);
          if (mounted) {
            setState(() {
              _searchResults = apiResults;
              _isSearching = false;
            });
          }
          return;
        }
      } catch (_) {}
    }

    // 4. Offline Curated Fallback (Offline Mode)
    final qLower = trimmed.toLowerCase();
    final offlineMatches = <Map<String, String>>[];
    for (final v in YouTubeRepository.topicVideos.values.expand((e) => e)) {
      final title = (v['title'] ?? '').toLowerCase();
      final channel = (v['channel'] ?? '').toLowerCase();
      final cat = (v['category'] ?? '').toLowerCase();
      if (title.contains(qLower) || channel.contains(qLower) || cat.contains(qLower)) {
        if (!offlineMatches.any((m) => m['videoId'] == v['videoId'])) {
          offlineMatches.add(v);
        }
      }
    }

    if (mounted) {
      setState(() {
        _searchResults = offlineMatches;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      color: bgColor,
      child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input Field
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: textColor, fontSize: 15),
                textInputAction: TextInputAction.search,
                onSubmitted: _performSearch,
                decoration: InputDecoration(
                  hintText: 'Search focus tutorials, courses & soundscapes...',
                  hintStyle: TextStyle(color: subTextColor, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF3B82F6)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: subTextColor),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchResults = [];
                              _hasSearched = false;
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (val) => setState(() {}),
              ),
            ),
            const SizedBox(height: 16),

            // Discovery & Recent Searches (When not actively showing search results)
            if (!_hasSearched) ...[
              if (_recentSearches.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "RECENT SEARCHES",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: subTextColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _recentSearches.clear()),
                      child: const Text("Clear All", style: TextStyle(fontSize: 12, color: Color(0xFFEF4444))),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _recentSearches.map((term) {
                    return ActionChip(
                      label: Text(term, style: TextStyle(color: textColor, fontSize: 13)),
                      avatar: const Icon(Icons.history, size: 16, color: Color(0xFF3B82F6)),
                      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onPressed: () {
                        _searchController.text = term;
                        _performSearch(term);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Trending Topics
              Row(
                children: [
                  const Icon(Icons.whatshot, size: 18, color: Color(0xFFFF6B35)),
                  const SizedBox(width: 8),
                  Text(
                    "TRENDING TOPICS",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: subTextColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  "Kotlin Tutorial",
                  "Python Masterclass",
                  "Machine Learning",
                  "Quantum Physics",
                  "System Design",
                  "Mindfulness & Focus"
                ].map((term) {
                  return ActionChip(
                    label: Text(term, style: TextStyle(color: textColor, fontSize: 13)),
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onPressed: () {
                      _searchController.text = term;
                      _performSearch(term);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Content Area (Searching Indicator, Results, or Empty State)
            Expanded(
              child: _isSearching
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF3B82F6)),
                          SizedBox(height: 16),
                          Text("Scraping educational videos...", style: TextStyle(color: Color(0xFF94A3B8))),
                        ],
                      ),
                    )
                  : _hasSearched && _searchResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off_rounded, size: 64, color: Color(0xFF64748B)),
                              const SizedBox(height: 12),
                              Text(
                                "No educational videos found for '${_searchController.text}'",
                                style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Try searching for broader terms like 'python tutorial' or 'physics lecture'",
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final video = _searchResults[index];
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => VideoPlayerScreen(
                                    videoId: video['videoId'] ?? '',
                                    title: video['title'] ?? 'Educational Video',
                                    channel: video['channel'] ?? 'YouTube Creator',
                                    thumbnail: video['thumbnail'] ?? '',
                                    category: 'Search',
                                  ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                          child: Image.network(
                                            video['thumbnail'] ?? '',
                                            height: 190,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              height: 190,
                                              color: Colors.blueGrey,
                                              child: const Center(child: Icon(Icons.video_library, size: 48, color: Colors.white)),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 10,
                                          right: 10,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.85),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              video['duration'] ?? '10:00',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor: const Color(0xFF3B82F6),
                                            child: Text(
                                              (video['channel'] ?? 'Y').substring(0, 1).toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  video['title'] ?? '',
                                                  style: TextStyle(
                                                    fontSize: 14.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: textColor,
                                                    height: 1.25,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  video['channel'] ?? 'YouTube Creator',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: subTextColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
