import 'dart:io' show Platform;
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/constants.dart';

/// Animated 4-point gradient mesh background.
/// Creates a premium ambient motion effect (Apple/CRED-inspired).
class GradientMeshBackground extends StatefulWidget {
  final Widget? child;

  const GradientMeshBackground({this.child, super.key});

  /// Static mesh when reduce-motion is on or device likely low-end Android.
  static bool shouldUseStaticMesh(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return true;
    final features =
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures;
    if (features.disableAnimations) return true;

    if (!kIsWeb && Platform.isAndroid) {
      final mq = MediaQuery.of(context);
      final logicalShortSide = min(mq.size.width, mq.size.height);
      // Heuristic: sub-360dp short side often correlates with low RAM tier.
      if (logicalShortSide < 360) return true;
    }
    return false;
  }

  @override
  State<GradientMeshBackground> createState() => _GradientMeshBackgroundState();
}

class _GradientMeshBackgroundState extends State<GradientMeshBackground>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (GradientMeshBackground.shouldUseStaticMesh(context)) {
      _controller?.dispose();
      _controller = null;
      return CustomPaint(
        painter: _MeshPainter(progress: 0),
        child: widget.child,
      );
    }

    _controller ??= AnimationController(
      vsync: this,
      duration: AppMotion.meshBackground,
    )..repeat();

    final controller = _controller!;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _MeshPainter(progress: controller.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _MeshPainter extends CustomPainter {
  final double progress;

  _MeshPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      Offset(
        size.width * (0.2 + 0.1 * sin(progress * 2 * pi)),
        size.height * (0.15 + 0.05 * cos(progress * 2 * pi)),
      ),
      Offset(
        size.width * (0.8 + 0.08 * cos(progress * 2 * pi + 1)),
        size.height * (0.3 + 0.1 * sin(progress * 2 * pi + 1)),
      ),
      Offset(
        size.width * (0.3 + 0.12 * sin(progress * 2 * pi + 2)),
        size.height * (0.7 + 0.08 * cos(progress * 2 * pi + 2)),
      ),
      Offset(
        size.width * (0.75 + 0.06 * cos(progress * 2 * pi + 3)),
        size.height * (0.85 + 0.05 * sin(progress * 2 * pi + 3)),
      ),
    ];

    final colors = [
      neopopAccentFillFaint,
      neopopPrimaryFillSubtle,
      neopopAccentFillWhisper,
      neopopYellow.withValues(alpha: AppDimensions.meshYellowOpacity),
    ];

    final radii = [
      size.width * 0.55,
      size.width * 0.45,
      size.width * 0.50,
      size.width * 0.40,
    ];

    for (int i = 0; i < 4; i++) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [colors[i], colors[i].withOpacity(0)],
          stops: const [0.0, 1.0],
        ).createShader(
          Rect.fromCircle(center: points[i], radius: radii[i]),
        );

      canvas.drawCircle(points[i], radii[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MeshPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
