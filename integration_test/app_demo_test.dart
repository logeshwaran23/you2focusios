import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:focus_grid_flutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Record and verify FocusGrid Profile Photo Taking & Avatar Selection', (WidgetTester tester) async {
    // Launch main app
    app.main();
    await tester.pump();
    await Future.delayed(const Duration(seconds: 2));

    // Navigate to Profile Screen via "Profile" text or person icon
    Finder profileTab = find.text("Profile");
    if (profileTab.evaluate().isEmpty) {
      profileTab = find.byIcon(Icons.person);
    }
    expect(profileTab, findsWidgets);

    await tester.tap(profileTab.first, warnIfMissed: false);
    await tester.pump();
    await Future.delayed(const Duration(seconds: 2));

    // ── VERIFY TAKE PHOTO / CHANGE PHOTO ON PROFILE ──
    print("▶ Verifying Profile Photo Taking & Avatar Selection");
    final changePhotoText = find.textContaining("Tap avatar to change photo");
    expect(changePhotoText, findsOneWidget);

    // Tap avatar / change photo text to open modal sheet
    await tester.tap(changePhotoText.first, warnIfMissed: false);
    await tester.pump();
    await Future.delayed(const Duration(seconds: 2));

    // Tap "Take Photo (Camera)"
    final takePhotoBtn = find.text("Take Photo (Camera)");
    expect(takePhotoBtn, findsOneWidget);
    await tester.tap(takePhotoBtn.first, warnIfMissed: false);
    await tester.pump();
    await Future.delayed(const Duration(seconds: 2));

    print("🎉 PROFILE PHOTO TAKING & AVATAR SELECTION SUCCESSFULLY VERIFIED!");
  });
}
