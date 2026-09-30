# figma_glass

[![pub package](https://img.shields.io/pub/v/figma_glass.svg)](https://pub.dev/packages/figma_glass)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Figma's **Glass** effect in Flutter. Every control from Figma's Glass panel is
a field you can set: Light angle, Light, Refraction, Depth, Dispersion, Frost
and Splay. Copy the numbers from your design and the panel looks the same in
your app.

<p align="center">
  <img src="https://raw.githubusercontent.com/parthbhensdadiya226/figma_glass/main/doc/feed.gif" width="260" alt="Glass tab bar and top bar over a scrolling feed">
</p>

| Music player | Wallet | Sign in |
|:---:|:---:|:---:|
| <img src="https://raw.githubusercontent.com/parthbhensdadiya226/figma_glass/main/doc/music_player.png" width="220" alt="Player controls on glass over album art"> | <img src="https://raw.githubusercontent.com/parthbhensdadiya226/figma_glass/main/doc/wallet.png" width="220" alt="Glass payment card and transaction list"> | <img src="https://raw.githubusercontent.com/parthbhensdadiya226/figma_glass/main/doc/sign_in.png" width="220" alt="Glass text fields and button over a sunset"> |

| Gallery | Playground |
|:---:|:---:|
| <img src="https://raw.githubusercontent.com/parthbhensdadiya226/figma_glass/main/doc/gallery.png" width="220" alt="Glass list tiles over a wallpaper"> | <img src="https://raw.githubusercontent.com/parthbhensdadiya226/figma_glass/main/doc/playground.png" width="220" alt="A glass panel with a slider for every setting"> |

All of these screens are in the [example app](example/lib), running on an
Android phone.

## Features

- All seven Figma Glass settings, with the same names and ranges as in Figma.
- Real refraction: the background bends at the edges of the glass, with
  optional colour fringing (dispersion), drawn by a fragment shader.
- Smooth Gaussian frost, a light bevel that follows the light angle, plus fill
  and stroke like Figma's Fill and Stroke sections.
- Works over still backgrounds and over content that scrolls or animates.
- No dependencies besides Flutter.

## Install

```yaml
dependencies:
  figma_glass: ^0.1.1
```

The shader ships with the package. You don't need to add anything to your
app's `flutter: shaders:` section.

## Quick start

Glass needs to know what is behind it. Put the backdrop in
`GlassBackground.background` and the glass panels in its `child`:

```dart
import 'package:figma_glass/figma_glass.dart';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassBackground(
      // What the glass shows through: images, gradients, text...
      background: Image.asset('assets/wallpaper.jpg', fit: BoxFit.cover),
      // The glass panels, on top.
      child: Center(
        child: SizedBox(
          width: 300,
          height: 140,
          child: FigmaGlass(
            settings: const GlassSettings(
              lightAngle: -45,
              lightIntensity: 0.8,
              refraction: 80,
              depth: 20,
              dispersion: 50,
              frost: 4,
              splay: 0,
            ),
            borderRadius: BorderRadius.circular(14),
            fill: Colors.white.withValues(alpha: 0.05),
            strokeColor: Colors.white.withValues(alpha: 0.24),
            child: const Center(child: Text('Hello, glass')),
          ),
        ),
      ),
    );
  }
}
```

## From Figma to Flutter

Select the layer in Figma, open the Glass effect and copy each value across:

| Figma | `GlassSettings` | Range | What it does |
|---|---|---|---|
| Light angle | `lightAngle` | -180 to 180 | Where the light comes from. 0 is the top, -45 is top-left |
| Light | `lightIntensity` | 0 to 1 | Brightness of the rim and glow (Figma shows 0–100%) |
| Refraction | `refraction` | 0 to 100 | How much the background bends at the edge |
| Depth | `depth` | 0 to 100 | How far in from the edge the bevel reaches, in logical pixels |
| Dispersion | `dispersion` | 0 to 100 | Colour fringing on the bent edge |
| Frost | `frost` | 0 to 100 | Background blur |
| Splay | `splay` | 0 to 100 | How far the bend spreads towards the middle |

The rest of the layer maps to `FigmaGlass` itself:

| Figma | `FigmaGlass` |
|---|---|
| Corner radius | `borderRadius` |
| Fill (colour and opacity) | `fill` |
| Stroke (colour and opacity) | `strokeColor`, `strokeWidth` |
| Layer content | `child` |

Values outside a range are clamped. Use `copyWith` to change one value, or
`GlassSettings.lerp` to animate between two looks.

### Presets

Two starting points, both taken from Figma Glass examples:

- `GlassSettings.input`: a thin, sharp edge with strong refraction and colour
  fringing. Good for text fields, buttons and chips.
- `GlassSettings.card`: flat frosted glass with a soft, wide highlight and no
  bending. Good for large panels.

```dart
FigmaGlass(settings: GlassSettings.card.copyWith(frost: 12))
```

## Scrolling and animated backgrounds

`GlassBackground` takes a snapshot of `background` whenever `background`
repaints: after the first frame, when an image in it finishes loading, when it
animates, or when its size changes. Rebuilding the screen without changing
the background (a `setState` for a button, typing in a field) takes no new
snapshot.

Some content moves without repainting the background: `ListView` items, for
example, sit on their own layers and only slide when you scroll. For a list
that scrolls under a glass tab bar, set `continuous: true` so the snapshot is
taken every frame:

```dart
GlassBackground(
  continuous: true,
  background: ListView(children: posts),
  child: Stack(
    children: [
      Positioned(left: 20, right: 20, bottom: 24, child: GlassTabBar()),
    ],
  ),
)
```

Touches on empty parts of `child` pass through to `background`, so the list
still scrolls. The glass panels themselves can move freely (drag them, put
them in a scrolling list) without `continuous`; only a changing backdrop
needs it.

## Rules for a correct result

- Don't put glass inside `background`. It would show up in its own snapshot.
- `background` fills the whole `GlassBackground`. Anything the glass should
  show through has to be in it.
- Content that is drawn above the glass, or outside `background`, isn't
  refracted.

## Fine tuning

`GlassCalibration` holds the gains used to match Figma's rendering. The
defaults are tuned against Figma, so you shouldn't need to change them. They
are there if your design needs a brighter rim or a softer frost:

| Field | Default | Effect |
|---|---|---|
| `glowGain` | 1.3 | Brightness of the soft glow along the bevel |
| `rimGain` | 0.55 | Brightness of the thin rim |
| `oppositePeak` | 0.85 | Rim brightness on the side away from the light |
| `darkFloor` | 0.04 | Rim brightness where the edge is side-on to the light |
| `frostScale` | 0.35 | Blur per unit of Frost |
| `refractionGain` | 1 | Multiplies the edge bend |

```dart
FigmaGlass(calibration: const GlassCalibration(rimGain: 0.8), ...)
```

## How it works

1. `GlassBackground` renders `background` into a snapshot image each time it
   repaints.
2. Each `FigmaGlass` blurs only the part of the snapshot under itself (plus
   the margin that refraction and the blur reach into) with a Gaussian blur
   for Frost, and reuses it until the snapshot, Frost or its position
   changes.
3. A fragment shader draws the blurred region inside the rounded rectangle,
   pulling samples inward near the edge (refraction) and splitting the red
   and blue channels (dispersion).
4. Fill, the light bevel, stroke and `child` are painted on top with normal
   Flutter painting.

Without a `GlassBackground` above it, `FigmaGlass` falls back to a
`BackdropFilter` blur with the same fill, light and stroke, but no
refraction.

## Performance

- A still background costs one snapshot, plus one small blur per glass
  panel. Nothing is redone while the screen is idle.
- Snapshots and blurs are made synchronously, so the glass always matches
  the frame it is drawn in; it doesn't lag behind or flicker while
  scrolling.
- `continuous: true` takes a snapshot every frame and blurs each panel's
  region again. That's fine for a few bars or buttons over a list. With many
  large panels, measure in `--profile` mode on a real device.
- Memory stays flat: on a Galaxy A36, a minute of continuous scrolling in the
  feed demo and 50 page opens and closes across the demos showed no growth.

## Try the example

```bash
cd example
flutter run --release
```

The gallery has a tab bar over a feed, a music player, a wallet card (drag it
to move the light), a sign-in form and a playground with a slider for every
setting.

## Platforms

| Android | iOS | Web |
|:---:|:---:|:---:|
| ✅ | ✅ | ✅ |

Tested on Android with Impeller (Vulkan). iOS and web use the same Flutter
APIs (fragment shaders and `RepaintBoundary` snapshots) but haven't been
tested on devices yet. Reports are welcome in the
[issue tracker](https://github.com/parthbhensdadiya226/figma_glass/issues).

## Requirements

Flutter 3.44 or newer, Dart 3.12 or newer.

## License

MIT. See [LICENSE](LICENSE).

This package is not affiliated with or endorsed by Figma. "Figma" is a
trademark of Figma, Inc., and is used here only to describe the effect.
