import 'package:figma_glass/figma_glass.dart';
import 'package:flutter/material.dart';

import '../art.dart';
import '../common.dart';

/// Player controls on a glass panel over full-screen album art.
class MusicDemo extends StatefulWidget {
  const MusicDemo({super.key});

  @override
  State<MusicDemo> createState() => _MusicDemoState();
}

class _MusicDemoState extends State<MusicDemo>
    with SingleTickerProviderStateMixin {
  static const _length = Duration(minutes: 3, seconds: 24);

  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: _length,
    value: 0.38,
  );
  bool _liked = true;

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      if (_progress.isAnimating) {
        _progress.stop();
      } else {
        _progress.repeat();
      }
    });
  }

  String _format(Duration d) =>
      '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final muted = Colors.white.withValues(alpha: 0.7);
    return Scaffold(
      body: GlassBackground(
        background: const AlbumArt(),
        child: Stack(
          children: [
            Positioned(
              top: padding.top + 12,
              left: 16,
              child: const GlassBackButton(),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: padding.bottom + 16,
              child: FigmaGlass(
                settings: const GlassSettings(
                  lightAngle: -30,
                  lightIntensity: 0.6,
                  refraction: 70,
                  depth: 36,
                  dispersion: 35,
                  frost: 40,
                  splay: 15,
                ),
                borderRadius: BorderRadius.circular(32),
                fill: Colors.black.withValues(alpha: 0.22),
                strokeColor: Colors.white.withValues(alpha: 0.22),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ocean Drive',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Neon Tides',
                                  style: TextStyle(fontSize: 16, color: muted),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _liked = !_liked),
                            icon: Icon(
                              _liked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: _liked ? const Color(0xFFFF6B8A) : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AnimatedBuilder(
                        animation: _progress,
                        builder: (context, _) {
                          final position = _length * _progress.value;
                          return Column(
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 5,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 7,
                                  ),
                                  overlayShape: SliderComponentShape.noOverlay,
                                  activeTrackColor: Colors.white,
                                  inactiveTrackColor: Colors.white.withValues(
                                    alpha: 0.25,
                                  ),
                                  thumbColor: Colors.white,
                                ),
                                child: Slider(
                                  value: _progress.value,
                                  onChanged: (v) => _progress.value = v,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    _format(position),
                                    style: TextStyle(color: muted),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '-${_format(_length - position)}',
                                    style: TextStyle(color: muted),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.shuffle_rounded, color: muted),
                          const Icon(Icons.skip_previous_rounded, size: 40),
                          GestureDetector(
                            onTap: _togglePlay,
                            child: SizedBox.square(
                              dimension: 72,
                              child: FigmaGlass(
                                settings: buttonGlass,
                                borderRadius: BorderRadius.circular(36),
                                fill: Colors.white.withValues(alpha: 0.18),
                                strokeColor: Colors.white.withValues(
                                  alpha: 0.3,
                                ),
                                child: Icon(
                                  _progress.isAnimating
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                          const Icon(Icons.skip_next_rounded, size: 40),
                          Icon(Icons.repeat_rounded, color: muted),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.volume_down_rounded, color: muted),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: 0.65,
                                  minHeight: 5,
                                  color: Colors.white,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.25,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Icon(Icons.volume_up_rounded, color: muted),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
