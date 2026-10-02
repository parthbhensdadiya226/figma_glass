## 0.1.2

* Added a Buy Me a Coffee link (`funding` in pubspec and a Support section in the README).

## 0.1.1

* `FigmaGlass` repaints when it moves under a different `GlassBackground`,
  instead of sampling the old one until its next repaint.
* `GlassCalibration.toString` includes `oppositePeak` and `darkFloor`.
* `GlassBackground` docs now describe when the snapshot is taken: whenever
  the background repaints.

## 0.1.0

* Initial release.
* `FigmaGlass`: Figma's Glass effect with Light angle, Light, Refraction,
  Depth, Dispersion, Frost and Splay, plus fill, stroke and corner radius.
* `GlassBackground`: snapshots the backdrop so a fragment shader can refract
  it. Captures again whenever the background repaints, or every frame with
  `continuous: true` for content that scrolls on its own layer. Without it,
  `FigmaGlass` falls back to blur + fill + light.
* Frost uses a real Gaussian blur of only the region under each panel, made
  synchronously, so the glass never lags or flickers while scrolling.
* Glass stays aligned with the background when it moves without repainting,
  such as during page transitions or inside scrolling lists.
* Presets: `GlassSettings.input` and `GlassSettings.card`.
* `GlassCalibration` for fine-tuning rim, glow, frost and refraction.
* Example gallery: tab bar over a feed, music player, wallet card, sign-in
  form and a playground.
