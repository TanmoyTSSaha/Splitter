import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

/// Reusable glassmorphism container with frosted-glass effect.
/// Creates visual depth over gradient mesh backgrounds.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool useBlur;

  const GlassCard({
    required this.child,
    this.blur = AppDimensions.glassCardBlurDefault,
    this.opacity = AppDimensions.glassCardOpacityDefault,
    this.borderRadius = groupCardRadius,
    this.padding,
    this.margin,
    this.useBlur = true,
    super.key,
  });

  bool _shouldBlur(BuildContext context) {
    if (!useBlur) return false;
    if (MediaQuery.disableAnimationsOf(context)) return false;
    return true;
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: neopopOnBackground.withOpacity(opacity),
      border: Border.all(
        color: neopopOnBackground.withOpacity(
          AppDimensions.glassCardBorderOpacity,
        ),
        width: AppDimensions.borderWidthHairline,
      ),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          neopopOnBackground.withOpacity(
            opacity + AppDimensions.glassCardGradientOpacityBump,
          ),
          neopopOnBackground.withOpacity(
            opacity - AppDimensions.glassCardGradientOpacityDip,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding ?? const EdgeInsets.all(groupGutter),
      decoration: _cardDecoration(),
      child: child,
    );

    if (!_shouldBlur(context)) {
      return Container(
        margin: margin,
        child: content,
      );
    }

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: content,
        ),
      ),
    );
  }
}
