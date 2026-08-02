import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Utils/recap_persona_theme.dart';

/// Share Pack card kinds — praise-only, no default spend totals (v2 F11).
enum RecapSharePackKind {
  persona,
  settlementsClosed,
  spendPersonality,
  goalMomentum,
}

class RecapSharePackCardData {
  const RecapSharePackCardData({
    required this.kind,
    required this.month,
    required this.firstName,
    required this.personaTitle,
    required this.personaType,
    this.badgeName,
    this.settlementsClosed = 0,
    this.topSpendCategory = DisplayFallbacks.none,
    this.habitLabel = '',
    this.goalName,
    this.goalProgressPercent,
    this.goalHit = false,
  });

  final RecapSharePackKind kind;
  final DateTime month;
  final String firstName;
  final String personaTitle;
  final String personaType;
  final String? badgeName;
  final int settlementsClosed;
  final String topSpendCategory;
  final String habitLabel;
  final String? goalName;
  final double? goalProgressPercent;
  final bool goalHit;
}

/// Fixed 9:16 export layout for Share Pack cards.
class RecapSharePackCard extends StatelessWidget {
  const RecapSharePackCard({
    required this.data,
    super.key,
  });

  final RecapSharePackCardData data;

  static const storyWidth = RecapShareCardConfig.storyWidth;
  static const storyHeight = RecapShareCardConfig.storyHeight;

  @override
  Widget build(BuildContext context) {
    final monthName =
        DateFormat(AppDateFormats.monthName).format(data.month).toUpperCase();
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
              Text(
                AppStringFormat.recapNameTitle(data.firstName, monthName),
                style: TextStyle(
                  fontFamily: kFontCourier,
                  fontWeight: FontWeight.bold,
                  fontSize: splitrFontMicro,
                  letterSpacing: 1.2,
                  color: AppPalette.recapOnSurfaceMuted,
                ),
              ),
              const Spacer(),
              ..._hero(),
              const SizedBox(height: 16),
              Text(
                AppStrings.recap.sharePackOnSplitr,
                style: TextStyle(
                  fontFamily: kFontCourier,
                  fontSize: splitrFontMicro,
                  color: AppPalette.recapOnSurfaceMuted,
                ),
              ),
              const Spacer(),
              Text(
                AppStrings.recap.securedBySplitr,
                style: TextStyle(
                  fontFamily: kFontCourier,
                  fontSize: splitrFontNanoSm,
                  letterSpacing: 1.5,
                  color: AppPalette.recapOnSurfaceMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _hero() {
    switch (data.kind) {
      case RecapSharePackKind.persona:
        return [
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
          if (data.badgeName != null) ...[
            const SizedBox(height: 12),
            Text(
              data.badgeName!,
              style: TextStyle(
                fontFamily: kFontAlbra,
                fontSize: splitrFontTitle,
                color: AppPalette.recapOnSurface,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            AppStrings.recap.sharePackPersonaPraise,
            style: TextStyle(
              fontFamily: kFontCourier,
              fontSize: splitrFontCaption,
              color: AppPalette.recapOnSurfaceMuted,
            ),
          ),
        ];
      case RecapSharePackKind.settlementsClosed:
        return [
          Text(
            AppStringFormat.settlementsClosedShare(data.settlementsClosed),
            style: TextStyle(
              fontFamily: kFontAlbra,
              fontSize: splitrFontRecapMd,
              fontWeight: FontWeight.w800,
              color: AppPalette.recapOnSurface,
              height: 1.15,
            ),
          ),
        ];
      case RecapSharePackKind.spendPersonality:
        return [
          Text(
            data.topSpendCategory.toUpperCase(),
            style: TextStyle(
              fontFamily: kFontAlbra,
              fontSize: splitrFontRecapMd,
              fontWeight: FontWeight.w800,
              color: AppPalette.mintAccent,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data.habitLabel,
            style: TextStyle(
              fontFamily: kFontAlbra,
              fontSize: splitrFontTitle,
              color: AppPalette.recapOnSurface,
            ),
          ),
        ];
      case RecapSharePackKind.goalMomentum:
        final label = data.goalHit
            ? AppStrings.recap.sharePackGoalHit
            : AppStringFormat.goalProgressPercent(
                data.goalProgressPercent ?? 0,
              );
        return [
          Text(
            label,
            style: TextStyle(
              fontFamily: kFontAlbra,
              fontSize: splitrFontRecapMd,
              fontWeight: FontWeight.w800,
              color: AppPalette.recapOnSurface,
            ),
          ),
          if (data.goalName != null) ...[
            const SizedBox(height: 12),
            Text(
              data.goalName!,
              style: TextStyle(
                fontFamily: kFontCourier,
                fontSize: splitrFontCaption,
                color: AppPalette.recapOnSurfaceMuted,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ];
    }
  }
}
