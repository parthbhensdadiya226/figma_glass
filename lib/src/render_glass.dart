// ignore_for_file: prefer_initializing_formals

import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' show GlobalKey;

import 'glass_painting.dart';
import 'glass_settings.dart';

/// Paints the glass: the refracted + frosted snapshot of the background (our
/// own fragment shader on `Paint.shader`), or a plain blurred backdrop when no
/// snapshot is available, then fill, light bevel, stroke and the child.
class RenderGlass extends RenderProxyBox {
  RenderGlass({
    required GlassSettings settings,
    required GlassCalibration calibration,
    required BorderRadius borderRadius,
    required Color fill,
    required Color? strokeColor,
    required double strokeWidth,
    required ui.FragmentProgram? program,
    ui.Image? image,
    double imageScale = 1,
    GlobalKey? boundaryKey,
    RenderBox? child,
  }) : _settings = settings,
       _calibration = calibration,
       _borderRadius = borderRadius,
       _fill = fill,
       _strokeColor = strokeColor,
       _strokeWidth = strokeWidth,
       _program = program,
       _image = image,
       _imageScale = imageScale,
       _boundaryKey = boundaryKey,
       super(child);

  GlassSettings _settings;
  GlassCalibration _calibration;
  BorderRadius _borderRadius;
  Color _fill;
  Color? _strokeColor;
  double _strokeWidth;
  ui.FragmentProgram? _program;
  ui.FragmentShader? _shader;
  ui.Image? _image;
  double _imageScale;
  GlobalKey? _boundaryKey;
  final LayerHandle<BackdropFilterLayer> _filterLayer =
      LayerHandle<BackdropFilterLayer>();

  // Where in the snapshot this box was last drawn from. A parent can move
  // this box without repainting it (for example a scrolling list item),
  // which would leave the glass showing the old spot.
  Matrix4? _paintedToBoundary;
  bool _checkScheduled = false;

  // The part of the snapshot under this box, blurred by Frost. Remade only
  // when the snapshot, the blur or the region changes.
  ui.Image? _blurred;
  ui.Image? _blurredFrom;
  double _blurredSigma = 0;
  Rect _blurredRegion = Rect.zero;

  set settings(GlassSettings v) {
    if (v == _settings) return;
    _settings = v;
    markNeedsPaint();
  }

  set calibration(GlassCalibration v) {
    if (v == _calibration) return;
    _calibration = v;
    markNeedsPaint();
  }

  set borderRadius(BorderRadius v) {
    if (v == _borderRadius) return;
    _borderRadius = v;
    markNeedsPaint();
  }

  set fill(Color v) {
    if (v == _fill) return;
    _fill = v;
    markNeedsPaint();
  }

  set strokeColor(Color? v) {
    if (v == _strokeColor) return;
    _strokeColor = v;
    markNeedsPaint();
  }

  set strokeWidth(double v) {
    if (v == _strokeWidth) return;
    _strokeWidth = v;
    markNeedsPaint();
  }

  set program(ui.FragmentProgram? v) {
    if (identical(v, _program)) return;
    _program = v;
    _shader?.dispose();
    _shader = null;
    markNeedsPaint();
  }

  set image(ui.Image? v) {
    if (identical(v, _image)) return;
    _image = v;
    markNeedsPaint();
  }

  set imageScale(double v) {
    if (v == _imageScale) return;
    _imageScale = v;
    markNeedsPaint();
  }

  set boundaryKey(GlobalKey? v) {
    if (v == _boundaryKey) return;
    _boundaryKey = v;
    markNeedsPaint();
  }

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _scheduleMoveCheck();
  }

  // Runs after frames that happen anyway; it never schedules a frame itself.
  void _scheduleMoveCheck() {
    if (_checkScheduled) return;
    _checkScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _checkScheduled = false;
      if (!attached) return;
      _repaintIfMoved();
      _scheduleMoveCheck();
    });
  }

  void _repaintIfMoved() {
    final painted = _paintedToBoundary;
    final boundary = _boundaryKey?.currentContext?.findRenderObject();
    if (painted == null || boundary is! RenderBox || !boundary.attached) {
      return;
    }
    if (getTransformTo(boundary) != painted) markNeedsPaint();
  }

  @override
  void detach() {
    _dropBlur();
    super.detach();
  }

  void _dropBlur() {
    _blurred?.dispose();
    _blurred = null;
    _blurredFrom = null;
  }

  @override
  void dispose() {
    _dropBlur();
    _shader?.dispose();
    _shader = null;
    _filterLayer.layer = null;
    super.dispose();
  }

  ui.ImageFilter _buildFilter() {
    final sigma = _settings.blurSigmaFor(_calibration.frostScale);
    return sigma > 0
        ? ui.ImageFilter.blur(
            sigmaX: sigma,
            sigmaY: sigma,
            tileMode: TileMode.mirror,
          )
        : ui.ImageFilter.matrix(Matrix4.identity().storage);
  }

  /// Blurs [region] of [image] with a Gaussian blur, synchronously, so the
  /// glass never shows an unblurred or half-updated frame.
  ui.Image _blurRegion(ui.Image image, double sigma, Rect region) {
    if (_blurred != null &&
        identical(_blurredFrom, image) &&
        _blurredSigma == sigma &&
        _blurredRegion == region) {
      return _blurred!;
    }
    final bounds = Offset.zero & region.size;
    final recorder = ui.PictureRecorder();
    Canvas(recorder)
      ..clipRect(bounds)
      ..saveLayer(
        bounds,
        Paint()
          ..imageFilter = ui.ImageFilter.blur(
            sigmaX: sigma,
            sigmaY: sigma,
            tileMode: TileMode.clamp,
          ),
      )
      ..drawImage(image, -region.topLeft, Paint())
      ..restore();
    final picture = recorder.endRecording();
    final blurred = picture.toImageSync(
      region.width.toInt(),
      region.height.toInt(),
    );
    picture.dispose();
    // Frames already recorded keep their own reference to the old image.
    _blurred?.dispose();
    _blurred = blurred;
    _blurredFrom = image;
    _blurredSigma = sigma;
    _blurredRegion = region;
    return blurred;
  }

  /// Draws the refracted, frosted snapshot with our own shader. Returns false
  /// when no snapshot is available (caller falls back to BackdropFilter).
  bool _paintSnapshot(Canvas canvas, Rect rect) {
    final program = _program;
    final image = _image;
    final boundary = _boundaryKey?.currentContext?.findRenderObject();
    if (program == null || image == null || boundary is! RenderBox) {
      return false;
    }
    if (!boundary.attached) return false;

    final toBoundary = _paintedToBoundary = getTransformTo(boundary);
    // Snapshot pixels per logical pixel of this box.
    final scale = toBoundary.getMaxScaleOnAxis() * _imageScale;
    final inImage =
        MatrixUtils.transformPoint(toBoundary, Offset.zero) * _imageScale;

    // Blur only what the glass can sample: its own area, plus the bevel that
    // refraction reaches into, plus 3 sigma so the blur is exact at the edge.
    var texture = image;
    var origin = inImage;
    var shaderBlur = 0.0;
    final sigma = _settings.blurSigmaFor(_calibration.frostScale) * scale;
    if (sigma >= 0.5) {
      final pad = sigma * 3 + glassBevelWidth(_settings, size) * scale;
      final area = (inImage & (size * scale))
          .inflate(pad)
          .intersect(
            Offset.zero & Size(image.width.toDouble(), image.height.toDouble()),
          );
      final region = Rect.fromLTRB(
        area.left.floorToDouble(),
        area.top.floorToDouble(),
        area.right.ceilToDouble(),
        area.bottom.ceilToDouble(),
      );
      if (region.width >= 1 && region.height >= 1) {
        texture = _blurRegion(image, sigma, region);
        origin = inImage - region.topLeft;
      } else {
        shaderBlur = sigma;
      }
    } else {
      _dropBlur();
    }

    final shader = _shader ??= program.fragmentShader();
    shader
      ..setFloat(0, rect.left)
      ..setFloat(1, rect.top)
      ..setFloat(2, size.width * scale)
      ..setFloat(3, size.height * scale)
      ..setFloat(4, origin.dx)
      ..setFloat(5, origin.dy)
      ..setFloat(6, texture.width.toDouble())
      ..setFloat(7, texture.height.toDouble())
      ..setFloat(8, _borderRadius.topLeft.x * scale)
      ..setFloat(9, glassBevelWidth(_settings, size) * scale)
      ..setFloat(
        10,
        _settings.refractionNormalized * _calibration.refractionGain,
      )
      ..setFloat(11, _settings.dispersionNormalized)
      ..setFloat(12, _settings.splayNormalized)
      ..setFloat(13, shaderBlur)
      ..setFloat(14, scale)
      ..setImageSampler(0, texture);
    canvas.drawRRect(_borderRadius.toRRect(rect), Paint()..shader = shader);
    return true;
  }

  void _paintOverlay(PaintingContext context, Offset offset, Rect localRect) {
    final localRRect = _borderRadius.toRRect(localRect);
    if (_fill.a > 0) {
      context.canvas.drawRRect(localRRect, Paint()..color = _fill);
    }
    super.paint(context, offset);
    // The child may have pushed layers, so take the canvas again.
    final canvas = context.canvas;
    paintGlassLight(canvas, localRect, localRRect, _settings, _calibration);
    final strokeColor = _strokeColor;
    if (strokeColor != null && _strokeWidth > 0) {
      canvas.drawRRect(
        localRRect.deflate(_strokeWidth / 2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _strokeWidth
          ..color = strokeColor,
      );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.pushClipRRect(
      true,
      offset,
      Offset.zero & size,
      _borderRadius.toRRect(Offset.zero & size),
      (PaintingContext clipContext, Offset clipOffset) {
        final rect = clipOffset & size;
        _paintedToBoundary = null;
        if (_paintSnapshot(clipContext.canvas, rect)) {
          _filterLayer.layer = null;
          _paintOverlay(clipContext, clipOffset, rect);
          return;
        }
        final layer = _filterLayer.layer ??= BackdropFilterLayer();
        layer.filter = _buildFilter();
        clipContext.pushLayer(layer, (layerContext, layerOffset) {
          _paintOverlay(layerContext, layerOffset, layerOffset & size);
        }, clipOffset);
      },
    );
  }
}
