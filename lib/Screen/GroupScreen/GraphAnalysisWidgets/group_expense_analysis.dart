import 'package:fl_chart/fl_chart.dart';

import 'package:flutter/material.dart';

import 'package:splitter/Constants/constants.dart';

import 'package:splitter/Constants/shared.dart';

import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';

import 'package:splitter/Widgets/tab_empty_state.dart';



class GroupExpenseAnalysis extends StatefulWidget {

  final Map<String, double> categoryBreakdown;

  final DurationLabel selectedDuration;

  final ValueChanged<DurationLabel> onDurationChanged;



  const GroupExpenseAnalysis({

    required this.categoryBreakdown,

    required this.selectedDuration,

    required this.onDurationChanged,

    super.key,

  });



  @override

  State<GroupExpenseAnalysis> createState() => _GroupExpenseAnalysisState();

}



class _GroupExpenseAnalysisState extends State<GroupExpenseAnalysis> {

  int touchIndex = -1;



  List<Color> _generateColors(int count) {

    final colors = <Color>[];

    for (int i = 0; i < count; i++) {

      double opacity = 1.0 - (i * (0.7 / count));

      if (opacity < 0.2) opacity = 0.2;

      colors.add(neopopAccent.withOpacity(opacity));

    }

    return colors;

  }



  @override

  Widget build(BuildContext context) {

    if (widget.categoryBreakdown.isEmpty) {

      return Column(

        children: [

          Align(

            alignment: Alignment.centerRight,

            child: _durationDropdown(),

          ),

          const Expanded(

            child: TabEmptyState(

              variant: TabEmptyVariant.analytics,

              title: 'No expense data for this period',

              compact: true,

            ),

          ),

        ],

      );

    }



    final entries = widget.categoryBreakdown.entries.toList()

      ..sort((a, b) => b.value.compareTo(a.value));

    final total = entries.fold<double>(0.0, (sum, e) => sum + e.value);

    final colors = _generateColors(entries.length);



    return SingleChildScrollView(

      physics: const BouncingScrollPhysics(),

      child: Column(

        mainAxisAlignment: MainAxisAlignment.start,

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Align(

            alignment: Alignment.centerRight,

            child: _durationDropdown(),

          ),

          SizedBox(height: height_16),

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

                      touchIndex =

                          pieTouchResponse.touchedSection!.touchedSectionIndex;

                    });

                  },

                ),

                startDegreeOffset: 180,

                borderData: FlBorderData(show: false),

                sectionsSpace: 1,

                centerSpaceRadius: 0,

                sections: entries.asMap().entries.map((entry) {

                  final i = entry.key;

                  final cat = entry.value;

                  final isTouched = i == touchIndex;

                  final percentage = total > 0 ? (cat.value / total) * 100 : 0;



                  return PieChartSectionData(

                    color: colors[i],

                    value: cat.value,

                    title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',

                    radius: isTouched ? 130 : 125,

                    titlePositionPercentageOffset: 0.55,

                    titleStyle: body2_text.copyWith(

                      color: groupOnSurface,

                      fontWeight: FontWeight.w700,

                    ),

                    borderSide: isTouched

                        ? const BorderSide(color: groupOnSurface, width: 1)

                        : BorderSide(color: groupOnSurface.withOpacity(0)),

                  );

                }).toList(),

              ),

            ),

          ),

          SizedBox(height: height_16),

          Wrap(

            spacing: width_16 * 1.5,

            runSpacing: height_10,

            children: entries.asMap().entries.map((entry) {

              final i = entry.key;

              final cat = entry.value;

              final percentage = total > 0 ? (cat.value / total) * 100 : 0;

              return Row(

                mainAxisSize: MainAxisSize.min,

                children: [

                  Container(

                    decoration: BoxDecoration(

                      color: colors[i],

                      borderRadius: BorderRadius.circular(4),

                    ),

                    height: height_10 * 2,

                    width: width_10 * 2,

                  ),

                  SizedBox(width: width_10),

                  Text(

                    '${cat.key} ${percentage.toStringAsFixed(0)}%',

                    style: body2_text.copyWith(color: groupOnSurface),

                  ),

                ],

              );

            }).toList(),

          ),

        ],

      ),

    );

  }



  Widget _durationDropdown() {
    return Container(
      height: 48,
      padding: EdgeInsets.symmetric(horizontal: groupGutter),
      decoration: BoxDecoration(
        color: neopopSecondaryGrey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: neopopGrey.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 18,
            color: groupOnSurfaceMuted,
          ),
          SizedBox(width: groupGapSm),
          Text(
            'Duration',
            style: body2_text.copyWith(color: groupOnSurfaceMuted),
          ),
          SizedBox(width: groupGapSm),
          DropdownButtonHideUnderline(
            child: DropdownButton<DurationLabel>(
              value: widget.selectedDuration,
              dropdownColor: Colors.white,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: groupOnSurface),
              style: body1_text.copyWith(
                color: groupOnSurface,
                fontWeight: FontWeight.w600,
              ),
              borderRadius: BorderRadius.circular(12),
              items: DurationLabel.values.map((lbl) {
                return DropdownMenuItem<DurationLabel>(
                  value: lbl,
                  child: Text(lbl.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) widget.onDurationChanged(value);
              },
            ),
          ),
        ],
      ),
    );
  }

}


