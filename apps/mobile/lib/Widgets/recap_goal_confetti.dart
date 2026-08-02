import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:splitr/Constants/app_palette.dart';

/// Brief confetti burst when a goal hits target in-month (F9).
class RecapGoalConfetti extends StatefulWidget {
  const RecapGoalConfetti({
    super.key,
    required this.child,
    required this.active,
  });

  final Widget child;
  final bool active;

  @override
  State<RecapGoalConfetti> createState() => _RecapGoalConfettiState();
}

class _RecapGoalConfettiState extends State<RecapGoalConfetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _particles = List.generate(28, (_) => _Particle.random(_random));
    if (widget.active) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant RecapGoalConfetti oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _controller.value,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Particle {
  _Particle({
    required this.color,
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.rotation,
  });

  final Color color;
  final double x;
  final double y;
  final double size;
  final double speedX;
  final double speedY;
  final double rotation;

  factory _Particle.random(math.Random random) {
    const colors = [
      AppPalette.mintAccent,
      AppPalette.shareCardSettledGreen,
      Colors.white,
      Color(0xFFFFD54F),
    ];
    return _Particle(
      color: colors[random.nextInt(colors.length)],
      x: random.nextDouble(),
      y: random.nextDouble() * 0.35,
      size: 4 + random.nextDouble() * 5,
      speedX: (random.nextDouble() - 0.5) * 2,
      speedY: -0.5 - random.nextDouble(),
      rotation: random.nextDouble() * math.pi,
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles, required this.progress});

  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: (1 - progress).clamp(0.0, 1.0));
      final x = size.width * p.x + p.speedX * progress * 90;
      final y = size.height * 0.35 +
          p.speedY * progress * 100 +
          progress * progress * 280;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + progress * 5);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.65,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
