import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Provides the background that [FigmaGlass] panels refract.
///
/// [background] is rendered and snapshotted; [child] is laid over it (glass
/// panels go in [child]). The snapshot is taken after the first frame, and
/// again whenever [background] repaints, so a still background costs a
/// single snapshot. Set [continuous] to re-capture every frame when the
/// background moves on its own layer without repainting, such as a
/// scrolling list.
class GlassBackground extends StatefulWidget {
  /// Creates the backdrop for the [FigmaGlass] panels in [child].
  const GlassBackground({
    super.key,
    required this.background,
    required this.child,
    this.continuous = false,
  });

  /// Everything the glass panels should show through them, such as images,
  /// gradients or cards. It must not contain the glass panels themselves.
  final Widget background;

  /// The layer on top of [background], holding the [FigmaGlass] panels.
  final Widget child;

  /// Whether to capture [background] again every frame, for backgrounds that
  /// scroll or animate on their own layer (lists, videos, animations). This
  /// keeps the screen redrawing every frame, so leave it off otherwise.
  final bool continuous;

  @override
  State<GlassBackground> createState() => _GlassBackgroundState();
}

/// A captured image of a [GlassBackground]'s background.
class GlassSnapshot {
  /// Creates a snapshot.
  const GlassSnapshot(this.image, this.pixelRatio, this.boundaryKey);

  /// The captured background, or null before the first capture.
  final ui.Image? image;

  /// Device pixels per logical pixel of [image].
  final double pixelRatio;

  /// Key of the boundary the background was captured from.
  final GlobalKey boundaryKey;
}

class _GlassScope extends InheritedWidget {
  const _GlassScope({required this.snapshot, required super.child});
  final GlassSnapshot snapshot;

  @override
  bool updateShouldNotify(_GlassScope old) =>
      !identical(snapshot.image, old.snapshot.image);
}

/// The snapshot of the enclosing [GlassBackground], if any.
GlassSnapshot? glassSnapshotOf(BuildContext context) =>
    context.dependOnInheritedWidgetOfExactType<_GlassScope>()?.snapshot;

class _GlassBackgroundState extends State<GlassBackground> {
  final _key = GlobalKey();
  ui.Image? _image;
  double _ratio = 1;
  bool _scheduled = false;
  int _retries = 0;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void didUpdateWidget(GlassBackground old) {
    super.didUpdateWidget(old);
    if (widget.continuous && !old.continuous) _schedule();
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  void _schedule() {
    if (_scheduled) return;
    _scheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      _capture();
    });
  }

  void _capture() {
    if (!mounted) return;
    final object = _key.currentContext?.findRenderObject();
    if (object is! RenderRepaintBoundary || !object.attached) return;
    final ratio = MediaQuery.devicePixelRatioOf(context);
    final ui.Image image;
    try {
      // Synchronous: the glass gets the new picture on the very next frame.
      image = object.toImageSync(pixelRatio: ratio);
    } catch (_) {
      // Not painted yet (for example an offstage route): try again shortly.
      if (_retries++ < 3) _schedule();
      return;
    }
    _retries = 0;
    final old = _image;
    setState(() {
      _image = image;
      _ratio = ratio;
    });
    // Frames already recorded keep their own reference to the old image.
    old?.dispose();
    if (widget.continuous) _schedule();
  }

  @override
  Widget build(BuildContext context) {
    return _GlassScope(
      snapshot: GlassSnapshot(_image, _ratio, _key),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: _PaintNotifier(
              key: _key,
              onPaint: _schedule,
              child: widget.background,
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

/// A [RepaintBoundary] that reports each time its content is repainted, so
/// the snapshot is only retaken when the background actually changed.
class _PaintNotifier extends SingleChildRenderObjectWidget {
  const _PaintNotifier({super.key, required this.onPaint, super.child});

  final VoidCallback onPaint;

  @override
  _RenderPaintNotifier createRenderObject(BuildContext context) =>
      _RenderPaintNotifier(onPaint);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderPaintNotifier renderObject,
  ) {
    renderObject.onPaint = onPaint;
  }
}

class _RenderPaintNotifier extends RenderRepaintBoundary {
  _RenderPaintNotifier(this.onPaint);

  VoidCallback onPaint;

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    onPaint();
  }
}
