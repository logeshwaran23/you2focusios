import 'package:flutter/material.dart';
import 'data/repository/vimeo_repository.dart';
import 'data/repository/youtube_repository.dart';
import 'data/repository/streak_service.dart';
import 'data/repository/auth_service.dart';
import 'ui/profile_screen.dart';
import 'ui/search_screen.dart';
import 'ui/favorites_screen.dart';
import 'ui/history_screen.dart';
import 'ui/video_player_screen.dart';
import 'ui/focus_store_screen.dart';

void main() {
  runApp(const You2FocusApp());
}

class You2FocusApp extends StatefulWidget {
  const You2FocusApp({super.key});

  @override
  State<You2FocusApp> createState() => _You2FocusAppState();
}

class _You2FocusAppState extends State<You2FocusApp> {
  bool _isDarkMode = true;
  int _userCoins = 50;
  int _loginStreak = 1;
  int _streakFreezes = 1;
  String _selectedAgeGroup = 'Adult';
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    AuthService.init();
    StreakService.streakNotifier.addListener(_onStreakChanged);
    _loadStreakData();
  }

  @override
  void dispose() {
    StreakService.streakNotifier.removeListener(_onStreakChanged);
    super.dispose();
  }

  void _onStreakChanged() {
    if (mounted) {
      final streakData = StreakService.streakNotifier.value;
      setState(() {
        _loginStreak = streakData.streakCount;
        _streakFreezes = streakData.streakFreezes;
      });
    }
  }

  Future<void> _loadStreakData() async {
    final streakData = await StreakService.checkAndUpdateStreak();
    if (mounted) {
      setState(() {
        _loginStreak = streakData.streakCount;
        _streakFreezes = streakData.streakFreezes;
      });
    }
  }

  void _addStreakFreeze(int amount) async {
    final updated = await StreakService.addStreakFreeze(amount);
    if (mounted) {
      setState(() {
        _streakFreezes = updated.streakFreezes;
      });
    }
  }

  void _toggleTheme(bool isDark) {
    setState(() => _isDarkMode = isDark);
  }

  void _changeAgeGroup(String newAge) {
    setState(() => _selectedAgeGroup = newAge);
  }

  void _changeLanguage(String newLang) {
    setState(() => _selectedLanguage = newLang);
  }

  void _addCoins(int amount) {
    setState(() => _userCoins += amount);
  }


  @override
  Widget build(BuildContext context) {
    const focusBlue = Color(0xFF38BDF8);
    const focusGreen = Color(0xFF22C55E);

    return MaterialApp(
      title: 'You2Focus',
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode
          ? ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color(0xFF0F172A),
              colorScheme: const ColorScheme.dark(
                primary: focusBlue,
                secondary: focusGreen,
                surface: Color(0xFF131B2A),
                onSurface: Colors.white,
              ),
            )
          : ThemeData.light().copyWith(
              scaffoldBackgroundColor: const Color(0xFFF8FAFC),
              colorScheme: const ColorScheme.light(
                primary: focusBlue,
                secondary: focusGreen,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
      home: MainNavigationScreen(
        isDarkMode: _isDarkMode,
        userCoins: _userCoins,
        loginStreak: _loginStreak,
        streakFreezes: _streakFreezes,
        selectedAgeGroup: _selectedAgeGroup,
        selectedLanguage: _selectedLanguage,
        onToggleTheme: _toggleTheme,
        onAgeGroupChanged: _changeAgeGroup,
        onLanguageChanged: _changeLanguage,
        onAddCoins: _addCoins,
        onAddStreakFreeze: _addStreakFreeze,
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/age_selection': (context) => AgeSelectionScreen(
              onAgeSelected: (age) {
                setState(() => _selectedAgeGroup = age);
                Navigator.pushReplacementNamed(context, '/language_selection');
              },
            ),
        '/language_selection': (context) => LanguageSelectionScreen(
              onLanguageSelected: (lang) {
                setState(() => _selectedLanguage = lang);
                Navigator.pushReplacementNamed(context, '/main');
              },
            ),
        '/main': (context) => MainNavigationScreen(
              isDarkMode: _isDarkMode,
              userCoins: _userCoins,
              loginStreak: _loginStreak,
              streakFreezes: _streakFreezes,
              selectedAgeGroup: _selectedAgeGroup,
              selectedLanguage: _selectedLanguage,
              onToggleTheme: _toggleTheme,
              onAddCoins: _addCoins,
              onAddStreakFreeze: _addStreakFreeze,
            ),
      },

    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// FEATURE 1: LOGIN SCREEN (Login_Screen.kt)
// ═════════════════════════════════════════════════════════════════════════════

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isSignUp = false;
  bool _isPasswordVisible = false;
  bool _isTermsAccepted = true;
  bool _showErrorBanner = false;
  bool _isLoading = false;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    // Prefill with existing profile if active
    final currentUser = AuthService.userNotifier.value;
    if (currentUser.isLoggedIn && currentUser.email != 'learner@focusgrid.app') {
      _emailController.text = currentUser.email;
      _nameController.text = currentUser.displayName;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _showFeedback(String msg, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleAuthSubmit() async {
    if (!_isTermsAccepted) {
      _showFeedback('Please accept the Terms of Service & Privacy Policy to continue');
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty) {
      _showFeedback('Please enter your email address');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      _showFeedback('Please enter a valid email address (e.g. user@gmail.com)');
      return;
    }
    if (password.isEmpty) {
      _showFeedback('Please enter your password');
      return;
    }
    if (password.length < 4) {
      _showFeedback('Password must be at least 4 characters long');
      return;
    }
    if (_isSignUp && name.isEmpty) {
      _showFeedback('Please enter your full name');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isSignUp) {
        await AuthService.signUp(
          email: email,
          password: password,
          displayName: name,
        );
      } else {
        await AuthService.signInWithEmail(
          email: email,
          password: password,
          displayName: name.isNotEmpty ? name : null,
        );
      }

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushReplacementNamed(context, '/age_selection');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
          _showErrorBanner = true;
        });
      }
    }
  }

  void _handleGoogleSignIn() {
    if (!_isTermsAccepted) {
      _showFeedback('Please accept the Terms of Service & Privacy Policy to continue');
      return;
    }

    final customGoogleEmailCtrl = TextEditingController(
      text: _emailController.text.contains('@') ? _emailController.text : '',
    );
    final customGoogleNameCtrl = TextEditingController(
      text: _nameController.text.isNotEmpty ? _nameController.text : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF131B2A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Color(0xFF334155), width: 1.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'G',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4285F4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Google Sign-In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Choose an account for You2Focus',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Enter your Google / Gmail account:',
                style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: customGoogleEmailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'yourname@gmail.com',
                  hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  prefixIcon: const Icon(Icons.mail_outline, color: Color(0xFF38BDF8), size: 20),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF334155)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: customGoogleNameCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Display Name (optional)',
                  hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF38BDF8), size: 20),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF334155)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final emailInput = customGoogleEmailCtrl.text.trim();
                    if (emailInput.isEmpty || !emailInput.contains('@')) {
                      _showFeedback('Please enter a valid Gmail address');
                      return;
                    }
                    Navigator.pop(ctx);
                    setState(() => _isLoading = true);
                    await AuthService.signInWithGoogle(
                      email: emailInput,
                      displayName: customGoogleNameCtrl.text.trim().isNotEmpty
                          ? customGoogleNameCtrl.text.trim()
                          : null,
                    );
                    if (mounted) {
                      setState(() => _isLoading = false);
                      Navigator.pushReplacementNamed(context, '/age_selection');
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline, color: Colors.black, size: 20),
                  label: const Text(
                    'Continue with this Google Account',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const focusGreen = Color(0xFF22C55E);
    const focusBlue = Color(0xFF38BDF8);
    const textGray = Color(0xFF94A3B8);
    const loginCardBg = Color(0xFF131B2A);
    const borderColor = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),

              // Brand Header
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                      physics: const NeverScrollableScrollPhysics(),
                      children: List.generate(9, (index) {
                        final isCenter = index == 4;
                        return Container(
                          decoration: BoxDecoration(
                            color: isCenter
                                ? const Color(0xFFEAB308)
                                : const Color(0xFF312E81),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: isCenter
                              ? const Icon(Icons.play_arrow,
                                  size: 9, color: Colors.black)
                              : null,
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'You2Focus',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: focusGreen,
                        ),
                      ),
                      Text(
                        'Learn with Clarity. Grow with Focus',
                        style: TextStyle(fontSize: 12, color: textGray),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Title Header
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _isSignUp ? 'Create Account' : 'Welcome Back',
                  key: ValueKey(_isSignUp),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: focusBlue,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isSignUp
                    ? 'Sign up to begin your learning journey'
                    : 'Sign in to continue your learning journey',
                style: const TextStyle(fontSize: 13, color: textGray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Error Banner (shown only on actual error)
              if (_showErrorBanner && _errorMessage.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7F1D1D).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFCF6679).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Color(0xFFCF6679), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13, height: 1.3),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showErrorBanner = false;
                          });
                        },
                        child: const Icon(Icons.close,
                            color: textGray, size: 16),
                      ),
                    ],
                  ),
                ),

              // Input Card Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: loginCardBg.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isSignUp) ...[
                      _buildTextField(
                        controller: _nameController,
                        label: 'Name',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 12),
                    ],
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      isPasswordVisible: _isPasswordVisible,
                      onTogglePassword: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _handleAuthSubmit,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: focusBlue,
                              side: const BorderSide(color: borderColor),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: focusBlue),
                                  )
                                : Text(
                                    _isSignUp ? 'Create Account' : 'Sign In',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _isSignUp = !_isSignUp;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: focusBlue,
                              side: const BorderSide(color: borderColor),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              _isSignUp ? 'Sign In' : 'Create Account',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (!_isSignUp) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => _showForgotPasswordDialog(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.lock_outline,
                            size: 13, color: textGray),
                        label: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: focusBlue, fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: const [
                  Expanded(child: Divider(color: borderColor)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      ' OR ',
                      style: TextStyle(color: textGray, fontSize: 11),
                    ),
                  ),
                  Expanded(child: Divider(color: borderColor)),
                ],
              ),

              const SizedBox(height: 20),

              OutlinedButton.icon(
                onPressed: _handleGoogleSignIn,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: borderColor),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Text(
                  'G',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                label: const Text(
                  'Continue with Google',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: focusBlue,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: !_isTermsAccepted
                      ? const Color(0xFF7F1D1D).withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: !_isTermsAccepted
                        ? const Color(0xFFEF4444).withValues(alpha: 0.35)
                        : borderColor,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _isTermsAccepted,
                      onChanged: (val) {
                        setState(() {
                          _isTermsAccepted = val ?? false;
                        });
                      },
                      activeColor: focusBlue,
                      checkColor: Colors.black,
                      side: const BorderSide(color: Color(0xFF94A3B8)),
                    ),
                    Expanded(
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text('I agree to ',
                              style: TextStyle(
                                  fontSize: 11.5, color: textGray)),
                          GestureDetector(
                            onTap: () => _showTextDialog(
                                context,
                                'Terms of Service',
                                'You2Focus Terms of Service:\n\nBy using You2Focus, you agree to engage in focused learning and follow community safety rules.'),
                            child: const Text(
                              'Terms of Service',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: focusBlue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const Text(' & ',
                              style: TextStyle(
                                  fontSize: 11.5, color: textGray)),
                          GestureDetector(
                            onTap: () => _showTextDialog(
                                context,
                                'Privacy Policy',
                                'You2Focus Privacy Policy:\n\nYour privacy is paramount. Your learning preferences are secured and never sold to third parties.'),
                            child: const Text(
                              'Privacy Policy',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: focusBlue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    TextInputType keyboardType = TextInputType.text,
  }) {
    const focusBlue = Color(0xFF38BDF8);
    const textGray = Color(0xFF94A3B8);
    const borderColor = Color(0xFF1E293B);
    const inputBg = Color(0xFF0F172A);

    return TextField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: textGray, fontSize: 13),
        prefixIcon: Icon(icon, color: focusBlue, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: textGray,
                  size: 20,
                ),
                onPressed: onTogglePassword,
              )
            : null,
        filled: true,
        fillColor: inputBg.withValues(alpha: 0.5),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: focusBlue),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final resetEmailController =
        TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131B2A),
        title: const Text('Reset Password',
            style:
                TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Enter your email address and we'll send you a password reset link.",
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Password reset link sent to ${resetEmailController.text.isEmpty ? "your email" : resetEmailController.text}'),
                  backgroundColor: const Color(0xFF22C55E),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38BDF8),
              foregroundColor: Colors.black,
            ),
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  void _showTextDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131B2A),
        title: Text(title,
            style: const TextStyle(
                color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Text(body,
              style: const TextStyle(color: Colors.white, fontSize: 13)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close',
                style: TextStyle(color: Color(0xFF38BDF8))),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// FEATURE 2: AGE SELECTION SCREEN (Exact 100% Match with AgeSelectionScreen.kt)
// ═════════════════════════════════════════════════════════════════════════════

class AgeSelectionScreen extends StatefulWidget {
  final ValueChanged<String>? onAgeSelected;

  const AgeSelectionScreen({super.key, this.onAgeSelected});

  @override
  State<AgeSelectionScreen> createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen> {
  void _selectAge(String age) {
    if (widget.onAgeSelected != null) {
      widget.onAgeSelected!(age);
    } else {
      Navigator.pushReplacementNamed(context, '/language_selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    const focusGreen = Color(0xFF22C55E);
    const textGray = Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Brand Header
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                      physics: const NeverScrollableScrollPhysics(),
                      children: List.generate(9, (index) {
                        final isCenter = index == 4;
                        return Container(
                          decoration: BoxDecoration(
                            color: isCenter
                                ? const Color(0xFFEAB308)
                                : const Color(0xFF312E81),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: isCenter
                              ? const Icon(Icons.play_arrow,
                                  size: 9, color: Colors.black)
                              : null,
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'You2Focus',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: focusGreen,
                        ),
                      ),
                      Text(
                        'Learn with Clarity. Grow with Focus',
                        style: TextStyle(fontSize: 12, color: textGray),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),

              const Text(
                'Select your age group',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Get personalized educational and devotional content.',
                style: TextStyle(color: textGray, fontSize: 14),
              ),
              const SizedBox(height: 32),

              // Kids Card (Green #1B5E20)
              GestureDetector(
                onTap: () => _selectAge('Kids'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20).withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF4CAF50)),
                  ),
                  child: Column(
                    children: const [
                      Text('🧒', style: TextStyle(fontSize: 42)),
                      SizedBox(height: 8),
                      Text(
                        'Kids',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Curated for kids',
                        style: TextStyle(color: textGray, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 13+ Card (Blue #0D47A1)
              GestureDetector(
                onTap: () => _selectAge('13+'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D47A1).withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF2196F3)),
                  ),
                  child: Column(
                    children: const [
                      Text('👨‍🎓', style: TextStyle(fontSize: 42)),
                      SizedBox(height: 8),
                      Text(
                        '13+',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Curated for teens/adults and seniors',
                        style: TextStyle(color: textGray, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Skip Button
              Center(
                child: TextButton(
                  onPressed: () => _selectAge('13+'),
                  child: const Text(
                    'Skip for now (Default: 13+)',
                    style: TextStyle(color: textGray, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                'Note: You can change your age selection at any time in the profile screen.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// FEATURE 3: LANGUAGE SELECTION SCREEN (LanguageSelectionScreen.kt)
// ═════════════════════════════════════════════════════════════════════════════

class LanguageSelectionScreen extends StatefulWidget {
  final ValueChanged<String>? onLanguageSelected;

  const LanguageSelectionScreen({super.key, this.onLanguageSelected});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLanguage = 'English';

  final languages = [
    {'name': 'English', 'native': 'English', 'symbol': 'A'},
    {'name': 'Tamil', 'native': 'தமிழ்', 'symbol': 'அ'},
    {'name': 'Telugu', 'native': 'తెలుగు', 'symbol': 'అ'},
    {'name': 'Hindi', 'native': 'हिंदी', 'symbol': 'अ'},
  ];

  void _proceed() {
    if (widget.onLanguageSelected != null) {
      widget.onLanguageSelected!(_selectedLanguage);
    } else {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    const focusGreen = Color(0xFF22C55E);
    const textGray = Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Brand Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                      physics: const NeverScrollableScrollPhysics(),
                      children: List.generate(9, (index) {
                        final isCenter = index == 4;
                        return Container(
                          decoration: BoxDecoration(
                            color: isCenter
                                ? const Color(0xFFEAB308)
                                : const Color(0xFF312E81),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: isCenter
                              ? const Icon(Icons.play_arrow,
                                  size: 8, color: Colors.black)
                              : null,
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'You2Focus',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: focusGreen,
                        ),
                      ),
                      Text(
                        'Learn with Clarity. Grow with Focus',
                        style: TextStyle(fontSize: 11, color: textGray),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Select Content\nLanguage',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose your preferred language for videos and learning material.',
                style: TextStyle(color: textGray, fontSize: 13),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.25,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  children: languages.map((lang) {
                    final isSelected = lang['name'] == _selectedLanguage;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedLanguage = lang['name']!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1E3A27)
                              : const Color(0xFF131B2A),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? focusGreen
                                : const Color(0xFF1E293B),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            if (isSelected)
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: focusGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    lang['symbol']!,
                                    style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? focusGreen : Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    lang['native']!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      color: isSelected ? Colors.white : textGray,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),

              const Center(
                child: Text(
                  'Note: You can change your content language in the profile screen at any time.',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 14),

              ElevatedButton(
                onPressed: _proceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: focusGreen,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Confirm & Proceed',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// FEATURE 4: MAIN NAVIGATION CONTAINER (MainActivity.kt)
// ═════════════════════════════════════════════════════════════════════════════

class MainNavigationScreen extends StatefulWidget {
  final bool isDarkMode;
  final int userCoins;
  final int loginStreak;
  final int streakFreezes;
  final String selectedAgeGroup;
  final String selectedLanguage;
  final ValueChanged<bool> onToggleTheme;
  final ValueChanged<String>? onAgeGroupChanged;
  final ValueChanged<String>? onLanguageChanged;
  final ValueChanged<int> onAddCoins;
  final ValueChanged<int>? onAddStreakFreeze;

  const MainNavigationScreen({
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
    required this.onAddCoins,
    this.onAddStreakFreeze,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        isDarkMode: widget.isDarkMode,
        userCoins: widget.userCoins,
        loginStreak: widget.loginStreak,
        selectedLanguage: widget.selectedLanguage,
        selectedAgeGroup: widget.selectedAgeGroup,
        onToggleTheme: widget.onToggleTheme,
        onOpenShop: () => _showShopModal(context),
        onOpenSearch: () => setState(() => _currentIndex = 1),
      ),

      // VimeoScreen(isDarkMode: widget.isDarkMode), // Vimeo tab hidden (not deleted)
      SearchScreen(isDarkMode: widget.isDarkMode),
      FavoritesScreen(isDarkMode: widget.isDarkMode),
      HistoryScreen(isDarkMode: widget.isDarkMode),
      ProfileScreen(
        isDarkMode: widget.isDarkMode,
        userCoins: widget.userCoins,
        loginStreak: widget.loginStreak,
        streakFreezes: widget.streakFreezes,
        selectedAgeGroup: widget.selectedAgeGroup,
        selectedLanguage: widget.selectedLanguage,
        onToggleTheme: widget.onToggleTheme,
        onAgeGroupChanged: widget.onAgeGroupChanged,
        onLanguageChanged: widget.onLanguageChanged,
        onAddStreakFreeze: widget.onAddStreakFreeze,

        onOpenAgeSelection: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AgeSelectionScreen(
                onAgeSelected: (age) {
                  widget.onAgeGroupChanged?.call(age);
                  Navigator.pop(context);
                },
              ),
            ),
          );
        },
        onOpenLanguageSelection: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LanguageSelectionScreen(
                onLanguageSelected: (lang) {
                  widget.onLanguageChanged?.call(lang);
                  Navigator.pop(context);
                },
              ),
            ),
          );
        },
        onOpenShop: () => _showShopModal(context),
        onGoHome: () => setState(() => _currentIndex = 0),
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: widget.isDarkMode ? const Color(0xFF111827) : Colors.white,
          border: Border(
            top: BorderSide(
              color: widget.isDarkMode
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF22C55E),
          unselectedItemColor: widget.isDarkMode
              ? const Color(0xFF94A3B8)
              : const Color(0xFF64748B),
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: 'Home'),
            // BottomNavigationBarItem(
            //     icon: Icon(Icons.play_arrow_rounded), label: 'Vimeo'), // Vimeo tab hidden
            BottomNavigationBarItem(
                icon: Icon(Icons.search_rounded), label: 'Search'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border_rounded), label: 'Favorites'),
            BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded), label: 'History'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  void _showShopModal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FocusStoreScreen(
          isDarkMode: widget.isDarkMode,
          userCoins: widget.userCoins,
          streakFreezes: widget.streakFreezes,
          onAddCoins: widget.onAddCoins,
          onAddStreakFreeze: widget.onAddStreakFreeze,
        ),
      ),
    );
  }

}

// ═════════════════════════════════════════════════════════════════════════════
// FEATURE 5: HOME SCREEN (HomeScreen.kt)
// ═════════════════════════════════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final int userCoins;
  final int loginStreak;
  final String selectedLanguage;
  final String selectedAgeGroup;
  final ValueChanged<bool>? onToggleTheme;
  final VoidCallback onOpenShop;
  final VoidCallback? onOpenSearch;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.userCoins,
    required this.loginStreak,
    required this.selectedLanguage,
    required this.selectedAgeGroup,
    this.onToggleTheme,
    required this.onOpenShop,
    this.onOpenSearch,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  String? _selectedSubcategory;
  final YouTubeRepository _repository = YouTubeRepository();
  List<Map<String, String>> _youtubeVideos = [];
  bool _isLoading = false;
  bool _isTopicsMenuCollapsed = false;
  final Set<String> _expandedCategories = {};

  static const Map<String, List<Map<String, String>>> _subcategoryItems = {
    'Education & Learning': [
      {'title': 'Study Strategies & Learning Science', 'icon': '🧠'},
      {'title': 'Academic Mastery', 'icon': '📐'},
      {'title': 'Skills & Career Learning', 'icon': '💼'},
      {'title': 'Self-Directed Learning', 'icon': '📖'},
      {'title': 'Critical Thinking & Problem Solving', 'icon': '🧩'},
    ],
    'Competitive Exams': [
      {'title': 'Quantitative Aptitude & Mathematics', 'icon': '📊'},
      {'title': 'Logical Reasoning & Mental Ability', 'icon': '🧩'},
      {'title': 'Verbal Ability & Language', 'icon': '📝'},
      {'title': 'General Awareness & Current Affairs', 'icon': '🌍'},
      {'title': 'Exam Strategy & Performance', 'icon': '🏆'},
    ],
    'Knowledge & Discovery': [
      {'title': 'Science & the Universe', 'icon': '🌌'},
      {'title': 'History & Civilizations', 'icon': '🏛️'},
      {'title': 'Geography & Our Planet', 'icon': '🌍'},
      {'title': 'Human Behavior & Society', 'icon': '👥'},
      {'title': 'Curiosities & Hidden Knowledge', 'icon': '🔍'},
    ],
    'Technology & AI': [
      {'title': 'Artificial Intelligence & Generative AI', 'icon': '🤖'},
      {'title': 'Software Development & Engineering', 'icon': '💻'},
      {'title': 'Emerging Technologies', 'icon': '🚀'},
      {'title': 'Cybersecurity & Digital Safety', 'icon': '🛡️'},
      {'title': 'Future of Technology', 'icon': '🔮'},
    ],
    'Business & Finance': [
      {'title': 'Personal Finance & Wealth Building', 'icon': '💰'},
      {'title': 'Investing & Markets', 'icon': '📈'},
      {'title': 'Entrepreneurship & Startups', 'icon': '🚀'},
      {'title': 'Business Strategy & Leadership', 'icon': '👔'},
      {'title': 'Economics & Financial Intelligence', 'icon': '🌐'},
    ],
    'Spirituality & Philosophy': [
      {'title': 'Indian Wisdom & Vedanta', 'icon': '🕉️'},
      {'title': 'Meditation & Inner Awareness', 'icon': '🧘'},
      {'title': 'Philosophy & Meaning', 'icon': '📜'},
      {'title': 'World Wisdom Traditions', 'icon': '🌍'},
      {'title': 'Purpose, Values & Self-Mastery', 'icon': '🎯'},
    ],
    'Health & Fitness': [
      {'title': 'Exercise & Physical Performance', 'icon': '🏋️'},
      {'title': 'Nutrition & Healthy Eating', 'icon': '🥗'},
      {'title': 'Sleep & Recovery', 'icon': '😴'},
      {'title': 'Mental Wellbeing & Stress Management', 'icon': '🧠'},
      {'title': 'Healthy Lifestyle & Longevity', 'icon': '🌿'},
    ],
  };

  final List<Map<String, String>> _topicMenuItems = const [
    {'title': 'Education & Learning', 'icon': '🎓'},
    {'title': 'Competitive Exams', 'icon': '📚'},
    {'title': 'Knowledge & Discovery', 'icon': '🔬'},
    {'title': 'Technology & AI', 'icon': '🤖'},
    {'title': 'Business & Finance', 'icon': '💼'},
    {'title': 'Spirituality & Philosophy', 'icon': '🕉️'},
    {'title': 'Health & Fitness', 'icon': '❤️'},
  ];

  final List<String> _categories = [
    'All',
    'Education & Learning',
    'Competitive Exams',
    'Knowledge & Discovery',
    'Technology & AI',
    'Business & Finance',
    'Spirituality & Philosophy',
    'Health & Fitness',
  ];

  int _currentPage = 1;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadVideos(_selectedCategory);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 400) {
      _loadMoreVideos();
    }
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedLanguage != widget.selectedLanguage ||
        oldWidget.selectedAgeGroup != widget.selectedAgeGroup) {
      _currentPage = 1;
      _loadVideos(_selectedCategory);
    }
  }

  Future<void> _loadVideos(String category, {bool forceRefresh = false}) async {
    _currentPage = 1;
    setState(() { _isLoading = true; _youtubeVideos = []; });
    try {
      final videos = await _repository.getVideosByCategory(
        category,
        language: widget.selectedLanguage,
        forceRefresh: forceRefresh,
      );
      if (mounted) {
        final seen = <String>{};
        final deduped = <Map<String, String>>[];
        for (final v in videos) {
          final id = v['videoId'] ?? '';
          if (id.isNotEmpty && seen.add(id)) deduped.add(v);
        }
        setState(() { _youtubeVideos = deduped; _isLoading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _loadSubcategoryVideos(String subcategory, {bool forceRefresh = false}) async {
    _currentPage = 1;
    setState(() { _isLoading = true; _youtubeVideos = []; });
    try {
      final videos = await _repository.getVideosBySubcategory(
        subcategory,
        forceRefresh: forceRefresh,
      );
      if (mounted) {
        final seen = <String>{};
        final deduped = <Map<String, String>>[];
        for (final v in videos) {
          final id = v['videoId'] ?? '';
          if (id.isNotEmpty && seen.add(id)) deduped.add(v);
        }
        setState(() { _youtubeVideos = deduped; _isLoading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _loadMoreVideos() async {
    if (_isLoading || _isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    _currentPage++;

    try {
      final more = await _repository.loadMoreVideos(
        category: _selectedCategory,
        subcategory: _selectedSubcategory,
        language: widget.selectedLanguage,
        page: _currentPage,
      );

      if (mounted) {
        final existingIds = _youtubeVideos.map((v) => v['videoId'] ?? '').toSet();
        final newVideos = <Map<String, String>>[];
        for (final v in more) {
          final id = v['videoId'] ?? '';
          if (id.isNotEmpty && !existingIds.contains(id)) {
            existingIds.add(id);
            newVideos.add(v);
          }
        }
        setState(() {
          _youtubeVideos.addAll(newVideos);
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Widget _buildExploreTopicsCard(bool isDark, Color textColor, Color subTextColor, Color cardBg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('📁', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore 7 Topics &',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isTopicsMenuCollapsed
                          ? 'Tap to expand topic menu'
                          : 'Tap to collapse topic menu',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isTopicsMenuCollapsed = !_isTopicsMenuCollapsed;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isTopicsMenuCollapsed ? 'Open' : 'Close',
                        style: const TextStyle(
                          color: Color(0xFF0284C7),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        _isTopicsMenuCollapsed
                            ? Icons.keyboard_arrow_down_rounded
                            : Icons.keyboard_arrow_up_rounded,
                        size: 16,
                        color: const Color(0xFF0284C7),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (!_isTopicsMenuCollapsed) ...[
            const SizedBox(height: 12),
            ..._topicMenuItems.map((item) {
              final catTitle = item['title']!;
              final iconEmoji = item['icon']!;
              final isExpanded = _expandedCategories.contains(catTitle);
              final subcategoryList = _subcategoryItems[catTitle] ?? [];

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isExpanded
                        ? const Color(0xFF93C5FD)
                        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    width: isExpanded ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedCategories.remove(catTitle);
                          } else {
                            _expandedCategories.add(catTitle);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Builder(builder: (context) {
                          final isCatActive = _selectedSubcategory != null &&
                              (_getSubcategoryInfo(_selectedSubcategory!)?['category'] == catTitle);

                          return Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  iconEmoji,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  catTitle,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              if (isCatActive) ...[
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F2FE),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFBAE6FD)),
                                  ),
                                  child: const Text(
                                    'ACTIVE',
                                    style: TextStyle(
                                      color: Color(0xFF0284C7),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: isCatActive ? const Color(0xFF0284C7) : subTextColor,
                                size: 22,
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                    if (isExpanded && subcategoryList.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: Column(
                          children: subcategoryList.map((subcatItem) {
                            final subTitle = subcatItem['title']!;
                            final subIcon = subcatItem['icon']!;
                            final isSubSelected = _selectedSubcategory == subTitle;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  if (_selectedSubcategory == subTitle) {
                                    // Toggle off: clear subcategory and show all videos in All tab
                                    setState(() {
                                      _selectedSubcategory = null;
                                    });
                                    _loadVideos('All');
                                  } else {
                                    // Stay in 'All' tab and load the subcategory videos below the card
                                    setState(() {
                                      _selectedSubcategory = subTitle;
                                    });
                                    _loadSubcategoryVideos(subTitle);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSubSelected
                                        ? (isDark ? const Color(0xFF0F2027) : const Color(0xFFEFF6FF))
                                        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC)),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSubSelected
                                          ? const Color(0xFF38BDF8)
                                          : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                      width: isSubSelected ? 1.5 : 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        subIcon,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          subTitle,
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                            color: isSubSelected ? const Color(0xFF0284C7) : textColor,
                                          ),
                                        ),
                                      ),
                                      if (isSubSelected) ...[
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: Color(0xFF0284C7),
                                          size: 18,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Map<String, String>? _getSubcategoryInfo(String subcatTitle) {
    for (final entry in _subcategoryItems.entries) {
      for (final item in entry.value) {
        if (item['title'] == subcatTitle) {
          return {
            'category': entry.key,
            'title': item['title']!,
            'icon': item['icon']!,
          };
        }
      }
    }
    return null;
  }

  Widget _buildSelectedSubcategoryBanner(bool isDark, Color textColor, Color subTextColor) {
    final info = _getSubcategoryInfo(_selectedSubcategory ?? '');
    final catName = info?['category'] ?? 'Education & Learning';
    final subIcon = info?['icon'] ?? '📐';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF38BDF8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            _selectedSubcategory = null;
            _isTopicsMenuCollapsed = false;
          });
          _loadVideos('All');
        },
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE0F2FE),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                subIcon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$catName ›',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to change topic or category',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Change',
                  style: TextStyle(
                    color: Color(0xFF0284C7),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF0284C7),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    final isAllCategory = _selectedCategory == 'All';

    return Container(
      color: bgColor,
      child: SafeArea(
        child: Column(
          children: [
            // ── 1. Top Bar Header (Logo + Green "You2Focus" + Search + Theme Pill) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // App Grid Logo
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
                        'You2Focus',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF00E676), // Bright Green matching screenshot
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      // Continuous Streak Badge
                      ValueListenableBuilder<StreakData>(
                        valueListenable: StreakService.streakNotifier,
                        builder: (context, streakData, _) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text("🔥", style: TextStyle(fontSize: 13)),
                                const SizedBox(width: 4),
                                Text(
                                  "${streakData.streakCount}d",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Search Icon (Right Side)
                      IconButton(
                        onPressed: widget.onOpenSearch,
                        icon: Icon(Icons.search, color: textColor, size: 24),
                        tooltip: 'Search',
                      ),
                      const SizedBox(width: 4),

                      // Theme Switcher Pill (Desert Light / Cosmic Night Dark)
                      GestureDetector(
                        onTap: () {
                          widget.onToggleTheme?.call(!isDark);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 34,
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: isDark
                                ? const LinearGradient(
                                    colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  )
                                : const LinearGradient(
                                    colors: [Color(0xFFE28743), Color(0xFFFDE047)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF6366F1).withValues(alpha: 0.4)
                                  : const Color(0xFFF59E0B).withValues(alpha: 0.6),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isDark ? Colors.indigo : Colors.orange).withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: isDark
                                ? [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F172A),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: const [
                                          BoxShadow(color: Colors.black26, blurRadius: 4),
                                        ],
                                      ),
                                      child: const Text(
                                        'Dark',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    const Text('🌙', style: TextStyle(fontSize: 13)),
                                    const SizedBox(width: 3),
                                  ]
                                : [
                                    const SizedBox(width: 4),
                                    const Text('☀️', style: TextStyle(fontSize: 13)),
                                    const SizedBox(width: 5),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: const [
                                          BoxShadow(color: Colors.black12, blurRadius: 4),
                                        ],
                                      ),
                                      child: const Text(
                                        'Light',
                                        style: TextStyle(
                                          color: Color(0xFF78350F),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                          ),
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),

            // ── 2. Subheader (Red YouTube Logo + YouTube text centered) ─────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 13),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'YouTube',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── 3. Category Chips Row ───────────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: _categories.map((category) {
                  final isSelected = category == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        if (_selectedCategory != category) {
                          setState(() {
                            _selectedCategory = category;
                            _selectedSubcategory = null;
                          });
                          _loadVideos(category);
                        } else if (_selectedSubcategory != null) {
                          setState(() => _selectedSubcategory = null);
                          _loadVideos(category);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF38BDF8)
                              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF38BDF8)
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                          ),
                        ),
                        child: Row(
                          children: [
                            if (category == 'All') ...[
                              Icon(Icons.grid_view_rounded,
                                  size: 15, color: isSelected ? const Color(0xFF0F172A) : subTextColor),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              category,
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF0F172A)
                                    : (isDark ? Colors.white : const Color(0xFF334155)),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 12),

            // ── 4. Video List & Topic Accordion ───────────────────────────────
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
                : RefreshIndicator(
                    onRefresh: () => _selectedSubcategory != null
                      ? _loadSubcategoryVideos(_selectedSubcategory!, forceRefresh: true)
                      : _loadVideos(_selectedCategory, forceRefresh: true),
                    color: const Color(0xFF38BDF8),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: isAllCategory ? (_youtubeVideos.length + 2) : (_youtubeVideos.length + 1),
                      itemBuilder: (context, index) {
                        if (isAllCategory && index == 0) {
                          if (_selectedSubcategory != null) {
                            return _buildSelectedSubcategoryBanner(isDark, textColor, subTextColor);
                          }
                          return _buildExploreTopicsCard(isDark, textColor, subTextColor, cardBg);
                        }

                        final videoIndex = isAllCategory ? (index - 1) : index;
                        
                        // Bottom Infinite Loader / Load More Button
                        if (videoIndex == _youtubeVideos.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Center(
                              child: _isLoadingMore
                                  ? const SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Color(0xFF38BDF8),
                                      ),
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: _loadMoreVideos,
                                      icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                                      label: const Text(
                                        'Load More Videos 🚀',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF38BDF8),
                                        foregroundColor: const Color(0xFF0F172A),
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        elevation: 2,
                                      ),
                                    ),
                            ),
                          );
                        }

                        if (videoIndex > _youtubeVideos.length) return const SizedBox.shrink();
                        final video = _youtubeVideos[videoIndex];

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
                                  category: _selectedCategory,
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
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: Image.network(
                                      video['thumbnail']!,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 200,
                                          width: double.infinity,
                                          color: Colors.blueGrey,
                                          child: const Center(child: Icon(Icons.video_library, size: 50, color: Colors.white)),
                                        );
                                      },
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      video['title'] ?? 'Title',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                        height: 1.25,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      video['channel'] ?? 'Channel',
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
                      );
                    },
                  ),
                ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// FEATURE 6: VIMEO EDUCATIONAL SCREEN (VimeoScreen.kt)
// ═════════════════════════════════════════════════════════════════════════════

class VimeoScreen extends StatefulWidget {
  final bool isDarkMode;

  const VimeoScreen({super.key, required this.isDarkMode});

  @override
  State<VimeoScreen> createState() => _VimeoScreenState();
}

class _VimeoScreenState extends State<VimeoScreen> {
  String _selectedCategory = 'All';
  final VimeoRepository _repository = VimeoRepository();
  List<Map<String, String>> _vimeoVideos = [];
  bool _isLoading = false;

  final List<String> _categories = [
    'All',
    'Education & Learning',
    'Competitive Exams',
    'Business & Finance',
    'Technology & AI',
    'Health & Fitness',
    'Spirituality & Philosophy',
    'Knowledge & Discovery'
  ];

  @override
  void initState() {
    super.initState();
    _loadVideos(_selectedCategory);
  }

  Future<void> _loadVideos(String category, {bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final videos = await _repository.getVideosByCategory(category, forceRefresh: forceRefresh);
      if (mounted) {
        setState(() {
          _vimeoVideos = videos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? const Color(0xFF0B101A) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with centered Vimeo logo and text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 44,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(Icons.menu_rounded, color: Color(0xFF1AB7EA), size: 26),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1AB7EA),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1AB7EA).withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'v',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            height: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'vimeo',
                        style: TextStyle(
                          color: Color(0xFF1AB7EA),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 44,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SearchScreen(isDarkMode: widget.isDarkMode),
                            ),
                          );
                        },
                        icon: Icon(Icons.search, color: widget.isDarkMode ? Colors.white : Colors.black, size: 26),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
                ],
              ),
            ),


            
            // Categories
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        if (_selectedCategory != category) {
                          setState(() {
                            _selectedCategory = category;
                          });
                          _loadVideos(category);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue
                              : (widget.isDarkMode ? const Color(0xFF1E293B) : Colors.grey[200]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : (widget.isDarkMode ? Colors.white : Colors.black87),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Video List
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                : _vimeoVideos.isEmpty
                  ? Center(
                      child: Text(
                        "No videos found for this category.",
                        style: TextStyle(color: widget.isDarkMode ? Colors.white54 : Colors.black54),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _loadVideos(_selectedCategory, forceRefresh: true),
                      color: Colors.blue,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _vimeoVideos.length,
                        itemBuilder: (context, index) {
                          final video = _vimeoVideos[index];
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VideoPlayerScreen(
                                    videoId: video['videoId'] ?? '',
                                    title: video['title'] ?? 'Educational Video',
                                    channel: video['channel'] ?? 'Vimeo Creator',
                                    thumbnail: video['thumbnail'] ?? '',
                                    category: _selectedCategory,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: widget.isDarkMode ? const Color(0xFF0F172A) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Thumbnail
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                        child: Image.network(
                                          video['thumbnail']!,
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              height: 200,
                                              width: double.infinity,
                                              color: Colors.blueGrey,
                                              child: const Center(child: Icon(Icons.video_library, size: 50, color: Colors.white)),
                                            );
                                          },
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.85),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            video['duration'] ?? '10:00',
                                            style: const TextStyle(color: Colors.white, fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Info
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          video['title'] ?? 'Video',
                                          style: TextStyle(
                                            color: widget.isDarkMode ? Colors.white : Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          (video['channel'] ?? 'Vimeo Creator')
                                              .replaceAll(' • null', '')
                                              .replaceAll('• null', '')
                                              .trim(),
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
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
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// FEATURE 7: SEARCH SCREEN (SearchScreen.kt) - Ported to lib/ui/search_screen.dart
// ═════════════════════════════════════════════════════════════════════════════

// ═════════════════════════════════════════════════════════════════════════════
// FEATURE 8: FAVORITES SCREEN (FavoritesScreen.kt) - Ported to lib/ui/favorites_screen.dart
// ═════════════════════════════════════════════════════════════════════════════

// ═════════════════════════════════════════════════════════════════════════════
// FEATURE 9: HISTORY SCREEN (HistoryScreen.kt) - Ported to lib/ui/history_screen.dart
// ═════════════════════════════════════════════════════════════════════════════

// ═════════════════════════════════════════════════════════════════════════════
// FEATURE 10: PROFILE & SETTINGS SCREEN (ProfileScreen.kt)

class ShopModal extends StatelessWidget {
  final bool isDarkMode;
  final int userCoins;
  final ValueChanged<int> onAddCoins;

  const ShopModal({
    super.key,
    required this.isDarkMode,
    required this.userCoins,
    required this.onAddCoins,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Focus Shop',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '🪙 $userCoins',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => onAddCoins(10),
            icon: const Text('🎬'),
            label: const Text('Watch Ad (+10 Coins)'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Close'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// VIDEO PLAYER SCREEN - Ported to lib/ui/video_player_screen.dart
// ═════════════════════════════════════════════════════════════════════════════
