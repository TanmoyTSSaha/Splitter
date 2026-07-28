import 'package:flutter/animation.dart';

/// Left-to-right letter order for the Splitr. wordmark SVG paths.
abstract final class SplitrFluidWordmarkTimeline {
  static const letterCount = 7;

  static const staggerMs = 143;
  static const passMs = 210;
  static const holdAllFinalMs = 180;
  static const blackFadeMs = 270;

  /// Path IDs in draw order (S → .).
  static const letterOrder = <String>[
    'g0_p2',
    'g0_p1',
    'g0_p0',
    'g1_p2',
    'g1_p1',
    'g1_p0',
    'g2_p0',
  ];

  static int get fluidChainEndMs => (letterCount + 1) * staggerMs + passMs;

  static int get totalMs =>
      fluidChainEndMs + holdAllFinalMs + blackFadeMs;

  static int startMs(int letterIndex, int passIndex) =>
      (letterIndex + passIndex) * staggerMs;

  static int endMs(int letterIndex, int passIndex) =>
      startMs(letterIndex, passIndex) + passMs;

  static LetterFluidFrame frameAt(Duration elapsed) {
    final t = elapsed.inMilliseconds.clamp(0, totalMs);
    final letters = List<LetterPaintState>.generate(
      letterCount,
      (i) => _letterStateAt(i, t),
    );

    final blackFadeStart = fluidChainEndMs + holdAllFinalMs;
    final blackFadeT = t <= blackFadeStart
        ? 0.0
        : Curves.easeIn.transform(
            ((t - blackFadeStart) / blackFadeMs).clamp(0.0, 1.0),
          );

    return LetterFluidFrame(letters: letters, blackFadeT: blackFadeT);
  }

  static LetterPaintState _letterStateAt(int letterIndex, int t) {
    final c1 = _passReveal(letterIndex, 0, t);
    final c2 = _passReveal(letterIndex, 1, t);
    final c3 = _passReveal(letterIndex, 2, t);

    final ghostAlpha = c1 <= 0 ? 1.0 : 0.0;

    return LetterPaintState(
      ghostAlpha: ghostAlpha,
      c1Reveal: c1,
      c2Reveal: c2,
      c3Reveal: c3,
    );
  }

  static double _passReveal(int letterIndex, int passIndex, int t) {
    final start = startMs(letterIndex, passIndex);
    final end = endMs(letterIndex, passIndex);
    if (t <= start) return 0;
    if (t >= end) return 1;
    final progress = (t - start) / (end - start);
    return Curves.easeOut.transform(progress);
  }
}

/// Snapshot of all letter paint states at one instant.
class LetterFluidFrame {
  const LetterFluidFrame({
    required this.letters,
    required this.blackFadeT,
  });

  final List<LetterPaintState> letters;
  final double blackFadeT;
}

/// Per-letter reveal fractions for ghost + three color passes.
class LetterPaintState {
  const LetterPaintState({
    required this.ghostAlpha,
    required this.c1Reveal,
    required this.c2Reveal,
    required this.c3Reveal,
  });

  final double ghostAlpha;
  final double c1Reveal;
  final double c2Reveal;
  final double c3Reveal;
}
