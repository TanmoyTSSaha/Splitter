import 'package:flutter/material.dart';

import 'package:splitr/Constants/app_dimensions.dart';

import 'package:splitr/Constants/app_formats.dart';

import 'package:splitr/Constants/app_motion.dart';

import 'package:splitr/Constants/app_palette.dart';

import 'package:splitr/Constants/constants.dart';

import 'package:splitr/Constants/domain_values.dart';

import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

import 'package:splitr/Model/trip_model.dart';

import 'package:intl/intl.dart';

class TripGradientCard extends StatelessWidget {
  final TripModel trip;

  final VoidCallback onTap;

  const TripGradientCard({
    super.key,
    required this.trip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = _getTripGradient(trip.tripName);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: groupCarouselCardWidth,
        padding: const EdgeInsets.all(groupGutter),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(groupCardRadius),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.last.withValues(
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
                Row(
                  children: [
                    for (int i = 0;
                        i < (trip.memberIds.length.clamp(0, 2));
                        i++)
                      Align(
                        widthFactor: 0.6,
                        child: CircleAvatar(
                          radius: AppDimensions.tripMemberAvatarRadius,
                          backgroundColor: shareCardFillSoft,
                          child: Icon(
                            Icons.person,
                            size: AppDimensions.tripMemberIconSize,
                            color: shareCardOnSurface,
                          ),
                        ),
                      ),
                    if (trip.memberIds.length > 2)
                      Align(
                        widthFactor: 0.6,
                        child: CircleAvatar(
                          radius: AppDimensions.tripMemberAvatarRadius,
                          backgroundColor: neopopBackgroundFillMedium,
                          child: Text(
                            "+${trip.memberIds.length - 2}",
                            style: const TextStyle(
                              fontSize: splitrFontNano,
                              color: shareCardOnSurface,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Icon(
                  _getTripIcon(trip.tripName),
                  color: shareCardTextMuted,
                  size: groupCarouselIconLg,
                ),
              ],
            ),
            const SizedBox(height: groupGap20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: groupGapXs,
                    vertical: groupGap2,
                  ),
                  decoration: BoxDecoration(
                    color: neopopBackgroundFillSoft,
                    borderRadius: BorderRadius.circular(groupRadiusSm),
                  ),
                  child: Text(
                    "${DateFormat(AppDateFormats.tripRange).format(trip.startDate)} - ${DateFormat(AppDateFormats.tripRange).format(trip.endDate)}",
                    style: const TextStyle(
                      fontSize: splitrFontNano,
                      color: shareCardOnSurface,
                    ),
                  ),
                ),
                const SizedBox(height: groupGapSm),
                Text(
                  trip.tripName,
                  style: sub_headline5_text.copyWith(
                    color: shareCardOnSurface,
                    fontWeight: FontWeight.bold,
                    fontFamily: kFontAlbra,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getTripGradient(String name) {
    final lowerName = name.toLowerCase();

    if (lowerName.contains(TripNameKeywords.goa)) {
      return const LinearGradient(
        colors: [AppPalette.tripPurpleStart, AppPalette.tripPurpleEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    if (lowerName.contains(TripNameKeywords.bali)) {
      return const LinearGradient(
        colors: [AppPalette.tripOrangeStart, AppPalette.tripOrangeEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    return const LinearGradient(
      colors: [AppPalette.tripIndigoStart, AppPalette.tripIndigoEnd],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  IconData _getTripIcon(String name) {
    final lowerName = name.toLowerCase();

    if (lowerName.contains(TripNameKeywords.goa) ||
        lowerName.contains(TripNameKeywords.flight)) {
      return Icons.flight_takeoff_rounded;
    }

    if (lowerName.contains(TripNameKeywords.beach) ||
        lowerName.contains(TripNameKeywords.bali)) {
      return Icons.beach_access_rounded;
    }

    return Icons.explore_rounded;
  }
}
