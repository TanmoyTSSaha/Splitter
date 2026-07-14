import 'package:flutter/material.dart';
import 'package:splitr/Utils/currency_utils.dart';
import 'package:intl/intl.dart';
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Services/shareable_card_service.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/app_dimensions.dart';

/// A premium glassmorphism card that displays a settlement confirmation.
/// Wrapped in [RepaintBoundary] so it can be captured as an image and shared.
class ShareableSettlementCard extends StatelessWidget {
  final String fromName;
  final String toName;
  final double amount;
  final String groupName;
  final DateTime settledDate;
  final GlobalKey repaintKey;

  const ShareableSettlementCard({
    required this.fromName,
    required this.toName,
    required this.amount,
    required this.groupName,
    required this.settledDate,
    required this.repaintKey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Capturable Card ──
        RepaintBoundary(
          key: repaintKey,
          child: Container(
            width: AppDimensions.groupShareCardWidth,
            padding: const EdgeInsets.all(AppDimensions.groupShareCardPadding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(groupCardRadiusXl),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppPalette.shareCardGradientStart,
                  AppPalette.shareCardGradientMid,
                  AppPalette.shareCardGradientEnd,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: neopopAccentFillMedium,
                  blurRadius: AppDimensions.groupShareShadowBlur,
                  spreadRadius: AppDimensions.groupShareShadowSpread,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Status Badge ──
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: groupGutter, vertical: groupGapSm),
                  decoration: BoxDecoration(
                    color: AppPalette.shareCardSettledGreenFill,
                    borderRadius: BorderRadius.circular(groupCardRadiusLg),
                    border: Border.all(
                      color: AppPalette.shareCardSettledGreenBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppPalette.shareCardSettledGreen,
                          size: groupCarouselIconSm),
                      const SizedBox(width: groupGapXs),
                      Text(
                        AppStrings.groups.settledBadge,
                        style: TextStyle(
                          color: AppPalette.shareCardSettledGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: splitrFontBodySm,
                          letterSpacing: AppDimensions.letterSpacingSection,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: groupGapLg),

                // ── Amount ──
                Text(
                  '${userCurrencySymbol()}${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: shareCardOnSurface,
                    fontSize: splitrFontRecapMd,
                    fontWeight: FontWeight.w800,
                    letterSpacing: AppDimensions.letterSpacingTight,
                  ),
                ),

                const SizedBox(height: groupGap20),

                // ── From → To ──
                Container(
                  padding: const EdgeInsets.all(groupGutter),
                  decoration: BoxDecoration(
                    color: shareCardFillSubtle,
                    borderRadius: BorderRadius.circular(groupCardRadius),
                    border: Border.all(
                      color: shareCardFillSoft,
                    ),
                  ),
                  child: Row(
                    children: [
                      // From
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: AppDimensions.groupShareAvatarSize,
                              height: AppDimensions.groupShareAvatarSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    neopopAccentScrim,
                                    neopopAccentBorderStrong,
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _initial(fromName),
                                  style: const TextStyle(
                                    color: shareCardOnSurface,
                                    fontWeight: FontWeight.w700,
                                    fontSize: splitrFontSubhead,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: groupGapSm),
                            Text(
                              fromName,
                              style: const TextStyle(
                                color: shareCardOnSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: splitrFontBodySm,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              AppStrings.lending.paid,
                              style: TextStyle(
                                color: shareCardIconMuted,
                                fontSize: splitrFontCaptionSm,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Arrow
                      Container(
                        padding: const EdgeInsets.all(groupGapSm),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: neopopAccentFillMedium,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: neopopAccent,
                          size: AppDimensions.groupIconMd,
                        ),
                      ),

                      // To
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: AppDimensions.groupShareAvatarSize,
                              height: AppDimensions.groupShareAvatarSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    neopopYellowScrim,
                                    neopopYellowBorderStrong,
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _initial(toName),
                                  style: const TextStyle(
                                    color: shareCardOnSurface,
                                    fontWeight: FontWeight.w700,
                                    fontSize: splitrFontSubhead,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: groupGapSm),
                            Text(
                              toName,
                              style: const TextStyle(
                                color: shareCardOnSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: splitrFontBodySm,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              AppStrings.groups.received,
                              style: TextStyle(
                                color: shareCardIconMuted,
                                fontSize: splitrFontCaptionSm,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: groupGutter),

                // ── Meta row ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      groupName,
                      style: TextStyle(
                        color: shareCardTextMuted,
                        fontSize: splitrFontCaption,
                      ),
                    ),
                    Text(
                      DateFormat(AppDateFormats.shortDayYear)
                          .format(settledDate),
                      style: TextStyle(
                        color: shareCardTextMuted,
                        fontSize: splitrFontCaption,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: groupGap20),

                // ── Branding ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome_rounded,
                        color: neopopAccentIconDim, size: groupIconSm),
                    const SizedBox(width: groupGapXxs),
                    Text(
                      AppBranding.brandLogo,
                      style: TextStyle(
                        color: neopopAccentIconDim,
                        fontWeight: FontWeight.w700,
                        fontSize: splitrFontBodySm,
                        letterSpacing: AppDimensions.letterSpacingWide,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: groupGap20),

        // ── Share Button (outside boundary) ──
        SizedBox(
          width: AppDimensions.groupShareButtonWidth,
          child: ElevatedButton.icon(
            onPressed: () => ShareableCardService.captureAndShare(
              repaintKey,
              filename: '${AppBranding.exportFilePrefix}_settlement',
              shareText: AppStringFormat.settlementShareText(
                fromName,
                userCurrencySymbol(),
                amount.toStringAsFixed(0),
                toName,
                AppBranding.brandName,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: neopopAccent,
              foregroundColor: neopopBackground,
              padding: const EdgeInsets.symmetric(vertical: groupGap14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(groupCardRadius),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.share_rounded, size: groupCarouselIconSm),
            label: Text(
              AppStrings.actions.share,
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: splitrFontBodyMd),
            ),
          ),
        ),
      ],
    );
  }

  String _initial(String name) {
    if (name.isEmpty) return DisplayFallbacks.questionMark;
    return name[0].toUpperCase();
  }
}
