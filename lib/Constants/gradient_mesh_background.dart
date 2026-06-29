import 'dart:math';
import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';

/// Animated 4-point gradient mesh background.
/// Creates a premium ambient motion effect (Apple/CRED-inspired).
class GradientMeshBackground extends StatefulWidget {
  final Widget? child;

  const GradientMeshBackground({this.child, super.key});

  @override
  State<GradientMeshBackground> createState() => _GradientMeshBackgroundState();
}

class _GradientMeshBackgroundState extends State<GradientMeshBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _MeshPainter(progress: _controller.value),
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
    // Animated radial gradients at 4 points
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
      neopopAccent.withOpacity(0.08),
      neopopPrimary.withOpacity(0.06),
      const Color(0xFF18C595).withOpacity(0.05),
      neopopYellow.withOpacity(0.04),
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
