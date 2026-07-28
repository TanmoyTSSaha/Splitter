import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:splitr/Constants/app_assets.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

/// One-shot Lottie for monthly badge unlock on persona slide (F10).
class RecapBadgeLottie extends StatelessWidget {
  const RecapBadgeLottie({
    super.key,
    this.size = groupIconMd,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        AppAssets.lottieRupeeCoinFallback,
        repeat: false,
        fit: BoxFit.contain,
      ),
    );
  }
}
