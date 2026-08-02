import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/theme_accent_colors.dart';
import 'package:splitr/Constants/staggered_list_animation.dart';
import 'package:splitr/Model/trip_model.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Screen/TripScreen/shareable_trip_summary_card.dart';
import 'package:splitr/Services/currency_service.dart';
import 'package:splitr/Services/trip_service.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

/// Trip Timeline Tab — chronological expense feed with day selector.
class TripTimelineTab extends StatefulWidget {
  final TripModel trip;

  const TripTimelineTab({
    required this.trip,
    super.key,
  });

  @override
  State<TripTimelineTab> createState() => _TripTimelineTabState();
}

class _TripTimelineTabState extends State<TripTimelineTab> {
  final TripService _tripService = TripService();
  List<TripDaySummary> _days = [];
  TripSummaryStats _summary = TripSummaryStats(
    totalSpent: 0,
    avgPerDay: 0,
    totalTransactions: 0,
    mvpMemberName: DisplayFallbacks.na,
    mvpAmount: 0,
    biggestExpenseDesc: DisplayFallbacks.na,
    biggestExpenseAmount: 0,
    topCategory: DisplayFallbacks.na,
  );
  int _selectedDay = 0;
  bool _isLoading = true;
  String? _loadError;
  final GlobalKey _shareCardKey = GlobalKey();

  String get _tripSym => CurrencyService.symbolFor(widget.trip.tripCurrency);

  @override
  void initState() {
    super.initState();
    _fetchTripData();
  }

  Future<void> _fetchTripData() async {
    try {
      setState(() {
        _loadError = null;
        if (!_isLoading) _isLoading = true;
      });
      // 1. Fetch transactions
      final transactions =
          await _tripService.getTripTransactions(widget.trip.groupId);

      // 2. Fetch members for name mapping
      final members = await _tripService.getTripMembers(widget.trip.groupId);
      final userNameMap = {
        for (var m in members)
          m[SupabaseColumns.id] as String: m['name'] as String
      };

      // 3. Process data
      if (mounted) {
        setState(() {
          _days = _tripService.bucketByDay(
            trip: widget.trip,
            transactions: transactions,
            userNameMap: userNameMap,
          );
          _summary = _tripService.computeSummary(
            trip: widget.trip,
            transactions: transactions,
            userNameMap: userNameMap,
          );
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      AppErrorReporter.report(
        AppStrings.errors.loadTripTimeline,
        error: e,
        stack: stack,
      );
      if (mounted) {
        setState(() {
          _loadError = AppStrings.errors.loadTripTimeline;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: neopopAccent));
    }
    if (_loadError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _loadError!,
              style: body2_text.copyWith(color: groupOnSurfaceMuted),
            ),
            const SizedBox(height: groupGapMd),
            TextButton(
              onPressed: _fetchTripData,
              child: Text(
                AppStrings.actions.tryAgain,
                style: body2_text.copyWith(color: neopopAccent),
              ),
            ),
          ],
        ),
      );
    }
    return CustomScrollView(
      slivers: [
        // ─── Day Selector ───
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: height_16),
            child: SizedBox(
              height: 72,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: height_16),
                itemCount: _days.length,
                itemBuilder: (context, index) {
                  final day = _days[index];
                  final isSelected = index == _selectedDay;
                  final dateFormat = DateFormat(AppDateFormats.weekdayShort);

                  return GestureDetector(
                    onTap: () => setState(() => _selectedDay = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.only(right: groupGapSm),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? neopopAccent : groupSurfaceFillSubtle,
                        borderRadius: BorderRadius.circular(groupCardRadius),
                        border: Border.all(
                          color: isSelected ? neopopAccent : groupMutedFillSoft,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dateFormat.format(day.date),
                            style: caption_text.copyWith(
                              color: isSelected
                                  ? neopopBackground
                                  : groupOnSurfaceMuted,
                              fontSize: splitrFontCaptionSm,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${day.date.day}',
                            style: body1_text.copyWith(
                              color: isSelected
                                  ? neopopBackground
                                  : groupOnSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          if (day.transactionCount > 0)
                            Container(
                              margin: const EdgeInsets.only(top: groupGap2),
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? neopopBackground
                                    : neopopYellow,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // ─── Day Header ───
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(height_16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStringFormat.tripDayNumber(_days[_selectedDay].dayNumber),
                  style: sub_headline5_text.copyWith(color: groupOnSurface),
                ),
                if (_days[_selectedDay].totalSpent > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: groupCarouselGap, vertical: groupGapXxs),
                    decoration: BoxDecoration(
                      color: neopopAccentFillSoft,
                      borderRadius: BorderRadius.circular(groupCardRadiusLg),
                    ),
                    child: Text(
                      '${_tripSym}${_days[_selectedDay].totalSpent.toStringAsFixed(0)}',
                      style: body2_text.copyWith(
                          color: neopopAccent, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // ─── Timeline Feed ───
        if (_days[_selectedDay].expenses.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: height_16 * 4),
              child: Column(
                children: [
                  Icon(Icons.beach_access_rounded,
                      color: groupMutedIconMuted, size: 48),
                  SizedBox(height: height_10),
                  Text(AppStrings.trips.noExpensesDay,
                      style: body1_text.copyWith(color: groupOnSurfaceMuted)),
                ],
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final expense = _days[_selectedDay].expenses[index];
                return StaggeredListItem(
                  index: index,
                  child: _buildTimelineCard(expense, index),
                );
              },
              childCount: _days[_selectedDay].expenses.length,
            ),
          ),

        // ─── Trip Summary Card ───
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(height_16),
            child: _buildSummaryCard(),
          ),
        ),

        if (widget.trip.isPast && _summary.totalTransactions > 0)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: height_16),
              child: Column(
                children: [
                  Text(
                    AppStrings.trips.tripCompleteShare,
                    style: body2_text.copyWith(color: neopopGrey),
                  ),
                  SizedBox(height: height_10),
                  ShareableTripSummaryCard(
                    trip: widget.trip,
                    summary: _summary,
                    repaintKey: _shareCardKey,
                  ),
                ],
              ),
            ),
          ),

        SliverToBoxAdapter(child: SizedBox(height: height_16 * 4)),
      ],
    );
  }

  Widget _buildTimelineCard(TripExpenseEntry expense, int index) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: height_16, vertical: groupGapXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: groupProgressIndicatorSize,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: neopopAccent,
                    boxShadow: [
                      BoxShadow(
                        color: neopopAccentBorderStrong,
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 2,
                  height: 60,
                  color: groupMutedFillSoft,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Expense card
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(groupCardRadius),
                border: Border.all(
                  color: neopopGrey.withValues(alpha: 0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: groupSurfaceFillFaint,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(height_10 * 1.2),
                child: Row(
                  children: [
                    // Category icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: neopopAccentFillSoft,
                        borderRadius: BorderRadius.circular(groupRadiusMd),
                      ),
                      child: Icon(
                        _categoryIcon(expense.category),
                        color: neopopAccent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.description,
                            style: body1_text.copyWith(
                              color: groupOnSurface,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${expense.paidByName} • ${DateFormat(AppDateFormats.time12h).format(expense.timestamp.toLocal())}',
                            style: caption_text.copyWith(
                              color: groupOnSurfaceMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${_tripSym}${expense.amount.toStringAsFixed(0)}',
                      style: body1_text.copyWith(
                          color: ThemeAccentColors.amount(context),
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(groupCardRadius),
        border: Border.all(
          color: neopopGrey.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: groupSurfaceFillFaint,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(height_16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics_rounded,
                    color: neopopAccent, size: 20),
                SizedBox(width: height_10 / 2),
                Text(AppStrings.trips.tripSummary,
                    style: body1_text.copyWith(
                        color: neopopAccent, fontWeight: FontWeight.w600)),
              ],
            ),
            SizedBox(height: height_16),
            _summaryRow(AppStrings.trips.totalSpent,
                '${_tripSym}${_summary.totalSpent.toStringAsFixed(0)}'),
            _summaryRow(AppStrings.trips.perDayAvg,
                '${_tripSym}${_summary.avgPerDay.toStringAsFixed(0)}'),
            _summaryRow(
                AppStrings.trips.transactions, '${_summary.totalTransactions}'),
            Divider(color: neopopGreyBorderSoft, height: 24),
            _summaryRow(AppStrings.trips.mvpLabel, _summary.mvpMemberName,
                subtitle: AppStringFormat.paidAmount(
                  _tripSym,
                  _summary.mvpAmount.toStringAsFixed(0),
                )),
            _summaryRow(
                AppStrings.trips.biggestLabel, _summary.biggestExpenseDesc,
                subtitle:
                    '${_tripSym}${_summary.biggestExpenseAmount.toStringAsFixed(0)}'),
            _summaryRow(
                AppStrings.trips.topCategoryLabel, _summary.topCategory),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: groupGapXxs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: caption_text.copyWith(color: groupOnSurfaceMuted)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: body2_text.copyWith(
                      color: groupOnSurface, fontWeight: FontWeight.w600)),
              if (subtitle != null)
                Text(subtitle,
                    style: caption_text.copyWith(
                        color: groupOnSurfaceMuted, fontSize: splitrFontMicro)),
            ],
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case CategorySlugValues.food:
        return Icons.restaurant_rounded;
      case CategorySlugValues.transport:
      case CategorySlugValues.transportation:
        return Icons.directions_car_rounded;
      case CategorySlugValues.stay:
      case CategorySlugValues.accommodation:
        return Icons.hotel_rounded;
      case CategorySlugValues.shopping:
        return Icons.shopping_bag_rounded;
      case CategorySlugValues.entertainment:
        return Icons.movie_rounded;
      case CategorySlugValues.drinks:
        return Icons.local_bar_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }
}
