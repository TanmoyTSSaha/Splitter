import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:splitr/Constants/app_assets.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Widgets/splitr_fluid_wordmark_painter.dart';
import 'package:splitr/Widgets/splitr_fluid_wordmark_timeline.dart';
import 'package:xml/xml.dart';

/// One letter path from the splash wordmark SVG.
class LetterPathData {
  const LetterPathData({
    required this.id,
    required this.letterIndex,
    required this.path,
    required this.bounds,
    required this.revealGuidePath,
  });

  final String id;
  final int letterIndex;
  final Path path;
  final Rect bounds;
  /// Left→right flow curve; color front follows via [PathMetric.extractPath].
  final Path revealGuidePath;
}

/// Parsed SVG geometry for the animated wordmark.
class WordmarkSvgData {
  const WordmarkSvgData({
    required this.viewBoxWidth,
    required this.viewBoxHeight,
    required this.letters,
  });

  final double viewBoxWidth;
  final double viewBoxHeight;
  final List<LetterPathData> letters;
}

Future<WordmarkSvgData> loadWordmarkSvg() async {
  final raw = await rootBundle.loadString(AppAssets.splashWordmarkStrokes);
  final doc = XmlDocument.parse(raw);
  final svg = doc.rootElement;
  final viewBox = svg.getAttribute('viewBox')!.split(RegExp(r'\s+'));
  final viewBoxWidth = double.parse(viewBox[2]);
  final viewBoxHeight = double.parse(viewBox[3]);

  final pathById = <String, Path>{};
  for (final group in svg.findElements('g')) {
    for (final pathEl in group.findElements('path')) {
      final id = pathEl.getAttribute('id');
      final d = pathEl.getAttribute('d');
      if (id == null || id.isEmpty || d == null || d.isEmpty) continue;
      pathById[id] = parseSvgPathData(d);
    }
  }

  final letters = <LetterPathData>[];
  for (var i = 0; i < SplitrFluidWordmarkTimeline.letterOrder.length; i++) {
    final id = SplitrFluidWordmarkTimeline.letterOrder[i];
    final path = pathById[id];
    if (path == null) continue;
    final bounds = path.getBounds();
    letters.add(
      LetterPathData(
        id: id,
        letterIndex: i,
        path: path,
        bounds: bounds,
        revealGuidePath: buildLetterRevealGuide(bounds),
      ),
    );
  }

  return WordmarkSvgData(
    viewBoxWidth: viewBoxWidth,
    viewBoxHeight: viewBoxHeight,
    letters: letters,
  );
}

/// Animated Splitr. wordmark — goo-fluid fill, then black fade.
class SplitrStrokeWordmark extends StatefulWidget {
  const SplitrStrokeWordmark({
    super.key,
    this.onDrawComplete,
    this.loop = false,
  });

  final VoidCallback? onDrawComplete;
  /// Full cycle → hold → reset. For splash preview only.
  final bool loop;

  @override
  State<SplitrStrokeWordmark> createState() => _SplitrStrokeWordmarkState();
}

class _SplitrStrokeWordmarkState extends State<SplitrStrokeWordmark>
    with SingleTickerProviderStateMixin {
  static Future<WordmarkSvgData>? _cachedSvgFuture;

  late final AnimationController _controller;
  late final Future<WordmarkSvgData> _svgDataFuture;
  bool _drawCompleteNotified = false;
  Timer? _holdTimer;

  static const _wordmarkHeight = splitrFontRecapXl;
  static const _wordmarkAspect = 135.15 / 48.0;

  static Size get _wordmarkSize => Size(
        _wordmarkHeight * _wordmarkAspect,
        _wordmarkHeight,
      );

  Widget _staticWordmark() {
    final size = _wordmarkSize;
    return Image.asset(
      AppAssets.splashWordmarkDark,
      width: size.width,
      height: size.height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }

  @override
  void initState() {
    super.initState();
    _svgDataFuture = _cachedSvgFuture ??= loadWordmarkSvg();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.splashFluid,
    );
    _controller.addStatusListener(_onAnimationStatus);
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;

    if (!_drawCompleteNotified) {
      _drawCompleteNotified = true;
      widget.onDrawComplete?.call();
    }

    if (!widget.loop) return;

    _holdTimer?.cancel();
    _holdTimer = Timer(AppMotion.splashHold, () {
      if (!mounted) return;
      _drawCompleteNotified = false;
      _controller
        ..reset()
        ..forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      return;
    }
    if (!_controller.isAnimating && _controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _controller.removeStatusListener(_onAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    if (disableAnimations) {
      return _staticWordmark();
    }

    return FutureBuilder<WordmarkSvgData>(
      future: _svgDataFuture,
      builder: (context, snapshot) {
        final size = _wordmarkSize;
        final width = size.width;
        final height = size.height;

        if (!snapshot.hasData) {
          // ponytail: empty placeholder — native splash already shows black wordmark
          return SizedBox(width: width, height: height);
        }

        final data = snapshot.data!;

        return SizedBox(
          width: width,
          height: height,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final elapsedMs =
                  (_controller.value * SplitrFluidWordmarkTimeline.totalMs)
                      .round();
              final frame = SplitrFluidWordmarkTimeline.frameAt(
                Duration(milliseconds: elapsedMs),
              );

              return CustomPaint(
                size: Size(width, height),
                painter: SplitrFluidWordmarkPainter(
                  svgData: data,
                  frame: frame,
                  ghostColor: AppPalette.recapMutedFill,
                  colors: const [
                    SplitrStrokeWordmarkColors.yellow,
                    SplitrStrokeWordmarkColors.red,
                    SplitrStrokeWordmarkColors.green,
                  ],
                  blackTarget: groupOnSurface,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Flow guide for path-following color reveal (left → right through glyph).
Path buildLetterRevealGuide(Rect bounds) {
  final midY = bounds.center.dy;
  final height = bounds.height;
  final pad = bounds.width * 0.15;

  return Path()
    ..moveTo(bounds.left - pad, midY)
    ..cubicTo(
      bounds.left + bounds.width * 0.28,
      midY - height * 0.38,
      bounds.left + bounds.width * 0.62,
      midY + height * 0.38,
      bounds.right + pad,
      midY,
    );
}

/// Brand fluid colors for the splash wordmark animation.
abstract final class SplitrStrokeWordmarkColors {
  static const yellow = neopopYellow;
  static const red = neopopError;
  static const green = neopopSuccessBright;
}
