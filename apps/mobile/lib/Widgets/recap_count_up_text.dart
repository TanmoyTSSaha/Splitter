import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_motion.dart';

/// Robinhood-style count-up for recap hero numbers.
class RecapCountUpText extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey<double>(value),
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: AppCurves.staggerSlide,
      builder: (context, animatedValue, _) {
        final formatted = NumberFormat(AppDateFormats.numberGrouped)
            .format(animatedValue.round());
        return Text(formatted, style: style);
      },
    );
  }
}
