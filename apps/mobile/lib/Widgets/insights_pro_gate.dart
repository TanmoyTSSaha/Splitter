import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/theme_accent_colors.dart';
import 'package:splitr/Controllers/premium_subscription_controller.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Widgets/premium_gate.dart';

/// Blurs and locks Pro-only insight sections for free users.
class InsightsProGate extends StatelessWidget {
  final String featureLabel;
  final Widget child;
  final double blurSigma;

  /// When set, bypasses [PremiumSubscriptionController] (tests only).
  @visibleForTesting
  final bool? testIsPremium;

  const InsightsProGate({
    required this.featureLabel,
    required this.child,
    this.blurSigma = AppDimensions.proGateBlur,
    this.testIsPremium,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (testIsPremium != null) {
      return testIsPremium! ? child : _lockedOverlay(context);
    }

    return Obx(() {
      final isPro = Get.find<PremiumSubscriptionController>().isPremium.value;
      if (isPro) return child;
      return _lockedOverlay(context);
    });
  }

  Widget _lockedOverlay(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(groupCardRadius),
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: blurSigma,
              sigmaY: blurSigma,
            ),
            child: AbsorbPointer(child: child),
          ),
        ),
        Positioned.fill(
          child: Material(
            color: groupCardFill.withValues(
              alpha: AppDimensions.proGateScrimOpacity,
            ),
            borderRadius: BorderRadius.circular(groupCardRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(groupCardRadius),
              onTap: () => requirePremium(featureLabel: featureLabel),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(groupGapMd),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_rounded,
                          color: ThemeAccentColors.highlight(context),
                          size: AppDimensions.proGateIcon),
                      const SizedBox(height: groupGapSm),
                      Text(
                        '${AppStrings.insights.unlockFeature}$featureLabel',
                        textAlign: TextAlign.center,
                        style: body1_text.copyWith(
                          color: groupOnSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: groupGapXxs),
                      Text(
                        AppStrings.insights.upgradeToPro,
                        style:
                            caption_text.copyWith(color: groupOnSurfaceMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
