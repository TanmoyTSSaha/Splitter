import 'dart:async';

import 'package:flutter/material.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Screen/ProfileScreen/recap_slide_scaffold.dart';
import 'package:story_view/story_view.dart';

/// CRED-style story host: segmented progress, tap zones, optional intro auto-advance.
class MonthlyRecapStoryHost extends StatefulWidget {
  const MonthlyRecapStoryHost({
    required this.slides,
    this.autoAdvanceIntro = false,
    this.onIntroAutoAdvanced,
    this.onComplete,
    super.key,
  });

  final List<Widget> slides;
  final bool autoAdvanceIntro;
  final VoidCallback? onIntroAutoAdvanced;
  final VoidCallback? onComplete;

  @override
  State<MonthlyRecapStoryHost> createState() => _MonthlyRecapStoryHostState();
}

class _MonthlyRecapStoryHostState extends State<MonthlyRecapStoryHost> {
  late final StoryController _controller;
  Timer? _introTimer;
  var _closing = false;

  @override
  void initState() {
    super.initState();
    _controller = StoryController();
  }

  @override
  void dispose() {
    _closing = true;
    _introTimer?.cancel();
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  void _closeRecap() {
    if (_closing || !mounted) return;
    _closing = true;
    _introTimer?.cancel();
    _controller.pause();
    Navigator.of(context).pop();
  }

  void _pauseOnShow() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.pause();
    });
  }

  void _onStoryShow(StoryItem storyItem, int index) {
    _introTimer?.cancel();
    if (widget.autoAdvanceIntro && index == 0) {
      _introTimer = Timer(AppMotion.recapIntroAutoAdvance, () {
        if (!mounted) return;
        widget.onIntroAutoAdvanced?.call();
        _controller.next();
      });
      return;
    }
    _pauseOnShow();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final storyItems = widget.slides
        .map(
          (slide) => StoryItem(
            RecapSlideScaffold(
              child: SizedBox.expand(child: slide),
            ),
            duration: AppMotion.recapStorySlide,
          ),
        )
        .toList();

    // ponytail: parent vertical drag — story_view 0.16.6 null-derefs verticalDragInfo on swipe end
    return GestureDetector(
      onVerticalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity > 400) _closeRecap();
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          StoryView(
            storyItems: storyItems,
            controller: _controller,
            progressPosition: ProgressPosition.top,
            repeat: false,
            inline: false,
            indicatorColor: neopopOnBackground.withValues(alpha: 0.25),
            indicatorForegroundColor: neopopAccent,
            indicatorHeight: IndicatorHeight.small,
            indicatorOuterPadding: EdgeInsets.fromLTRB(
              groupGapSm,
              topInset + groupGapSm,
              groupGapSm,
              0,
            ),
            onStoryShow: _onStoryShow,
            onComplete: () {
              if (_closing) return;
              widget.onComplete?.call();
            },
          ),
        Positioned(
          top: topInset + groupGapSm,
          right: groupGapLg,
          child: GestureDetector(
            onTap: _closeRecap,
            child: Container(
              padding: const EdgeInsets.all(groupGapSm),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppPalette.recapBorder),
                color: neopopBackground.withValues(alpha: 0.6),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: AppPalette.recapOnSurface,
                size: 20,
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }
}
