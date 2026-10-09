import 'package:flutter/material.dart';
import '../data/repository/history_repository.dart';
import 'video_player_screen.dart';

class HistoryScreen extends StatefulWidget {
  final bool isDarkMode;

  const HistoryScreen({super.key, required this.isDarkMode});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isYouTubeExpanded = false;

  void _removeItem(String id) {
    HistoryRepository().removeItem(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Removed from watch history"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearAllHistory() {
    HistoryRepository().clearAll();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Watch history cleared"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bgColor = isDark ? const Color(0xFF0B1120) : const Color(0xFFF1F5F9);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return ValueListenableBuilder<List<WatchHistoryItem>>(
      valueListenable: HistoryRepository().historyNotifier,
      builder: (context, allHistoryItems, child) {
        final youtubeHistory = allHistoryItems.where((item) => item.platform.toLowerCase() == 'youtube').toList();
        final vimeoHistory = allHistoryItems.where((item) => item.platform.toLowerCase() == 'vimeo').toList();
        final totalVideos = allHistoryItems.length;

        return Container(
          color: bgColor,
          child: SafeArea(
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                "Watch History",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6B46C1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                "$totalVideos videos",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert_rounded, color: textColor),
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        onSelected: (value) {
                          if (value == 'clear') {
                            _clearAllHistory();
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'clear',
                            child: Row(
                              children: [
                                const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  "Clear All History",
                                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // ── YOUTUBE SECTION ─────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.red,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "YouTube Videos",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "(${youtubeHistory.length})",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: subTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (youtubeHistory.isNotEmpty) ...[
                          if (_isYouTubeExpanded)
                            // Expanded view
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.85,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                itemCount: youtubeHistory.length,
                                itemBuilder: (context, index) {
                                  return _buildVideoCard(youtubeHistory[index], cardBg, textColor, subTextColor);
                                },
                              ),
                            )
                          else
                            // Horizontal scrollable carousel
                            SizedBox(
                              height: 195,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                itemCount: youtubeHistory.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 210,
                                    margin: const EdgeInsets.only(right: 12.0),
                                    child: _buildVideoCard(youtubeHistory[index], cardBg, textColor, subTextColor),
                                  );
                                },
                              ),
                            ),

                          const SizedBox(height: 12),
                          Center(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _isYouTubeExpanded = !_isYouTubeExpanded;
                                });
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _isYouTubeExpanded ? "Show Less" : "View All",
                                      style: const TextStyle(
                                        color: Color(0xFF22C55E),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      _isYouTubeExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                      color: const Color(0xFF22C55E),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ] else
                          _buildEmptySection("YouTube Videos", Colors.red, cardBg, textColor, subTextColor),

                        const SizedBox(height: 24),

                        // ── VIMEO SECTION ──────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF06B6D4).withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_circle_outline,
                                  color: Color(0xFF06B6D4),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Vimeo Videos",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (vimeoHistory.isNotEmpty)
                          SizedBox(
                            height: 195,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              itemCount: vimeoHistory.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 210,
                                  margin: const EdgeInsets.only(right: 12.0),
                                  child: _buildVideoCard(vimeoHistory[index], cardBg, textColor, subTextColor),
                                );
                              },
                            ),
                          )
                        else
                          _buildEmptySection("Vimeo Videos", const Color(0xFF06B6D4), cardBg, textColor, subTextColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoCard(WatchHistoryItem item, Color cardBg, Color textColor, Color subTextColor) {
    final percentStr = "${(item.progress * 100).toInt()}%";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoPlayerScreen(
              videoId: item.videoId,
              title: item.title,
              channel: item.channel,
              thumbnail: item.thumbnail,
              category: 'History',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Stack
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    item.thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.blueGrey.shade800,
                      child: const Center(
                        child: Icon(Icons.play_circle_fill, color: Colors.white, size: 36),
                      ),
                    ),
                  ),
                ),
                // Platform Badge Top-Left
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.54),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.platform == 'youtube' ? Icons.play_arrow_rounded : Icons.play_circle_outline,
                      color: item.platform == 'youtube' ? Colors.red : const Color(0xFF06B6D4),
                      size: 12,
                    ),
                  ),
                ),
                // Delete X Top-Right
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () {
                      _removeItem(item.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.watchedTimeStr,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF22C55E),
                              ),
                            ),
                            Text(
                              percentStr,
                              style: TextStyle(
                                fontSize: 10,
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: item.progress,
                            minHeight: 3,
                            backgroundColor: widget.isDarkMode ? const Color(0xFF334155) : Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySection(String title, Color iconColor, Color cardBg, Color textColor, Color subTextColor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: cardBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.isDarkMode ? const Color(0xFF1E293B) : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.video_library_outlined,
              size: 32,
              color: subTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "No videos found yet",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: subTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

