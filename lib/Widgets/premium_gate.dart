import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Controllers/premium_subscription_controller.dart';
import 'package:splitter/Screen/ProfileScreen/premium_plan_screen.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: neopopYellow.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: neopopYellow.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_rounded, size: 12, color: neopopYellow),
          const SizedBox(width: 4),
          Text('PRO', style: caption_text.copyWith(color: neopopYellow)),
        ],
      ),
    );
  }
}
