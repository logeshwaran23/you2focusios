import 'package:flutter/material.dart';
import 'video_player_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final bool isDarkMode;

  const FavoritesScreen({super.key, required this.isDarkMode});

  static final List<Map<String, String>> favoriteVideos = [
    {
      "videoId": "fav1",
      "title": "Flutter & Dart Full Course - Build iOS & Android Apps",
      "channel": "You2Focus Engineering",
      "thumbnail": "https://img.youtube.com/vi/1gDhl4leEzA/hqdefault.jpg",
      "duration": "45:00",
    },
    {
      "videoId": "fav2",
      "title": "System Design Masterclass: Microservices & Cloud",
      "channel": "Tech Academy",
      "thumbnail": "https://img.youtube.com/vi/SqcY0GlETPk/hqdefault.jpg",
      "duration": "1:15:30",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode;
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
              Row(
                children: [
                  const Icon(Icons.favorite_rounded, color: Color(0xFFEF4444), size: 28),
                  const SizedBox(width: 10),
                  Text(
                    "Saved Favorites",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "Access your bookmarked educational lectures offline anytime.",
                style: TextStyle(fontSize: 13, color: subTextColor),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: favoriteVideos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.favorite_border_rounded, size: 64, color: Color(0xFF64748B)),
                            const SizedBox(height: 12),
                            Text("No Favorites Saved Yet", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text("Tap the heart icon on any video to bookmark it here.", style: TextStyle(color: subTextColor, fontSize: 13)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: favoriteVideos.length,
                        itemBuilder: (context, index) {
                          final video = favoriteVideos[index];
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VideoPlayerScreen(
                                    videoId: video['videoId'] ?? '',
                                    title: video['title'] ?? 'Educational Video',
                                    channel: video['channel'] ?? 'Educational Channel',
                                    thumbnail: video['thumbnail'] ?? '',
                                    category: 'Favorites',
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                        child: Image.network(
                                          video['thumbnail']!,
                                          height: 180,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            height: 180,
                                            color: Colors.blueGrey,
                                            child: const Center(child: Icon(Icons.video_library, size: 48, color: Colors.white)),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.black.withValues(alpha: 0.7),
                                          child: const Icon(Icons.favorite, color: Color(0xFFEF4444), size: 20),
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
                                            video['duration']!,
                                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: const Color(0xFFEF4444),
                                          child: Text(
                                            video['channel']!.substring(0, 1),
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                video['title']!,
                                                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: textColor, height: 1.25),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(video['channel']!, style: TextStyle(fontSize: 12, color: subTextColor)),
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
