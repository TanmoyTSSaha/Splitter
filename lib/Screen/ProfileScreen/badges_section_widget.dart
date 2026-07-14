import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/achievement_icon_map.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Controller/achievement_controller.dart';
import 'package:splitr/Model/achievement_model.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Constants/app_strings.dart';

class BadgesSectionWidget extends StatelessWidget {
  const BadgesSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AchievementController>()) {
      return const SizedBox.shrink();
    }
    final controller = Get.find<AchievementController>();

    return Obx(() {
      if (controller.isLoading.value && controller.achievements.isEmpty) {
        return const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      }

      final badges = controller.achievements;
      if (badges.isEmpty) {
        return const SizedBox.shrink();
      }

      return SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.profile.achievements,
              style: headline3_text.copyWith(
                fontFamily: kFontAlbra,
                fontWeight: FontWeight.w600,
                color: groupOnSurface,
              ),
            ),
            const SizedBox(height: groupGapSm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: badges.map(_buildBadge).toList(),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBadge(AchievementModel badge) {
    final assetPath = AchievementIconMap.assetFor(badge.iconKey);
    return Container(
      margin: const EdgeInsets.only(right: groupGapMd),
      width: 100,
      child: Column(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color:
                  badge.isUnlocked ? neopopAccentFillSoft : groupMutedFillSoft,
              borderRadius: BorderRadius.circular(groupRadiusBadge),
              border: Border.all(
                color: badge.isUnlocked ? neopopAccent : groupOnSurfaceMuted,
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(groupCarouselGap),
            child: Opacity(
              opacity: badge.isUnlocked ? 1.0 : 0.4,
              child: assetPath != null
                  ? Image.asset(
                      assetPath,
                      errorBuilder: (_, __, ___) => Icon(
                        AchievementIconMap.iconFor(badge.iconKey),
                        size: 32,
                        color: badge.isUnlocked
                            ? neopopAccent
                            : groupOnSurfaceMuted,
                      ),
                    )
                  : Icon(
                      AchievementIconMap.iconFor(badge.iconKey),
                      size: 32,
                      color: badge.isUnlocked
                          ? neopopAccent
                          : groupOnSurfaceMuted,
                    ),
            ),
          ),
          const SizedBox(height: groupGapSm),
          Text(
            badge.name,
            style: body2_text.copyWith(
              color: badge.isUnlocked ? groupOnSurface : groupOnSurfaceMuted,
              fontWeight: FontWeight.w600,
              fontSize: splitrFontCaption,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
