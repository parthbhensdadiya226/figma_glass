import 'package:figma_glass/figma_glass.dart';
import 'package:flutter/material.dart';

import '../art.dart';
import '../common.dart';

/// Glass bars floating over a feed that scrolls underneath them.
///
/// The feed is the [GlassBackground.background], so it has to be captured
/// again as it moves: `continuous: true`. Touches on empty parts of the
/// glass layer fall through to the feed, so it scrolls normally.
class FeedDemo extends StatefulWidget {
  const FeedDemo({super.key});

  @override
  State<FeedDemo> createState() => _FeedDemoState();
}

class _FeedDemoState extends State<FeedDemo> {
  int _tab = 0;

  static const _names = [
    'Maya Chen',
    'Leo Park',
    'Aria Sol',
    'Noah Grey',
    'Isla Moon',
    'Kai River',
  ];

  static const _captions = [
    'Golden hour never misses. Shot on the ridge above the bay.',
    'Tried a new palette for the poster series. Thoughts?',
    'Weekend build: a tiny synth with way too many knobs.',
    'Found this wall on the walk home and had to stop.',
    'Colour study #14. Warm on cool, as always.',
    'Morning light through the studio window.',
  ];

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      body: GlassBackground(
        continuous: true,
        background: ColoredBox(
          color: const Color(0xFF0D0D12),
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
              16,
              padding.top + 76,
              16,
              padding.bottom + 110,
            ),
            itemCount: 24,
            itemBuilder: (context, i) => _Post(
              seed: i,
              name: _names[i % _names.length],
              caption: _captions[i % _captions.length],
            ),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: padding.top + 12,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  const GlassBackButton(),
                  const Spacer(),
                  SizedBox(
                    height: 44,
                    child: FigmaGlass(
                      settings: buttonGlass,
                      borderRadius: BorderRadius.circular(22),
                      fill: Colors.white.withValues(alpha: 0.08),
                      strokeColor: Colors.white.withValues(alpha: 0.2),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 22),
                        child: Center(
                          child: Text(
                            'Discover',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox.square(
                    dimension: 44,
                    child: FigmaGlass(
                      settings: buttonGlass,
                      borderRadius: BorderRadius.circular(22),
                      fill: Colors.white.withValues(alpha: 0.1),
                      strokeColor: Colors.white.withValues(alpha: 0.2),
                      child: const Icon(Icons.search_rounded, size: 22),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: padding.bottom + 16,
              child: _TabBar(
                index: _tab,
                onTap: (i) => setState(() => _tab = i),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  static const _icons = [
    Icons.home_rounded,
    Icons.explore_rounded,
    Icons.favorite_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: FigmaGlass(
        settings: tileGlass,
        borderRadius: BorderRadius.circular(34),
        fill: Colors.white.withValues(alpha: 0.06),
        strokeColor: Colors.white.withValues(alpha: 0.2),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              for (var i = 0; i < _icons.length; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        color: Colors.white.withValues(
                          alpha: i == index ? 0.16 : 0,
                        ),
                      ),
                      child: Icon(
                        _icons[i],
                        size: 26,
                        color: i == index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Post extends StatelessWidget {
  const _Post({required this.seed, required this.name, required this.caption});

  final int seed;
  final String name;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final muted = Colors.white.withValues(alpha: 0.6);
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: SizedBox.square(
                  dimension: 36,
                  child: ScenePhoto(seed: seed + 50),
                ),
              ),
              const SizedBox(width: 10),
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${seed + 2}h', style: TextStyle(color: muted)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: seed.isEven ? 1 : 4 / 3,
              child: ScenePhoto(seed: seed),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.favorite_border_rounded),
              const SizedBox(width: 6),
              Text('${(seed * 37) % 900 + 40}'),
              const SizedBox(width: 18),
              const Icon(Icons.chat_bubble_outline_rounded),
              const SizedBox(width: 6),
              Text('${(seed * 7) % 60 + 3}'),
            ],
          ),
          const SizedBox(height: 8),
          Text(caption, style: TextStyle(color: muted, height: 1.35)),
        ],
      ),
    );
  }
}
