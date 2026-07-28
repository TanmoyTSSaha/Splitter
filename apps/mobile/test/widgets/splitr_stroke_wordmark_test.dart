import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Widgets/splitr_fluid_wordmark_timeline.dart';
import 'package:splitr/Widgets/splitr_stroke_wordmark.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SplitrFluidWordmarkTimeline', () {
    test('total duration is 1804ms', () {
      expect(SplitrFluidWordmarkTimeline.totalMs, 1804);
    });

    test('frameAt(0) shows ghost only', () {
      final frame = SplitrFluidWordmarkTimeline.frameAt(Duration.zero);
      expect(frame.blackFadeT, 0);
      for (final letter in frame.letters) {
        expect(letter.ghostAlpha, 1);
        expect(letter.c1Reveal, 0);
        expect(letter.c2Reveal, 0);
        expect(letter.c3Reveal, 0);
      }
    });

    test('frameAt S C1 start has S c1 reveal progressing', () {
      final start = SplitrFluidWordmarkTimeline.startMs(0, 0);
      final mid = Duration(milliseconds: start + 105);
      final frame = SplitrFluidWordmarkTimeline.frameAt(mid);
      expect(frame.letters[0].ghostAlpha, 0);
      expect(frame.letters[0].c1Reveal, greaterThan(0));
      expect(frame.letters[0].c1Reveal, lessThan(1));
    });

    test('frameAt p C1 start has S c2 and p c1 active', () {
      final start = SplitrFluidWordmarkTimeline.startMs(1, 0);
      final mid = Duration(milliseconds: start + 105);
      final frame = SplitrFluidWordmarkTimeline.frameAt(mid);
      expect(frame.letters[0].c2Reveal, greaterThan(0));
      expect(frame.letters[1].c1Reveal, greaterThan(0));
    });

    test('frameAt fluid chain end has all C3 complete', () {
      final end = SplitrFluidWordmarkTimeline.endMs(6, 2);
      final frame = SplitrFluidWordmarkTimeline.frameAt(
        Duration(milliseconds: end),
      );
      for (final letter in frame.letters) {
        expect(letter.c3Reveal, 1);
      }
      expect(frame.blackFadeT, 0);
    });

    test('frameAt total has black fade complete', () {
      final frame = SplitrFluidWordmarkTimeline.frameAt(
        Duration(milliseconds: SplitrFluidWordmarkTimeline.totalMs),
      );
      expect(frame.blackFadeT, 1);
    });
  });

  group('buildLetterRevealGuide', () {
    test('flows left to right through glyph bounds', () {
      const bounds = Rect.fromLTWH(10, 20, 30, 40);
      final guide = buildLetterRevealGuide(bounds);
      final metrics = guide.computeMetrics().toList();
      expect(metrics, isNotEmpty);

      final start = metrics.first.getTangentForOffset(0)!.position;
      final end =
          metrics.first.getTangentForOffset(metrics.first.length)!.position;
      expect(start.dx, lessThan(bounds.left));
      expect(end.dx, greaterThan(bounds.right));
      expect(start.dy, closeTo(bounds.center.dy, 0.01));
      expect(end.dy, closeTo(bounds.center.dy, 0.01));
    });
  });

  testWidgets('shows brand logo text when animations disabled', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: Scaffold(
            body: SplitrStrokeWordmark(),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text(AppBranding.brandLogo), findsOneWidget);
  });
}
