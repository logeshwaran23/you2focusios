import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repository/streak_service.dart';
import '../data/repository/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final bool isDarkMode;
  final int userCoins;
  final int loginStreak;
  final int streakFreezes;
  final String selectedAgeGroup;
  final String selectedLanguage;
  final ValueChanged<bool> onToggleTheme;
  final ValueChanged<String>? onAgeGroupChanged;
  final ValueChanged<String>? onLanguageChanged;
  final VoidCallback? onOpenAgeSelection;
  final VoidCallback? onOpenLanguageSelection;
  final VoidCallback onOpenShop;
  final VoidCallback? onGoHome;
  final ValueChanged<int>? onAddStreakFreeze;

  const ProfileScreen({
    super.key,
    required this.isDarkMode,
    required this.userCoins,
    required this.loginStreak,
    this.streakFreezes = 1,
    required this.selectedAgeGroup,
    required this.selectedLanguage,
    required this.onToggleTheme,
    this.onAgeGroupChanged,
    this.onLanguageChanged,
    this.onOpenAgeSelection,
    this.onOpenLanguageSelection,
    required this.onOpenShop,
    this.onGoHome,
    this.onAddStreakFreeze,
  });


  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  IconData? _selectedAvatarIcon;
  Color _avatarBgColor = const Color(0xFF0284C7);

  // ── Streak state (self-managed, reactive from StreakService) ──
  int _streakCount = 1;
  int _longestStreak = 1;
  int _streakFreezes = 1;
  List<String> _weeklyHistory = [];
  bool _isCheckedInToday = false;

  @override
  void initState() {
    super.initState();
    AuthService.userNotifier.addListener(_onAuthChanged);
    StreakService.streakNotifier.addListener(_onStreakChanged);
    _initStreak();
  }

  @override
  void dispose() {
    AuthService.userNotifier.removeListener(_onAuthChanged);
    StreakService.streakNotifier.removeListener(_onStreakChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onStreakChanged() {
    if (mounted) {
      final data = StreakService.streakNotifier.value;
      setState(() {
        _streakCount = data.streakCount;
        _longestStreak = data.longestStreak;
        _streakFreezes = data.streakFreezes;
        _weeklyHistory = data.weeklyHistory;
        _isCheckedInToday = data.isCheckedInToday;
      });
    }
  }

  /// Loads and updates the streak from SharedPreferences.
  /// Shows a daily check-in dialog ONLY ONCE per day.
  Future<void> _initStreak() async {
    final data = await StreakService.checkAndUpdateStreak();
    if (!mounted) return;

    setState(() {
      _streakCount = data.streakCount;
      _longestStreak = data.longestStreak;
      _streakFreezes = data.streakFreezes;
      _weeklyHistory = data.weeklyHistory;
      _isCheckedInToday = data.isCheckedInToday;
    });

    // Show check-in celebration ONLY on fresh daily login (not if already done today)
    final prefs = await SharedPreferences.getInstance();
    final shownKey = 'profile_checkin_shown_${_todayStr()}';
    final alreadyShown = prefs.getBool(shownKey) ?? false;

    if (!alreadyShown && data.isCheckedInToday && mounted) {
      await prefs.setBool(shownKey, true);
      _showCheckinDialog(data.streakCount);
    }
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
  }

  void _showCheckinDialog(int streak) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                Text(
                  'Day $streak Streak!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  streak == 1
                      ? 'Welcome! Your streak journey begins today.'
                      : 'Amazing! You\'ve been on fire for $streak days in a row!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_events_rounded, color: Color(0xFFFBBF24), size: 20),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text('Keep it up! Come back tomorrow!',
                            style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38BDF8),
                      foregroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Let\'s Go! 🚀',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAgeGroupSelectionSheet(BuildContext context) {
    final isDark = widget.isDarkMode;
    final sheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    final ageOptions = [
      {'label': 'Kids', 'sub': 'Age 5 to 12 • Safe curated videos & fun quizzes'},
      {'label': 'Teens', 'sub': 'Age 13 to 17 • STEM topics, study music & AI guides'},
      {'label': 'Adult', 'sub': 'Age 18+ • Productivity, deep work & pro focus tools'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select Age Group Preference",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: textColor),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...ageOptions.map((opt) {
                final isSelected = widget.selectedAgeGroup.contains(opt['label']!);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
                        : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF38BDF8) : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      opt['label']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? const Color(0xFF38BDF8) : textColor,
                      ),
                    ),
                    subtitle: Text(
                      opt['sub']!,
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Color(0xFF38BDF8))
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onAgeGroupChanged?.call(opt['label']!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("✨ Age Group preference updated to ${opt['label']}!"),
                          backgroundColor: const Color(0xFF38BDF8),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageSelectionSheet(BuildContext context) {
    final isDark = widget.isDarkMode;
    final sheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    final languages = [
      {'name': 'English', 'flag': '🇺🇸'},
      {'name': 'Tamil', 'flag': '🇮🇳'},
      {'name': 'Telugu', 'flag': '🇮🇳'},
      {'name': 'Hindi', 'flag': '🇮🇳'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select Content Language",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: textColor),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: languages.map((lang) {
                  final isSelected = widget.selectedLanguage == lang['name'];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      widget.onLanguageChanged?.call(lang['name']!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("🌐 Content Language updated to ${lang['name']}!"),
                          backgroundColor: const Color(0xFF8B5CF6),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF8B5CF6)
                            : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF8B5CF6) : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(lang['flag']!, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Text(
                            lang['name']!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : textColor,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.check, size: 16, color: Colors.white),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showPhotoSelectionSheet(BuildContext context) {
    final isDark = widget.isDarkMode;
    final sheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Change Profile Photo",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: textColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Option 1: Take Photo (Camera)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Color(0xFF38BDF8)),
                ),
                title: Text("Take Photo (Camera)", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                subtitle: const Text("Capture a new photo instantly", style: TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedAvatarIcon = Icons.person;
                    _avatarBgColor = const Color(0xFF0284C7);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("📸 Photo captured & updated as Profile Picture!"),
                      backgroundColor: Color(0xFF0284C7),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const Divider(),

              // Option 2: Choose Avatar
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.face, color: Color(0xFF8B5CF6)),
                ),
                title: Text("Choose Avatar Icon", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                subtitle: const Text("Select from custom learner badges", style: TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () {
                  Navigator.pop(context);
                  _showAvatarPicker();
                },
              ),
              const Divider(),

              // Option 3: Reset to Default
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.refresh, color: Colors.grey),
                ),
                title: Text("Reset to Default", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedAvatarIcon = null;
                    _avatarBgColor = const Color(0xFF0284C7);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Profile picture reset to default cat avatar."),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final currentUser = AuthService.userNotifier.value;
    final nameCtrl = TextEditingController(text: currentUser.displayName);
    final emailCtrl = TextEditingController(text: currentUser.email);
    final isDark = widget.isDarkMode;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF131B2A) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.edit_note, color: Color(0xFF38BDF8), size: 28),
              const SizedBox(width: 8),
              Text(
                'Edit Profile',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.person, color: Color(0xFF38BDF8), size: 20),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Email Address / Gmail',
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.email, color: Color(0xFF38BDF8), size: 20),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameCtrl.text.trim();
                final newEmail = emailCtrl.text.trim();
                if (newName.isEmpty || newEmail.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name and email cannot be empty')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                await AuthService.updateProfile(
                  displayName: newName,
                  email: newEmail,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Profile updated successfully!'),
                      backgroundColor: Color(0xFF22C55E),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Save Changes', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showAccountSwitchDialog(BuildContext context) {
    final isDark = widget.isDarkMode;
    final currentUser = AuthService.userNotifier.value;
    final sheetBg = isDark ? const Color(0xFF131B2A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Signed in as ${currentUser.email}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Color(0xFF38BDF8)),
                ),
                title: Text('Edit Profile Info', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                subtitle: const Text('Change name or email', style: TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showEditProfileDialog(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('G', style: TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                title: Text('Switch Google Account', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                subtitle: const Text('Connect a different Gmail account', style: TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout, color: Color(0xFFEF4444)),
                ),
                title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                subtitle: const Text('Return to sign in screen', style: TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await AuthService.signOut();
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAvatarPicker() {
    final isDark = widget.isDarkMode;
    final avatars = [
      {'icon': Icons.school, 'color': const Color(0xFF22C55E), 'name': 'Scholar'},
      {'icon': Icons.psychology, 'color': const Color(0xFF38BDF8), 'name': 'Genius'},
      {'icon': Icons.rocket_launch, 'color': const Color(0xFFF59E0B), 'name': 'Rocket'},
      {'icon': Icons.auto_awesome, 'color': const Color(0xFFEC4899), 'name': 'Star'},
      {'icon': Icons.self_improvement, 'color': const Color(0xFF8B5CF6), 'name': 'Guru'},
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          title: const Text("Select Avatar Badge", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: avatars.map((av) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedAvatarIcon = av['icon'] as IconData;
                    _avatarBgColor = av['color'] as Color;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("✨ Profile avatar updated to ${av['name']}!"),
                      backgroundColor: av['color'] as Color,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: av['color'] as Color,
                  child: Icon(av['icon'] as IconData, color: Colors.white, size: 22),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    final isDark = widget.isDarkMode;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.logout, color: Colors.black87),
            SizedBox(width: 10),
            Text("Sign Out", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text("Are you sure you want to sign out of You2Focus?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Signed out successfully."),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text("Sign Out"),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.chat_bubble_outline, color: Color(0xFF3B82F6)),
            SizedBox(width: 10),
            Text("Feedback & Suggestions", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("We'd love to hear your thoughts to improve You2Focus!"),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Enter your feedback...",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("🎉 Thank you for your feedback!"),
                  backgroundColor: Color(0xFF3B82F6),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
            ),
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;
    final userCoins = widget.userCoins;
    final selectedAgeGroup = widget.selectedAgeGroup;
    final selectedLanguage = widget.selectedLanguage;
    final onToggleTheme = widget.onToggleTheme;
    final onOpenShop = widget.onOpenShop;

    final bgColor = isDarkMode ? const Color(0xFF090D16) : const Color(0xFFF8FAFC);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : Colors.black54;
    final cardBg = isDarkMode
        ? const Color(0xFF131B2A)
        : Colors.white.withValues(alpha: 0.85);
    final cardBorder = isDarkMode
        ? const Color(0xFF243044)
        : const Color(0xFFCBD5E1);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF090D16) : const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.home, color: textColor, size: 26),
          tooltip: "Home",
          onPressed: widget.onGoHome,
        ),
        title: Text(
          "Profile",
          style: TextStyle(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: textColor, size: 26),
            tooltip: "Sign Out",
            onPressed: () => _showLogoutConfirmDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFeedbackDialog(context),
        backgroundColor: isDarkMode ? const Color(0xFF334155) : const Color(0xFF4F46E5),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isDarkMode ? const Color(0xFF475569) : Colors.transparent, width: 1.5),
        ),
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 24),
      ),
      body: Stack(
        children: [
          // Background gradient orbs
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3B82F6).withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── 1. Android Photo Matched Profile User Header ───────────
                  _GlassCard(
                    isDarkMode: isDarkMode,
                    cardBg: cardBg,
                    cardBorder: cardBorder,
                    padding: const EdgeInsets.all(24.0),
                    child: Builder(
                      builder: (context) {
                        final currentUser = AuthService.userNotifier.value;
                        final isGoogleUser = currentUser.provider == 'google';

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Centered Round Avatar with tap to change
                            GestureDetector(
                              onTap: () => _showPhotoSelectionSheet(context),
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFE2E8F0),
                                  border: Border.all(
                                    color: isGoogleUser ? const Color(0xFF4285F4) : Colors.white,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: _selectedAvatarIcon != null
                                      ? Container(
                                          color: _avatarBgColor,
                                          child: Icon(_selectedAvatarIcon, color: Colors.white, size: 56),
                                        )
                                      : Image.network(
                                          currentUser.avatarUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            color: const Color(0xFF0284C7),
                                            child: Center(
                                              child: Text(
                                                currentUser.initial,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 44,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Dynamic User Display Name
                            Text(
                              currentUser.displayName,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),

                            // Dynamic User Email / Gmail Address
                            Text(
                              currentUser.email,
                              style: TextStyle(
                                fontSize: 14,
                                color: subTextColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),

                            // Badges Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: isDarkMode ? Colors.white24 : const Color(0xFFCBD5E1)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Text("🎂", style: TextStyle(fontSize: 14)),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Age: $selectedAgeGroup",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: isGoogleUser ? const Color(0xFF38BDF8) : const Color(0xFF4ADE80),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      if (isGoogleUser)
                                        const Padding(
                                          padding: EdgeInsets.only(right: 6),
                                          child: Text(
                                            'G',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        )
                                      else
                                        const Padding(
                                          padding: EdgeInsets.only(right: 6),
                                          child: Icon(Icons.check_circle, size: 16, color: Colors.black87),
                                        ),
                                      Text(
                                        isGoogleUser ? "Google Account" : "Signed In",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Quick Edit Profile & Switch Account action buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _showEditProfileDialog(context),
                                  icon: const Icon(Icons.edit_outlined, size: 15),
                                  label: const Text('Edit Profile', style: TextStyle(fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF38BDF8),
                                    side: const BorderSide(color: Color(0xFF38BDF8), width: 1),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                OutlinedButton.icon(
                                  onPressed: () => _showAccountSwitchDialog(context),
                                  icon: const Icon(Icons.swap_horiz, size: 16),
                                  label: const Text('Switch Account', style: TextStyle(fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF94A3B8),
                                    side: const BorderSide(color: Color(0xFF475569), width: 1),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── 2. Login Streak Card (Matching Screenshot Layout 1:1 + Weekly Tracker) ─
                  _GlassCard(
                    isDarkMode: isDarkMode,
                    cardBg: cardBg,
                    cardBorder: cardBorder,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("🔥", style: TextStyle(fontSize: 36)),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    "$_streakCount Day Login\nStreak!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Best: $_longestStreak days",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFFBBF24),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Tooltip(
                              message: "Best: $_longestStreak days | Freezes: $_streakFreezes",
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? const Color(0xFF0C4A6E) : const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.6)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text("❄️", style: TextStyle(fontSize: 14)),
                                    const SizedBox(width: 5),
                                    Text(
                                      "$_streakFreezes",
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ── Weekly 7-Day Continuous Streak Tracker ────────────
                        Builder(
                          builder: (context) {
                            final weeklyStatus = StreakService.getWeeklyStatus(_weeklyHistory);
                            final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                            final todayWeekday = DateTime.now().weekday; // 1 = Mon, 7 = Sun

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(7, (index) {
                                  final isActive = weeklyStatus.length > index && weeklyStatus[index];
                                  final isToday = (index + 1) == todayWeekday;

                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        dayNames[index],
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                                          color: isToday ? const Color(0xFF38BDF8) : subTextColor,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isActive
                                              ? const Color(0xFFF97316)
                                              : (isToday
                                                  ? const Color(0xFF38BDF8).withValues(alpha: 0.2)
                                                  : (isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0))),
                                          border: Border.all(
                                            color: isActive
                                                ? const Color(0xFFEA580C)
                                                : (isToday ? const Color(0xFF38BDF8) : Colors.transparent),
                                            width: isToday ? 2.0 : 1.0,
                                          ),
                                          boxShadow: isActive
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(0xFFF97316).withValues(alpha: 0.4),
                                                    blurRadius: 6,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        alignment: Alignment.center,
                                        child: isActive
                                            ? const Text("🔥", style: TextStyle(fontSize: 13))
                                            : (isToday
                                                ? const Text("✨", style: TextStyle(fontSize: 11))
                                                : const SizedBox.shrink()),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 14),

                        // Check-in status or manual check-in button
                        GestureDetector(
                          onTap: () async {
                            final data = await StreakService.recordActivity();
                            if (mounted) {
                              _showCheckinDialog(data.streakCount);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: _isCheckedInToday
                                  ? const Color(0xFF22C55E).withValues(alpha: 0.15)
                                  : const Color(0xFF38BDF8).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _isCheckedInToday
                                    ? const Color(0xFF22C55E).withValues(alpha: 0.5)
                                    : const Color(0xFF38BDF8).withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isCheckedInToday ? Icons.check_circle_rounded : Icons.touch_app_rounded,
                                  color: _isCheckedInToday ? const Color(0xFF22C55E) : const Color(0xFF38BDF8),
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isCheckedInToday
                                      ? "Checked In Today • Streak Protected"
                                      : "Tap to Check-In Today 🚀",
                                  style: TextStyle(
                                    color: _isCheckedInToday ? const Color(0xFF22C55E) : const Color(0xFF38BDF8),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Log in daily to earn\ncoins & protect your\nmomentum!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: subTextColor,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── 3. Focus Store Card ──────────────────────────────────
                  _GlassCard(
                    isDarkMode: isDarkMode,
                    cardBg: cardBg,
                    cardBorder: cardBorder,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Text("🛒", style: TextStyle(fontSize: 26)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Focus Store",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                        Text(
                                          "Passes, Streak Freezes & Earn Coins",
                                          style: TextStyle(fontSize: 11.5, color: subTextColor),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                "🪙 $userCoins",
                                style: const TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 48,
                                child: OutlinedButton(
                                  onPressed: onOpenShop,
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text("🛍️", style: TextStyle(fontSize: 14)),
                                      SizedBox(width: 6),
                                      Text(
                                        "Store",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFF59E0B),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 48,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFFD700), Color(0xFFF59E0B), Color(0xFFD97706)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("🎉 +10 FocusCoins earned from Ad!"),
                                            backgroundColor: Color(0xFFF59E0B),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Text("🎬", style: TextStyle(fontSize: 13)),
                                          SizedBox(width: 3),
                                          Flexible(
                                            child: Text(
                                              "Watch Ad (+10 🪙)",
                                              style: TextStyle(
                                                color: Color(0xFF1E1B4B),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── 4. Settings Section (Fully Interactive & Functional) ──
                  Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  _GlassCard(
                    isDarkMode: isDarkMode,
                    cardBg: cardBg,
                    cardBorder: cardBorder,
                    padding: EdgeInsets.zero,
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        children: [
                          // Item 1: Age Group (Interactive - Opens AgeSelectionScreen)
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isDarkMode ? Colors.white12 : const Color(0xFFCBD5E1)),
                              ),
                              child: Icon(Icons.people_alt_outlined, color: textColor, size: 22),
                            ),
                            title: Text(
                              "Age Group",
                              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Text(selectedAgeGroup, style: TextStyle(color: subTextColor, fontSize: 13)),
                            trailing: Icon(Icons.chevron_right, size: 22, color: subTextColor),
                            onTap: widget.onOpenAgeSelection ?? () => _showAgeGroupSelectionSheet(context),
                          ),
                          Divider(height: 1, color: isDarkMode ? Colors.white12 : Colors.black12),

                          // Item 2: Content Language (Interactive - Opens LanguageSelectionScreen)
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isDarkMode ? Colors.white12 : const Color(0xFFCBD5E1)),
                              ),
                              child: Icon(Icons.description_outlined, color: textColor, size: 22),
                            ),
                            title: Text(
                              "Content Language",
                              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Text(selectedLanguage, style: TextStyle(color: subTextColor, fontSize: 13)),
                            trailing: Icon(Icons.chevron_right, size: 22, color: subTextColor),
                            onTap: widget.onOpenLanguageSelection ?? () => _showLanguageSelectionSheet(context),
                          ),
                          Divider(height: 1, color: isDarkMode ? Colors.white12 : Colors.black12),

                          // Item 3: Theme Mode (Interactive Switch & Tap Handler)
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isDarkMode ? Colors.white12 : const Color(0xFFCBD5E1)),
                              ),
                              child: Icon(
                                isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                color: isDarkMode ? const Color(0xFF38BDF8) : const Color(0xFFF59E0B),
                                size: 22,
                              ),
                            ),
                            title: Text(
                              "Theme Mode",
                              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Text(
                              isDarkMode ? "Dark Mode" : "Light Mode",
                              style: TextStyle(color: subTextColor, fontSize: 13),
                            ),
                            trailing: Switch.adaptive(
                              value: isDarkMode,
                              onChanged: onToggleTheme,
                              activeThumbColor: const Color(0xFF8B5CF6),
                            ),
                            onTap: () => onToggleTheme(!isDarkMode),
                          ),
                          Divider(height: 1, color: isDarkMode ? Colors.white12 : Colors.black12),

                          // Item 4: Custom Theme & Text Styling Subheader & Card Button
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text("🎨", style: TextStyle(fontSize: 16)),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Custom Theme & Text Styling",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? const Color(0xFF3B0764).withValues(alpha: 0.4)
                                        : const Color(0xFFF3E8FF),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFA855F7).withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: const [
                                          Text("👑", style: TextStyle(fontSize: 18)),
                                          SizedBox(width: 8),
                                          Text(
                                            "Custom Theme Customizer",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Color(0xFFA855F7),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Upgrade to Premium Pass to unlock customizable premium texts & colors.",
                                        style: TextStyle(fontSize: 12, color: subTextColor),
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          onPressed: onOpenShop,
                                          icon: const Icon(Icons.lock_outline, size: 14, color: Color(0xFFFFD700)),
                                          label: const Text(
                                            "Unlock in Focus Store",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFFFD700),
                                              fontSize: 13,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                          ),
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
                  ),
                  const SizedBox(height: 24),

                  // ── 5. About Section (1:1 Screenshot Match) ───────────────
                  Text(
                    "About",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  _GlassCard(
                    isDarkMode: isDarkMode,
                    cardBg: cardBg,
                    cardBorder: cardBorder,
                    padding: EdgeInsets.zero,
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        children: [
                          // Item 1: About You2Focus
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isDarkMode ? Colors.white12 : const Color(0xFFCBD5E1)),
                              ),
                              child: Icon(Icons.info_outline, color: textColor, size: 22),
                            ),
                            title: Text(
                              "About You2Focus",
                              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Text("Learn more about our app", style: TextStyle(color: subTextColor, fontSize: 13)),
                            trailing: Icon(Icons.chevron_right, size: 22, color: subTextColor),
                            onTap: () => _showAboutYou2FocusDialog(context, isDarkMode),
                          ),
                          Divider(height: 1, color: isDarkMode ? Colors.white12 : Colors.black12),

                          // Item 2: Privacy Policy
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isDarkMode ? Colors.white12 : const Color(0xFFCBD5E1)),
                              ),
                              child: Icon(Icons.shield_outlined, color: textColor, size: 22),
                            ),
                            title: Text(
                              "Privacy Policy",
                              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Text("How we handle your data", style: TextStyle(color: subTextColor, fontSize: 13)),
                            trailing: Icon(Icons.chevron_right, size: 22, color: subTextColor),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                                  title: Text("Privacy Policy", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                                  content: Text(
                                    "You2Focus prioritizes user privacy. We do not collect sensitive personal identification or track user browsing behavior outside the app. All user preferences are stored securely on-device.",
                                    style: TextStyle(color: subTextColor, fontSize: 14),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Close", style: TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Divider(height: 1, color: isDarkMode ? Colors.white12 : Colors.black12),

                          // Item 3: Terms of Service
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isDarkMode ? Colors.white12 : const Color(0xFFCBD5E1)),
                              ),
                              child: Icon(Icons.description_outlined, color: textColor, size: 22),
                            ),
                            title: Text(
                              "Terms of Service",
                              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Text("App usage guidelines", style: TextStyle(color: subTextColor, fontSize: 13)),
                            trailing: Icon(Icons.chevron_right, size: 22, color: subTextColor),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                                  title: Text("Terms of Service", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                                  content: Text(
                                    "By using You2Focus, you agree to access only educational, high-quality, and constructive focus material. All focus coins and streak rewards are intended for personal motivation.",
                                    style: TextStyle(color: subTextColor, fontSize: 14),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Close", style: TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── 6. Account Action (Sign Out Card) ──────────────────────
                  _GlassCard(
                    isDarkMode: isDarkMode,
                    cardBg: cardBg,
                    cardBorder: cardBorder,
                    padding: EdgeInsets.zero,
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.logout, color: Colors.redAccent, size: 22),
                        ),
                        title: const Text(
                          "Sign Out",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () => _showLogoutConfirmDialog(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutYou2FocusDialog(BuildContext context, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF182232) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDarkMode ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular green badge with white info icon (1:1 screenshot match)
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF047857)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title: About You2Focus
                Text(
                  "About You2Focus",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),

                // Subtitle: Your focused learning companion
                Text(
                  "Your focused learning companion",
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Description Text (1:1 verbatim from screenshot)
                Text(
                  "You2Focus curates educational and devotional content with a premium, compact UI. Our platform helps learners of all ages discover meaningful videos that inspire growth and spirituality without distractions.",
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.5,
                    color: isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // Green Close Button (1:1 screenshot match with checkmark)
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.black, size: 20),
                  label: const Text(
                    "Close",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Reusable Glass Card widget ────────────────────────────────────────────────
class _GlassCard extends StatelessWidget {
  final Widget child;
  final bool isDarkMode;
  final Color cardBg;
  final Color cardBorder;
  final EdgeInsetsGeometry padding;

  const _GlassCard({
    required this.child,
    required this.isDarkMode,
    required this.cardBg,
    required this.cardBorder,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorder, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
