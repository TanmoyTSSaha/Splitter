import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/theme_accent_colors.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Controllers/premium_subscription_controller.dart';
import 'package:splitr/Screen/ProfileScreen/premium_plan_screen.dart';

/// Returns true if the user has Pro, otherwise opens the paywall.
Future<bool> requirePremium({String? featureLabel}) async {
  final premium = Get.find<PremiumSubscriptionController>();
  if (premium.isPremium.value) return true;

  await Get.to(() => PremiumPlanScreen(highlightFeature: featureLabel));
  return premium.isPremium.value;
}

/// Compact upsell chip for inline use.
class PremiumLockBadge extends StatelessWidget {
  const PremiumLockBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: groupGapSm, vertical: groupGap2),
      decoration: BoxDecoration(
        color: neopopYellowFillStrong,
        borderRadius: BorderRadius.circular(groupControlRadius),
        border: Border.all(color: neopopYellowBorderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_rounded,
            size: AppDimensions.chartLegendDot,
            color: ThemeAccentColors.highlight(context),
          ),
          const SizedBox(width: groupGapXxs),
          Text(AppStrings.insights.proBadge,
              style: caption_text.copyWith(
                  color: ThemeAccentColors.highlight(context))),
        ],
      ),
    );
  }
}
