import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'glass_background.dart';
import 'glass_settings.dart';
import 'render_glass.dart';

const _shaderAsset = 'packages/figma_glass/shaders/glass_refraction.frag';

/// A glass panel that reproduces Figma's Glass effect.
///
/// Every Figma control is a field on [settings]. Fill and stroke are ordinary
/// properties, like Figma's Fill and Stroke sections.
///
/// Refraction and dispersion use a fragment shader applied to the backdrop and
/// need Impeller (default on iOS, and on Android API 29+). Where that is not
/// available the widget falls back to blur + light + tint.
class FigmaGlass extends StatefulWidget {
  /// Creates a glass panel. Place it in the `child` of a [GlassBackground]
  /// to get refraction and dispersion.
  const FigmaGlass({
    super.key,
    this.settings = const GlassSettings(),
    this.calibration = const GlassCalibration(),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.fill = const Color(0x00000000),
    this.strokeColor,
    this.strokeWidth = 1,
    this.child,
  });

  /// The Glass values from Figma's panel: light, refraction, depth,
  /// dispersion, frost and splay.
  final GlassSettings settings;

  /// Gains used to match Figma's look; see [GlassCalibration].
  final GlassCalibration calibration;

  /// The corner radius of the panel (Figma "Corner radius").
  final BorderRadius borderRadius;

  /// Tint painted over the blurred backdrop (Figma "Fill", including opacity).
  final Color fill;

  /// Border colour (Figma "Stroke", including opacity). Null for no stroke.
  final Color? strokeColor;

  /// Border width in logical pixels, drawn inside the panel's edge.
  final double strokeWidth;

  /// The content shown on the glass, such as text or icons. It is not
  /// refracted or blurred.
  final Widget? child;

  @override
  State<FigmaGlass> createState() => _FigmaGlassState();
}

Future<ui.FragmentProgram?>? _programFuture;

Future<ui.FragmentProgram?> _loadProgram() {
  return _programFuture ??= ui.FragmentProgram.fromAsset(
    _shaderAsset,
  ).then<ui.FragmentProgram?>((p) => p).catchError((Object _) => null);
}

class _FigmaGlassState extends State<FigmaGlass> {
  ui.FragmentProgram? _program;

  @override
  void initState() {
    super.initState();
    _loadProgram().then((program) {
      if (mounted) setState(() => _program = program);
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = glassSnapshotOf(context);
    return _GlassRenderWidget(
      image: snapshot?.image,
      imageScale: snapshot?.pixelRatio ?? 1,
      boundaryKey: snapshot?.boundaryKey,
      settings: widget.settings,
      calibration: widget.calibration,
      borderRadius: widget.borderRadius,
      fill: widget.fill,
      strokeColor: widget.strokeColor,
      strokeWidth: widget.strokeWidth,
      program: _program,
      child: widget.child,
    );
  }
}

class _GlassRenderWidget extends SingleChildRenderObjectWidget {
  const _GlassRenderWidget({
    required this.settings,
    required this.calibration,
    required this.borderRadius,
    required this.fill,
    required this.strokeColor,
    required this.strokeWidth,
    required this.program,
    required this.image,
    required this.imageScale,
    required this.boundaryKey,
    super.child,
  });

  final GlassSettings settings;
  final GlassCalibration calibration;
  final BorderRadius borderRadius;
  final Color fill;
  final Color? strokeColor;
  final double strokeWidth;
  final ui.FragmentProgram? program;
  final ui.Image? image;
  final double imageScale;
  final GlobalKey? boundaryKey;

  @override
  RenderGlass createRenderObject(BuildContext context) => RenderGlass(
    settings: settings,
    calibration: calibration,
    borderRadius: borderRadius,
    fill: fill,
    strokeColor: strokeColor,
    strokeWidth: strokeWidth,
    program: program,
    image: image,
    imageScale: imageScale,
    boundaryKey: boundaryKey,
  );

  @override
  void updateRenderObject(BuildContext context, RenderGlass renderObject) {
    renderObject
      ..settings = settings
      ..calibration = calibration
      ..borderRadius = borderRadius
      ..fill = fill
      ..strokeColor = strokeColor
      ..strokeWidth = strokeWidth
      ..program = program
      ..image = image
      ..imageScale = imageScale
      ..boundaryKey = boundaryKey;
  }
}
