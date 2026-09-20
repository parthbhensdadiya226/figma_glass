import 'package:figma_glass/figma_glass.dart';
import 'package:flutter/material.dart';

// Glass values as they appear in Figma's Glass panel. Copy the numbers from
// your own Figma design the same way.

/// Small controls: buttons, icons, pills.
const buttonGlass = GlassSettings(
  lightAngle: -45,
  lightIntensity: 0.5,
  refraction: 70,
  depth: 30,
  dispersion: 20,
  frost: 6,
  splay: 20,
);

/// Bars and list tiles that carry text: more frost so text stays readable.
const tileGlass = GlassSettings(
  lightAngle: -45,
  lightIntensity: 0.5,
  refraction: 70,
  depth: 30,
  dispersion: 20,
  frost: 16,
  splay: 20,
);

/// A round glass back button used by every demo page.
class GlassBackButton extends StatelessWidget {
  const GlassBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: SizedBox.square(
        dimension: 44,
        child: FigmaGlass(
          settings: buttonGlass,
          borderRadius: BorderRadius.circular(22),
          fill: Colors.white.withValues(alpha: 0.1),
          strokeColor: Colors.white.withValues(alpha: 0.2),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
      ),
    );
  }
}
