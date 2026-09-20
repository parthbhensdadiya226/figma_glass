#include <flutter/runtime_effect.glsl>

uniform vec2 uOrigin;      // glass top-left in the canvas's local coordinates
uniform vec2 uSize;        // glass size, snapshot px
uniform vec2 uImgOrigin;   // glass top-left inside the snapshot, px
uniform vec2 uImgSize;     // snapshot size, px
uniform float uRadius;     // corner radius, px
uniform float uDepth;      // bevel width, px
uniform float uRefraction; // 0..1
uniform float uDispersion; // 0..1
uniform float uSplay;      // 0..1
uniform float uBlur;       // frost blur sigma, px
uniform float uScale;      // snapshot px per local unit
uniform sampler2D uTex;

out vec4 fragColor;

float sdRoundRect(vec2 p, vec2 halfSize, float r) {
  vec2 q = abs(p) - halfSize + r;
  return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}

vec4 tap(vec2 local) {
  vec2 c = clamp(uImgOrigin + local, vec2(0.5), uImgSize - vec2(0.5));
  // Pixel position to texture coordinates (0..1).
  return texture(uTex, c / uImgSize);
}

// Box blur over +-1.5 sigma (5x5 taps). Loop bounds are static for compatibility.
vec4 blurAt(vec2 local) {
  if (uBlur < 0.5) return tap(local);
  float step = uBlur * 0.75;
  vec4 sum = vec4(0.0);
  for (int i = -2; i <= 2; i++) {
    for (int j = -2; j <= 2; j++) {
      sum += tap(local + vec2(float(i), float(j)) * step);
    }
  }
  return sum / 25.0;
}

void main() {
  // FlutterFragCoord is in local (canvas) coordinates; everything below
  // works in snapshot pixels.
  vec2 local = (FlutterFragCoord().xy - uOrigin) * uScale;
  vec2 halfSize = uSize * 0.5;
  vec2 p = local - halfSize;
  float r = min(uRadius, min(halfSize.x, halfSize.y));

  float d = sdRoundRect(p, halfSize, r);  // < 0 inside

  vec2 h = vec2(1.0, 0.0);
  vec2 g = vec2(
    sdRoundRect(p + h.xy, halfSize, r) - sdRoundRect(p - h.xy, halfSize, r),
    sdRoundRect(p + h.yx, halfSize, r) - sdRoundRect(p - h.yx, halfSize, r));
  vec2 n = g / max(length(g), 1e-5);

  // 1 at the edge, 0 at `uDepth` px inside. Splay widens the falloff.
  float t = clamp(1.0 + d / max(uDepth, 1.0), 0.0, 1.0);
  float lens = pow(t, mix(2.0, 1.0, uSplay));

  // Sample from further inside so the rim pulls in and magnifies the background
  float shift = lens * uDepth * uRefraction * 0.6;

  float disp = uDispersion * 0.25;
  vec2 offR = -n * shift * (1.0 - disp);
  vec2 offG = -n * shift;
  vec2 offB = -n * shift * (1.0 + disp);

  vec4 cg = blurAt(local + offG);
  float rr = blurAt(local + offR).r;
  float bb = blurAt(local + offB).b;

  // Transparent outside the rounded corners.
  fragColor = d > 0.0 ? vec4(0.0) : vec4(rr, cg.g, bb, 1.0);
}
