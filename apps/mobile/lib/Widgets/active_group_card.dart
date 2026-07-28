import 'package:flutter/material.dart';

import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_motion.dart';

import 'package:splitr/Constants/app_palette.dart';

import 'package:splitr/Constants/app_strings.dart';

import 'package:splitr/Constants/constants.dart';

import 'package:splitr/Constants/domain_values.dart';

import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

import 'package:splitr/Model/group_model.dart';

class ActiveGroupCard extends StatelessWidget {
  final GroupModel groupModel;

  final VoidCallback onTap;

  const ActiveGroupCard({
    super.key,
    required this.groupModel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine color and icon based on group name or type (fallback for now)

    final Color cardColor = _getGroupColor(groupModel.groupName ?? "");

    final IconData cardIcon = _getGroupIcon(groupModel.groupName ?? "");

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: groupCarouselCardWidth,
        padding: const EdgeInsets.all(groupGutter),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(groupCardRadius),
          boxShadow: [
            BoxShadow(
              color: cardColor.withValues(
                alpha: AppDimensions.cardShadowColorOpacity,
              ),
              blurRadius: AppDimensions.groupCardShadowBlur,
              offset: AppAnimationOffsets.cardShadow,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(groupGapSm),
                  decoration: BoxDecoration(
                    color: shareCardFillMedium,
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: AppDimensions.activeGroupDotRadius,
                    backgroundColor: neopopPrimary,
                  ),
                ),
                Icon(
                  cardIcon,
                  color: shareCardTextMuted,
                  size: groupCarouselIconLg,
                ),
              ],
            ),
            const SizedBox(height: groupGap20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.premium.monthly.toUpperCase(),
                  style: caption_text.copyWith(
                    color: shareCardTextFaint,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold,
                    fontSize: splitrFontNano,
                  ),
                ),
                const SizedBox(height: groupGapXxs),
                Text(
                  groupModel.groupName ?? DisplayFallbacks.untitledGroup,
                  style: sub_headline5_text.copyWith(
                    color: shareCardOnSurface,
                    fontWeight: FontWeight.bold,
                    fontFamily: kFontAlbra,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getGroupColor(String name) {
    final lowerName = name.toLowerCase();

    if (lowerName.contains(CategorySlugValues.apartment) ||
        lowerName.contains(CategorySlugValues.rent)) {
      return AppPalette.cardDarkFill;
    }

    if (lowerName.contains(CategorySlugValues.dining) ||
        lowerName.contains(CategorySlugValues.food)) {
      return neopopAccent;
    }

    if (lowerName.contains(CategorySlugValues.trip) ||
        lowerName.contains(CategorySlugValues.travel)) {
      return CategoryMaterialColors.blue;
    }

    return AppPalette.cardDarkFill;
  }

  IconData _getGroupIcon(String name) {
    final lowerName = name.toLowerCase();

    if (lowerName.contains(CategorySlugValues.apartment) ||
        lowerName.contains(CategorySlugValues.rent)) {
      return Icons.home_rounded;
    }

    if (lowerName.contains(CategorySlugValues.dining) ||
        lowerName.contains(CategorySlugValues.food)) {
      return Icons.restaurant_rounded;
    }

    return Icons.group_rounded;
  }
}
