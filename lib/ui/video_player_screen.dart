import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:share_plus/share_plus.dart';
import '../data/repository/history_repository.dart';
import '../data/repository/streak_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  final String title;
  final String channel;
  final String thumbnail;
  final String category;

  const VideoPlayerScreen({
    super.key,
    required this.videoId,
    required this.title,
    this.channel = "Educational Channel",
    this.thumbnail = "",
    this.category = "Education",
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final WebViewController _webViewController;
  Timer? _timer;
  int _elapsedSeconds = 0;
  
  bool _isFavorite = false;
  bool _isProFocusActive = false;
  final TextEditingController _noteInputController = TextEditingController();
  final List<Map<String, String>> _notesList = [];
  String _currentTimeString = "0:00";

  bool get _isVimeoVideo {
    final id = widget.videoId.trim().toLowerCase();
    final thumb = widget.thumbnail.trim().toLowerCase();
    final channel = widget.channel.trim().toLowerCase();
    
    if (id.contains('vimeo') || thumb.contains('vimeo') || thumb.contains('vumbnail') || channel.contains('vimeo')) {
      return true;
    }
    
    final hasDigitsOnly = RegExp(r'^\d+$').hasMatch(id);
    final hasSlashDigits = RegExp(r'(/videos/)?\d+').hasMatch(id);
    
    if (hasDigitsOnly || hasSlashDigits) {
      final isYouTubeFormat = RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(id) && !hasDigitsOnly;
      if (!isYouTubeFormat) {
        return true;
      }
    }

    return false;
  }

  String get _cleanVimeoId {
    final id = widget.videoId.trim();
    final digitMatch = RegExp(r'(\d{6,12})').firstMatch(id);
    if (digitMatch != null) return digitMatch.group(1)!;
    final thumbMatch = RegExp(r'(\d{6,12})').firstMatch(widget.thumbnail);
    if (thumbMatch != null) return thumbMatch.group(1)!;
    return '76979871';
  }

  String get _cleanYoutubeId {
    final raw = widget.videoId.trim();
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(raw)) return raw;

    final urlRegex = RegExp(
      r'(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=))([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final match = urlRegex.firstMatch(raw);
    if (match != null && match.group(1) != null) return match.group(1)!;

    final vMatch = RegExp(r'v=([a-zA-Z0-9_-]{11})').firstMatch(raw);
    if (vMatch != null && vMatch.group(1) != null) return vMatch.group(1)!;

    final thumbMatch = RegExp(r'vi\/([a-zA-Z0-9_-]{11})').firstMatch(widget.thumbnail);
    if (thumbMatch != null && thumbMatch.group(1) != null) return thumbMatch.group(1)!;

    final genericMatch = RegExp(r'(?<!https?:\/\/[\w\.\/]*)([a-zA-Z0-9_-]{11})').firstMatch(raw);
    if (genericMatch != null && genericMatch.group(1) != null) return genericMatch.group(1)!;

    return '1gDhl4leEzA';
  }

  String _buildUniversalPlayerHtml({required bool isVimeo, required String targetId}) {
    if (isVimeo) {
      return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { width: 100%; height: 100%; background: #000; overflow: hidden; }
    .video-wrap { position: fixed; top: 0; left: 0; right: 0; bottom: 0; width: 100%; height: 100%; }
    iframe { width: 100%; height: 100%; border: 0; display: block; }
  </style>
</head>
<body>
  <div class="video-wrap">
    <iframe
      src="https://player.vimeo.com/video/$targetId?autoplay=1&muted=0&playsinline=1&title=0&byline=0&portrait=0&loop=0&color=38bdf8"
      allow="autoplay; fullscreen; picture-in-picture; encrypted-media"
      allowfullscreen
      playsinline
      webkit-playsinline>
    </iframe>
  </div>
</body>
</html>
''';
    } else {
      return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { width: 100%; height: 100%; background: #000; overflow: hidden; }
    .video-wrap { position: fixed; top: 0; left: 0; right: 0; bottom: 0; width: 100%; height: 100%; }
    iframe { width: 100%; height: 100%; border: 0; display: block; }
  </style>
</head>
<body>
  <div class="video-wrap">
    <iframe
      id="ytplayer"
      src="https://www.youtube-nocookie.com/embed/$targetId?autoplay=1&playsinline=1&rel=0&modestbranding=1&enablejsapi=1&iv_load_policy=3"
      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share; fullscreen"
      allowfullscreen
      playsinline
      webkit-playsinline>
    </iframe>
  </div>
</body>
</html>
''';
    }
  }

  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final isV = _isVimeoVideo;
    final targetId = isV ? _cleanVimeoId : _cleanYoutubeId;
    final baseUrl = isV ? 'https://player.vimeo.com' : 'https://www.youtube-nocookie.com';

    _webViewController = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {},
          onPageFinished: (_) {},
          onWebResourceError: (error) {
            debugPrint("Player WebView Error: \${error.description}");
          },
          onNavigationRequest: (request) {
            final url = request.url.toLowerCase();
            if (url.contains('youtube') ||
                url.contains('youtu.be') ||
                url.contains('vimeo') ||
                url.contains('vimeocdn') ||
                url.contains('ytimg') ||
                url.contains('googlevideo') ||
                url.contains('google') ||
                url.contains('gstatic') ||
                url.contains('doubleclick') ||
                url.startsWith('about:') ||
                url.startsWith('data:') ||
                url.startsWith('blob:')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadHtmlString(_buildUniversalPlayerHtml(isVimeo: isV, targetId: targetId), baseUrl: baseUrl);

    // Register video in Watch History
    final platform = isV ? 'vimeo' : 'youtube';
    HistoryRepository().addOrUpdateHistory(
      videoId: targetId,
      title: widget.title,
      channel: widget.channel,
      thumbnail: widget.thumbnail,
      platform: platform,
    );

    // Maintain continuous daily streak for watching educational content
    StreakService.recordActivity();

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!mounted) return;
      _elapsedSeconds++;
      final formatted = _formatSeconds(_elapsedSeconds);
      if (formatted != _currentTimeString) {
        setState(() {
          _currentTimeString = formatted;
        });
        final targetId = _isVimeoVideo ? _cleanVimeoId : _cleanYoutubeId;
        HistoryRepository().updateProgress(
          targetId,
          _elapsedSeconds / 600.0,
          formatted,
        );
      }
    });
  }

  String _formatSeconds(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "$m:${s.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    _noteInputController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final noteText = _noteInputController.text.trim();
    if (noteText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please type a note before saving!'),
          backgroundColor: Color(0xFFEF4444),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _notesList.insert(0, {
        "time": _currentTimeString,
        "text": noteText,
      });
      _noteInputController.clear();
    });

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Note saved at $_currentTimeString!'),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  int _userCoins = 1445;
  bool _isTakeawaysUnlocked = false;

  void _showTakeawaysSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        bool isAdPlaying = false;
        int adSeconds = 3;
        Timer? adTimer;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            if (isAdPlaying) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.ondemand_video_rounded, color: Color(0xFF10B981), size: 54),
                    const SizedBox(height: 16),
                    Text(
                      "Watching Rewarded Video Ad",
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: titleColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Unlocking takeaways in $adSeconds seconds...",
                      style: TextStyle(color: subtitleColor, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (4 - adSeconds) / 3,
                        backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        color: const Color(0xFF10B981),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (!_isTakeawaysUnlocked) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pill handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      "Unlock Top 3 Takeaways",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: titleColor),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "You have $_userCoins FocusCoins",
                      style: TextStyle(fontSize: 14, color: subtitleColor, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 24),

                    // Button 1: Watch Ad to Unlock
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          setSheetState(() {
                            isAdPlaying = true;
                            adSeconds = 3;
                          });
                          adTimer?.cancel();
                          adTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
                            if (adSeconds <= 1) {
                              timer.cancel();
                              setState(() {
                                _isTakeawaysUnlocked = true;
                              });
                              setSheetState(() {
                                isAdPlaying = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("📺 Ad Completed! Top 3 Takeaways Unlocked!"),
                                  backgroundColor: Color(0xFF10B981),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } else {
                              setSheetState(() {
                                adSeconds--;
                              });
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_circle_fill_rounded, size: 22),
                            SizedBox(width: 10),
                            Text(
                              "Watch Ad to Unlock",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Button 2: Use 40 coins
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_userCoins >= 40) {
                            setState(() {
                              _userCoins -= 40;
                              _isTakeawaysUnlocked = true;
                            });
                            setSheetState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("🪙 40 Coins Used! Remaining: $_userCoins FocusCoins"),
                                backgroundColor: const Color(0xFF10B981),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("❌ Not enough coins! You need 40 coins."),
                                backgroundColor: Color(0xFFEF4444),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.monetization_on_rounded, size: 22),
                            SizedBox(width: 10),
                            Text(
                              "Use 40 coins",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: subtitleColor, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Unlocked View - Exact User Screenshot Layout Format
            final takeaways = _generateTakeawaysForTitle(widget.title);
            final formattedTakeawaysText = takeaways.map((t) => "${t['num']}. ${t['title']}: ${t['desc']}").join("\n\n");

            final cardBg = isDark ? const Color(0xFF2E1065) : const Color(0xFFF3E8FF);
            final cardTitleColor = isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Header Badge: "Powered by AI"
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lightbulb_rounded, color: Color(0xFF0284C7), size: 16),
                          SizedBox(width: 6),
                          Text(
                            "Powered by AI",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Soft Purple Card (Exact match to user screenshot)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Title Row with Lightbulb Icon & Copy Action
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.lightbulb_rounded, color: Color(0xFF0284C7), size: 20),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "You2Focus Top 3 Takeaways",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: cardTitleColor,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: formattedTakeawaysText));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("✨ Copied Top 3 Takeaways to clipboard!"),
                                    backgroundColor: Color(0xFF10B981),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: Icon(Icons.copy_rounded, color: cardTitleColor, size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // 3 Takeaway Paragraphs
                        ...takeaways.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14.0),
                            child: Text(
                              "${item['num']}. ${item['title']}: ${item['desc']}",
                              style: TextStyle(
                                fontSize: 14.5,
                                height: 1.5,
                                color: isDark ? Colors.white.withValues(alpha: 0.95) : const Color(0xFF1E1B4B),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bottom Buttons Row: [ Regenerate (Outlined Green) ]   [ ← Done (Solid Green) ]
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setSheetState(() {
                                isAdPlaying = true;
                                adSeconds = 2;
                              });
                              adTimer?.cancel();
                              adTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
                                if (adSeconds <= 1) {
                                  timer.cancel();
                                  setSheetState(() {
                                    isAdPlaying = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("✨ Regenerated fresh Top 3 Takeaways!"),
                                      backgroundColor: Color(0xFF10B981),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                } else {
                                  setSheetState(() {
                                    adSeconds--;
                                  });
                                }
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF10B981),
                              side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text(
                              "Regenerate",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pop(sheetContext),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF22C55E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.arrow_back_rounded, size: 18),
                            label: const Text(
                              "Done",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Map<String, String>> _generateTakeawaysForTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('word') || lower.contains('english') || lower.contains('grammar') || lower.contains('vocabulary')) {
      return [
        {
          "num": "1",
          "title": "Master Core Vocabulary & Substitutions",
          "desc": "Memorize high-frequency single-word replacements for phrases commonly tested in English."
        },
        {
          "num": "2",
          "title": "Grammatical Precision & Usage",
          "desc": "Understand contextual nuances and formal rules required for accurate sentence structure."
        },
        {
          "num": "3",
          "title": "Rapid Exam Elimination Tactics",
          "desc": "Practice fast option-elimination strategies to maximize speed and score high accuracy."
        },
      ];
    } else if (lower.contains('ai') || lower.contains('python') || lower.contains('code') || lower.contains('tech') || lower.contains('data')) {
      return [
        {
          "num": "1",
          "title": "Core Architecture & Model Logic",
          "desc": "Grasp underlying data pipelines, algorithms, and computational flow."
        },
        {
          "num": "2",
          "title": "Hands-on Implementation & Debugging",
          "desc": "Write clean, modular code while effectively handling real-world runtime edge cases."
        },
        {
          "num": "3",
          "title": "Performance Optimization & Scaling",
          "desc": "Optimize execution speed, memory footprint, and production deployment efficiency."
        },
      ];
    } else if (lower.contains('science') || lower.contains('physics') || lower.contains('chemistry') || lower.contains('biology') || lower.contains('math')) {
      return [
        {
          "num": "1",
          "title": "Fundamental Laws & Scientific Principles",
          "desc": "Master essential theories, physical laws, and core scientific formulas."
        },
        {
          "num": "2",
          "title": "Systematic Analytical Problem Solving",
          "desc": "Break down complex multi-step numerical problems using step-by-step logic."
        },
        {
          "num": "3",
          "title": "High-Yield Memory Triggers & Exam Prep",
          "desc": "Focus on key diagrams, crucial equations, and frequently tested exam concepts."
        },
      ];
    } else {
      return [
        {
          "num": "1",
          "title": "Essential Core Concept Overview",
          "desc": "Fundamental principles, definitions, and main takeaways from this lesson."
        },
        {
          "num": "2",
          "title": "Practical Methodology & Action Plan",
          "desc": "Actionable step-by-step techniques for applying these principles effectively."
        },
        {
          "num": "3",
          "title": "Key Summary & Long-Term Mastery",
          "desc": "High-impact revision points designed for maximum retention and recall."
        },
      ];
    }
  }

  bool _isQuizUnlocked = false;

  void _showQuizSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFEDE8F5);
    final titleColor = isDark ? Colors.white : const Color(0xFF1E1B4B);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        bool isAdPlaying = false;
        int adSeconds = 3;
        Timer? adTimer;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            if (isAdPlaying) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.ondemand_video_rounded, color: Color(0xFF42B855), size: 54),
                    const SizedBox(height: 16),
                    Text(
                      "Watching Rewarded Video Ad",
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: titleColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Unlocking AI Quiz in $adSeconds seconds...",
                      style: TextStyle(color: subtitleColor, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (4 - adSeconds) / 3,
                        backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        color: const Color(0xFF42B855),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Locked Screen - Matches User's Screenshot UI 100%
            if (!_isQuizUnlocked) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle Bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      "Unlock AI Quiz",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Subtitle
                    Text(
                      "You have $_userCoins coins",
                      style: TextStyle(
                        fontSize: 14,
                        color: subtitleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Button 1: Watch Ad to Unlock
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          setSheetState(() {
                            isAdPlaying = true;
                            adSeconds = 3;
                          });
                          adTimer?.cancel();
                          adTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
                            if (adSeconds <= 1) {
                              timer.cancel();
                              setState(() {
                                _isQuizUnlocked = true;
                              });
                              setSheetState(() {
                                isAdPlaying = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("📺 Ad Completed! AI Quiz Unlocked!"),
                                  backgroundColor: Color(0xFF42B855),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } else {
                              setSheetState(() {
                                adSeconds--;
                              });
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF42B855),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Watch Ad to Unlock",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Button 2: Use 25 coins
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_userCoins >= 25) {
                            setState(() {
                              _userCoins -= 25;
                              _isQuizUnlocked = true;
                            });
                            setSheetState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("🪙 25 Coins Used! Remaining: $_userCoins FocusCoins"),
                                backgroundColor: const Color(0xFF42B855),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("❌ Not enough coins! You need 25 coins."),
                                backgroundColor: Color(0xFFEF4444),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF42B855),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Use 25 coins",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cancel Button
                    TextButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Color(0xFF42B855),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Unlocked Interactive 5-Question Quiz View
            int currentQIndex = 0;
            List<int?> selectedAnswers = List.filled(5, null);
            List<bool> submittedQuestions = List.filled(5, false);
            int correctCount = 0;
            bool isQuizCompleted = false;

            final List<Map<String, dynamic>> quizQuestions = [
              {
                "question": "Q1: What is the primary objective of structured learning in '${widget.title}'?",
                "options": [
                  "A) Core Theory & Conceptual Principles",
                  "B) Passive background listening without notes",
                  "C) Unfocused random video streaming",
                  "D) Skipping foundational concepts"
                ],
                "correctIndex": 0,
                "explanation": "Structured learning focuses on core theory & conceptual principles for mastery."
              },
              {
                "question": "Q2: How does note-taking during video playback improve retention?",
                "options": [
                  "A) Reduces attention span",
                  "B) Reinforces active recall and key timestamps",
                  "C) Has no effect on memory retention",
                  "D) Distracts from key lecture content"
                ],
                "correctIndex": 1,
                "explanation": "Timestamped note-taking activates dual-coding and active recall memory pathways."
              },
              {
                "question": "Q3: What is the main benefit of distraction-free study mode?",
                "options": [
                  "A) To force video fast-forwarding",
                  "B) To eliminate digital distractions and increase focus depth",
                  "C) To hide video playback completely",
                  "D) To limit total daily app usage"
                ],
                "correctIndex": 1,
                "explanation": "Distraction-free mode eliminates UI noise and establishes dedicated study Sprints."
              },
              {
                "question": "Q4: Which strategy is recommended for mastering advanced topics?",
                "options": [
                  "A) Jump directly to advanced without prerequisite knowledge",
                  "B) Complete recommended prerequisite modules before advanced topics",
                  "C) Avoid practicing exam-style problems",
                  "D) Read transcripts without watching videos"
                ],
                "correctIndex": 1,
                "explanation": "Sequential learning via recommended prerequisite paths guarantees deep comprehension."
              },
              {
                "question": "Q5: How are FocusCoins earned within You2Focus?",
                "options": [
                  "A) Completing study sessions & scoring correctly on AI quizzes",
                  "B) Closing the app immediately after launch",
                  "C) Leaving videos paused indefinitely",
                  "D) Purchasing non-educational items"
                ],
                "correctIndex": 0,
                "explanation": "FocusCoins reward consistent learning, focus session completion, and quiz accuracy!"
              },
            ];

            return StatefulBuilder(
              builder: (context, setQuizState) {
                if (isQuizCompleted) {
                  final String headerEmoji = correctCount >= 4 ? "🎉" : (correctCount >= 2 ? "👍" : "💪");
                  final String headerTitle = correctCount >= 4 ? "Outstanding!" : (correctCount >= 2 ? "Good Job!" : "Nice Effort!");

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B1C2A),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                            blurRadius: 16,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(headerEmoji, style: const TextStyle(fontSize: 56)),
                          const SizedBox(height: 12),
                          Text(
                            headerTitle,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "You got $correctCount/5 correct",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("🪙 ", style: TextStyle(fontSize: 16)),
                              Text(
                                "+${correctCount * 5} coins earned!",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(sheetContext),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD700),
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                "Awesome! 🎉",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final currentQ = quizQuestions[currentQIndex];
                final String qTitle = currentQ["question"] as String;
                final List<String> qOptions = List<String>.from(currentQ["options"]);
                final int correctIdx = currentQ["correctIndex"] as int;
                final String explanation = currentQ["explanation"] as String;

                final int? selectedOpt = selectedAnswers[currentQIndex];
                final bool isSubmitted = submittedQuestions[currentQIndex];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.quiz_rounded, color: Color(0xFF42B855), size: 26),
                              const SizedBox(width: 8),
                              Text(
                                "AI Quiz (Q${currentQIndex + 1} of 5)",
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF42B855)),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isQuizUnlocked = false;
                              });
                              setSheetState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.lock_outline_rounded, size: 14, color: subtitleColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Lock",
                                    style: TextStyle(fontSize: 12, color: subtitleColor, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Progress Bar (1 to 5)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (currentQIndex + 1) / 5,
                          backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          color: const Color(0xFF42B855),
                          minHeight: 6,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        qTitle,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: titleColor, height: 1.3),
                      ),
                      const SizedBox(height: 14),

                      ...qOptions.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final text = entry.value;
                        final isSelected = selectedOpt == idx;
                        final isCorrect = idx == correctIdx;

                        Color btnBg = isDark ? const Color(0xFF0F172A) : Colors.white;
                        Color borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);

                        if (isSubmitted) {
                          if (isCorrect) {
                            btnBg = const Color(0xFF10B981).withValues(alpha: 0.15);
                            borderCol = const Color(0xFF10B981);
                          } else if (isSelected && !isCorrect) {
                            btnBg = const Color(0xFFEF4444).withValues(alpha: 0.15);
                            borderCol = const Color(0xFFEF4444);
                          }
                        } else if (isSelected) {
                          borderCol = const Color(0xFF42B855);
                          btnBg = const Color(0xFF42B855).withValues(alpha: 0.1);
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: OutlinedButton(
                            onPressed: isSubmitted
                                ? null
                                : () {
                                    setQuizState(() {
                                      selectedAnswers[currentQIndex] = idx;
                                    });
                                  },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: btnBg,
                              side: BorderSide(color: borderCol, width: isSelected ? 2 : 1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                              alignment: Alignment.centerLeft,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? (isSubmitted
                                          ? (isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded)
                                          : Icons.radio_button_checked_rounded)
                                      : Icons.radio_button_off_rounded,
                                  color: borderCol,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    text,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                      color: titleColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      if (isSubmitted) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("💡 ", style: TextStyle(fontSize: 14)),
                              Expanded(
                                child: Text(
                                  explanation,
                                  style: TextStyle(fontSize: 12.5, color: subtitleColor, height: 1.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: selectedOpt == null
                              ? null
                              : () {
                                  if (!isSubmitted) {
                                    setQuizState(() {
                                      submittedQuestions[currentQIndex] = true;
                                      if (selectedOpt == correctIdx) {
                                        correctCount++;
                                        setState(() {
                                          _userCoins += 5;
                                        });
                                      }
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(selectedOpt == correctIdx
                                            ? "🎉 Correct! +5 FocusCoins! (Total Coins: $_userCoins)"
                                            : "❌ Incorrect answer."),
                                        backgroundColor: selectedOpt == correctIdx
                                            ? const Color(0xFF42B855)
                                            : const Color(0xFFEF4444),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  } else {
                                    if (currentQIndex < 4) {
                                      setQuizState(() {
                                        currentQIndex++;
                                      });
                                    } else {
                                      setQuizState(() {
                                        isQuizCompleted = true;
                                      });
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF42B855),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: Text(
                            !isSubmitted
                                ? "Submit Answer"
                                : (currentQIndex < 4 ? "Next Question (Q${currentQIndex + 2} →)" : "Finish Quiz 🏆"),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  int _proFocusRemainingSeconds = 0;
  Timer? _proFocusTimer;
  int _selectedProFocusDurationMinutes = 25;

  String _formatTimerCountdown(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  void _startProFocusTimer(int durationMinutes) {
    _proFocusTimer?.cancel();
    setState(() {
      _isProFocusActive = true;
      _selectedProFocusDurationMinutes = durationMinutes;
      _proFocusRemainingSeconds = durationMinutes * 60;
    });

    _proFocusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_proFocusRemainingSeconds > 1) {
        setState(() {
          _proFocusRemainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isProFocusActive = false;
          _proFocusRemainingSeconds = 0;
        });
        try {
          _webViewController.runJavaScript("document.querySelector('video')?.pause();");
        } catch (_) {}
        setState(() {
          _userCoins += 10;
        });
        _showProFocusRewardDialog();
      }
    });
  }

  void _stopProFocusTimer() {
    _proFocusTimer?.cancel();
    setState(() {
      _isProFocusActive = false;
      _proFocusRemainingSeconds = 0;
    });
  }

  void _showProFocusDialog() {
    if (_isProFocusActive) {
      _showProFocusExitConfirmDialog();
    } else {
      _showProFocusSetupDialog();
    }
  }

  void _showProFocusSetupDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        int tempDuration = _selectedProFocusDurationMinutes;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF14142B),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFF8E2DE2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8E2DE2).withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row with Badge & Close Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8E2DE2).withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF8E2DE2), width: 1),
                                ),
                                child: const Text(
                                  "⚡ PRO FOCUS",
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFD4AF37),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Expanded(
                                child: Text(
                                  "Screen Lock Timer",
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                          onPressed: () => Navigator.pop(dialogContext),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Description Subtitle
                    const Text(
                      "Lock the player screen & immerse in study. Only Video & Notes will stay accessible. Video auto-pauses when timer ends.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Section Title
                    const Text(
                      "Select Focus Duration",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Duration Options Row (5, 10, 25 Mins)
                    Row(
                      children: [5, 10, 25].map((duration) {
                        final isSelected = tempDuration == duration;
                        final String subText = duration == 25 ? "Standard" : (duration == 10 ? "Quick" : "Sprint");
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                tempDuration = duration;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF8E2DE2) : const Color(0xFF222234),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFFFD700) : Colors.white.withValues(alpha: 0.12),
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF8E2DE2).withValues(alpha: 0.4),
                                          blurRadius: 8,
                                        )
                                      ]
                                    : [],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "$duration Mins",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                      color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    subText,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isSelected ? Colors.white.withValues(alpha: 0.85) : Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 28),

                    // Start Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8E2DE2).withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            _startProFocusTimer(tempDuration);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("🔒 Pro Focus Lock Timer Started ($tempDuration Mins)!"),
                                backgroundColor: const Color(0xFF8E2DE2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock_rounded, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Start Pro Focus ($tempDuration Mins)",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.5,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showProFocusExitConfirmDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 24),
              SizedBox(width: 8),
              Text(
                "Exit Pro Focus Mode?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
              ),
            ],
          ),
          content: const Text(
            "Your study timer is currently active. Exiting early will unlock the screen.",
            style: TextStyle(fontSize: 13.5, color: Colors.white70),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Keep Focusing", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _stopProFocusTimer();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Pro Focus Mode Stopped"),
                    backgroundColor: Color(0xFFEF4444),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Exit Lock Mode", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showProFocusRewardDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF14142B), Color(0xFF1F1F40)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.6), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("🏆", style: TextStyle(fontSize: 52)),
                const SizedBox(height: 8),
                const Text(
                  "Focus Master Reward!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Congratulations! You completed your focus session!",
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  "+10",
                  style: TextStyle(fontSize: 54, fontWeight: FontWeight.w900, color: Color(0xFFFFD700)),
                ),
                const Text(
                  "FocusCoins",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white70),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8E2DE2).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF8E2DE2)),
                  ),
                  child: const Text(
                    "⚡ Session Completed Successfully",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37), fontSize: 12.5),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      "Claim 10 Coins ✨",
                      style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 16),
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

  Widget _buildProFocusBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E2DE2).withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.lock, color: Color(0xFFFFD700), size: 20),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "⚡ PRO FOCUS ACTIVE",
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${_formatTimerCountdown(_proFocusRemainingSeconds)} remaining",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _showProFocusExitConfirmDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              "Unlock",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Navigation Bar (Back to Home Page) ─────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacementNamed(context, '/');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              "Back to Home",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── 1. Video Player Area with Overlays ────────────────────────
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      color: Colors.black,
                      child: WebViewWidget(controller: _webViewController),
                    ),
                  ),

                  // Top Left Back Button Overlay on Video Player Card
                  Positioned(
                    top: 12,
                    left: 12,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacementNamed(context, '/');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      ),
                    ),
                  ),

                  // Top Left AI Badge Overlay
                  Positioned(
                    top: 12,
                    left: 56,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            "AI",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Left Share Overlay
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _showShareSheet,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.share, color: Colors.white, size: 18),
                      ),
                    ),
                  ),

                  // Bottom Right Fullscreen Overlay
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.fullscreen, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),

              if (_isProFocusActive) _buildProFocusBanner(),

              const SizedBox(height: 16),

              // ── 2. Brand Header (You2Focus Logo + Green Title) ─────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/ic_app_logo.png',
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.grid_view_rounded, color: Color(0xFFFBBF24), size: 28),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "You2Focus",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF00E676),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── 3. Video Title & Copy Icon ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: widget.title));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Title copied to clipboard!')),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: const Icon(Icons.copy_rounded, color: Colors.grey, size: 20),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── 4. Action Row (Favorite, Share, You2Focus Takeaways, AI Quiz, Pro Focus) ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                      iconColor: _isFavorite ? const Color(0xFFEF4444) : textColor,
                      label: "Favorite",
                      textColor: textColor,
                      onTap: () {
                        setState(() => _isFavorite = !_isFavorite);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_isFavorite ? "❤️ Added to Favorites!" : "Removed from Favorites"),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),

                    _buildActionButton(
                      icon: Icons.share_outlined,
                      iconColor: textColor,
                      label: "Share",
                      textColor: textColor,
                      onTap: _showShareSheet,
                    ),

                    _buildActionButton(
                      icon: Icons.description_outlined,
                      iconColor: textColor,
                      label: "You2Focus\nTakeaways",
                      textColor: textColor,
                      onTap: _showTakeawaysSheet,
                    ),

                    _buildActionButton(
                      icon: Icons.quiz_outlined,
                      iconColor: textColor,
                      label: "AI Quiz",
                      textColor: textColor,
                      onTap: _showQuizSheet,
                    ),

                    _buildActionButton(
                      icon: Icons.self_improvement,
                      iconColor: _isProFocusActive ? const Color(0xFF8B5CF6) : textColor,
                      label: "Pro Focus",
                      textColor: textColor,
                      onTap: _showProFocusDialog,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── 5. Add New Note Section ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Add New Note",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Current time: $_currentTimeString",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),

                        // Vibrant Save Note Button
                        ElevatedButton.icon(
                          onPressed: _saveNote,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 2,
                          ),
                          icon: const Icon(Icons.save_rounded, size: 18),
                          label: const Text(
                            "Save Note",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteInputController,
                      style: TextStyle(color: textColor, fontSize: 14),
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _saveNote(),
                      decoration: InputDecoration(
                        hintText: 'What did you learn at $_currentTimeString?',
                        hintStyle: TextStyle(color: subTextColor, fontSize: 13),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Saved Notes Live Display List with Delete Functionality
              if (_notesList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SAVED NOTES (${_notesList.length})",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subTextColor, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 10),
                      ..._notesList.asMap().entries.map((entry) {
                        final index = entry.key;
                        final note = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  note['time']!,
                                  style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  note['text']!,
                                  style: TextStyle(color: textColor, fontSize: 13, height: 1.3),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _notesList.removeAt(index);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('🗑️ Note deleted'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

              if (!_isProFocusActive) ...[
                const SizedBox(height: 20),
                _buildRecommendedLearningPath(),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedLearningPath() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final List<Map<String, String>> recommendedVideos = [
      {
        "id": "1gDhl4leEzA",
        "badge": "⏮ PREREQUISITE",
        "badgeColor": "0xFF10B981",
        "title": "Complete Beginner's Guide to Getting into Study",
        "channel": "Deep Dive With Ian",
        "duration": "12:45",
        "thumb": "https://img.youtube.com/vi/1gDhl4leEzA/hqdefault.jpg",
      },
      {
        "id": "3JZ_D3ELwOQ",
        "badge": "⏭ ADVANCED",
        "badgeColor": "0xFF8B5CF6",
        "title": "DataWeave 2.0 Advanced Masterclass & Architecture",
        "channel": "ShubhCode | Salesforce & Tech",
        "duration": "13:26",
        "thumb": "https://img.youtube.com/vi/3JZ_D3ELwOQ/hqdefault.jpg",
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("🎓 ", style: TextStyle(fontSize: 16)),
              Text(
                "Recommended Learning Path",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: recommendedVideos.map((video) {
              final badgeColorInt = int.parse(video['badgeColor']!);
              final color = Color(badgeColorInt);
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoPlayerScreen(
                          videoId: video['id']!,
                          title: video['title']!,
                          channel: video['channel']!,
                          thumbnail: video['thumb'] ?? '',
                          category: 'Recommended',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: color.withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            video['badge']!,
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Video Thumbnail with duration badge
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Image.network(
                                  video['thumb']!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: Colors.black26,
                                    child: const Icon(Icons.play_circle_fill, color: Colors.white54, size: 30),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  video['duration']!,
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Title
                        Text(
                          video['title']!,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Channel
                        Text(
                          video['channel']!,
                          style: TextStyle(
                            fontSize: 11,
                            color: subTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _shareContent(BuildContext context, String shareText, {String? subject}) {
    try {
      final box = context.findRenderObject() as RenderBox?;
      final Rect? origin = box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;

      Share.share(
        shareText,
        subject: subject,
        sharePositionOrigin: origin,
      );
    } catch (e) {
      debugPrint("Share error: $e");
      Clipboard.setData(ClipboardData(text: shareText));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📋 Link copied to clipboard!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  void _showShareSheet() {
    final shareText = "You2Focus • ${widget.title}\nShared via You2Focus\nhttps://you2focus.app/v/${widget.videoId}";

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                "Sharing text",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 16),

              // Preview Card Container (Matching User's Screenshot UI)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "You2Focus • ${widget.title}",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: titleColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Shared via You2Focus",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: subtitleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, color: Color(0xFF3B82F6)),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: shareText));
                            Navigator.pop(sheetContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ Video link & info copied to clipboard!'),
                                backgroundColor: Color(0xFF10B981),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.video_library_rounded, size: 18, color: Color(0xFF3B82F6)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 13,
                              color: titleColor,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Share Targets Section
              Text(
                "Share via",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildShareAppTarget(
                    icon: Icons.share_rounded,
                    label: "System Share",
                    color: const Color(0xFF3B82F6),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _shareContent(context, shareText, subject: "You2Focus • ${widget.title}");
                    },
                  ),
                  _buildShareAppTarget(
                    icon: Icons.chat_bubble_rounded,
                    label: "Messages",
                    color: const Color(0xFF10B981),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _shareContent(context, shareText);
                    },
                  ),
                  _buildShareAppTarget(
                    icon: Icons.email_rounded,
                    label: "Email",
                    color: const Color(0xFFEF4444),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _shareContent(context, shareText, subject: "You2Focus Video");
                    },
                  ),
                  _buildShareAppTarget(
                    icon: Icons.copy_rounded,
                    label: "Copy Link",
                    color: const Color(0xFF8B5CF6),
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: shareText));
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📋 Link copied to clipboard!'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareAppTarget({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _RewardedAdDialog extends StatefulWidget {
  final VoidCallback onFinished;
  const _RewardedAdDialog({required this.onFinished});

  @override
  State<_RewardedAdDialog> createState() => _RewardedAdDialogState();
}

class _RewardedAdDialogState extends State<_RewardedAdDialog> {
  int _secondsLeft = 3;
  Timer? _adTimer;

  @override
  void initState() {
    super.initState();
    _adTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        widget.onFinished();
      } else {
        if (mounted) {
          setState(() {
            _secondsLeft--;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.ondemand_video_rounded, color: Color(0xFF10B981), size: 48),
            const SizedBox(height: 12),
            const Text(
              "Watching Rewarded Video Ad",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              "Reward unlocks in $_secondsLeft second${_secondsLeft == 1 ? '' : 's'}...",
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (4 - _secondsLeft) / 3,
                backgroundColor: const Color(0xFF334155),
                color: const Color(0xFF10B981),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
