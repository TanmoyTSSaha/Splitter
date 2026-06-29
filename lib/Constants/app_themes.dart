import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';

/// Centralized app themes for light (default) and dark-surface screens.
abstract final class AppThemes {
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: neopopAccent,
    onPrimary: neopopOnPrimary,
    primaryContainer: neopopAccent,
    onPrimaryContainer: neopopBackground,
    secondary: neopopAccent,
    onSecondary: neopopOnAccent,
    secondaryContainer: neopopAccent,
    onSecondaryContainer: neopopBackground,
    surface: Colors.white,
    onSurface: neopopBackground,
    error: neopopError,
    onError: neopopOnError,
  );

  static final ThemeData light = ThemeData(
    colorScheme: _lightColorScheme,
    highlightColor: neopopAccent,
    splashColor: neopopAccent,
    useMaterial3: true,
    textTheme: splitter_custom_text_theme,
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: body2_text.copyWith(color: neopopGrey),
      labelStyle: body2_text.copyWith(color: neopopGrey),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: neopopGrey.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: neopopAccent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: neopopError),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: neopopError, width: 2),
      ),
    ),
  );

  static final ThemeData dark = ThemeData(
    colorScheme: neopopColorScheme,
    highlightColor: neopopAccent,
    splashColor: neopopAccent,
    useMaterial3: true,
    textTheme: splitter_custom_text_theme,
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: body2_text.copyWith(color: neopopGrey),
      labelStyle: body2_text.copyWith(color: neopopGrey),
      filled: true,
      fillColor: neopopSecondaryGrey,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: neopopOnPrimary.withValues(alpha: 0.2)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: neopopAccent, width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: neopopError),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: neopopError, width: 2),
      ),
    ),
  );
}
