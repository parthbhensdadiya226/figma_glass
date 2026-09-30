import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';

/// The adjustable values of Figma's Glass effect.
///
/// Names and ranges follow Figma's Glass panel, so values read off a Figma
/// node can be pasted in directly. Values outside a field's range are
/// clamped when the glass is drawn.
@immutable
class GlassSettings {
  /// Creates Glass values. The defaults match a new Glass effect in Figma.
  const GlassSettings({
    this.lightAngle = -45,
    this.lightIntensity = 0.8,
    this.refraction = 0,
    this.depth = 20,
    this.dispersion = 0,
    this.frost = 4,
    this.splay = 0,
  });

  /// Direction the light comes from, in degrees. 0° is from the top, positive
  /// is clockwise, so -45° lights the top-left edges (as in Figma's dial).
  final double lightAngle;

  /// Light strength, 0..1 (Figma shows 0–100%).
  final double lightIntensity;

  /// How strongly the backdrop bends near the edges, 0..100.
  final double refraction;

  /// How far in from the edge the bevel, light and refraction reach, in
  /// logical pixels, 0..100. Capped at half the shortest side of the glass.
  final double depth;

  /// Chromatic aberration (RGB split) of the refraction, 0..100.
  final double dispersion;

  /// Blur of the backdrop, 0..100. Figma's Frost value maps to a Gaussian
  /// sigma of `frost / 2`.
  final double frost;

  /// How far the refraction spreads inward, 0..100.
  final double splay;

  /// Figma "Prize card" style: frosted panel with a soft, wide light bevel.
  static const GlassSettings card = GlassSettings(
    lightAngle: -53,
    lightIntensity: 0.8,
    refraction: 0,
    depth: 100,
    dispersion: 0,
    frost: 4,
    splay: 0,
  );

  /// Figma "Sign-up input" style: strong edge refraction with colour fringing.
  static const GlassSettings input = GlassSettings(
    lightAngle: -45,
    lightIntensity: 0.8,
    refraction: 80,
    depth: 20,
    dispersion: 50,
    frost: 4,
    splay: 0,
  );

  /// [lightIntensity] clamped to 0..1.
  double get lightNormalized => lightIntensity.clamp(0.0, 1.0);

  /// [refraction] as 0..1.
  double get refractionNormalized => (refraction / 100).clamp(0.0, 1.0);

  /// [depth] as 0..1.
  double get depthNormalized => (depth / 100).clamp(0.0, 1.0);

  /// [dispersion] as 0..1.
  double get dispersionNormalized => (dispersion / 100).clamp(0.0, 1.0);

  /// [splay] as 0..1.
  double get splayNormalized => (splay / 100).clamp(0.0, 1.0);

  /// Gaussian sigma applied to the backdrop, for a given frost-to-sigma scale.
  double blurSigmaFor(double scale) => frost.clamp(0.0, 100.0) * scale;

  /// Gaussian sigma with the default scale (`frost / 2`).
  double get blurSigma => blurSigmaFor(0.5);

  /// Unit vector pointing towards the light, in screen coordinates (y down).
  ({double dx, double dy}) get lightDirection {
    final a = lightAngle * math.pi / 180;
    return (dx: math.sin(a), dy: -math.cos(a));
  }

  /// Whether the backdrop is bent at all, which needs the fragment shader.
  bool get hasRefraction => refraction > 0 || dispersion > 0;

  /// Returns a copy with the given values replaced.
  GlassSettings copyWith({
    double? lightAngle,
    double? lightIntensity,
    double? refraction,
    double? depth,
    double? dispersion,
    double? frost,
    double? splay,
  }) {
    return GlassSettings(
      lightAngle: lightAngle ?? this.lightAngle,
      lightIntensity: lightIntensity ?? this.lightIntensity,
      refraction: refraction ?? this.refraction,
      depth: depth ?? this.depth,
      dispersion: dispersion ?? this.dispersion,
      frost: frost ?? this.frost,
      splay: splay ?? this.splay,
    );
  }

  /// Interpolates between [a] and [b], for animating from one look to
  /// another. [t] is 0 for [a] and 1 for [b].
  static GlassSettings lerp(GlassSettings a, GlassSettings b, double t) {
    return GlassSettings(
      lightAngle: lerpDouble(a.lightAngle, b.lightAngle, t)!,
      lightIntensity: lerpDouble(a.lightIntensity, b.lightIntensity, t)!,
      refraction: lerpDouble(a.refraction, b.refraction, t)!,
      depth: lerpDouble(a.depth, b.depth, t)!,
      dispersion: lerpDouble(a.dispersion, b.dispersion, t)!,
      frost: lerpDouble(a.frost, b.frost, t)!,
      splay: lerpDouble(a.splay, b.splay, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is GlassSettings &&
      other.lightAngle == lightAngle &&
      other.lightIntensity == lightIntensity &&
      other.refraction == refraction &&
      other.depth == depth &&
      other.dispersion == dispersion &&
      other.frost == frost &&
      other.splay == splay;

  @override
  int get hashCode => Object.hash(
    lightAngle,
    lightIntensity,
    refraction,
    depth,
    dispersion,
    frost,
    splay,
  );

  @override
  String toString() =>
      'GlassSettings(lightAngle: $lightAngle, lightIntensity: $lightIntensity, '
      'refraction: $refraction, depth: $depth, dispersion: $dispersion, '
      'frost: $frost, splay: $splay)';
}

/// Gains that map Figma's Glass values onto this package's rendering.
///
/// Figma's Glass is a closed effect, so its exact light and refraction
/// formulas aren't known. The maths here is an approximation; these gains are
/// the calibration knobs used to match it by eye against a Figma node. `1.0`
/// leaves a term at its base strength.
@immutable
class GlassCalibration {
  /// Creates calibration gains. The defaults were matched by eye against
  /// Figma's Glass effect.
  const GlassCalibration({
    this.glowGain = 1.3,
    this.rimGain = 0.55,
    this.frostScale = 0.35,
    this.refractionGain = 1,
    this.oppositePeak = 0.85,
    this.darkFloor = 0.04,
  });

  /// Scales the soft bevel glow. 0 removes it.
  final double glowGain;

  /// Scales the thin specular rim. 0 removes it.
  final double rimGain;

  /// Gaussian sigma per unit of Frost (Figma Frost 4 -> sigma `4 * scale`).
  final double frostScale;

  /// Scales how far the backdrop bends at the edges.
  final double refractionGain;

  /// Brightness of the edge opposite the light, relative to the lit edge.
  final double oppositePeak;

  /// Brightness of the edges between the two lit corners (0 = dark).
  final double darkFloor;

  /// Returns a copy with the given gains replaced.
  GlassCalibration copyWith({
    double? glowGain,
    double? rimGain,
    double? frostScale,
    double? refractionGain,
    double? oppositePeak,
    double? darkFloor,
  }) {
    return GlassCalibration(
      glowGain: glowGain ?? this.glowGain,
      rimGain: rimGain ?? this.rimGain,
      frostScale: frostScale ?? this.frostScale,
      refractionGain: refractionGain ?? this.refractionGain,
      oppositePeak: oppositePeak ?? this.oppositePeak,
      darkFloor: darkFloor ?? this.darkFloor,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is GlassCalibration &&
      other.glowGain == glowGain &&
      other.rimGain == rimGain &&
      other.frostScale == frostScale &&
      other.refractionGain == refractionGain &&
      other.oppositePeak == oppositePeak &&
      other.darkFloor == darkFloor;

  @override
  int get hashCode => Object.hash(
    glowGain,
    rimGain,
    frostScale,
    refractionGain,
    oppositePeak,
    darkFloor,
  );

  @override
  String toString() =>
      'GlassCalibration(glowGain: $glowGain, rimGain: $rimGain, '
      'frostScale: $frostScale, refractionGain: $refractionGain, '
      'oppositePeak: $oppositePeak, darkFloor: $darkFloor)';
}
