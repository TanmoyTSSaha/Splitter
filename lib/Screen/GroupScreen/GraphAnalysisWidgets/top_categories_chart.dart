import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitter/Widgets/tab_empty_state.dart';

/// Animated donut chart showing top 5 expense categories by amount.
class TopCategoriesChart extends StatefulWidget {
  final List<MapEntry<String, double>> topCategories;

  const TopCategoriesChart({
    required this.topCategories,
    super.key,
  });

  @override
  State<TopCategoriesChart> createState() => _TopCategoriesChartState();
}

class _TopCategoriesChartState extends State<TopCategoriesChart> {
  int touchIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.topCategories.isEmpty) {
      return const TabEmptyState(
        variant: TabEmptyVariant.analytics,
        title: 'No category data yet',
        compact: true,
      );
    }

    final total =
        widget.topCategories.fold<double>(0.0, (sum, e) => sum + e.value);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Top Shared Expense Categories",
            style: body1_text.copyWith(
              fontWeight: FontWeight.w600,
              color: groupOnSurface,
            ),
          ),
          SizedBox(height: height_16),
          SizedBox(
            height: devSysWidth * 0.7,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchIndex = -1;
                            return;
                          }
                          touchIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    startDegreeOffset: -90,
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: devSysWidth * 0.15,
                    sections: _buildSections(total),
                  ),
                ),
                // Center text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Total",
                      style: caption_text.copyWith(color: neopopGrey),
                    ),
                    Text(
                      "₹${total.toStringAsFixed(0)}",
                      style: sub_headline4_text.copyWith(
                        color: neopopAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: height_16),
          // Legend list
          ...widget.topCategories.asMap().entries.map((entry) {
            int i = entry.key;
            var cat = entry.value;
            double percentage = total > 0 ? (cat.value / total) * 100 : 0;
            double opacity = 1.0 - (i * 0.15);
            if (opacity < 0.3) opacity = 0.3;

            return Padding(
              padding: EdgeInsets.only(bottom: height_10),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: neopopAccent.withOpacity(opacity),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  SizedBox(width: width_10),
                  Expanded(
                    child: Text(
                      cat.key,
                      style: body2_text.copyWith(color: groupOnSurface),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    "₹${cat.value.toStringAsFixed(0)}",
                    style: body2_text.copyWith(
                      fontWeight: FontWeight.w600,
                      color: groupOnSurface,
                    ),
                  ),
                  SizedBox(width: width_10),
                  SizedBox(
                    width: 45,
                    child: Text(
                      "${percentage.toStringAsFixed(1)}%",
                      style: caption_text.copyWith(color: neopopGrey),
                      textAlign: TextAlign.end,
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

  List<PieChartSectionData> _buildSections(double total) {
    return widget.topCategories.asMap().entries.map((entry) {
      int i = entry.key;
      var cat = entry.value;
      final isTouched = i == touchIndex;
      double opacity = 1.0 - (i * 0.15);
      if (opacity < 0.3) opacity = 0.3;

      return PieChartSectionData(
        color: neopopAccent.withOpacity(opacity),
        value: cat.value,
        title:
            isTouched ? "${(cat.value / total * 100).toStringAsFixed(1)}%" : '',
        radius: isTouched ? 70 : 60,
        titleStyle: body2_text.copyWith(
          color: groupOnSurface,
          fontWeight: FontWeight.w700,
        ),
        titlePositionPercentageOffset: 0.55,
        borderSide: isTouched
            ? const BorderSide(color: groupOnSurface, width: 1)
            : BorderSide(color: groupOnSurface.withOpacity(0)),
      );
    }).toList();
  }
}
