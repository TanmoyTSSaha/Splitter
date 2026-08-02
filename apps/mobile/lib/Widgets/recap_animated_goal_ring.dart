import 'package:flutter/material.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

/// Animated savings goal ring for recap slides.
class RecapAnimatedGoalRing extends StatefulWidget {
  const RecapAnimatedGoalRing({
    required this.progress,
    required this.label,
    this.size = 132,
    this.strokeWidth = 10,
    super.key,
  });

  final double progress;
  final String label;
  final double size;
  final double strokeWidth;

  @override
  State<RecapAnimatedGoalRing> createState() => _RecapAnimatedGoalRingState();
}

class _RecapAnimatedGoalRingState extends State<RecapAnimatedGoalRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _value;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _value = Tween<double>(begin: 0, end: widget.progress.clamp(0.0, 1.0))
        .animate(CurvedAnimation(
      parent: _controller,
      curve: AppCurves.staggerSlide,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant RecapAnimatedGoalRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _value = Tween<double>(begin: 0, end: widget.progress.clamp(0.0, 1.0))
          .animate(CurvedAnimation(
        parent: _controller,
        curve: AppCurves.staggerSlide,
      ));
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
      animation: _value,
      builder: (context, child) {
        final pct = (_value.value * 100).round();
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  value: _value.value,
                  strokeWidth: widget.strokeWidth,
                  backgroundColor: AppPalette.recapBorder,
                  color: AppPalette.mintAccent,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$pct%',
                    style: TextStyle(
                      fontFamily: kFontAlbra,
                      fontWeight: FontWeight.bold,
                      fontSize: splitrFontTitle,
                      color: AppPalette.recapOnSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: kFontCourier,
                      fontSize: splitrFontNanoSm,
                      color: AppPalette.recapOnSurfaceMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
