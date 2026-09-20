import 'dart:math' as math;
import 'dart:ui';

import 'glass_settings.dart';

/// Bevel width in logical pixels for a glass of [size]. Figma's Depth is in
/// pixels (measured on a test component), capped at half the shortest side, so
/// depth 20 is a 20 px lens on any glass that is at least 40 px tall, and
/// depth 100 reaches the centre of a 104 px card.
double glassBevelWidth(GlassSettings settings, Size size) {
  final maxBevel = math.min(size.width, size.height) / 2;
  return math.max(math.min(settings.depth.clamp(0.0, 100.0), maxBevel), 1.0);
}

/// Paints the directional light of the glass: a soft bevel gradient that is
/// brightest on the edges facing the light and faint on the opposite side,
/// plus a crisp specular hairline on the rim. Must be called with the canvas
/// already clipped to [rrect].
void paintGlassLight(
  Canvas canvas,
  Rect rect,
  RRect rrect,
  GlassSettings settings,
  GlassCalibration calibration,
) {
  final intensity = settings.lightNormalized;
  if (intensity <= 0) return;

  final dir = settings.lightDirection;
  final center = rect.center;
  final reach = (rect.width * dir.dx.abs() + rect.height * dir.dy.abs()) / 2;
  final toLight = Offset(dir.dx * reach, dir.dy * reach);

  // Peak brightness on the edge facing the light, a weaker peak on the
  // opposite edge, and a dim floor in between so every edge stays lit.
  Shader gradient(double strength) {
    final floor = calibration.darkFloor;
    const white = Color(0xFFFFFFFF);
    final peak = strength * intensity;
    return Gradient.linear(
      center + toLight,
      center - toLight,
      [
        white.withValues(alpha: peak),
        white.withValues(alpha: peak * floor),
        white.withValues(alpha: peak * floor),
        white.withValues(alpha: peak * calibration.oppositePeak),
      ],
      const [0.0, 0.4, 0.6, 1.0],
    );
  }

  final bevel = glassBevelWidth(settings, rect.size);

  // Soft bevel glow, `bevel` px deep.
  // Overlay blend: the light brightens what is behind the glass in proportion
  // to its brightness, so it vanishes over pure black (as in Figma) and shows
  // over dark-but-not-black surfaces such as the Prize card.
  final glow = Paint()
    ..blendMode = BlendMode.overlay
    ..style = PaintingStyle.stroke
    ..strokeWidth = bevel * 2
    ..shader = gradient(0.45 * calibration.glowGain);
  if (bevel > 3) {
    glow.maskFilter = MaskFilter.blur(BlurStyle.normal, bevel * 0.35);
  }
  canvas.drawRRect(rrect, glow);

  // Crisp specular rim. Its brightness follows the direction each part of the
  // outline faces relative to the light, so the straight edges stay lit while
  // the corner curves facing away from the light axis (top-right and
  // bottom-left for a diagonal light) fade out, as in Figma.
  final rimPeak = 0.9 * calibration.rimGain * intensity;
  Color rimColor(double nx, double ny) {
    final dot = nx * dir.dx + ny * dir.dy;
    final k = math.pow(dot.abs(), 1.2).toDouble();
    final side = dot >= 0 ? 1.0 : calibration.oppositePeak;
    final b = calibration.darkFloor + (1 - calibration.darkFloor) * k * side;
    return const Color(
      0xFFFFFFFF,
    ).withValues(alpha: (rimPeak * b).clamp(0.0, 1.0));
  }

  final rim = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  void clipped(Rect clip, Shader shader) {
    canvas.save();
    canvas.clipRect(clip);
    canvas.drawRRect(rrect, rim..shader = shader);
    canvas.restore();
  }

  const strip = 4.0;
  final l = rect.left, t = rect.top, rt = rect.right, b = rect.bottom;
  final tl = rrect.tlRadiusX, tr = rrect.trRadiusX;
  final br = rrect.brRadiusX, bl = rrect.blRadiusX;

  Shader solid(double nx, double ny) {
    final c = rimColor(nx, ny);
    return Gradient.linear(Offset.zero, const Offset(1, 0), [c, c]);
  }

  clipped(Rect.fromLTRB(l + tl, t, rt - tr, t + strip), solid(0, -1));
  clipped(Rect.fromLTRB(l + bl, b - strip, rt - br, b), solid(0, 1));
  clipped(Rect.fromLTRB(l, t + tl, l + strip, b - bl), solid(-1, 0));
  clipped(Rect.fromLTRB(rt - strip, t + tr, rt, b - br), solid(1, 0));

  // Corner arcs: a sweep gradient around the arc centre, one colour per
  // outward-normal angle (canvas angles: 0 = +x, clockwise).
  void corner(Rect clip, Offset center, double from) {
    const steps = 8;
    final colors = <Color>[];
    final stops = <double>[];
    for (var i = 0; i <= steps; i++) {
      final f = i / steps;
      final a = from + f * math.pi / 2;
      colors.add(rimColor(math.cos(a), math.sin(a)));
      stops.add(f);
    }
    clipped(
      clip,
      Gradient.sweep(
        center,
        colors,
        stops,
        TileMode.clamp,
        from,
        from + math.pi / 2,
      ),
    );
  }

  corner(Rect.fromLTWH(l, t, tl, tl), Offset(l + tl, t + tl), math.pi);
  corner(
    Rect.fromLTWH(rt - tr, t, tr, tr),
    Offset(rt - tr, t + tr),
    1.5 * math.pi,
  );
  corner(Rect.fromLTWH(rt - br, b - br, br, br), Offset(rt - br, b - br), 0);
  corner(
    Rect.fromLTWH(l, b - bl, bl, bl),
    Offset(l + bl, b - bl),
    0.5 * math.pi,
  );
}
