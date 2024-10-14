import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/shared.dart';

class GroupExpenseAnalysis extends StatefulWidget {
  const GroupExpenseAnalysis({super.key});

  @override
  State<GroupExpenseAnalysis> createState() => _GroupExpenseAnalysisState();
}

class _GroupExpenseAnalysisState extends State<GroupExpenseAnalysis> {
  int touchIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PieChart(
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

                touchIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          startDegreeOffset: 180,
          borderData: FlBorderData(
            show: false,
          ),
          sectionsSpace: 1,
          centerSpaceRadius: 0,
          sections: showingSections(),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(
      4,
      (i) {
        final isTouched = i == touchIndex;
        final color0 = getColorOpacity(neopopAccent, 0, 3);
        final color1 = getColorOpacity(neopopAccent, 1, 3);
        final color2 = getColorOpacity(neopopAccent, 2, 3);
        final color3 = getColorOpacity(neopopAccent, 3, 3);

        switch (i) {
          case 0:
            return PieChartSectionData(
              color: color0,
              value: 25,
              title: '',
              radius: 80,
              titlePositionPercentageOffset: 0.55,
              borderSide: isTouched
                  ? const BorderSide(color: neopopOnPrimary, width: 6)
                  : BorderSide(color: neopopOnPrimary.withOpacity(0)),
            );
          case 1:
            return PieChartSectionData(
              color: color1,
              value: 25,
              title: '',
              radius: 65,
              titlePositionPercentageOffset: 0.55,
              borderSide: isTouched
                  ? const BorderSide(color: neopopOnPrimary, width: 6)
                  : BorderSide(color: neopopOnPrimary.withOpacity(0)),
            );
          case 2:
            return PieChartSectionData(
              color: color2,
              value: 25,
              title: '',
              radius: 60,
              titlePositionPercentageOffset: 0.6,
              borderSide: isTouched
                  ? const BorderSide(color: neopopOnPrimary, width: 6)
                  : BorderSide(color: neopopOnPrimary.withOpacity(0)),
            );
          case 3:
            return PieChartSectionData(
              color: color3,
              value: 25,
              title: '',
              radius: 70,
              titlePositionPercentageOffset: 0.55,
              borderSide: isTouched
                  ? const BorderSide(color: neopopOnPrimary, width: 6)
                  : BorderSide(color: neopopOnPrimary.withOpacity(0)),
            );
          default:
            throw Error();
        }
      },
    );
  }
}
