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
  final color0 = neopopAccent.withOpacity(0.25);
  final color1 = neopopAccent.withOpacity(0.5);
  final color2 = neopopAccent.withOpacity(0.75);
  final color3 = neopopAccent.withOpacity(1.0);

  final TextEditingController durationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        FocusManager.instance.primaryFocus?.unfocus();
      }),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: devSysWidth * 0.75,
              width: devSysWidth,
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

                        touchIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  startDegreeOffset: 180,
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 1,
                  centerSpaceRadius: 0,
                  sections: showingSections(
                    color0: color0,
                    color1: color1,
                    color2: color2,
                    color3: color3,
                  ),
                ),
              ),
            ),
            SizedBox(height: height_16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: color0,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      height: height_10 * 2,
                      width: width_10 * 2,
                    ),
                    SizedBox(width: width_10),
                    Text(
                      "Rent 40%",
                      style: body2_text,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Grocery 15%",
                      style: body2_text,
                    ),
                    SizedBox(width: width_10),
                    Container(
                      decoration: BoxDecoration(
                        color: color1,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      height: height_10 * 2,
                      width: width_10 * 2,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: height_16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: color2,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      height: height_10 * 2,
                      width: width_10 * 2,
                    ),
                    SizedBox(width: width_10),
                    Text(
                      "Food 25%",
                      style: body2_text,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Travel 25%",
                      style: body2_text,
                    ),
                    SizedBox(width: width_10),
                    Container(
                      decoration: BoxDecoration(
                        color: color3,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      height: height_10 * 2,
                      width: width_10 * 2,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: height_16 * 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Select Duration",
                  style: body1_text,
                ),
                DropdownMenu<DurationLabel>(
                  initialSelection: DurationLabel.weekly,
                  controller: durationController,
                  // requestFocusOnTap is enabled/disabled by platforms when it is null.
                  // On mobile platforms, this is false by default. Setting this to true will
                  // trigger focus request on the text field and virtual keyboard will appear
                  // afterward. On desktop platforms however, this defaults to true.
                  requestFocusOnTap: true,
                  label: const Text('Duration'),
                  // onSelected: (ColorLabel? color) {
                  //   setState(() {
                  //     selectedColor = color;
                  //   });
                  // },
                  dropdownMenuEntries: DurationLabel.values
                      .map<DropdownMenuEntry<DurationLabel>>(
                          (DurationLabel lbl) {
                    return DropdownMenuEntry<DurationLabel>(
                      value: lbl,
                      label: lbl.label,
                      // enabled: lbl.label != 'Grey',
                      // style: MenuItemButton.styleFrom(
                      //   foregroundColor: lbl.idx,
                      // ),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: height_16),
            Text(
              "Recommandation: You can avoid unnecessary spendings by buying these products instead of these products",
              style: caption_text,
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections(
      {Color? color0, Color? color1, Color? color2, Color? color3}) {
    return List.generate(
      4,
      (i) {
        final isTouched = i == touchIndex;

        switch (i) {
          case 0:
            return PieChartSectionData(
              color: color0,
              value: 40,
              title: '',
              radius: 125,
              titlePositionPercentageOffset: 0.55,
              borderSide: isTouched
                  ? const BorderSide(color: neopopOnPrimary, width: 1)
                  : BorderSide(color: neopopOnPrimary.withOpacity(0)),
            );
          case 1:
            return PieChartSectionData(
              color: color1,
              value: 15,
              title: '',
              radius: 125,
              titlePositionPercentageOffset: 0.55,
              borderSide: isTouched
                  ? const BorderSide(color: neopopOnPrimary, width: 1)
                  : BorderSide(color: neopopOnPrimary.withOpacity(0)),
            );
          case 2:
            return PieChartSectionData(
              color: color2,
              value: 25,
              title: '',
              radius: 125,
              titlePositionPercentageOffset: 0.6,
              borderSide: isTouched
                  ? const BorderSide(color: neopopOnPrimary, width: 1)
                  : BorderSide(color: neopopOnPrimary.withOpacity(0)),
            );
          case 3:
            return PieChartSectionData(
              color: color3,
              value: 25,
              title: '',
              radius: 125,
              titlePositionPercentageOffset: 0.55,
              borderSide: isTouched
                  ? const BorderSide(color: neopopOnPrimary, width: 1)
                  : BorderSide(color: neopopOnPrimary.withOpacity(0)),
            );
          default:
            throw Error();
        }
      },
    );
  }
}
