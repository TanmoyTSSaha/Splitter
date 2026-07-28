import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Widgets/splitr_toast.dart';

void main() {
  group('SplitrToast.join', () {
    test('merges title and body with colon', () {
      expect(SplitrToast.join('Error', 'Something failed'),
          'Error: Something failed');
    });

    test('returns body when title empty', () {
      expect(SplitrToast.join('', 'Only body'), 'Only body');
    });

    test('returns title when body empty', () {
      expect(SplitrToast.join('Only title', ''), 'Only title');
    });
  });

  group('SplitrToastColors', () {
    test('light theme uses dark pill and white text', () {
      final colors = SplitrToastColors.forBrightness(Brightness.light);
      expect(colors.background, neopopBackground);
      expect(colors.foreground, neopopOnPrimary);
    });

    test('dark theme uses light pill and dark text', () {
      final colors = SplitrToastColors.forBrightness(Brightness.dark);
      expect(colors.background, Colors.white);
      expect(colors.foreground, neopopBackground);
    });
  });

  group('SplitrToastPill', () {
    Future<void> pumpPill(
      WidgetTester tester, {
      required Brightness brightness,
      required String message,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: Scaffold(
            body: Center(
              child: SplitrToastPill(
                message: message,
                brightness: brightness,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders message text', (tester) async {
      await pumpPill(
        tester,
        brightness: Brightness.light,
        message: 'Saved successfully',
      );
      expect(find.text('Saved successfully'), findsOneWidget);
    });

    testWidgets('light theme pill has dark background', (tester) async {
      await pumpPill(
        tester,
        brightness: Brightness.light,
        message: 'Hello',
      );
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SplitrToastPill),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, neopopBackground);
    });

    testWidgets('dark theme pill has white background', (tester) async {
      await pumpPill(
        tester,
        brightness: Brightness.dark,
        message: 'Hello',
      );
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SplitrToastPill),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, Colors.white);
    });
  });
}
