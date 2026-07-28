import 'package:flutter/material.dart';

import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/domain_values.dart';

/// Persona-driven share card gradients (F10).
abstract final class RecapPersonaTheme {
  static List<Color> shareGradient(String personaType) {
    switch (personaType) {
      case RecapPersonaTypes.settlementHero:
        return const [
          Color(0xFF0B2E1F),
          Color(0xFF145A32),
          Color(0xFF1B8A4A),
        ];
      case RecapPersonaTypes.goalGrinder:
        return const [
          Color(0xFF1A1535),
          Color(0xFF2E2560),
          Color(0xFF4A3F8C),
        ];
      case RecapPersonaTypes.groupHost:
        return const [
          Color(0xFF1A1A2E),
          Color(0xFF243B55),
          Color(0xFF2F6F95),
        ];
      case RecapPersonaTypes.quietMonth:
        return const [
          Color(0xFF121212),
          Color(0xFF1E1E1E),
          Color(0xFF2A2A2A),
        ];
      case RecapPersonaTypes.socialSplitter:
        return const [
          Color(0xFF1A1030),
          Color(0xFF2D1B4E),
          AppPalette.shareCardGradientEnd,
        ];
      default:
        return const [
          AppPalette.shareCardGradientStart,
          AppPalette.shareCardGradientMid,
          AppPalette.shareCardGradientEnd,
        ];
    }
  }
}
