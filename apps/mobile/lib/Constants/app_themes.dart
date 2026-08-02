import 'package:flutter/material.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/system_ui.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

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
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: kSplitrSystemUiOverlay,
    ),
    textTheme: splitter_custom_text_theme,
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: body2_text.copyWith(color: neopopGrey),
      labelStyle: body2_text.copyWith(color: neopopGrey),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(groupControlRadiusSm),
        borderSide: BorderSide(color: neopopGrey.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(groupControlRadiusSm),
        borderSide: const BorderSide(color: neopopAccent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(groupControlRadiusSm),
        borderSide: const BorderSide(color: neopopError),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(groupControlRadiusSm),
        borderSide: const BorderSide(color: neopopError, width: 2),
      ),
    ),
  );

  static final ThemeData dark = ThemeData(
    colorScheme: neopopColorScheme,
    highlightColor: neopopAccent,
    splashColor: neopopAccent,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: kSplitrSystemUiOverlay,
    ),
    textTheme: splitter_custom_text_theme,
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: body2_text.copyWith(color: neopopGrey),
      labelStyle: body2_text.copyWith(color: neopopGrey),
      filled: true,
      fillColor: neopopSecondaryGrey,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(groupControlRadiusSm),
        borderSide: BorderSide(color: neopopOnPrimary.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(groupControlRadiusSm),
        borderSide: const BorderSide(color: neopopAccent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(groupControlRadiusSm),
        borderSide: const BorderSide(color: neopopError),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(groupControlRadiusSm),
        borderSide: const BorderSide(color: neopopError, width: 2),
      ),
    ),
  );
}
