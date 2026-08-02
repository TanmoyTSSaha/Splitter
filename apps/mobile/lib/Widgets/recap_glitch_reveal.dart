import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Spotify-style glitch settle for persona title (F10).
class RecapGlitchReveal extends StatefulWidget {
  const RecapGlitchReveal({
    super.key,
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle style;

  @override
  State<RecapGlitchReveal> createState() => _RecapGlitchRevealState();
}

class _RecapGlitchRevealState extends State<RecapGlitchReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
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
      builder: (context, _) {
        final t = _controller.value;
        if (t >= 0.72) {
          return Text(widget.text, style: widget.style);
        }

        final intensity = (1 - t) * 10;
        final dx = math.sin(t * 48) * intensity;
        final dy = math.cos(t * 37) * intensity * 0.35;
        final alpha = (0.35 + t * 0.65).clamp(0.0, 1.0);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Transform.translate(
              offset: Offset(-dx, dy),
              child: Text(
                widget.text,
                style: widget.style.copyWith(
                  color: const Color(0xFF00E5FF).withValues(alpha: alpha * 0.55),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(dx, -dy),
              child: Text(
                widget.text,
                style: widget.style.copyWith(
                  color: const Color(0xFFFF4081).withValues(alpha: alpha * 0.45),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(dx * 0.35, dy * 0.2),
              child: Opacity(
                opacity: alpha,
                child: Text(widget.text, style: widget.style),
              ),
            ),
          ],
        );
      },
    );
  }
}
