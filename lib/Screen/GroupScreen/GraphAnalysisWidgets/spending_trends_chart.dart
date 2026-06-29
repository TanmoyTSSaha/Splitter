import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';

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
          "Not enough data for trends yet.",
          style: body2_text.copyWith(color: neopopGrey),
        ),
      );
    }

    final entries = monthlyTrends.entries.toList();
    final maxVal =
        entries.fold<double>(0.0, (prev, e) => e.value > prev ? e.value : prev);

    final spots = entries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Monthly Spending Overview",
            style: body1_text.copyWith(
              fontWeight: FontWeight.w600,
              color: groupOnSurface,
            ),
          ),
          SizedBox(height: height_16),
          SizedBox(
            height: devSysWidth * 0.6,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxVal > 0 ? maxVal / 4 : 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: neopopGrey.withOpacity(0.15),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      interval: maxVal > 0 ? maxVal / 4 : 1,
                      getTitlesWidget: (value, meta) {
                        String text;
                        if (value >= 1000) {
                          text = "₹${(value / 1000).toStringAsFixed(1)}K";
                        } else {
                          text = "₹${value.toStringAsFixed(0)}";
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            text,
                            style: const TextStyle(
                              fontSize: 10,
                              color: neopopGrey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int idx = value.toInt();
                        if (idx >= 0 && idx < entries.length) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              entries[idx].key.split(' ')[0],
                              style: const TextStyle(
                                fontSize: 10,
                                color: neopopGrey,
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
                maxY: maxVal * 1.15,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => neopopOnPrimary,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        int idx = spot.x.toInt();
                        String month =
                            idx < entries.length ? entries[idx].key : '';
                        return LineTooltipItem(
                          "$month\n₹${spot.y.toStringAsFixed(0)}",
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
                    curveSmoothness: 0.3,
                    color: neopopAccent,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: neopopAccent,
                        strokeWidth: 2,
                        strokeColor: neopopBackground,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          neopopAccent.withOpacity(0.3),
                          neopopAccent.withOpacity(0.05),
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
          SizedBox(height: height_16 * 1.5),
          // Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Spent",
                    style: caption_text.copyWith(color: neopopGrey),
                  ),
                  Text(
                    "₹${entries.fold<double>(0.0, (sum, e) => sum + e.value).toStringAsFixed(0)}",
                    style: sub_headline4_text.copyWith(color: neopopAccent),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Avg/Month",
                    style: caption_text.copyWith(color: neopopGrey),
                  ),
                  Text(
                    "₹${(entries.fold<double>(0.0, (sum, e) => sum + e.value) / entries.length).toStringAsFixed(0)}",
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
