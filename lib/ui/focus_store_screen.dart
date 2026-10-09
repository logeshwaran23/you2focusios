import 'dart:math' as math;
import 'package:flutter/material.dart';

class FocusStoreScreen extends StatefulWidget {
  final bool isDarkMode;
  final int userCoins;
  final int streakFreezes;
  final ValueChanged<int> onAddCoins;
  final ValueChanged<int>? onAddStreakFreeze;

  const FocusStoreScreen({
    super.key,
    required this.isDarkMode,
    required this.userCoins,
    this.streakFreezes = 0,
    required this.onAddCoins,
    this.onAddStreakFreeze,
  });

  @override
  State<FocusStoreScreen> createState() => _FocusStoreScreenState();
}

class _FocusStoreScreenState extends State<FocusStoreScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;

  double _currentAngle = 0.0;
  bool _isSpinning = false;
  int _spinsUsed = 0;
  final int _maxSpins = 3;

  final List<Map<String, dynamic>> _segments = [
    {'label': '100 Coins', 'coins': 100, 'color': const Color(0xFFF97316)}, // Orange
    {'label': 'Try Again', 'coins': 0, 'color': const Color(0xFF334155)},   // Slate
    {'label': '10 Coins', 'coins': 10, 'color': const Color(0xFFEAB308)},   // Yellow
    {'label': '15 Coins', 'coins': 15, 'color': const Color(0xFF06B6D4)},   // Cyan
    {'label': '20 Coins', 'coins': 20, 'color': const Color(0xFFA855F7)},   // Purple
    {'label': '50 Coins', 'coins': 50, 'color': const Color(0xFF22C55E)},   // Green
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _spinAnimation = AlwaysStoppedAnimation<double>(0.0);
  }


  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning) return;
    if (_spinsUsed >= _maxSpins) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚡ You have used all 3 spins for today! Check back tomorrow.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() {
      _isSpinning = true;
    });

    final random = math.Random();
    final targetIndex = random.nextInt(_segments.length);
    final targetReward = _segments[targetIndex];

    final segmentAngle = (2 * math.pi) / _segments.length;
    // Calculate target angle to point chosen segment at top (pointer at top)
    final targetSegmentCenterAngle = (targetIndex * segmentAngle) + (segmentAngle / 2);
    final totalRotations = 5 + random.nextInt(3); // 5 to 7 full rotations
    final finalAngle = (totalRotations * 2 * math.pi) + (2 * math.pi - targetSegmentCenterAngle);

    _spinAnimation = Tween<double>(
      begin: _currentAngle,
      end: _currentAngle + finalAngle,
    ).animate(CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOutCubic,
    ));

    _spinController.forward(from: 0.0).then((_) {
      final coinsWon = targetReward['coins'] as int;
      final label = targetReward['label'] as String;

      setState(() {
        _currentAngle = (_currentAngle + finalAngle) % (2 * math.pi);
        _isSpinning = false;
        _spinsUsed++;
      });

      if (coinsWon > 0) {
        widget.onAddCoins(coinsWon);
        _showRewardDialog('🎉 Congratulations!', 'You won $label!');
      } else {
        _showRewardDialog('😅 Try Again!', 'Better luck on your next spin!');
      }
    });
  }

  void _showRewardDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : const Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: widget.isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEAB308),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Awesome!', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _buyPass(String name, int cost) {
    if (widget.userCoins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Not enough coins to purchase $name! Watch ads to earn more.'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }
    widget.onAddCoins(-cost);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('👑 Successfully activated $name! Enjoy premium features.'),
        backgroundColor: const Color(0xFF22C55E),
      ),
    );
  }

  void _buyStreakFreeze() {
    const cost = 29;
    if (widget.userCoins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Not enough coins for Streak Freeze! Watch ads to earn more.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }
    widget.onAddCoins(-cost);
    widget.onAddStreakFreeze?.call(1);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❄️ Streak Freeze acquired! Your streak is now protected.'),
        backgroundColor: Color(0xFF0284C7),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bgColor = isDark ? const Color(0xFF0B0F19) : const Color(0xFFF1F5F9);
    final cardBg = isDark ? const Color(0xFF131C2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("👑", style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              "Focus Store",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. YOUR COIN BALANCE Card ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "YOUR COIN BALANCE",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text("🪙", style: TextStyle(fontSize: 30)),
                          const SizedBox(width: 8),
                          Text(
                            "${widget.userCoins}",
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFACC15),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      widget.onAddCoins(10);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🎬 Ad completed! +10 Coins added.'),
                          backgroundColor: Color(0xFFEAB308),
                        ),
                      );
                    },
                    icon: const Text("🎬", style: TextStyle(fontSize: 14)),
                    label: const Text(
                      "Watch Ad (+10 🪙)",
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEAB308),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── 2. PREMIUM BENEFITS INCLUDED Banner ────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1B4B), Color(0xFF1E293B)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEAB308).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Text("🎁", style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "PREMIUM BENEFITS INCLUDED",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFACC15),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Tap to view 6 exclusive perks & features",
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      _showPerksModal(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFACC15),
                      side: const BorderSide(color: Color(0xFFFACC15)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("View Perks →", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── 3. DAILY FORTUNE SPIN Card ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFEAB308).withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEAB308).withValues(alpha: 0.1),
                    blurRadius: 15,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "🎯 DAILY FORTUNE SPIN",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFACC15),
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              "1 Free Spin + 2 Bonus Ad Spins Daily!",
                              style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAB308).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFEAB308).withValues(alpha: 0.6)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "$_spinsUsed/$_maxSpins Spins",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFACC15),
                              ),
                            ),
                            Text(
                              _spinsUsed >= _maxSpins ? "Used" : "Available",
                              style: const TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Interactive Fortune Wheel Graphic
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _spinController,
                        builder: (context, child) {
                          final angle = _spinAnimation.value;
                          return Transform.rotate(
                            angle: angle,
                            child: SizedBox(
                              width: 230,
                              height: 230,
                              child: CustomPaint(
                                painter: _FortuneWheelPainter(_segments),
                              ),
                            ),
                          );
                        },
                      ),
                      // Top Pointer Arrow
                      Positioned(
                        top: 0,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 22),
                        ),
                      ),
                      // Center Hub
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFACC15), width: 3),
                        ),
                        child: const Center(
                          child: Text("🎯", style: TextStyle(fontSize: 20)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // FREE SPIN NOW Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSpinning ? null : _spinWheel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEAB308),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isSpinning
                                ? "SPINNING..."
                                : (_spinsUsed == 0 ? "FREE SPIN NOW 🎯" : "SPIN AGAIN 🎯"),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── 4. PREMIUM MEMBERSHIP PASSES Header ───────────────────────────
            Row(
              children: const [
                Text("👑", style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Text(
                  "PREMIUM MEMBERSHIP PASSES",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFACC15),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Pass 1: 1 Day Premium Pass
            _buildPassCard(
              isDarkMode: isDark,
              cardBg: cardBg,
              textColor: textColor,
              subTextColor: subTextColor,
              badgeText: "BEST STARTER",
              badgeColor: const Color(0xFFD97706),
              title: "1 Day Premium Pass",
              subtitle: "Ideal for single intensive study sessions",
              originalPrice: 129,
              discountPrice: 99,
              onTap: () => _buyPass("1 Day Premium Pass", 99),
            ),
            const SizedBox(height: 12),

            // Pass 2: 7 Days Premium Pass
            _buildPassCard(
              isDarkMode: isDark,
              cardBg: cardBg,
              textColor: textColor,
              subTextColor: subTextColor,
              badgeText: "POPULAR",
              badgeColor: const Color(0xFFEC4899),
              title: "7 Days Premium Pass",
              subtitle: "Full week of uninterrupted focus & AI tools",
              originalPrice: 669,
              discountPrice: 399,
              onTap: () => _buyPass("7 Days Premium Pass", 399),
            ),
            const SizedBox(height: 12),

            // Pass 3: 30 Days Premium Pass
            _buildPassCard(
              isDarkMode: isDark,
              cardBg: cardBg,
              textColor: textColor,
              subTextColor: subTextColor,
              badgeText: "EXCLUSIVE FOR YOU 👑",
              badgeColor: const Color(0xFFEAB308),
              title: "30 Days Premium Pass",
              subtitle: "Ultimate value — 1 month of full unlimited mastery",
              originalPrice: 1699,
              discountPrice: 999,
              onTap: () => _buyPass("30 Days Premium Pass", 999),
            ),
            const SizedBox(height: 24),

            // ── 5. STREAK PROTECTION Header ───────────────────────────────────
            Row(
              children: const [
                Text("🛡️", style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Text(
                  "STREAK PROTECTION",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF38BDF8),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Streak Freeze Purchase Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Text("❄️", style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Streak Freeze",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Auto-protects your streak if you miss a day! (Owned: ${widget.streakFreezes}/2 max)",
                          style: TextStyle(fontSize: 11.5, color: subTextColor),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: _buyStreakFreeze,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "🪙 59",
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Colors.white70,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "🪙 29",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFACC15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPassCard({
    required bool isDarkMode,
    required Color cardBg,
    required Color textColor,
    required Color subTextColor,
    required String badgeText,
    required Color badgeColor,
    required String title,
    required String subtitle,
    required int originalPrice,
    required int discountPrice,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badgeText,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11.5, color: subTextColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "🪙 $originalPrice",
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Colors.white70,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "🪙 $discountPrice",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFACC15),
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
    );
  }

  void _showPerksModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: widget.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "👑 Premium Perks Included",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPerkItem("🚫 Ad-free study experience across all videos"),
            _buildPerkItem("⚡ AI Focus summary & takeaways extraction"),
            _buildPerkItem("❄️ Free monthly Streak Freeze passes"),
            _buildPerkItem("🎯 Double Focus Coins from daily spin rewards"),
            _buildPerkItem("🎧 Background audio mode for offline listening"),
            _buildPerkItem("🎓 Exclusive access to masterclasses & courses"),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEAB308),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Got It!", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerkItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13.5)),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for drawing the 6-segment Fortune Wheel
class _FortuneWheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> segments;

  _FortuneWheelPainter(this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final sweepAngle = (2 * math.pi) / segments.length;

    final paint = Paint()..style = PaintingStyle.fill;
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < segments.length; i++) {
      final startAngle = (i * sweepAngle) - (math.pi / 2);
      paint.color = segments[i]['color'] as Color;

      // Draw Slice
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw Slice Border
      final borderPaint = Paint()
        ..color = const Color(0xFFFACC15).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      // Draw Label Text
      final labelAngle = startAngle + (sweepAngle / 2);
      final textRadius = radius * 0.65;
      final textX = center.dx + textRadius * math.cos(labelAngle);
      final textY = center.dy + textRadius * math.sin(labelAngle);

      textPainter.text = TextSpan(
        text: segments[i]['label'] as String,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      );
      textPainter.layout();

      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(labelAngle + (math.pi / 2));
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FortuneWheelPainter oldDelegate) => false;
}
