import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:splitr/Constants/app_motion.dart';

/// CRED-style Y-flip reveal with optional post-land pulse on child.
class RecapFlipReveal extends StatefulWidget {
  const RecapFlipReveal({
    required this.child,
    this.onLand,
    super.key,
  });

  final Widget child;
  final VoidCallback? onLand;

  @override
  State<RecapFlipReveal> createState() => _RecapFlipRevealState();
}

class _RecapFlipRevealState extends State<RecapFlipReveal>
    with TickerProviderStateMixin {
  late final AnimationController _flip;
  late final AnimationController _pulse;
  late final Animation<double> _flipAnim;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _flip = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: AppMotion.achievementCelebration,
    );
    _flipAnim = CurvedAnimation(parent: _flip, curve: AppCurves.settleSheet);
    _pulseAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.05), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
    _flip.forward().then((_) {
      if (!mounted) return;
      widget.onLand?.call();
      _pulse.forward();
    });
  }

  @override
  void dispose() {
    _flip.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_flipAnim, _pulseAnim]),
      builder: (context, child) {
        final flip = _flipAnim.value;
        final angle = flip * math.pi;
        final scale = _flip.isCompleted ? _pulseAnim.value : 1.0;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle)
            ..scale(scale),
          child: Opacity(
            opacity: flip < 0.5 ? 0.0 : 1.0,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
