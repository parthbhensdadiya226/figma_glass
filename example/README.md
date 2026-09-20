# figma_glass example

A small gallery of screens built with `figma_glass`:

| Screen | File | Shows |
|---|---|---|
| Tab bar over a feed | [feed_demo.dart](lib/demos/feed_demo.dart) | Glass bars over a list that scrolls underneath (`continuous: true`) |
| Music player | [music_demo.dart](lib/demos/music_demo.dart) | A frosted control panel over album art |
| Wallet card | [wallet_demo.dart](lib/demos/wallet_demo.dart) | Drag the card to move the light angle |
| Sign in | [sign_in_demo.dart](lib/demos/sign_in_demo.dart) | Glass text fields and buttons |
| Playground | [playground_demo.dart](lib/demos/playground_demo.dart) | A slider for every Figma Glass setting |

The artwork is drawn in code ([art.dart](lib/art.dart)), so there are no
image assets.

## Run it

```bash
flutter run --release
```

Use `--release` or `--profile` on a real device to judge the look and speed.

## The basic pattern

```dart
GlassBackground(
  background: const MyWallpaper(), // what the glass shows through
  child: Center(
    child: SizedBox(
      width: 300,
      height: 140,
      child: FigmaGlass(
        settings: GlassSettings.input,
        borderRadius: BorderRadius.circular(14),
        fill: Colors.white.withValues(alpha: 0.05),
        strokeColor: Colors.white.withValues(alpha: 0.24),
        child: const Center(child: Text('Hello, glass')),
      ),
    ),
  ),
)
```
