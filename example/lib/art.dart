import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Sunset over layered mountains and a lake. Used as a wallpaper.
class SunsetWallpaper extends StatelessWidget {
  const SunsetWallpaper({super.key});

  @override
  Widget build(BuildContext context) =>
      const CustomPaint(painter: _SunsetPainter(), size: Size.infinite);
}

class _SunsetPainter extends CustomPainter {
  const _SunsetPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final horizon = h * 0.62;

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1B1036),
            Color(0xFF5B2A86),
            Color(0xFFD9577A),
            Color(0xFFFFA35C),
          ],
          stops: [0, 0.35, 0.58, 0.62],
        ).createShader(Offset.zero & size),
    );

    final rnd = math.Random(7);
    final star = Paint()..color = Colors.white;
    for (var i = 0; i < 70; i++) {
      star.color = Colors.white.withValues(alpha: 0.3 + rnd.nextDouble() * 0.6);
      canvas.drawCircle(
        Offset(rnd.nextDouble() * w, rnd.nextDouble() * h * 0.35),
        0.6 + rnd.nextDouble() * 1.2,
        star,
      );
    }

    final sun = Offset(w * 0.62, horizon - h * 0.07);
    canvas.drawCircle(
      sun,
      w * 0.5,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFD27A).withValues(alpha: 0.55),
            const Color(0x00FFD27A),
          ],
        ).createShader(Rect.fromCircle(center: sun, radius: w * 0.5)),
    );
    canvas.drawCircle(sun, w * 0.16, Paint()..color = const Color(0xFFFFE3A3));

    void ridge(double base, double amp, double seed, Color color) {
      final path = Path()..moveTo(0, h);
      for (var x = 0.0; x <= w; x += 4) {
        final t = x / w;
        final y =
            base -
            amp *
                (0.55 * math.sin(t * 5.1 + seed) +
                    0.3 * math.sin(t * 11.7 + seed * 2) +
                    0.15 * math.sin(t * 23.3 + seed * 3));
        path.lineTo(x, y);
      }
      path
        ..lineTo(w, h)
        ..close();
      canvas.drawPath(path, Paint()..color = color);
    }

    ridge(horizon - h * 0.02, h * 0.09, 1.3, const Color(0xFF8C3F7A));
    ridge(horizon + h * 0.01, h * 0.06, 4.1, const Color(0xFF5A2466));
    ridge(horizon + h * 0.04, h * 0.045, 2.2, const Color(0xFF331650));

    final lake = Rect.fromLTRB(0, horizon + h * 0.06, w, h);
    canvas.drawRect(
      lake,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3B1E5E), Color(0xFF120A26)],
        ).createShader(lake),
    );
    final glint = Paint()..color = const Color(0xFFFFC98A);
    for (var i = 0; i < 9; i++) {
      final y = lake.top + 10 + i * 14.0;
      final half = w * (0.14 - i * 0.012);
      glint.color = const Color(0xFFFFC98A).withValues(alpha: 0.7 - i * 0.07);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(sun.dx, y),
            width: half * 2,
            height: 3,
          ),
          const Radius.circular(2),
        ),
        glint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Bold geometric cover art for the music player.
class AlbumArt extends StatelessWidget {
  const AlbumArt({super.key});

  @override
  Widget build(BuildContext context) =>
      const CustomPaint(painter: _AlbumPainter(), size: Size.infinite);
}

class _AlbumPainter extends CustomPainter {
  const _AlbumPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B3D91), Color(0xFF6A1B9A), Color(0xFFFF4F79)],
        ).createShader(rect),
    );

    // Diagonal stripes behind the rings give the refraction edges to bend.
    final stripe = Paint()..strokeWidth = 18;
    for (var i = -60; i < 40; i++) {
      stripe.color = i.isEven
          ? const Color(0xFFFFD166)
          : const Color(0xFF1A1A2E);
      final x = i * 36.0;
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        stripe,
      );
    }

    final c = Offset(size.width * 0.5, size.height * 0.34);
    final colors = [
      const Color(0xFFFFD166),
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFF1A1A2E),
    ];
    for (var i = 0; i < 9; i++) {
      canvas.drawCircle(
        c,
        size.width * (0.62 - i * 0.065),
        Paint()..color = colors[i % colors.length],
      );
    }

    final text = TextPainter(
      text: const TextSpan(
        text: 'NEON\nTIDES',
        style: TextStyle(
          color: Colors.white,
          fontSize: 64,
          height: 0.95,
          fontWeight: FontWeight.w900,
          letterSpacing: 4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(canvas, Offset(24, size.height * 0.08));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Soft colour blobs, like a mesh gradient.
class MeshBackground extends StatelessWidget {
  const MeshBackground({super.key});

  @override
  Widget build(BuildContext context) =>
      const CustomPaint(painter: _MeshPainter(), size: Size.infinite);
}

class _MeshPainter extends CustomPainter {
  const _MeshPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0E0E1A),
    );
    final blobs = [
      (0.15, 0.2, 0.55, const Color(0xFFFF4F79)),
      (0.9, 0.25, 0.5, const Color(0xFF3A86FF)),
      (0.3, 0.55, 0.45, const Color(0xFFFFBE0B)),
      (0.85, 0.7, 0.55, const Color(0xFF8338EC)),
      (0.2, 0.95, 0.5, const Color(0xFF06D6A0)),
    ];
    for (final (x, y, r, color) in blobs) {
      final center = Offset(size.width * x, size.height * y);
      final radius = size.width * r;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }
    // Thin lines make refraction visible even where the colours are smooth.
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.5;
    for (var y = 0.0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A small generated "photo" for the feed, different for each [seed].
class ScenePhoto extends StatelessWidget {
  const ScenePhoto({super.key, required this.seed});

  final int seed;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _ScenePainter(seed), size: Size.infinite);
}

class _ScenePainter extends CustomPainter {
  const _ScenePainter(this.seed);

  final int seed;

  static const _palettes = [
    [Color(0xFF00B4DB), Color(0xFF0083B0), Color(0xFFFFE259)],
    [Color(0xFFF7797D), Color(0xFFFBD786), Color(0xFF6A3093)],
    [Color(0xFF11998E), Color(0xFF38EF7D), Color(0xFF0B486B)],
    [Color(0xFFFC466B), Color(0xFF3F5EFB), Color(0xFFFFFFFF)],
    [Color(0xFFFF8008), Color(0xFFFFC837), Color(0xFF2C3E50)],
    [Color(0xFF8E2DE2), Color(0xFF4A00E0), Color(0xFF00F5A0)],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final p = _palettes[seed % _palettes.length];
    final rnd = math.Random(seed);
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p[0], p[1]],
        ).createShader(rect),
    );
    for (var i = 0; i < 6; i++) {
      final paint = Paint()
        ..color = (i.isEven ? p[2] : Colors.white).withValues(
          alpha: 0.25 + rnd.nextDouble() * 0.5,
        );
      final o = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      final r = 20 + rnd.nextDouble() * size.shortestSide * 0.3;
      if (rnd.nextBool()) {
        canvas.drawCircle(o, r, paint);
      } else {
        canvas.save();
        canvas.translate(o.dx, o.dy);
        canvas.rotate(rnd.nextDouble() * math.pi);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: r * 2, height: r),
            Radius.circular(r * 0.2),
          ),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_ScenePainter old) => old.seed != seed;
}
