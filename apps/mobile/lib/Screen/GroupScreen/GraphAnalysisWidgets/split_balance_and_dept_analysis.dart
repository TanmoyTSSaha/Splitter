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

/// Bar chart showing per-member net balance from group_balance.
class SplitBalanceAndDeptAnalysis extends StatefulWidget {
  final List<Map<String, dynamic>> memberBalances;

  const SplitBalanceAndDeptAnalysis({
    required this.memberBalances,
    super.key,
  });

  @override
  State<SplitBalanceAndDeptAnalysis> createState() =>
      _SplitBalanceAndDeptAnalysisState();
}

class _SplitBalanceAndDeptAnalysisState
    extends State<SplitBalanceAndDeptAnalysis> {
  @override
  Widget build(BuildContext context) {
    if (widget.memberBalances.isEmpty) {
      return TabEmptyState(
        variant: TabEmptyVariant.analytics,
        title: AppStrings.analytics.noBalanceData,
        compact: true,
      );
    }

    final data = widget.memberBalances;
    final maxVal = data.fold<double>(0.0, (prev, e) {
      final net = (e[AnalyticsKeys.netBalance] as num?)?.toDouble() ?? 0.0;
      return net.abs() > prev ? net.abs() : prev;
    });

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.analytics.splitBalancesAndDebt,
            style: body1_text.copyWith(
              fontWeight: FontWeight.w600,
              color: groupOnSurface,
            ),
          ),
          const SizedBox(height: groupGapSm),
          Text(
            AppStrings.analytics.netBalanceSubtitle,
            style: caption_text.copyWith(color: groupOnSurfaceMuted),
          ),
          const SizedBox(height: groupGapSm),
          Row(
            children: [
              _legendDot(neopopIsOwed, AppStrings.analytics.isOwed),
              const SizedBox(width: groupGapMd),
              _legendDot(neopopError, AppStrings.analytics.owes),
            ],
          ),
          const SizedBox(height: groupGapMd),
          AspectRatio(
            aspectRatio: AppDimensions.chartAspectRatio,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal > 0
                    ? maxVal * ChartScaleFactors.maxY120
                    : ChartScaleFactors.axisIntervalUnit.toDouble(),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < data.length) {
                          final name = AppStringFormat.truncateChartLabel(
                            data[idx][AnalyticsKeys.name]?.toString() ?? '',
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
                      reservedSize: AppDimensions.chartReservedSize,
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => neopopOnPrimary,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final net =
                          (data[groupIndex][AnalyticsKeys.netBalance] as num?)
                                  ?.toDouble() ??
                              0.0;
                      final label = net >= 0
                          ? AppStrings.analytics.isOwed
                          : AppStrings.analytics.owes;
                      return BarTooltipItem(
                        AppStringFormat.chartTooltip(
                          label,
                          userCurrencySymbol(),
                          net.abs().toStringAsFixed(0),
                        ),
                        body2_text.copyWith(color: neopopBackground),
                      );
                    },
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: data.asMap().entries.map((entry) {
                  final i = entry.key;
                  final member = entry.value;
                  final net =
                      (member[AnalyticsKeys.netBalance] as num?)?.toDouble() ??
                          0.0;
                  final isOwed = net >= 0;

                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: net.abs(),
                        color: isOwed ? neopopIsOwed : neopopError,
                        width: AppDimensions.chartBarWidthLg,
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
          const SizedBox(height: groupGapMd),
          ...data.map((member) {
            final net =
                (member[AnalyticsKeys.netBalance] as num?)?.toDouble() ?? 0.0;
            final isOwed = net >= 0;
            final symbol = userCurrencySymbol();
            final amount = net.abs().toStringAsFixed(0);

            return Padding(
              padding: const EdgeInsets.only(bottom: groupGapSm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      member[AnalyticsKeys.name]?.toString() ?? '',
                      style: body2_text.copyWith(color: groupOnSurface),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    isOwed
                        ? AppStringFormat.isOwedAmount(symbol, amount)
                        : AppStringFormat.owesAmount(symbol, amount),
                    style: caption_text.copyWith(
                      color: isOwed ? neopopIsOwed : neopopError,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
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
