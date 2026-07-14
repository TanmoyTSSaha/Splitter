import 'package:flutter/material.dart';
import 'package:splitr/Constants/app_motion.dart';

/// Wraps a list item with staggered fade-in + slide-up animation.
/// Use inside a ListView to create a cascading entrance effect.
class StaggeredListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;

  const StaggeredListItem({
    required this.child,
    required this.index,
    this.delay = AppMotion.staggerItemDelay,
    this.duration = AppMotion.staggerItemDuration,
    super.key,
  });

  @override
  State<StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<StaggeredListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: AppCurves.staggerFade,
    );

    _slideAnimation = Tween<Offset>(
      begin: AppAnimationOffsets.staggerSlideBegin,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppCurves.staggerSlide,
    ));

    // Staggered delay based on index
    Future.delayed(widget.delay * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
