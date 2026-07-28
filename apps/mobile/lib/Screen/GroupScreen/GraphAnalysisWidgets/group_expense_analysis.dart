import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/shared.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Widgets/tab_empty_state.dart';

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
      var opacity = 1.0 - (i * (ChartOpacityRules.categoryFadeRange / count));
      if (opacity < ChartOpacityRules.categoryFadeMin) {
        opacity = ChartOpacityRules.categoryFadeMin;
      }
      colors.add(neopopAccent.withValues(alpha: opacity));
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
          Expanded(
            child: TabEmptyState(
              variant: TabEmptyVariant.analytics,
              title: AppStrings.analytics.noExpenseDataForPeriod,
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
          const SizedBox(height: groupGapMd),
          SizedBox(
            height: devSysWidth * AppDimensions.chartPieHeightFactor,
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
                startDegreeOffset: ChartScaleFactors.pieStartDegreeFull,
                borderData: FlBorderData(show: false),
                sectionsSpace: AppDimensions.chartPieSectionsSpaceTight,
                centerSpaceRadius: AppDimensions.chartPieCenterRadiusNone,
                sections: entries.asMap().entries.map((entry) {
                  final i = entry.key;
                  final cat = entry.value;
                  final isTouched = i == touchIndex;
                  final percentage = total > 0 ? (cat.value / total) * 100 : 0;

                  return PieChartSectionData(
                    color: colors[i],
                    value: cat.value,
                    title: isTouched
                        ? '${percentage.toStringAsFixed(1)}${AppDisplaySymbols.percent}'
                        : '',
                    radius: isTouched
                        ? AppDimensions.chartPieTouchedOuter
                        : AppDimensions.chartPieTouchedInner,
                    titlePositionPercentageOffset:
                        ChartScaleFactors.pieTitleOffset,
                    titleStyle: body2_text.copyWith(
                      color: groupOnSurface,
                      fontWeight: FontWeight.w700,
                    ),
                    borderSide: isTouched
                        ? const BorderSide(
                            color: groupOnSurface,
                            width: AppDimensions.borderWidthHairline,
                          )
                        : BorderSide(
                            color: groupOnSurface.withValues(alpha: 0),
                          ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: groupGapMd),
          Wrap(
            spacing: groupGapLg,
            runSpacing: groupGapSm,
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
                      borderRadius: BorderRadius.circular(groupRadiusSm),
                    ),
                    height: AppDimensions.chartLegendSwatch,
                    width: AppDimensions.chartLegendSwatch,
                  ),
                  const SizedBox(width: groupGapSm),
                  Text(
                    '${cat.key} ${percentage.toStringAsFixed(0)}${AppDisplaySymbols.percent}',
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
      height: groupCtaHeightCompact,
      padding: const EdgeInsets.symmetric(horizontal: groupGutter),
      decoration: BoxDecoration(
        color: groupMutedFillWhisper,
        borderRadius: BorderRadius.circular(groupPillRadius),
        border: Border.all(color: groupMutedBorderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            size: groupCarouselIconSm,
            color: groupOnSurfaceMuted,
          ),
          const SizedBox(width: groupGapSm),
          Text(
            AppStrings.analytics.duration,
            style: body2_text.copyWith(color: groupOnSurfaceMuted),
          ),
          const SizedBox(width: groupGapSm),
          DropdownButtonHideUnderline(
            child: DropdownButton<DurationLabel>(
              value: widget.selectedDuration,
              dropdownColor: groupCardFill,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: groupOnSurface,
              ),
              style: body1_text.copyWith(
                color: groupOnSurface,
                fontWeight: FontWeight.w600,
              ),
              borderRadius: BorderRadius.circular(groupControlRadius),
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
