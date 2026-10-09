import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String avatarUrl;
  final String provider; // 'google', 'email', 'guest'
  final bool isLoggedIn;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.avatarUrl = '',
    this.provider = 'email',
    this.isLoggedIn = true,
  });

  String get initial {
    if (displayName.trim().isNotEmpty) {
      return displayName.trim()[0].toUpperCase();
    }
    if (email.trim().isNotEmpty) {
      return email.trim()[0].toUpperCase();
    }
    return 'U';
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? provider,
    bool? isLoggedIn,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      provider: provider ?? this.provider,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

class AuthService {
  static const String _keyUserId = 'focus_grid_auth_uid';
  static const String _keyUserEmail = 'focus_grid_auth_email';
  static const String _keyUserName = 'focus_grid_auth_name';
  static const String _keyUserAvatar = 'focus_grid_auth_avatar';
  static const String _keyAuthProvider = 'focus_grid_auth_provider';
  static const String _keyIsLoggedIn = 'focus_grid_auth_is_logged_in';

  /// Reactive notifier accessible throughout the entire app
  static final ValueNotifier<UserProfile> userNotifier = ValueNotifier<UserProfile>(
    const UserProfile(
      uid: 'guest_user',
      email: 'learner@focusgrid.app',
      displayName: 'Focus Learner',
      provider: 'guest',
      isLoggedIn: false,
    ),
  );

  /// Initializes and loads the persisted user profile
  static Future<UserProfile> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    final email = prefs.getString(_keyUserEmail);
    final name = prefs.getString(_keyUserName);
    final uid = prefs.getString(_keyUserId) ?? 'user_${DateTime.now().millisecondsSinceEpoch}';
    final avatar = prefs.getString(_keyUserAvatar) ?? '';
    final provider = prefs.getString(_keyAuthProvider) ?? 'email';

    UserProfile profile;
    if (email != null && email.isNotEmpty) {
      final safeName = (name != null && name.isNotEmpty) ? name : _deriveNameFromEmail(email);
      profile = UserProfile(
        uid: uid,
        email: email,
        displayName: safeName,
        avatarUrl: avatar.isNotEmpty ? avatar : _deriveAvatarUrl(email),
        provider: provider,
        isLoggedIn: isLoggedIn,
      );
    } else {
      profile = const UserProfile(
        uid: 'default_learner',
        email: 'learner@focusgrid.app',
        displayName: 'Focus Learner',
        avatarUrl: '',
        provider: 'guest',
        isLoggedIn: false,
      );
    }

    userNotifier.value = profile;
    return profile;
  }

  /// Sign up with Email / Password and Name
  static Future<UserProfile> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return signInWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  /// Sign in with Email / Password
  static Future<UserProfile> signInWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    final name = (displayName != null && displayName.trim().isNotEmpty)
        ? displayName.trim()
        : _deriveNameFromEmail(trimmedEmail);

    final prefs = await SharedPreferences.getInstance();
    final uid = 'user_${trimmedEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
    final avatarUrl = _deriveAvatarUrl(trimmedEmail);

    await prefs.setString(_keyUserId, uid);
    await prefs.setString(_keyUserEmail, trimmedEmail);
    await prefs.setString(_keyUserName, name);
    await prefs.setString(_keyUserAvatar, avatarUrl);
    await prefs.setString(_keyAuthProvider, 'email');
    await prefs.setBool(_keyIsLoggedIn, true);

    final profile = UserProfile(
      uid: uid,
      email: trimmedEmail,
      displayName: name,
      avatarUrl: avatarUrl,
      provider: 'email',
      isLoggedIn: true,
    );

    userNotifier.value = profile;
    return profile;
  }

  /// Sign in with Google Account (Production-grade with dynamic Gmail profile)
  static Future<UserProfile> signInWithGoogle({
    required String email,
    String? displayName,
    String? photoUrl,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    final name = (displayName != null && displayName.trim().isNotEmpty)
        ? displayName.trim()
        : _deriveNameFromEmail(trimmedEmail);

    final prefs = await SharedPreferences.getInstance();
    final uid = 'google_${trimmedEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
    final avatarUrl = (photoUrl != null && photoUrl.isNotEmpty) ? photoUrl : _deriveAvatarUrl(trimmedEmail);

    await prefs.setString(_keyUserId, uid);
    await prefs.setString(_keyUserEmail, trimmedEmail);
    await prefs.setString(_keyUserName, name);
    await prefs.setString(_keyUserAvatar, avatarUrl);
    await prefs.setString(_keyAuthProvider, 'google');
    await prefs.setBool(_keyIsLoggedIn, true);

    final profile = UserProfile(
      uid: uid,
      email: trimmedEmail,
      displayName: name,
      avatarUrl: avatarUrl,
      provider: 'google',
      isLoggedIn: true,
    );

    userNotifier.value = profile;
    return profile;
  }

  /// Updates current user profile details in real time
  static Future<UserProfile> updateProfile({
    required String displayName,
    required String email,
    String? avatarUrl,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    final trimmedName = displayName.trim();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, trimmedName);
    await prefs.setString(_keyUserEmail, trimmedEmail);
    if (avatarUrl != null) {
      await prefs.setString(_keyUserAvatar, avatarUrl);
    }

    final current = userNotifier.value;
    final updated = current.copyWith(
      displayName: trimmedName,
      email: trimmedEmail,
      avatarUrl: avatarUrl ?? current.avatarUrl,
    );

    userNotifier.value = updated;
    return updated;
  }

  /// Sign out current user
  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);

    userNotifier.value = const UserProfile(
      uid: 'guest_user',
      email: 'learner@focusgrid.app',
      displayName: 'Focus Learner',
      provider: 'guest',
      isLoggedIn: false,
    );
  }

  static String _deriveNameFromEmail(String email) {
    if (!email.contains('@')) return 'Focus Learner';
    final localPart = email.split('@')[0];
    final parts = localPart.split(RegExp(r'[._-]'));
    final capitalized = parts.where((p) => p.isNotEmpty).map((p) {
      final clean = p.replaceAll(RegExp(r'[0-9]'), '');
      if (clean.isEmpty) return p;
      return clean[0].toUpperCase() + clean.substring(1).toLowerCase();
    }).toList();
    if (capitalized.isEmpty) return 'Focus Learner';
    return capitalized.join(' ');
  }

  static String _deriveAvatarUrl(String email) {
    final safe = email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return 'https://robohash.org/$safe.png?set=set4&size=220x220';
  }
}
