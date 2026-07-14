import 'package:flutter/material.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

/// Theme-aware replacements for [neopopYellow] foreground on light surfaces.
abstract final class ThemeAccentColors {
  static bool _isLight(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.light;

  /// Owe / warning / error-ish amounts.
  static Color oweWarning(BuildContext ctx) =>
      _isLight(ctx) ? groupOnSurface : neopopYellow;

  /// Positive / credit / Pro / accent highlights.
  static Color highlight(BuildContext ctx) =>
      _isLight(ctx) ? neopopAccent : neopopYellow;

  /// Neutral money labels (receipt prices, trip amounts).
  static Color amount(BuildContext ctx) =>
      _isLight(ctx) ? groupOnSurface : neopopYellow;
}
