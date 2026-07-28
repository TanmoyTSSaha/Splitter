import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Utils/recap_persona_theme.dart';

class RecapShareCardData {
  const RecapShareCardData({
    required this.firstName,
    required this.month,
    required this.totalSpent,
    required this.trendLabel,
    required this.topCategory,
    required this.personaTitle,
    required this.personaType,
    required this.currencySymbol,
    this.groupHighlight,
    this.goalHighlight,
  });

  final String firstName;
  final DateTime month;
  final double totalSpent;
  final String trendLabel;
  final String topCategory;
  final String personaTitle;
  final String personaType;
  final String currencySymbol;
  final String? groupHighlight;
  final String? goalHighlight;
}

/// Fixed 9:16 story export layout (360×640 logical → 1080×1920 at 3×).
class RecapShareCard extends StatelessWidget {
  const RecapShareCard({
    required this.data,
    super.key,
  });

  final RecapShareCardData data;

  static const storyWidth = RecapShareCardConfig.storyWidth;
  static const storyHeight = RecapShareCardConfig.storyHeight;

  @override
  Widget build(BuildContext context) {
    final monthName =
        DateFormat(AppDateFormats.monthName).format(data.month).toUpperCase();
    final firstDay = DateTime(data.month.year, data.month.month, 1);
    final lastDay = DateTime(data.month.year, data.month.month + 1, 0);
    final dateRange = AppStringFormat.recapDateRange(
      DateFormat(AppDateFormats.monthAbbrDay).format(firstDay).toUpperCase(),
      DateFormat(AppDateFormats.monthAbbrDay).format(lastDay).toUpperCase(),
      data.month.year,
    );
    final formattedTotal =
        NumberFormat(AppDateFormats.numberGrouped).format(data.totalSpent);

    final gradient = RecapPersonaTheme.shareGradient(data.personaType);

    return SizedBox(
      width: storyWidth,
      height: storyHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            groupGapLg,
            72,
            groupGapLg,
            48,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppBranding.brandLogo,
                style: TextStyle(
                  fontFamily: kFontAlbra,
                  fontSize: splitrFontHeadline3,
                  fontWeight: FontWeight.w800,
                  color: AppPalette.recapOnSurface,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: neopopAccentFillWhisper,
                  borderRadius: BorderRadius.circular(groupRadiusSm),
                  border: Border.all(color: AppPalette.recapBorder),
                ),
                child: Text(
                  AppStringFormat.recapNameTitle(data.firstName, monthName),
                  style: TextStyle(
                    fontFamily: kFontCourier,
                    fontWeight: FontWeight.bold,
                    fontSize: splitrFontMicro,
                    letterSpacing: 1.2,
                    color: AppPalette.recapOnSurface,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                dateRange,
                style: TextStyle(
                  fontFamily: kFontCourier,
                  fontSize: splitrFontMicro,
                  color: AppPalette.recapOnSurfaceMuted,
                ),
              ),
              const Spacer(),
              Text(
                data.personaTitle.toUpperCase(),
                style: TextStyle(
                  fontFamily: kFontAlbra,
                  fontSize: splitrFontRecapMd,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  color: AppPalette.mintAccent,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.recap.thisMonthISpent,
                style: TextStyle(
                  fontFamily: kFontAlbra,
                  fontSize: splitrFontTitle,
                  color: AppPalette.recapOnSurface,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    data.currencySymbol,
                    style: TextStyle(
                      fontFamily: kFontAlbra,
                      fontSize: splitrFontRecapLg,
                      color: AppPalette.recapOnSurfaceMuted,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formattedTotal,
                    style: TextStyle(
                      fontFamily: kFontAlbra,
                      fontSize: splitrFontSwipeHero,
                      fontWeight: FontWeight.bold,
                      color: AppPalette.recapOnSurface,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                data.trendLabel,
                style: TextStyle(
                  fontFamily: kFontCourier,
                  fontSize: splitrFontCaption,
                  color: AppPalette.recapOnSurfaceMuted,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStringFormat.categoryWithBrand(data.topCategory),
                style: TextStyle(
                  fontFamily: kFontCourier,
                  fontSize: splitrFontMicro,
                  color: AppPalette.recapOnSurfaceMuted,
                ),
              ),
              if (data.groupHighlight != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${AppStrings.recap.topGroupLabel}: ${data.groupHighlight}',
                  style: TextStyle(
                    fontFamily: kFontCourier,
                    fontSize: splitrFontMicro,
                    color: AppPalette.recapOnSurfaceMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (data.goalHighlight != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${AppStrings.recap.topGoal}: ${data.goalHighlight}',
                  style: TextStyle(
                    fontFamily: kFontCourier,
                    fontSize: splitrFontMicro,
                    color: AppPalette.recapOnSurfaceMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.recap.poweredBy,
                        style: TextStyle(
                          fontFamily: kFontCourier,
                          fontSize: splitrFontNanoSm,
                          letterSpacing: 1.5,
                          color: AppPalette.recapOnSurfaceMuted,
                        ),
                      ),
                      Text(
                        AppBranding.brandName,
                        style: TextStyle(
                          fontFamily: kFontAlbra,
                          fontSize: splitrFontHeadline3,
                          fontWeight: FontWeight.bold,
                          color: AppPalette.recapOnSurface,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    AppBranding.shareHashtag,
                    style: TextStyle(
                      fontFamily: kFontCourier,
                      fontSize: splitrFontMicro,
                      fontWeight: FontWeight.bold,
                      color: AppPalette.mintAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
