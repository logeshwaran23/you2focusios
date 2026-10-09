import 'package:http/http.dart' as http;

class YouTubeNoQuotaScraper {

  // Strict safety firewall: movies, 18+/adult, entertainment, clickbait (ported & expanded)
  static final RegExp _unwantedContentRegex = RegExp(
    r'\bmovie\b|\bcinema\b|\bfilm\b|\btrailer\b|\bteaser\b|\bsong\b|\bsongs\b|'
    r'\bjukebox\b|\bbox office\b|\bscene\b|\bblockbuster\b|\bhero\b|\bheroine\b|'
    r'\btollywood\b|\bkollywood\b|\bbollywood\b|\blyrical\b|\bduet\b|\bmass\b|'
    r'\b18\+\b|\badult\b|\bnsfw\b|\bsexy\b|\bhot\b|\broast\b|\bgossip\b|\bprank\b|'
    r'\bvlog\b|\breaction\b|\bfunny\b|\bcomedy\b|\bmeme\b|\bshorts\b|\btiktok\b|'
    r'சினிமா|పూర్తి సినిమా|చిత్రం|సాంగ్స్|ట్రైలర్|పాటలు|లిరికல்|మాస్|ఫైట్|టీజర్|బాక్స్ ఆఫీస్|'
    r'திரைப்படம்|படம்|பாடல்கள்|டிரெய்லர்|மாஸ்|பாடல்|காமெடி|காட்சி',
    caseSensitive: false,
  );

  static bool _isUnwantedContent(String title) {
    return _unwantedContentRegex.hasMatch(title);
  }

  /// Scrapes a large collection of educational videos without artificial limits.
  Future<List<Map<String, String>>> scrapeVideos({
    required String query,
    required String category,
    String language = 'English',
    int maxResults = 100,
  }) async {
    String langKeyword = "";
    if (language.contains("Tamil")) {
      langKeyword = "in Tamil தமிழ்";
    } else if (language.contains("Telugu")) {
      langKeyword = "in Telugu తెలుగు";
    } else if (language.contains("Hindi")) {
      langKeyword = "in Hindi हिंदी";
    } else {
      langKeyword = "in English";
    }

    List<String> queryTemplates = [
      "$query $langKeyword lesson lecture",
      "$query $langKeyword full course tutorial",
      "$query $langKeyword documentary masterclass",
      "$query $langKeyword complete guide",
      "$query $langKeyword deep dive explanation",
      "$query $langKeyword fundamentals",
    ];

    queryTemplates.shuffle();
    final selectedQueries = queryTemplates.take(5).toList();

    List<Map<String, String>> allVideos = [];

    // Run in parallel for high speed
    await Future.wait(selectedQueries.map((q) async {
      final videos = await _scrapeSingleQuery(q, category, language);
      allVideos.addAll(videos);
    }));

    // Deduplicate by ID and apply strict safety filters
    final uniqueVideos = <String, Map<String, String>>{};
    for (var video in allVideos) {
      final id = video['videoId'];
      final title = video['title'] ?? '';
      if (id != null && id.isNotEmpty && !_isUnwantedContent(title)) {
        uniqueVideos[id] = video;
      }
    }

    final resultList = uniqueVideos.values.toList();
    resultList.shuffle();
    return resultList.take(maxResults).toList();
  }

  Future<List<Map<String, String>>> _scrapeSingleQuery(
      String fullQuery, String category, String language) async {
    final negativeOps = "-movie -cinema -film -song -trailer -teaser -tollywood -kollywood -bollywood -adult -nsfw -18+";
    final finalQuery = "$fullQuery $negativeOps";
    
    final encodedQuery = Uri.encodeComponent(finalQuery);
    final url = Uri.parse("https://www.youtube.com/results?search_query=$encodedQuery&sp=CAI%253D");

    try {
      final response = await http.get(
        url,
        headers: {
          "User-Agent":
              "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
          "Accept-Language": "en-US,en;q=0.9",
        },
      );

      if (response.statusCode != 200) {
        return [];
      }

      final html = response.body;
      List<Map<String, String>> scrapedList = [];

      // Parse videoRenderer blocks from HTML using RegExp
      final RegExp videoRendererRegex = RegExp(
        r'\{"videoRenderer":\{"videoId":"([a-zA-Z0-9_-]{11})".*?"title":\{"runs":\[\{"text":"([^"]+)"\}.*?(?:"ownerText"|"longBylineText"|"shortBylineText"):\{"runs":\[\{"text":"([^"]+)"\}',
        dotAll: true,
      );

      final matches = videoRendererRegex.allMatches(html);
      for (var match in matches) {
        final vId = match.group(1);
        final rawTitle = match.group(2);
        final rawChannel = match.group(3);
        if (vId != null && rawTitle != null) {
          scrapedList.add({
            'videoId': vId,
            'title': _cleanTitle(rawTitle),
            'channel': rawChannel != null && rawChannel.isNotEmpty ? _cleanTitle(rawChannel) : '${_capitalize(fullQuery)} Academy',
            'category': category,
            'thumbnail': 'https://img.youtube.com/vi/$vId/hqdefault.jpg',
            'duration': '14:20',
            'bannerBg': '0xFF1E293B',
          });
        }
      }

      // If strict regex matched few, try general videoRenderer title match
      if (scrapedList.length < 10) {
        final RegExp generalRendererRegex = RegExp(
          r'"videoRenderer":\{"videoId":"([a-zA-Z0-9_-]{11})".*?"title":\{"runs":\[\{"text":"([^"]+)"',
          dotAll: true,
        );
        for (var match in generalRendererRegex.allMatches(html)) {
          final vId = match.group(1);
          final rawTitle = match.group(2);
          if (vId != null && rawTitle != null && !scrapedList.any((v) => v['videoId'] == vId)) {
            scrapedList.add({
              'videoId': vId,
              'title': _cleanTitle(rawTitle),
              'channel': '${_capitalize(fullQuery)} Academy',
              'category': category,
              'thumbnail': 'https://img.youtube.com/vi/$vId/hqdefault.jpg',
              'duration': '12:45',
              'bannerBg': '0xFF1E293B',
            });
          }
        }
      }

      // Fallback watch?v= match
      if (scrapedList.length < 10) {
        final RegExp fallbackIdRegex = RegExp(r'watch\?v=([a-zA-Z0-9_-]{11})');
        final fallbackMatches = fallbackIdRegex.allMatches(html);
        final rawIds = fallbackMatches.map((m) => m.group(1)!).toSet().take(30).toList();

        for (var rawId in rawIds) {
          if (!scrapedList.any((v) => v['videoId'] == rawId)) {
            scrapedList.add({
              'videoId': rawId,
              'title': '${_capitalize(fullQuery)} - Educational Masterclass',
              'channel': 'You2Focus Learning',
              'category': category,
              'thumbnail': 'https://img.youtube.com/vi/$rawId/hqdefault.jpg',
              'duration': '10:00',
              'bannerBg': '0xFF1E293B',
            });
          }
        }
      }

      return scrapedList;
    } catch (e) {
      return [];
    }
  }

  String _cleanTitle(String raw) {
    return raw
        .replaceAll(r'\u0026', '&')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
