import 'dart:math';
import 'package:flutter/material.dart';
import 'package:splitr/Utils/currency_utils.dart';
import 'package:flutter/services.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

/// Iconic swipe-to-settle gesture with spring physics, shimmer, haptics,
/// and confetti burst on completion. Splitr's brand signature interaction.
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
      duration: AppMotion.settleSwipePrimary,
    )..repeat();

    _confettiController = AnimationController(
      vsync: this,
      duration: AppMotion.settleSwipeSecondary,
    );

    _springController = AnimationController(
      vsync: this,
      duration: AppMotion.settleSwipeReset,
    );

    _springAnimation = _springController.drive(
      CurveTween(curve: AppCurves.settleSpring),
    );

    _springController.addListener(() {
      setState(() {
        _dragPosition = _springAnimation.value * 0;
      });
    });

    // Generate confetti particles
    for (int i = 0; i < 60; i++) {
      _particles.add(_ConfettiParticle(
        color: SettleConfettiColors.list[i % SettleConfettiColors.list.length],
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

      Future.delayed(AppMotion.settleSwipeDelay, () {
        widget.onSettled();
      });
    } else {
      // Spring back
      _springController.reset();
      final startPos = _dragPosition;
      _springAnimation =
          Tween<double>(begin: startPos, end: 0.0).animate(CurvedAnimation(
        parent: _springController,
        curve: AppCurves.settleSpring,
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
      color: AppScrimColors.dark,
      child: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Top bar with cancel
                Padding(
                  padding: const EdgeInsets.all(groupGutter),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: widget.onCancel,
                        icon: const Icon(Icons.close_rounded,
                            color: neopopOnBackground,
                            size: AppDimensions.groupIconLg),
                      ),
                      Text(AppStrings.settle.title, style: sub_headline4_text),
                      const SizedBox(
                          width: AppDimensions.swipeSettleCancelSpacer),
                    ],
                  ),
                ),

                const Spacer(),

                // Amount display
                Text(
                  "${userCurrencySymbol()}${widget.amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: splitrFontSwipeHero,
                    fontWeight: FontWeight.w700,
                    color: _settled ? neopopAccent : neopopOnBackground,
                    fontFamily: kFontAlbra,
                    letterSpacing: AppDimensions.letterSpacingSwipeHero,
                  ),
                ),
                const SizedBox(height: groupGapSm),
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
                      TextSpan(text: AppStrings.settle.flowArrow),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: groupGutter * 2),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        _maxDrag = constraints.maxWidth -
                            AppDimensions.swipeSettleIconPadding;
                        return Container(
                          height: AppDimensions.swipeSettleTrackHeight,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(groupPillRadius),
                            color: neopopOnPrimaryFillFaint,
                            border: Border.all(
                              color: Color.lerp(
                                neopopGreyBorder,
                                neopopAccent,
                                _progress,
                              )!,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Progress fill
                              AnimatedContainer(
                                duration: AppMotion.micro,
                                width: _dragPosition +
                                    AppDimensions.swipeSettleIconPadding,
                                height: AppDimensions.swipeSettleTrackHeight,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(groupPillRadius),
                                  gradient: LinearGradient(
                                    colors: [
                                      neopopAccent.withValues(
                                          alpha: 0.3 * _progress),
                                      neopopAccent.withValues(
                                          alpha: 0.1 * _progress),
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
                                            neopopGreyBorderSoft,
                                            neopopOnBackground,
                                            neopopGreyBorderSoft,
                                          ],
                                          stops: const [0.0, 0.5, 1.0],
                                        ).createShader(bounds);
                                      },
                                      child: Text(
                                        AppStrings.settle.swipeHint,
                                        style: body1_text.copyWith(
                                          color: neopopOnPrimary,
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
                                top: AppDimensions.swipeSettleThumbTop,
                                child: GestureDetector(
                                  onHorizontalDragUpdate: _onDragUpdate,
                                  onHorizontalDragEnd: _onDragEnd,
                                  child: Container(
                                    width: AppDimensions.swipeSettleThumbSize,
                                    height: groupCtaHeight,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color.lerp(neopopOnBackground,
                                          neopopAccent, _progress),
                                      boxShadow: [
                                        BoxShadow(
                                          color: neopopAccent.withValues(
                                              alpha: 0.3 * _progress),
                                          blurRadius: AppDimensions
                                              .swipeSettleThumbShadowBlur,
                                          spreadRadius: AppDimensions
                                              .swipeSettleThumbShadowSpread,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _progress > 0.85
                                          ? Icons.check_rounded
                                          : Icons.arrow_forward_rounded,
                                      color: neopopBackground,
                                      size: AppDimensions.swipeSettleIconSize,
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
                      const Icon(Icons.check_circle_rounded,
                          color: neopopAccent,
                          size: AppDimensions.swipeSettleTrackHeight),
                      const SizedBox(height: groupGapSm),
                      Text(AppStrings.settle.settled,
                          style: headline2_text.copyWith(color: neopopAccent)),
                    ],
                  ),

                const SizedBox(height: groupGapXl * 2),
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
        ..color = p.color.withValues(alpha: (1 - progress).clamp(0.0, 1.0));

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
