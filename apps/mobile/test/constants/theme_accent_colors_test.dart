import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/app_themes.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/theme_accent_colors.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

void main() {
  group('ThemeAccentColors', () {
    testWidgets('light theme uses black for owe/amount and green for highlight',
        (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppThemes.light,
          home: Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(ThemeAccentColors.oweWarning(ctx), groupOnSurface);
      expect(ThemeAccentColors.amount(ctx), groupOnSurface);
      expect(ThemeAccentColors.highlight(ctx), neopopAccent);
    });

    testWidgets('dark theme keeps neopopYellow for all accents', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppThemes.dark,
          home: Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(ThemeAccentColors.oweWarning(ctx), neopopYellow);
      expect(ThemeAccentColors.amount(ctx), neopopYellow);
      expect(ThemeAccentColors.highlight(ctx), neopopYellow);
    });
  });
}
