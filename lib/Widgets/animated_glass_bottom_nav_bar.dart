import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';

/// Vertical clearance reserved above the floating bottom nav bar.
/// Sized for 56px nav items + padding.
const double bottomNavClearance = 80.0;

/// Data model for a single bottom-navigation tab.
class BottomNavItemData {
  final IconData outlineIcon;
  final IconData filledIcon;
  final String label;

  const BottomNavItemData({
    required this.outlineIcon,
    required this.filledIcon,
    required this.label,
  });
}

/// Transparent floating bottom nav with glass circles/pills and tab animations.
class AnimatedGlassBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItemData> items;

  const AnimatedGlassBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(items.length, (index) {
            return _AnimatedNavItem(
              key: ValueKey(items[index].label),
              isSelected: currentIndex == index,
              item: items[index],
              onTap: () => onTap(index),
            );
          }),
        ),
      ),
    );
  }
}

class _AnimatedNavItem extends StatefulWidget {
  final bool isSelected;
  final BottomNavItemData item;
  final VoidCallback onTap;

  const _AnimatedNavItem({
    required this.isSelected,
    required this.item,
    required this.onTap,
    super.key,
  });

  @override
  State<_AnimatedNavItem> createState() => _AnimatedNavItemState();
}

class _AnimatedNavItemState extends State<_AnimatedNavItem>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 300);
  static const _inactiveSize = 56.0;
  static const _iconCircleSize = 48.0;
  static const _iconSize = 26.0;
  static const _glassBlur = 20.0;
  static const _glassOpacity = 0.75;

  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _labelFade;
  late final Animation<Offset> _labelSlide;
  late final Animation<double> _accentScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _labelFade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _labelSlide = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _accentScale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    if (widget.isSelected) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_AnimatedNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected == oldWidget.isSelected) return;
    if (widget.isSelected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
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
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final isSelected = widget.isSelected;
          final borderRadius = isSelected ? 999.0 : _inactiveSize / 2;

          return AnimatedSize(
            duration: _duration,
            curve: Curves.easeOutCubic,
            alignment: Alignment.center,
            child: _GlassShell(
              borderRadius: borderRadius,
              blur: _glassBlur,
              opacity: _glassOpacity,
              child: SizedBox(
                height: _inactiveSize,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: _inactiveSize,
                      height: _inactiveSize,
                      child: Center(
                        child: SizedBox(
                          width: _iconCircleSize,
                          height: _iconCircleSize,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ScaleTransition(
                                scale: _accentScale,
                                child: Container(
                                  width: _iconCircleSize,
                                  height: _iconCircleSize,
                                  decoration: const BoxDecoration(
                                    color: neopopAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Icon(
                                isSelected
                                    ? widget.item.filledIcon
                                    : widget.item.outlineIcon,
                                color: isSelected
                                    ? neopopOnAccent
                                    : neopopOnBackground,
                                size: _iconSize,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: _expandAnimation.value,
                        child: SlideTransition(
                          position: _labelSlide,
                          child: FadeTransition(
                            opacity: _labelFade,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Text(
                                widget.item.label,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: neopopOnBackground,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GlassShell extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;

  const _GlassShell({
    required this.child,
    required this.borderRadius,
    required this.blur,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: neopopBackground.withValues(alpha: opacity),
            border: Border.all(
              color: neopopOnBackground.withValues(alpha: 0.12),
              width: 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                neopopBackground.withValues(alpha: opacity + 0.05),
                neopopBackground.withValues(alpha: opacity - 0.05),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
