import 'package:flutter/material.dart';

import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/app_palette.dart';

/// Fade-up reveal with per-index delay (F8 ledger rows, F7 avatars).
class RecapStaggerReveal extends StatefulWidget {
  const RecapStaggerReveal({
    super.key,
    required this.index,
    required this.child,
    this.step = const Duration(milliseconds: 40),
  });

  final int index;
  final Widget child;
  final Duration step;

  @override
  State<RecapStaggerReveal> createState() => _RecapStaggerRevealState();
}

class _RecapStaggerRevealState extends State<RecapStaggerReveal> {
  var _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.step * widget.index, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: AppMotion.standard,
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.08),
        duration: AppMotion.standard,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// One-shot green flash when a loan closed in-month (F8).
class RecapGreenFlash extends StatefulWidget {
  const RecapGreenFlash({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
  });

  final Widget child;
  final Duration duration;

  @override
  State<RecapGreenFlash> createState() => _RecapGreenFlashState();
}

class _RecapGreenFlashState extends State<RecapGreenFlash> {
  var _flash = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.duration, () {
      if (mounted) setState(() => _flash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_flash)
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(
                color: AppPalette.shareCardSettledGreen.withValues(alpha: 0.28),
              ),
            ),
          ),
      ],
    );
  }
}
