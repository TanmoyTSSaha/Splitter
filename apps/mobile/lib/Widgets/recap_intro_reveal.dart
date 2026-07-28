import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Widgets/splitr_stroke_wordmark.dart';

/// CRED-style intro reveal: wordmark stroke, staggered title, teaser card.
class RecapIntroReveal extends StatefulWidget {
  const RecapIntroReveal({
    required this.firstName,
    required this.monthName,
    required this.subtitle,
    this.teaserCard,
    super.key,
  });

  final String firstName;
  final String monthName;
  final String subtitle;
  final Widget? teaserCard;

  @override
  State<RecapIntroReveal> createState() => _RecapIntroRevealState();
}

class _RecapIntroRevealState extends State<RecapIntroReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hapticFired = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.recapIntro,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _interval(double begin, double end) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, end, curve: AppCurves.staggerSlide),
    );
  }

  Widget _staggerLine(String text, double fontSize, double begin, double end) {
    final anim = _interval(begin, end);
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(anim),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: kFontAlbra,
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: AppPalette.recapOnSurface,
            height: 1.05,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 0.9, curve: Curves.easeOutBack),
    );

    cardAnim.addListener(() {
      if (!_hapticFired && cardAnim.value > 0.85) {
        _hapticFired = true;
        HapticFeedback.lightImpact();
      }
    });

    final subtitleAnim = _interval(0.45, 0.65);

    return Column(
      children: [
        const SizedBox(
          height: 56,
          child: Center(
            child: SplitrStrokeWordmark(),
          ),
        ),
        const SizedBox(height: 24),
        if (widget.firstName != DisplayFallbacks.your) ...[
          _staggerLine(
            widget.firstName,
            splitrFontTitle,
            0.15,
            0.35,
          ),
          const SizedBox(height: 8),
        ],
        _staggerLine('Your', splitrFontRecapDisplay, 0.2, 0.42),
        const SizedBox(height: 4),
        _staggerLine(widget.monthName, splitrFontRecapDisplay, 0.28, 0.5),
        const SizedBox(height: 4),
        _staggerLine('Recap', splitrFontRecapDisplay, 0.36, 0.58),
        const SizedBox(height: 32),
        FadeTransition(
          opacity: subtitleAnim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(subtitleAnim),
            child: Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kFontCourier,
                fontSize: splitrFontMicro,
                letterSpacing: 2.0,
                fontWeight: FontWeight.bold,
                color: AppPalette.recapOnSurfaceMuted,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        FadeTransition(
          opacity: subtitleAnim,
          child: Container(
            height: 1,
            width: 240,
            color: AppPalette.recapBorder,
          ),
        ),
        const SizedBox(height: groupCtaHeightCompact),
        if (widget.teaserCard != null)
          ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(cardAnim),
            child: FadeTransition(
              opacity: cardAnim,
              child: widget.teaserCard!,
            ),
          ),
      ],
    );
  }
}
