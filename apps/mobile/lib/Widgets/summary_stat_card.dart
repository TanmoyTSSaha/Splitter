import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:splitr/Constants/app_dimensions.dart';

import 'package:splitr/Constants/app_motion.dart';

import 'package:splitr/Constants/constants.dart';

import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

import 'package:splitr/Controllers/currency_controller.dart';

class SummaryStatCard extends StatelessWidget {
  final String title;

  final String amount;

  final String subtitle;

  final bool isPositive;

  const SummaryStatCard({
    super.key,
    required this.title,
    required this.amount,
    required this.subtitle,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(groupCardRadius),
      child: Container(
        padding: const EdgeInsets.all(groupGutter),
        decoration: BoxDecoration(
          color: groupCardFill,
          borderRadius: BorderRadius.circular(groupCardRadius),
          boxShadow: [
            BoxShadow(
              color: groupSurfaceFillSubtle,
              blurRadius: AppDimensions.summaryStatShadowBlur,
              offset: AppAnimationOffsets.cardShadow,
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Colored circle — fills the top-right corner of the card

            Positioned(
              right: AppDimensions.summaryStatDecorOffset,
              top: AppDimensions.summaryStatDecorOffset,
              child: Container(
                width: AppDimensions.summaryStatDecorCircle,
                height: AppDimensions.summaryStatDecorCircle,
                decoration: BoxDecoration(
                  color: isPositive
                      ? neopopAccentFillLight
                      : neopopPrimaryFillLight,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: caption_text.copyWith(
                    color: neopopGrey,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold,
                    letterSpacing: AppDimensions.letterSpacingSection,
                  ),
                ),
                const SizedBox(height: groupGapSm),
                Obx(() {
                  final sym = Get.find<CurrencyController>().symbol;

                  return Text(
                    "$sym$amount",
                    style: headline2_text.copyWith(
                      color: isPositive ? neopopAccent : neopopPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
                const SizedBox(height: groupGapSm),
                Row(
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      size: AppDimensions.tripMemberIconSize,
                      color: neopopGrey,
                    ),
                    const SizedBox(width: groupGapXxs),
                    Text(
                      subtitle,
                      style: caption_text.copyWith(
                        color: neopopGrey,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
