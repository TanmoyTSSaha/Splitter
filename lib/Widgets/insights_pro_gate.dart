import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Controllers/premium_subscription_controller.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitter/Widgets/premium_gate.dart';

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
    this.blurSigma = 6,
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
          borderRadius: BorderRadius.circular(16),
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
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => requirePremium(featureLabel: featureLabel),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(groupGapMd),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_rounded, color: neopopYellow, size: 28),
                      const SizedBox(height: groupGapSm),
                      Text(
                        'Unlock $featureLabel',
                        textAlign: TextAlign.center,
                        style: body1_text.copyWith(
                          color: groupOnSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Upgrade to Pro',
                        style: caption_text.copyWith(color: groupOnSurfaceMuted),
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
