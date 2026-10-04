import 'dart:io';

import 'package:figma_glass_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Opens the gallery and every demo on a real device or simulator, and saves
/// a screenshot of each, to check the glass shader draws on that platform.
///
/// flutter drive --driver=test_driver/integration_test.dart \
///   --target=integration_test/gallery_test.dart
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // The demos animate forever, so wait a fixed time instead of settling.
  Future<void> wait(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('the gallery and every demo draw their glass', (tester) async {
    if (Platform.isAndroid) await binding.convertFlutterSurfaceToImage();
    await tester.pumpWidget(const GlassGalleryApp());
    await wait(tester);
    await binding.takeScreenshot('0_gallery');

    const demos = {
      'Tab bar over a feed': '1_feed',
      'Music player': '2_music',
      'Wallet card': '3_wallet',
      'Sign in': '4_sign_in',
      'Playground': '5_playground',
    };
    for (final MapEntry(key: title, value: name) in demos.entries) {
      final tile = find.text(title);
      await tester.scrollUntilVisible(
        tile,
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(tile);
      await wait(tester);
      await binding.takeScreenshot(name);
      expect(tester.takeException(), isNull, reason: title);

      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await wait(tester);
    }
  });
}
