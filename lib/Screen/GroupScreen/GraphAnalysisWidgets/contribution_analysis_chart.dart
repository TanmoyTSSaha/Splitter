import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitter/Widgets/tab_empty_state.dart';

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
      return const TabEmptyState(
        variant: TabEmptyVariant.analytics,
        title: 'No transaction data yet',
        compact: true,
      );
    }

    final entries = memberContributions.entries.toList();
    final maxVal = entries.fold<double>(0.0, (prev, e) {
      final paid = e.value['paid'] ?? 0.0;
      final share = e.value['share'] ?? 0.0;
      return [prev, paid, share].reduce((a, b) => a > b ? a : b);
    });

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Legend
          Row(
            children: [
              _legendDot(neopopAccent, 'Paid'),
              SizedBox(width: width_16),
              _legendDot(neopopAccent.withOpacity(0.35), 'Your share'),
            ],
          ),
          SizedBox(height: height_16),
          SizedBox(
            height: entries.length * 80.0 + 40,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal * 1.15,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => neopopOnPrimary,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String label = rodIndex == 0 ? 'Paid' : 'Your share';
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
                  leftTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        int idx = value.toInt();
                        if (idx >= 0 && idx < entries.length) {
                          String name = entries[idx].key;
                          // Truncate long names
                          if (name.length > 10) {
                            name = "${name.substring(0, 9)}…";
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
                gridData: const FlGridData(show: false),
                barGroups: entries.asMap().entries.map((entry) {
                  int i = entry.key;
                  var data = entry.value.value;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data['paid'] ?? 0.0,
                        color: neopopAccent,
                        width: 12,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        toY: data['share'] ?? 0.0,
                        color: neopopAccent.withOpacity(0.35),
                        width: 12,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: height_16),
          // Summary cards
          ...entries.map((e) => Padding(
                padding: EdgeInsets.only(bottom: height_10),
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
                            text:
                                "Paid ₹${(e.value['paid'] ?? 0).toStringAsFixed(0)}",
                            style: caption_text.copyWith(
                              color: neopopAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(text: "  •  "),
                          TextSpan(
                            text:
                                'Share ₹${(e.value['share'] ?? 0).toStringAsFixed(0)}',
                            style: caption_text.copyWith(color: neopopGrey),
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
