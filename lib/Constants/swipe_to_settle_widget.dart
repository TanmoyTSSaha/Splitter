import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splitter/Constants/constants.dart';

/// Iconic swipe-to-settle gesture with spring physics, shimmer, haptics,
/// and confetti burst on completion. SplitO's brand signature interaction.
class SwipeToSettleWidget extends StatefulWidget {
  final double amount;
  final String fromName;
  final String toName;
  final VoidCallback onSettled;
  final VoidCallback onCancel;

  const SwipeToSettleWidget({
    required this.amount,
    required this.fromName,
    required this.toName,
    required this.onSettled,
    required this.onCancel,
    super.key,
  });

  @override
  State<SwipeToSettleWidget> createState() => _SwipeToSettleWidgetState();
}

class _SwipeToSettleWidgetState extends State<SwipeToSettleWidget>
    with TickerProviderStateMixin {
  double _dragPosition = 0.0;
  double _maxDrag = 0.0;
  bool _settled = false;

  late AnimationController _shimmerController;
  late AnimationController _confettiController;
  late AnimationController _springController;
  late Animation<double> _springAnimation;

  // Confetti particles
  final List<_ConfettiParticle> _particles = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _springAnimation = _springController.drive(
      CurveTween(curve: Curves.elasticOut),
    );

    _springController.addListener(() {
      setState(() {
        _dragPosition = _springAnimation.value * 0;
      });
    });

    // Generate confetti particles
    for (int i = 0; i < 60; i++) {
      _particles.add(_ConfettiParticle(
        color: [
          neopopAccent,
          neopopYellow,
          Colors.cyan,
          Colors.pinkAccent,
          Colors.purpleAccent,
          Colors.greenAccent
        ][i % 6],
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 8 + 4,
        speedX: (_random.nextDouble() - 0.5) * 6,
        speedY: _random.nextDouble() * -8 - 2,
        rotation: _random.nextDouble() * 2 * pi,
      ));
    }

    _confettiController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _confettiController.dispose();
    _springController.dispose();
    super.dispose();
  }

  double get _progress =>
      _maxDrag > 0 ? (_dragPosition / _maxDrag).clamp(0.0, 1.0) : 0.0;

  void _onDragUpdate(DragUpdateDetails details) {
    if (_settled) return;
    setState(() {
      _dragPosition = (_dragPosition + details.delta.dx).clamp(0.0, _maxDrag);
    });

    // Haptic feedback at thresholds
    if (_progress > 0.25 && _progress < 0.27) {
      HapticFeedback.lightImpact();
    } else if (_progress > 0.50 && _progress < 0.52) {
      HapticFeedback.mediumImpact();
    } else if (_progress > 0.75 && _progress < 0.77) {
      HapticFeedback.heavyImpact();
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_settled) return;
    if (_progress >= 0.85) {
      // Settled!
      setState(() {
        _settled = true;
        _dragPosition = _maxDrag;
      });
      HapticFeedback.heavyImpact();
      _confettiController.forward();

      Future.delayed(const Duration(milliseconds: 800), () {
        widget.onSettled();
      });
    } else {
      // Spring back
      _springController.reset();
      final startPos = _dragPosition;
      _springAnimation =
          Tween<double>(begin: startPos, end: 0.0).animate(CurvedAnimation(
        parent: _springController,
        curve: Curves.elasticOut,
      ));
      _springController.addListener(() {
        if (mounted) {
          setState(() {
            _dragPosition = _springAnimation.value;
          });
        }
      });
      _springController.forward();
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Top bar with cancel
                Padding(
                  padding: EdgeInsets.all(width_16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: widget.onCancel,
                        icon: const Icon(Icons.close_rounded,
                            color: neopopOnBackground, size: 28),
                      ),
                      Text("Settle Up", style: sub_headline4_text),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                const Spacer(),

                // Amount display
                Text(
                  "₹${widget.amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w700,
                    color: _settled ? neopopAccent : neopopOnBackground,
                    fontFamily: 'Albra',
                    letterSpacing: -2,
                  ),
                ),
                SizedBox(height: height_10),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: body1_text.copyWith(color: neopopGrey),
                    children: [
                      TextSpan(
                        text: widget.fromName,
                        style: body1_text.copyWith(
                            color: neopopYellow, fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(text: "  →  "),
                      TextSpan(
                        text: widget.toName,
                        style: body1_text.copyWith(
                            color: neopopAccent, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Swipe track
                if (!_settled)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width_16 * 2),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        _maxDrag = constraints.maxWidth - 64;
                        return Container(
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            color: neopopOnPrimary.withOpacity(0.08),
                            border: Border.all(
                              color: Color.lerp(neopopGrey.withOpacity(0.2),
                                  neopopAccent, _progress)!,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Progress fill
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 50),
                                width: _dragPosition + 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  gradient: LinearGradient(
                                    colors: [
                                      neopopAccent.withOpacity(0.3 * _progress),
                                      neopopAccent.withOpacity(0.1 * _progress),
                                    ],
                                  ),
                                ),
                              ),

                              // Shimmer text
                              Center(
                                child: AnimatedBuilder(
                                  animation: _shimmerController,
                                  builder: (_, __) {
                                    return ShaderMask(
                                      shaderCallback: (bounds) {
                                        return LinearGradient(
                                          begin: Alignment(
                                              -1.0 +
                                                  2 * _shimmerController.value,
                                              0),
                                          end: Alignment(
                                              1.0 +
                                                  2 * _shimmerController.value,
                                              0),
                                          colors: [
                                            neopopGrey.withOpacity(0.3),
                                            neopopOnBackground,
                                            neopopGrey.withOpacity(0.3),
                                          ],
                                          stops: const [0.0, 0.5, 1.0],
                                        ).createShader(bounds);
                                      },
                                      child: Text(
                                        "Swipe to settle →",
                                        style: body1_text.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // Draggable thumb
                              Positioned(
                                left: _dragPosition,
                                top: 4,
                                child: GestureDetector(
                                  onHorizontalDragUpdate: _onDragUpdate,
                                  onHorizontalDragEnd: _onDragEnd,
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color.lerp(neopopOnBackground,
                                          neopopAccent, _progress),
                                      boxShadow: [
                                        BoxShadow(
                                          color: neopopAccent
                                              .withOpacity(0.3 * _progress),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _progress > 0.85
                                          ? Icons.check_rounded
                                          : Icons.arrow_forward_rounded,
                                      color: neopopBackground,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                // Success state
                if (_settled)
                  Column(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: neopopAccent, size: 64),
                      SizedBox(height: height_10),
                      Text("Settled! 🎉",
                          style: headline2_text.copyWith(color: neopopAccent)),
                    ],
                  ),

                SizedBox(height: height_16 * 4),
              ],
            ),

            // Confetti overlay
            if (_settled)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _ConfettiPainter(
                      particles: _particles,
                      progress: _confettiController.value,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ConfettiParticle {
  final Color color;
  final double x, y, size, speedX, speedY, rotation;

  _ConfettiParticle({
    required this.color,
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.rotation,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final paint = Paint()
        ..color = p.color.withOpacity((1 - progress).clamp(0.0, 1.0));

      final x = size.width * p.x + p.speedX * progress * 80;
      final y = size.height * 0.4 +
          p.speedY * progress * 120 +
          progress * progress * 300; // Gravity

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + progress * 4);
      canvas.drawRect(
        Rect.fromCenter(
            center: Offset.zero, width: p.size, height: p.size * 0.6),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
