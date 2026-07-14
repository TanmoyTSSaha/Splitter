import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Utils/currency_utils.dart';
import 'package:splitr/Widgets/tab_empty_state.dart';

/// Grouped bar chart comparing user's spending vs group average per category.
class ExpenseComparisonChart extends StatelessWidget {
  final Map<String, Map<String, double>> categoryComparison;

  const ExpenseComparisonChart({
    required this.categoryComparison,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryComparison.isEmpty) {
      return TabEmptyState(
        variant: TabEmptyVariant.analytics,
        title: AppStrings.analytics.noComparisonData,
        compact: true,
      );
    }

    final entries = categoryComparison.entries.toList();
    final maxVal = entries.fold<double>(0.0, (prev, e) {
      final user = e.value[AnalyticsKeys.userAmount] ?? 0.0;
      final avg = e.value[AnalyticsKeys.groupAvgAmount] ?? 0.0;
      return [prev, user, avg].reduce((a, b) => a > b ? a : b);
    });
    final axisInterval = maxVal > 0
        ? maxVal / ChartScaleFactors.axisDivisorThirds
        : ChartScaleFactors.axisIntervalUnit.toDouble();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.analytics.spendingVsGroupAverage,
            style: body1_text.copyWith(
              fontWeight: FontWeight.w600,
              color: groupOnSurface,
            ),
          ),
          const SizedBox(height: groupGapSm),
          Text(
            AppStrings.analytics.spendingVsGroupAverageSubtitle,
            style: caption_text.copyWith(color: groupOnSurfaceMuted),
          ),
          const SizedBox(height: groupGapSm),
          Row(
            children: [
              _legendDot(neopopAccent, AppStrings.analytics.youPaid),
              const SizedBox(width: groupGapMd),
              _legendDot(neopopYellow, AppStrings.analytics.groupAvgPaid),
            ],
          ),
          const SizedBox(height: groupGapMd),
          SizedBox(
            height: entries.length * AppDimensions.chartComparisonRowHeight +
                AppDimensions.chartComparisonPadding,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal * ChartScaleFactors.maxY120,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => neopopOnPrimary,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final label = rodIndex == 0
                          ? AppStrings.analytics.youPaid
                          : AppStrings.analytics.groupAvgPaid;
                      return BarTooltipItem(
                        AppStringFormat.chartTooltip(
                          label,
                          userCurrencySymbol(),
                          rod.toY.toStringAsFixed(0),
                        ),
                        body2_text.copyWith(color: neopopBackground),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: AppDimensions.chartAxisReservedSizeBottom,
                      interval: axisInterval,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            "${userCurrencySymbol()}${value.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: splitrFontNanoSm,
                              color: groupOnSurfaceMuted,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: AppDimensions.chartAxisReservedSizeBottomSm,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < entries.length) {
                          final name = AppStringFormat.truncateChartLabel(
                            entries[idx].key,
                            ChartTruncateLengths.name8,
                          );
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: groupFontMicro,
                                color: groupOnSurface,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: axisInterval,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: groupMutedFillSoft,
                    strokeWidth: AppDimensions.borderWidthHairline,
                  ),
                ),
                barGroups: entries.asMap().entries.map((entry) {
                  final i = entry.key;
                  final data = entry.value.value;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[AnalyticsKeys.userAmount] ?? 0.0,
                        color: neopopAccent,
                        width: AppDimensions.chartBarWidthSm,
                        borderRadius: const BorderRadius.only(
                          topLeft:
                              Radius.circular(AppDimensions.chartBarRadius),
                          topRight:
                              Radius.circular(AppDimensions.chartBarRadius),
                        ),
                      ),
                      BarChartRodData(
                        toY: data[AnalyticsKeys.groupAvgAmount] ?? 0.0,
                        color: neopopYellow,
                        width: AppDimensions.chartBarWidthSm,
                        borderRadius: const BorderRadius.only(
                          topLeft:
                              Radius.circular(AppDimensions.chartBarRadius),
                          topRight:
                              Radius.circular(AppDimensions.chartBarRadius),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppDimensions.chartLegendDot,
          height: AppDimensions.chartLegendDot,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(groupRadiusXs),
          ),
        ),
        const SizedBox(width: groupGapSm),
        Text(label, style: caption_text.copyWith(color: groupOnSurface)),
      ],
    );
  }
}
