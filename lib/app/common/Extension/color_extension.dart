
import 'package:flutter/material.dart';

extension ColorExtension on Color {
  Color lightThemeColor() {
    final scheme = ColorScheme.fromSeed(
      seedColor: this,
      brightness: Brightness.light,
    );
    return scheme.primaryContainer; // 类似“对应的浅色”
  }

  /// Returns a shadow color that adapts to this color as the background.
  ///
  /// - Light backgrounds -> dark (black) shadow
  /// - Dark backgrounds  -> subtle light (white) shadow (glow-like)
  Color adaptiveShadowColor({double opacity = 0.24}) {
    final luminance = computeLuminance();
    final isLightBackground = luminance >= 0.5;
    final base = isLightBackground ? Colors.black : Colors.white;
    final scaledOpacity = isLightBackground ? opacity : (opacity * 0.45);
    return base.withOpacity(scaledOpacity.clamp(0.0, 1.0));
  }

  /// A neutral (gray) shadow derived from this background color.
  /// Keeps saturation at 0 and shifts lightness up/down based on background.
  Color adaptiveGrayShadowColor({double opacity = 0.9, double deltaLightness = 0.35}) {
    final hsl = HSLColor.fromColor(this);
    final isLightBackground = computeLuminance() >= 0.5;

    final targetLightness = (hsl.lightness + (isLightBackground ? -deltaLightness : deltaLightness))
        .clamp(0.0, 1.0);

    return hsl
        .withSaturation(0.0)
        .withLightness(targetLightness)
        .toColor()
        .withOpacity(opacity.clamp(0.0, 1.0));
  }
}