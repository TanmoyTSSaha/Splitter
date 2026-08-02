import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:splitr/Widgets/splitr_fluid_wordmark_timeline.dart';
import 'package:splitr/Widgets/splitr_stroke_wordmark.dart';

/// Paints ghost base, goo-fluid color fills, and terminal black fade.
class SplitrFluidWordmarkPainter extends CustomPainter {
  const SplitrFluidWordmarkPainter({
    required this.svgData,
    required this.frame,
    required this.ghostColor,
    required this.colors,
    required this.blackTarget,
  });

  final WordmarkSvgData svgData;
  final LetterFluidFrame frame;
  final Color ghostColor;
  final List<Color> colors;
  final Color blackTarget;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / svgData.viewBoxWidth;
    final scaleY = size.height / svgData.viewBoxHeight;
    canvas.scale(scaleX, scaleY);

    _drawGhostLayer(canvas);
    _drawGooLayer(canvas);
    _drawBlackFade(canvas);
  }

  void _drawGhostLayer(Canvas canvas) {
    final ghostPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = ghostColor;

    for (var i = 0; i < svgData.letters.length; i++) {
      final state = frame.letters[i];
      if (state.ghostAlpha <= 0) continue;

      canvas.save();
      if (state.ghostAlpha < 1) {
        ghostPaint.color = ghostColor.withValues(alpha: state.ghostAlpha);
      } else {
        ghostPaint.color = ghostColor;
      }
      canvas.drawPath(svgData.letters[i].path, ghostPaint);
      canvas.restore();
    }
  }

  void _drawGooLayer(Canvas canvas) {
    for (var i = 0; i < svgData.letters.length; i++) {
      final letter = svgData.letters[i];
      final state = frame.letters[i];

      if (state.c1Reveal > 0) {
        _drawPass(
          canvas,
          letter.path,
          letter.revealGuidePath,
          letter.bounds,
          colors[0],
          state.c1Reveal,
        );
      }
      if (state.c2Reveal > 0) {
        _drawPass(
          canvas,
          letter.path,
          letter.revealGuidePath,
          letter.bounds,
          colors[1],
          state.c2Reveal,
        );
      }
      if (state.c3Reveal > 0) {
        _drawPass(
          canvas,
          letter.path,
          letter.revealGuidePath,
          letter.bounds,
          colors[2],
          state.c3Reveal,
        );
      }
    }
  }

  void _drawPass(
    Canvas canvas,
    Path fillPath,
    Path guidePath,
    Rect bounds,
    Color color,
    double reveal,
  ) {
    if (reveal <= 0) return;

    canvas.save();
    canvas.clipPath(fillPath);

    final paint = Paint()..color = color;

    if (reveal >= 1) {
      paint.style = PaintingStyle.fill;
      canvas.drawPath(fillPath, paint);
    } else {
      // ponytail: thick trimmed stroke along guide ≈ path-following fill front
      final brushWidth = math.max(bounds.width, bounds.height) * 1.65;
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = brushWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      for (final metric in guidePath.computeMetrics()) {
        final end = metric.length * reveal;
        if (end <= 0) continue;
        canvas.drawPath(metric.extractPath(0, end), paint);
      }
    }

    canvas.restore();
  }

  void _drawBlackFade(Canvas canvas) {
    if (frame.blackFadeT <= 0) return;

    final finalColor = Color.lerp(colors[2], blackTarget, frame.blackFadeT)!;

    for (final letter in svgData.letters) {
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = finalColor;
      canvas.drawPath(letter.path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SplitrFluidWordmarkPainter oldDelegate) {
    return oldDelegate.frame != frame ||
        oldDelegate.svgData != svgData ||
        oldDelegate.ghostColor != ghostColor ||
        oldDelegate.blackTarget != blackTarget ||
        oldDelegate.colors != colors;
  }
}
