import 'package:figma_glass/figma_glass.dart';
import 'package:flutter/material.dart';

import 'art.dart';
import 'common.dart';
import 'demos/feed_demo.dart';
import 'demos/music_demo.dart';
import 'demos/playground_demo.dart';
import 'demos/sign_in_demo.dart';
import 'demos/wallet_demo.dart';

void main() => runApp(const GlassGalleryApp());

class GlassGalleryApp extends StatelessWidget {
  const GlassGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'figma_glass',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      home: const GalleryPage(),
    );
  }
}

class _Demo {
  const _Demo(this.icon, this.title, this.subtitle, this.page);
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget page;
}

const _demos = [
  _Demo(
    Icons.view_day_rounded,
    'Tab bar over a feed',
    'Glass bars over content that scrolls underneath',
    FeedDemo(),
  ),
  _Demo(
    Icons.music_note_rounded,
    'Music player',
    'Controls on glass over album art',
    MusicDemo(),
  ),
  _Demo(
    Icons.credit_card_rounded,
    'Wallet card',
    'Drag the card to move the light',
    WalletDemo(),
  ),
  _Demo(
    Icons.login_rounded,
    'Sign in',
    'Glass text fields and button',
    SignInDemo(),
  ),
  _Demo(
    Icons.tune_rounded,
    'Playground',
    'Every Figma Glass control as a slider',
    PlaygroundDemo(),
  ),
];

/// The background stays still and the glass tiles scroll over it, so a
/// single snapshot is enough (no `continuous` capture needed).
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return Scaffold(
      body: GlassBackground(
        background: const SunsetWallpaper(),
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, padding.top + 28, 20, 32),
          children: [
            const Text(
              'figma_glass',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              "Figma's Glass effect in Flutter",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            for (final demo in _demos) ...[
              _DemoTile(demo: demo),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }
}

class _DemoTile extends StatelessWidget {
  const _DemoTile({required this.demo});

  final _Demo demo;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => demo.page)),
      child: SizedBox(
        height: 84,
        child: FigmaGlass(
          settings: tileGlass,
          borderRadius: BorderRadius.circular(24),
          fill: Colors.black.withValues(alpha: 0.12),
          strokeColor: Colors.white.withValues(alpha: 0.18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Icon(demo.icon, size: 30),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        demo.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        demo.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
