import 'package:figma_glass/figma_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GlassSettings', () {
    test('presets carry the values read from Figma', () {
      expect(GlassSettings.input.refraction, 80);
      expect(GlassSettings.input.depth, 20);
      expect(GlassSettings.input.dispersion, 50);
      expect(GlassSettings.card.lightAngle, -53);
      expect(GlassSettings.card.depth, 100);
      expect(GlassSettings.card.hasRefraction, isFalse);
    });

    test('values are clamped to their range', () {
      const s = GlassSettings(
        refraction: 250,
        dispersion: -5,
        lightIntensity: 3,
      );
      expect(s.refractionNormalized, 1);
      expect(s.dispersionNormalized, 0);
      expect(s.lightNormalized, 1);
    });

    test('frost maps to blur sigma', () {
      expect(const GlassSettings(frost: 4).blurSigma, 2);
    });

    test('light direction: -45° is top-left, 0° is top', () {
      final tl = const GlassSettings(lightAngle: -45).lightDirection;
      expect(tl.dx, lessThan(0));
      expect(tl.dy, lessThan(0));
      final top = const GlassSettings(lightAngle: 0).lightDirection;
      expect(top.dx.abs(), lessThan(1e-9));
      expect(top.dy, -1);
    });

    test('copyWith and equality', () {
      final a = GlassSettings.input;
      expect(a.copyWith(), a);
      expect(a.copyWith(frost: 9), isNot(a));
    });

    test('calibration toString lists every gain', () {
      final text = const GlassCalibration(oppositePeak: 0.5).toString();
      expect(text, contains('oppositePeak: 0.5'));
      expect(text, contains('darkFloor: 0.04'));
    });
  });

  testWidgets('FigmaGlass lays out with its child and rebuilds on change', (
    tester,
  ) async {
    Widget app(GlassSettings s) => MaterialApp(
      home: Stack(
        children: [
          Positioned(
            left: 20,
            top: 20,
            child: SizedBox(
              width: 200,
              height: 80,
              child: FigmaGlass(settings: s, child: const Text('hi')),
            ),
          ),
        ],
      ),
    );

    await tester.pumpWidget(app(GlassSettings.input));
    await tester.pumpAndSettle();
    expect(find.text('hi'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(app(GlassSettings.card));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
