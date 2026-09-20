import 'package:figma_glass/figma_glass.dart';
import 'package:flutter/material.dart';

import '../common.dart';

/// Every Figma Glass control as a slider, on a draggable panel.
class PlaygroundDemo extends StatefulWidget {
  const PlaygroundDemo({super.key});

  @override
  State<PlaygroundDemo> createState() => _PlaygroundDemoState();
}

class _PlaygroundDemoState extends State<PlaygroundDemo> {
  GlassSettings _settings = GlassSettings.input;
  Offset _pos = const Offset(40, 140);
  double _radius = 14;
  double _fillOpacity = 0.05;
  bool _stroke = true;

  void _set(GlassSettings s) => setState(() => _settings = s);

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return Scaffold(
      // GlassBackground snapshots `background`; FigmaGlass panels placed in
      // `child` refract that snapshot.
      body: GlassBackground(
        background: const _GridBackground(),
        child: Stack(
          children: [
            Positioned(
              left: _pos.dx,
              top: _pos.dy,
              child: GestureDetector(
                onPanUpdate: (d) => setState(() => _pos += d.delta),
                child: SizedBox(
                  width: 300,
                  height: 140,
                  child: FigmaGlass(
                    settings: _settings,
                    borderRadius: BorderRadius.circular(_radius),
                    fill: Colors.white.withValues(alpha: _fillOpacity),
                    strokeColor: _stroke ? const Color(0x3DBD9B37) : null,
                    child: const Center(
                      child: Text(
                        'Drag me',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: padding.top + 12,
              left: 16,
              child: const GlassBackButton(),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _Controls(
                settings: _settings,
                radius: _radius,
                fillOpacity: _fillOpacity,
                stroke: _stroke,
                onSettings: _set,
                onRadius: (v) => setState(() => _radius = v),
                onFill: (v) => setState(() => _fillOpacity = v),
                onStroke: (v) => setState(() => _stroke = v),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.settings,
    required this.radius,
    required this.fillOpacity,
    required this.stroke,
    required this.onSettings,
    required this.onRadius,
    required this.onFill,
    required this.onStroke,
  });

  final GlassSettings settings;
  final double radius;
  final double fillOpacity;
  final bool stroke;
  final ValueChanged<GlassSettings> onSettings;
  final ValueChanged<double> onRadius;
  final ValueChanged<double> onFill;
  final ValueChanged<bool> onStroke;

  @override
  Widget build(BuildContext context) {
    Widget slider(
      String label,
      double value,
      double min,
      double max,
      ValueChanged<double> onChanged,
    ) {
      return Row(
        children: [
          SizedBox(width: 92, child: Text(label)),
          Expanded(
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              value.toStringAsFixed(value.abs() < 2 && max <= 1 ? 2 : 0),
            ),
          ),
        ],
      );
    }

    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 340,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            children: [
              Wrap(
                spacing: 4,
                children: [
                  for (final (name, preset) in const [
                    ('Input', GlassSettings.input),
                    ('Card', GlassSettings.card),
                  ])
                    ChoiceChip(
                      label: Text(name),
                      selected: settings == preset,
                      onSelected: (_) => onSettings(preset),
                    ),
                ],
              ),
              slider(
                'Light angle',
                settings.lightAngle,
                -180,
                180,
                (v) => onSettings(settings.copyWith(lightAngle: v)),
              ),
              slider(
                'Light',
                settings.lightIntensity,
                0,
                1,
                (v) => onSettings(settings.copyWith(lightIntensity: v)),
              ),
              slider(
                'Refraction',
                settings.refraction,
                0,
                100,
                (v) => onSettings(settings.copyWith(refraction: v)),
              ),
              slider(
                'Depth',
                settings.depth,
                0,
                100,
                (v) => onSettings(settings.copyWith(depth: v)),
              ),
              slider(
                'Dispersion',
                settings.dispersion,
                0,
                100,
                (v) => onSettings(settings.copyWith(dispersion: v)),
              ),
              slider(
                'Frost',
                settings.frost,
                0,
                100,
                (v) => onSettings(settings.copyWith(frost: v)),
              ),
              slider(
                'Splay',
                settings.splay,
                0,
                100,
                (v) => onSettings(settings.copyWith(splay: v)),
              ),
              slider('Radius', radius, 0, 70, onRadius),
              slider('Fill opacity', fillOpacity, 0, 1, onFill),
              SwitchListTile(
                dense: true,
                title: const Text('Stroke'),
                value: stroke,
                onChanged: onStroke,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Colourful, high-detail background so refraction and dispersion are visible.
class _GridBackground extends StatelessWidget {
  const _GridBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F2027), Color(0xFF5B2A86), Color(0xFFE94057)],
        ),
      ),
      child: CustomPaint(painter: _GridPainter(), size: Size.infinite),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 2;
    for (var x = 0.0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    for (var y = 0.0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
    final dot = Paint();
    for (var i = 0; i < 14; i++) {
      canvas.drawCircle(
        Offset(
          size.width * ((i * 0.37) % 1),
          size.height * ((i * 0.23 + 0.1) % 1),
        ),
        18 + (i % 4) * 8,
        dot..color = HSVColor.fromAHSV(1, i * 26.0, 0.7, 1).toColor(),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
