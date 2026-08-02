import 'package:flutter/material.dart';
import 'package:splitr/Constants/app_motion.dart';

/// Subtle scale pulse for recap share CTA (F11).
class RecapPulseCta extends StatefulWidget {
  const RecapPulseCta({
    required this.child,
    this.onTap,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<RecapPulseCta> createState() => _RecapPulseCtaState();
}

class _RecapPulseCtaState extends State<RecapPulseCta>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.settleSwipePrimary,
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
