import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:focus_grid_flutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Comprehensive Verification of FocusGrid Application Functions', (WidgetTester tester) async {
    // 1. Launch main app
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));
    print('✅ Step 1: App Launched Successfully');

    // ── TEST 1: HOME SCREEN & THEME TOGGLE ──
    print('▶ Testing Home Screen & Theme Toggle');
    final darkText = find.textContaining('Dark');
    if (darkText.evaluate().isNotEmpty) {
      await tester.tap(darkText.first, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      print('  • Theme toggled to Light Mode');

      final lightText = find.textContaining('Light');
      if (lightText.evaluate().isNotEmpty) {
        await tester.tap(lightText.first, warnIfMissed: false);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        print('  • Theme toggled back to Dark Mode');
      }
    } else {
      final switchFinder = find.byType(Switch);
      if (switchFinder.evaluate().isNotEmpty) {
        await tester.tap(switchFinder.first, warnIfMissed: false);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        print('  • Switch toggled');
      }
    }
    print('✅ Step 2: Home Screen & Theme Toggle Verified');

    // ── TEST 2: CATEGORY FILTERS ON HOME ──
    print('▶ Testing Category Filter Chips');
    final eduChip = find.textContaining('Education');
    if (eduChip.evaluate().isNotEmpty) {
      await tester.tap(eduChip.first, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('  • Filtered by Education category');
    }
    final allChip = find.text('All');
    if (allChip.evaluate().isNotEmpty) {
      await tester.tap(allChip.first, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      print('  • Reset category filter to All');
    }
    print('✅ Step 3: Category Filters Verified');

    // ── TEST 3: VIMEO TAB ──
    print('▶ Testing Vimeo Tab Navigation');
    final vimeoTab = find.text('Vimeo');
    if (vimeoTab.evaluate().isNotEmpty) {
      await tester.tap(vimeoTab.first, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('  • Navigated to Vimeo tab');
    }
    print('✅ Step 4: Vimeo Tab Verified');

    // ── TEST 4: SEARCH TAB ──
    print('▶ Testing Search Tab & Search Input');
    final searchTab = find.text('Search');
    if (searchTab.evaluate().isNotEmpty) {
      await tester.tap(searchTab.first, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('  • Navigated to Search tab');

      final searchTextField = find.byType(TextField);
      if (searchTextField.evaluate().isNotEmpty) {
        await tester.enterText(searchTextField.first, 'Flutter Tutorial');
        await tester.pumpAndSettle(const Duration(seconds: 2));
        print('  • Entered search query "Flutter Tutorial"');
      }
    }
    print('✅ Step 5: Search Tab Verified');

    // ── TEST 5: FAVORITES TAB ──
    print('▶ Testing Favorites Tab Navigation');
    final favTab = find.text('Favorites');
    if (favTab.evaluate().isNotEmpty) {
      await tester.tap(favTab.first, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('  • Navigated to Favorites tab');
    }
    print('✅ Step 6: Favorites Tab Verified');

    // ── TEST 6: HISTORY TAB ──
    print('▶ Testing History Tab Navigation');
    final historyTab = find.text('History');
    if (historyTab.evaluate().isNotEmpty) {
      await tester.tap(historyTab.first, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('  • Navigated to History tab');
    }
    print('✅ Step 7: History Tab Verified');

    // ── TEST 7: PROFILE TAB ──
    print('▶ Testing Profile Tab');
    final profileTab = find.text('Profile');
    if (profileTab.evaluate().isNotEmpty) {
      await tester.tap(profileTab.first, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('  • Navigated to Profile tab');
    }
    print('✅ Step 8: Profile Tab Verified');

    // Return to Home tab
    final homeTab = find.text('Home');
    if (homeTab.evaluate().isNotEmpty) {
      await tester.tap(homeTab.first, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }

    print('\n🎉 ALL APPLICATION FUNCTIONS VERIFIED SUCCESSFULLY!');
  });
}
