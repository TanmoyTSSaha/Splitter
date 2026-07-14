import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Utils/currency_utils.dart';
import 'package:splitr/Widgets/tab_empty_state.dart';

/// Horizontal bar chart showing each member's actual contribution (paid)
/// vs their fair share.
class ContributionAnalysisChart extends StatelessWidget {
  final Map<String, Map<String, double>> memberContributions;

  const ContributionAnalysisChart({
    required this.memberContributions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (memberContributions.isEmpty) {
      return TabEmptyState(
        variant: TabEmptyVariant.analytics,
        title: AppStrings.analytics.noTransactionData,
        compact: true,
      );
    }

    final entries = memberContributions.entries.toList();
    final maxVal = entries.fold<double>(0.0, (prev, e) {
      final paid = e.value[AnalyticsKeys.paid] ?? 0.0;
      final share = e.value[AnalyticsKeys.share] ?? 0.0;
      return [prev, paid, share].reduce((a, b) => a > b ? a : b);
    });

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _legendDot(neopopAccent, AppStrings.groups.paid),
              const SizedBox(width: groupGapMd),
              _legendDot(neopopAccentBorder, AppStrings.analytics.yourShare),
            ],
          ),
          const SizedBox(height: groupGapMd),
          SizedBox(
            height: entries.length * AppDimensions.chartContributionRowHeight +
                AppDimensions.chartContributionPadding,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal * ChartScaleFactors.maxY115,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => neopopOnPrimary,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final label = rodIndex == 0
                          ? AppStrings.groups.paid
                          : AppStrings.analytics.yourShare;
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
                  leftTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: AppDimensions.chartAxisReservedSizeBottom,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < entries.length) {
                          final name = AppStringFormat.truncateChartLabel(
                            entries[idx].key,
                            ChartTruncateLengths.name10,
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
                gridData: const FlGridData(show: false),
                barGroups: entries.asMap().entries.map((entry) {
                  final i = entry.key;
                  final data = entry.value.value;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[AnalyticsKeys.paid] ?? 0.0,
                        color: neopopAccent,
                        width: AppDimensions.chartBarWidthMd,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(
                            AppDimensions.chartBarRadiusMd,
                          ),
                          topRight: Radius.circular(
                            AppDimensions.chartBarRadiusMd,
                          ),
                        ),
                      ),
                      BarChartRodData(
                        toY: data[AnalyticsKeys.share] ?? 0.0,
                        color: neopopAccentBorder,
                        width: AppDimensions.chartBarWidthMd,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(
                            AppDimensions.chartBarRadiusMd,
                          ),
                          topRight: Radius.circular(
                            AppDimensions.chartBarRadiusMd,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: groupGapMd),
          ...entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: groupGapSm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.key,
                      style: body2_text.copyWith(color: groupOnSurface),
                    ),
                    RichText(
                      text: TextSpan(
                        style: caption_text,
                        children: [
                          TextSpan(
                            text: AppStringFormat.paidAmount(
                              userCurrencySymbol(),
                              (e.value[AnalyticsKeys.paid] ?? 0)
                                  .toStringAsFixed(0),
                            ),
                            style: caption_text.copyWith(
                              color: neopopAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(text: AppSeparators.bullet),
                          TextSpan(
                            text: AppStringFormat.shareAmount(
                              userCurrencySymbol(),
                              (e.value[AnalyticsKeys.share] ?? 0)
                                  .toStringAsFixed(0),
                            ),
                            style: caption_text.copyWith(
                                color: groupOnSurfaceMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
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
