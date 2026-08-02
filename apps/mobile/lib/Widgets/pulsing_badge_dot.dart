import 'package:flutter/material.dart';
import 'package:splitr/Constants/app_palette.dart';

/// Profile menu badge dot with scale pulse (F13).
class PulsingBadgeDot extends StatefulWidget {
  const PulsingBadgeDot({super.key});

  @override
  State<PulsingBadgeDot> createState() => _PulsingBadgeDotState();
}

class _PulsingBadgeDotState extends State<PulsingBadgeDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1, end: 1.2).animate(
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
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 8,
        height: 8,
        margin: const EdgeInsets.only(right: 8),
        decoration: const BoxDecoration(
          color: AppPalette.mintAccent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
