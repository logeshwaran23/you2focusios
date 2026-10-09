import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StreakData {
  final int streakCount;
  final int longestStreak;
  final int streakFreezes;
  final String lastLoginDate;
  final bool isCheckedInToday;
  final List<String> weeklyHistory;
  final int totalCheckins;

  const StreakData({
    required this.streakCount,
    required this.longestStreak,
    required this.streakFreezes,
    required this.lastLoginDate,
    required this.isCheckedInToday,
    this.weeklyHistory = const [],
    this.totalCheckins = 1,
  });

  StreakData copyWith({
    int? streakCount,
    int? longestStreak,
    int? streakFreezes,
    String? lastLoginDate,
    bool? isCheckedInToday,
    List<String>? weeklyHistory,
    int? totalCheckins,
  }) {
    return StreakData(
      streakCount: streakCount ?? this.streakCount,
      longestStreak: longestStreak ?? this.longestStreak,
      streakFreezes: streakFreezes ?? this.streakFreezes,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      isCheckedInToday: isCheckedInToday ?? this.isCheckedInToday,
      weeklyHistory: weeklyHistory ?? this.weeklyHistory,
      totalCheckins: totalCheckins ?? this.totalCheckins,
    );
  }
}

class StreakService {
  static const String _keyStreakCount = 'focus_grid_login_streak';
  static const String _keyLongestStreak = 'focus_grid_longest_streak';
  static const String _keyStreakFreezes = 'focus_grid_streak_freezes';
  static const String _keyLastLoginDate = 'focus_grid_last_login_date';
  static const String _keyWeeklyHistory = 'focus_grid_weekly_history';
  static const String _keyTotalCheckins = 'focus_grid_total_checkins';

  /// Reactive notifier accessible across the entire app
  static final ValueNotifier<StreakData> streakNotifier = ValueNotifier<StreakData>(
    const StreakData(
      streakCount: 1,
      longestStreak: 1,
      streakFreezes: 1,
      lastLoginDate: '',
      isCheckedInToday: false,
      weeklyHistory: [],
      totalCheckins: 1,
    ),
  );

  static String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
    } catch (_) {}
    return null;
  }

  /// Checks the current date against stored last login date and continuously maintains the streak.
  static Future<StreakData> checkAndUpdateStreak() async {
    final prefs = await SharedPreferences.getInstance();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayStr = _formatDate(today);

    int streakCount = prefs.getInt(_keyStreakCount) ?? 0;
    int longestStreak = prefs.getInt(_keyLongestStreak) ?? 0;
    int streakFreezes = prefs.getInt(_keyStreakFreezes) ?? 1; // Default 1 bonus freeze
    int totalCheckins = prefs.getInt(_keyTotalCheckins) ?? 0;
    String lastLoginDate = prefs.getString(_keyLastLoginDate) ?? '';

    List<String> weeklyHistory = [];
    final rawWeekly = prefs.getString(_keyWeeklyHistory);
    if (rawWeekly != null && rawWeekly.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawWeekly);
        if (decoded is List) {
          weeklyHistory = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }

    bool isCheckedInToday = false;

    if (lastLoginDate.isEmpty) {
      // First app launch ever
      streakCount = 1;
      longestStreak = 1;
      totalCheckins = 1;
      lastLoginDate = todayStr;
      isCheckedInToday = true;
      if (!weeklyHistory.contains(todayStr)) weeklyHistory.add(todayStr);
    } else {
      final lastDate = _parseDate(lastLoginDate);
      if (lastDate == null) {
        streakCount = 1;
        longestStreak = 1;
        totalCheckins = 1;
        lastLoginDate = todayStr;
        isCheckedInToday = true;
        if (!weeklyHistory.contains(todayStr)) weeklyHistory.add(todayStr);
      } else {
        final dayDiff = today.difference(lastDate).inDays;

        if (dayDiff == 0) {
          // Already active today!
          isCheckedInToday = true;
          if (streakCount < 1) streakCount = 1;
          if (!weeklyHistory.contains(todayStr)) weeklyHistory.add(todayStr);
        } else if (dayDiff == 1) {
          // Consecutive day login — streak continues and increments!
          streakCount += 1;
          totalCheckins += 1;
          lastLoginDate = todayStr;
          isCheckedInToday = true;
          if (!weeklyHistory.contains(todayStr)) weeklyHistory.add(todayStr);
          if (streakCount > longestStreak) {
            longestStreak = streakCount;
          }
        } else if (dayDiff > 1) {
          // One or more days missed
          final missedDays = dayDiff - 1;
          if (streakFreezes >= missedDays) {
            // Streak freezes saved the streak! Streak continues and increments for today
            streakFreezes -= missedDays;
            streakCount += 1;
            totalCheckins += 1;
            lastLoginDate = todayStr;
            isCheckedInToday = true;
            if (!weeklyHistory.contains(todayStr)) weeklyHistory.add(todayStr);
            if (streakCount > longestStreak) {
              longestStreak = streakCount;
            }
          } else {
            // Freezes exhausted — streak resets to 1 for today's new start
            streakFreezes = 0;
            streakCount = 1;
            totalCheckins += 1;
            lastLoginDate = todayStr;
            isCheckedInToday = true;
            if (!weeklyHistory.contains(todayStr)) weeklyHistory.add(todayStr);
          }
        }
      }
    }

    if (streakCount > longestStreak) {
      longestStreak = streakCount;
    }

    // Keep weekly history trimmed to last 14 days
    if (weeklyHistory.length > 14) {
      weeklyHistory = weeklyHistory.sublist(weeklyHistory.length - 14);
    }

    // Save updated values to SharedPreferences
    await prefs.setInt(_keyStreakCount, streakCount);
    await prefs.setInt(_keyLongestStreak, longestStreak);
    await prefs.setInt(_keyStreakFreezes, streakFreezes);
    await prefs.setInt(_keyTotalCheckins, totalCheckins);
    await prefs.setString(_keyLastLoginDate, lastLoginDate);
    await prefs.setString(_keyWeeklyHistory, jsonEncode(weeklyHistory));

    final data = StreakData(
      streakCount: streakCount,
      longestStreak: longestStreak,
      streakFreezes: streakFreezes,
      lastLoginDate: lastLoginDate,
      isCheckedInToday: isCheckedInToday,
      weeklyHistory: weeklyHistory,
      totalCheckins: totalCheckins,
    );

    streakNotifier.value = data;
    return data;
  }

  /// Manually triggers daily check-in or focus activity to ensure streak is active today
  static Future<StreakData> recordActivity() async {
    return await checkAndUpdateStreak();
  }

  /// Manually add streak freezes (e.g. via reward or purchase in Focus Store)
  static Future<StreakData> addStreakFreeze(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_keyStreakFreezes) ?? 1;
    int updated = (current + amount).clamp(0, 5);
    await prefs.setInt(_keyStreakFreezes, updated);

    final currentData = streakNotifier.value;
    final updatedData = currentData.copyWith(streakFreezes: updated);
    streakNotifier.value = updatedData;

    return updatedData;
  }

  /// Returns 7 booleans [Mon, Tue, Wed, Thu, Fri, Sat, Sun] for the current week
  static List<bool> getWeeklyStatus(List<String> history) {
    final now = DateTime.now();
    // Monday of current week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final List<bool> days = [];

    for (int i = 0; i < 7; i++) {
      final day = DateTime(monday.year, monday.month, monday.day + i);
      final dayStr = _formatDate(day);
      days.add(history.contains(dayStr));
    }

    return days;
  }
}
