import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_motion.dart';

/// Robinhood-style count-up for recap hero numbers.
class RecapCountUpText extends StatefulWidget {
  const RecapCountUpText({
    required this.value,
    required this.style,
    this.duration = AppMotion.recapCountUp,
    super.key,
  });

  final double value;
  final TextStyle style;
  final Duration duration;

  @override
  State<RecapCountUpText> createState() => _RecapCountUpTextState();
}

class _RecapCountUpTextState extends State<RecapCountUpText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.staggerSlide),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant RecapCountUpText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(begin: 0, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: AppCurves.staggerSlide),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final formatted = NumberFormat(AppDateFormats.numberGrouped)
            .format(_animation.value.round());
        return Text(formatted, style: widget.style);
      },
    );
  }
}
