import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';

/// Reusable glassmorphism container with frosted-glass effect.
/// Creates visual depth over gradient mesh backgrounds.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassCard({
    required this.child,
    this.blur = 15.0,
    this.opacity = 0.08,
    this.borderRadius = 16.0,
    this.padding,
    this.margin,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? EdgeInsets.all(height_16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: neopopOnBackground.withOpacity(opacity),
              border: Border.all(
                color: neopopOnBackground.withOpacity(0.1),
                width: 1,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  neopopOnBackground.withOpacity(opacity + 0.03),
                  neopopOnBackground.withOpacity(opacity - 0.02),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
