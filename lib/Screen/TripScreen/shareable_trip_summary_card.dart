import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Model/trip_model.dart';
import 'package:splitr/Services/currency_service.dart';
import 'package:splitr/Services/shareable_card_service.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_strings.dart';

/// A premium shareable trip summary card with dark gradient and stats.
/// Wrapped in [RepaintBoundary] for image capture and sharing.
class ShareableTripSummaryCard extends StatelessWidget {
  final TripModel trip;
  final TripSummaryStats summary;
  final GlobalKey repaintKey;

  const ShareableTripSummaryCard({
    required this.trip,
    required this.summary,
    required this.repaintKey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat(AppDateFormats.shortDay);
    final sym = CurrencyService.symbolFor(trip.tripCurrency);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Capturable Card ──
        RepaintBoundary(
          key: repaintKey,
          child: Container(
            width: 340,
            padding: const EdgeInsets.all(groupGapLg),
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
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(groupGap10),
                      decoration: BoxDecoration(
                        color: neopopAccentFillMedium,
                        borderRadius: BorderRadius.circular(groupControlRadius),
                      ),
                      child: const Icon(
                        Icons.flight_takeoff_rounded,
                        color: neopopAccent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.tripName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: splitrFontSubhead,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (trip.destination != null)
                            Text(
                              '${AppStrings.trips.locationPinPrefix}${trip.destination}',
                              style: TextStyle(
                                color: shareCardTextMuted,
                                fontSize: splitrFontCaption,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // ── Date Range ──
                Container(
                  margin: const EdgeInsets.only(top: groupGapXxs),
                  padding: const EdgeInsets.symmetric(
                      horizontal: groupGap10, vertical: groupGapXxs),
                  decoration: BoxDecoration(
                    color: shareCardFillSubtle,
                    borderRadius: BorderRadius.circular(groupControlRadiusSm),
                  ),
                  child: Text(
                    AppStringFormat.tripShareCardDateRange(
                      dateFormat.format(trip.startDate),
                      dateFormat.format(trip.endDate),
                      trip.endDate.year,
                      trip.totalDays,
                    ),
                    style: TextStyle(
                      color: shareCardBorderStrong,
                      fontSize: splitrFontCaptionSm,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Total Spent Hero ──
                Center(
                  child: Column(
                    children: [
                      Text(
                        AppStrings.trips.totalSpent,
                        style: TextStyle(
                          color: shareCardBorderStrong,
                          fontSize: splitrFontCaption,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${sym}${summary.totalSpent.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: splitrFontDisplayLg,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Stats Grid ──
                Container(
                  padding: const EdgeInsets.all(groupGap14),
                  decoration: BoxDecoration(
                    color: shareCardFillWhisper,
                    borderRadius: BorderRadius.circular(groupCardRadius),
                    border: Border.all(
                      color: shareCardFillFaint,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _statTile(
                              '📊',
                              AppStrings.trips.perDay,
                              '${sym}${summary.avgPerDay.toStringAsFixed(0)}',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 36,
                            color: shareCardFillSoft,
                          ),
                          Expanded(
                            child: _statTile(
                              '🧾',
                              AppStrings.trips.transactions,
                              '${summary.totalTransactions}',
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        color: shareCardFillFaint,
                        height: 20,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _statTile(
                              '🏆',
                              AppStrings.trips.mvp,
                              summary.mvpMemberName,
                              subtitle:
                                  '${sym}${summary.mvpAmount.toStringAsFixed(0)}',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 36,
                            color: shareCardFillSoft,
                          ),
                          Expanded(
                            child: _statTile(
                              '📂',
                              AppStrings.trips.topCategory,
                              summary.topCategory,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Biggest Expense ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: groupGap14, vertical: groupGap10),
                  decoration: BoxDecoration(
                    color: neopopYellowFillSoft,
                    borderRadius: BorderRadius.circular(groupControlRadius),
                    border: Border.all(
                      color: neopopYellowFillMedium,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('💰',
                          style: TextStyle(fontSize: splitrFontSubhead)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.trips.biggestExpense,
                              style: TextStyle(
                                color: shareCardBorderStrong,
                                fontSize: splitrFontMicro,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              summary.biggestExpenseDesc,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: splitrFontBodySm,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${sym}${summary.biggestExpenseAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: neopopYellow,
                          fontWeight: FontWeight.w700,
                          fontSize: splitrFontBodyMd,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ── Branding ──
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          color: neopopAccentIconMuted, size: 14),
                      const SizedBox(width: groupGapXxs),
                      Text(
                        AppBranding.brandLogo,
                        style: TextStyle(
                          color: neopopAccentIconMuted,
                          fontWeight: FontWeight.w700,
                          fontSize: splitrFontBodySm,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── Share Button (outside boundary) ──
        SizedBox(
          width: 200,
          child: ElevatedButton.icon(
            onPressed: () => ShareableCardService.captureAndShare(
              repaintKey,
              filename:
                  '${AppBranding.exportFilePrefix}_trip_${trip.tripName.replaceAll(' ', '_').toLowerCase()}',
              shareText: AppStringFormat.tripShareMessage(
                tripName: trip.tripName,
                symbol: sym,
                spentAmount: summary.totalSpent.toStringAsFixed(0),
                totalDays: trip.totalDays,
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
            icon: const Icon(Icons.share_rounded, size: 18),
            label: Text(
              AppStrings.trips.shareTrip,
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: splitrFontBodyMd),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statTile(String emoji, String label, String value,
      {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: groupGapSm),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: splitrFontBodyLg)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: shareCardBorderStrong,
              fontSize: splitrFontMicro,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: splitrFontBodySm,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(
                color: shareCardBorderSoft,
                fontSize: splitrFontMicro,
              ),
            ),
        ],
      ),
    );
  }
}
