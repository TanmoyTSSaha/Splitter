import 'package:flutter/material.dart';
import 'package:splitr/Constants/app_themes.dart';

/// Applies dark input/text defaults for screens with a dark scaffold background.
class DarkSurfaceTheme extends StatelessWidget {
  final Widget child;

  const DarkSurfaceTheme({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppThemes.dark,
      child: child,
    );
  }
}
