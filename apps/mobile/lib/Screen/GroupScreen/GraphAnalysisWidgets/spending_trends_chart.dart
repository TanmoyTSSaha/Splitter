import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Utils/currency_utils.dart';

/// Smooth line chart with gradient fill showing monthly group spending trends.
class SpendingTrendsChart extends StatelessWidget {
  final Map<String, double> monthlyTrends;

  const SpendingTrendsChart({
    required this.monthlyTrends,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (monthlyTrends.isEmpty) {
      return Center(
        child: Text(
          AppStrings.analytics.notEnoughTrendData,
          style: body2_text.copyWith(color: groupOnSurfaceMuted),
        ),
      );
    }

    final entries = monthlyTrends.entries.toList();
    final maxVal =
        entries.fold<double>(0.0, (prev, e) => e.value > prev ? e.value : prev);
    final axisInterval = maxVal > 0
        ? maxVal / ChartScaleFactors.axisDivisorQuarters
        : ChartScaleFactors.axisIntervalUnit.toDouble();

    final spots = entries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.analytics.monthlySpendingOverview,
            style: body1_text.copyWith(
              fontWeight: FontWeight.w600,
              color: groupOnSurface,
            ),
          ),
          const SizedBox(height: groupGapMd),
          SizedBox(
            height: devSysWidth * AppDimensions.chartLineHeightFactor,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: axisInterval,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: groupMutedFillMedium,
                    strokeWidth: AppDimensions.borderWidthHairline,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: AppDimensions.chartAxisReservedSizeLeft,
                      interval: axisInterval,
                      getTitlesWidget: (value, meta) {
                        final symbol = userCurrencySymbol();
                        final text = value >=
                                ChartScaleFactors.axisCompactThousands
                            ? '$symbol${(value / ChartScaleFactors.axisCompactThousands).toStringAsFixed(1)}${AppAmountSuffix.thousand}'
                            : '$symbol${value.toStringAsFixed(0)}';
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            text,
                            style: const TextStyle(
                              fontSize: groupFontMicro,
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
                      reservedSize: AppDimensions.chartAxisReservedSizeBottomXs,
                      interval: ChartScaleFactors.axisIntervalUnit.toDouble(),
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < entries.length) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              entries[idx].key.split(' ').first,
                              style: const TextStyle(
                                fontSize: groupFontMicro,
                                color: groupOnSurfaceMuted,
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
                minX: 0,
                maxX: (entries.length - 1).toDouble(),
                minY: 0,
                maxY: maxVal * ChartScaleFactors.maxY115,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => neopopOnPrimary,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final idx = spot.x.toInt();
                        final month =
                            idx < entries.length ? entries[idx].key : '';
                        return LineTooltipItem(
                          "$month\n${userCurrencySymbol()}${spot.y.toStringAsFixed(0)}",
                          body2_text.copyWith(color: neopopBackground),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: ChartScaleFactors.curveSmoothness,
                    color: neopopAccent,
                    barWidth: AppDimensions.chartLineWidth,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: AppDimensions.chartDotRadius,
                        color: neopopAccent,
                        strokeWidth: groupProgressStrokeWidth,
                        strokeColor: neopopBackground,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          neopopAccentBorderSoft,
                          neopopAccentFillWhisper,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: groupGapLg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.trips.totalSpent,
                    style: caption_text.copyWith(color: groupOnSurfaceMuted),
                  ),
                  Text(
                    "${userCurrencySymbol()}${entries.fold<double>(0.0, (sum, e) => sum + e.value).toStringAsFixed(0)}",
                    style: sub_headline4_text.copyWith(color: neopopAccent),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppStrings.analytics.avgPerMonth,
                    style: caption_text.copyWith(color: groupOnSurfaceMuted),
                  ),
                  Text(
                    "${userCurrencySymbol()}${(entries.fold<double>(0.0, (sum, e) => sum + e.value) / entries.length).toStringAsFixed(0)}",
                    style: sub_headline4_text.copyWith(color: groupOnSurface),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
