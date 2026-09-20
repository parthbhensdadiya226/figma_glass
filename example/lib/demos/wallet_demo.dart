import 'dart:math' as math;

import 'package:figma_glass/figma_glass.dart';
import 'package:flutter/material.dart';

import '../art.dart';
import '../common.dart';

/// A glass payment card. Drag on the card and the light follows your finger.
class WalletDemo extends StatefulWidget {
  const WalletDemo({super.key});

  @override
  State<WalletDemo> createState() => _WalletDemoState();
}

class _WalletDemoState extends State<WalletDemo> {
  double _lightAngle = -45;

  void _pointLight(Offset local, Size size) {
    final d = local - size.center(Offset.zero);
    // 0° is light from the top, positive is clockwise (Figma's dial).
    setState(() => _lightAngle = math.atan2(d.dx, -d.dy) * 180 / math.pi);
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return Scaffold(
      body: GlassBackground(
        background: const MeshBackground(),
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, padding.top + 12, 20, 24),
          children: [
            const Row(
              children: [
                GlassBackButton(),
                SizedBox(width: 16),
                Text(
                  'Wallet',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 28),
            AspectRatio(
              aspectRatio: 1.586, // ID-1 card.
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.biggest;
                  return GestureDetector(
                    onPanDown: (d) => _pointLight(d.localPosition, size),
                    onPanUpdate: (d) => _pointLight(d.localPosition, size),
                    child: FigmaGlass(
                      settings: GlassSettings(
                        lightAngle: _lightAngle,
                        lightIntensity: 1,
                        refraction: 60,
                        depth: 40,
                        dispersion: 40,
                        frost: 10,
                        splay: 10,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      fill: Colors.white.withValues(alpha: 0.06),
                      strokeColor: Colors.white.withValues(alpha: 0.25),
                      child: const _CardFace(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Light ${_lightAngle.round()}°  ·  drag the card',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                for (final (icon, label) in const [
                  (Icons.arrow_upward_rounded, 'Send'),
                  (Icons.arrow_downward_rounded, 'Request'),
                  (Icons.add_rounded, 'Top up'),
                  (Icons.more_horiz_rounded, 'More'),
                ])
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox.square(
                          dimension: 58,
                          child: FigmaGlass(
                            settings: buttonGlass,
                            borderRadius: BorderRadius.circular(29),
                            fill: Colors.white.withValues(alpha: 0.1),
                            strokeColor: Colors.white.withValues(alpha: 0.2),
                            child: Icon(icon),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(label),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            FigmaGlass(
              settings: GlassSettings.card,
              borderRadius: BorderRadius.circular(24),
              fill: Colors.black.withValues(alpha: 0.15),
              strokeColor: Colors.white.withValues(alpha: 0.15),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    for (final (icon, title, date, amount) in const [
                      (Icons.coffee_rounded, 'Corner Café', 'Today', '-4.80'),
                      (
                        Icons.train_rounded,
                        'Metro pass',
                        'Yesterday',
                        '-32.00',
                      ),
                      (Icons.work_rounded, 'Salary', 'Mon', '+2,450.00'),
                      (Icons.shopping_bag_rounded, 'Market', 'Sun', '-61.25'),
                    ])
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                          child: Icon(icon, color: Colors.white),
                        ),
                        title: Text(title),
                        subtitle: Text(date),
                        trailing: Text(
                          amount,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: amount.startsWith('+')
                                ? const Color(0xFF7CF5C4)
                                : Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace();

  @override
  Widget build(BuildContext context) {
    const mono = TextStyle(
      fontSize: 20,
      letterSpacing: 2.5,
      fontWeight: FontWeight.w500,
    );
    final label = TextStyle(
      fontSize: 10,
      letterSpacing: 1.2,
      color: Colors.white.withValues(alpha: 0.7),
    );
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'glass',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.contactless_rounded,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 44,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: const LinearGradient(
                colors: [Color(0xFFF6E27A), Color(0xFFCB9B51)],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text('••••  ••••  ••••  4821', style: mono),
          const SizedBox(height: 14),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CARD HOLDER', style: label),
                  const Text('ALEX MORGAN'),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EXPIRES', style: label),
                  const Text('09/29'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
