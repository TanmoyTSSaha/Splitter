import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitter/Widgets/tab_empty_state.dart';

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
      return const TabEmptyState(
        variant: TabEmptyVariant.analytics,
        title: 'No comparison data yet',
        compact: true,
      );
    }

    final entries = categoryComparison.entries.toList();
    final maxVal = entries.fold<double>(0.0, (prev, e) {
      double user = e.value['userAmount'] ?? 0.0;
      double avg = e.value['groupAvgAmount'] ?? 0.0;
      return [prev, user, avg].reduce((a, b) => a > b ? a : b);
    });

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Spending vs Group Average',
            style: body1_text.copyWith(
              fontWeight: FontWeight.w600,
              color: groupOnSurface,
            ),
          ),
          SizedBox(height: height_10),
          Text(
            'Amount paid out-of-pocket vs group average paid per member',
            style: caption_text.copyWith(color: groupOnSurfaceMuted),
          ),
          SizedBox(height: height_10),
          Row(
            children: [
              _legendDot(neopopAccent, 'You paid'),
              SizedBox(width: width_16),
              _legendDot(neopopYellow, 'Group avg paid'),
            ],
          ),
          SizedBox(height: height_16),
          SizedBox(
            height: entries.length * 70.0 + 60,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => neopopOnPrimary,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String label = rodIndex == 0 ? 'You paid' : 'Group avg paid';
                      return BarTooltipItem(
                        "$label: ₹${rod.toY.toStringAsFixed(0)}",
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
                      reservedSize: 40,
                      interval: maxVal > 0 ? maxVal / 3 : 1,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            "₹${value.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 9,
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
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        int idx = value.toInt();
                        if (idx >= 0 && idx < entries.length) {
                          String name = entries[idx].key;
                          if (name.length > 8) {
                            name = "${name.substring(0, 7)}…";
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 10,
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
                  horizontalInterval: maxVal > 0 ? maxVal / 3 : 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: neopopGrey.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                barGroups: entries.asMap().entries.map((entry) {
                  int i = entry.key;
                  var data = entry.value.value;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data['userAmount'] ?? 0.0,
                        color: neopopAccent,
                        width: 10,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(3),
                          topRight: Radius.circular(3),
                        ),
                      ),
                      BarChartRodData(
                        toY: data['groupAvgAmount'] ?? 0.0,
                        color: neopopYellow,
                        width: 10,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(3),
                          topRight: Radius.circular(3),
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(width: width_10 / 2),
        Text(label, style: caption_text.copyWith(color: groupOnSurface)),
      ],
    );
  }
}
