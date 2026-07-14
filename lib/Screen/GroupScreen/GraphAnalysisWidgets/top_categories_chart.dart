import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Utils/currency_utils.dart';
import 'package:splitr/Widgets/tab_empty_state.dart';

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
      return TabEmptyState(
        variant: TabEmptyVariant.analytics,
        title: AppStrings.analytics.noCategoryData,
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
            AppStrings.analytics.topSharedExpenseCategories,
            style: body1_text.copyWith(
              fontWeight: FontWeight.w600,
              color: groupOnSurface,
            ),
          ),
          const SizedBox(height: groupGapMd),
          SizedBox(
            height: devSysWidth * AppDimensions.chartDonutHeightFactor,
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
                    startDegreeOffset: ChartScaleFactors.pieStartDegreeTop,
                    borderData: FlBorderData(show: false),
                    sectionsSpace: AppDimensions.chartPieSectionsSpace,
                    centerSpaceRadius:
                        devSysWidth * AppDimensions.chartPieCenterRadiusFactor,
                    sections: _buildSections(total),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.analytics.total,
                      style: caption_text.copyWith(color: groupOnSurfaceMuted),
                    ),
                    Text(
                      "${userCurrencySymbol()}${total.toStringAsFixed(0)}",
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
          const SizedBox(height: groupGapMd),
          ...widget.topCategories.asMap().entries.map((entry) {
            final i = entry.key;
            final cat = entry.value;
            final percentage = total > 0 ? (cat.value / total) * 100 : 0;
            var opacity = 1.0 - (i * ChartOpacityRules.pieFadeStep);
            if (opacity < ChartOpacityRules.pieFadeMin) {
              opacity = ChartOpacityRules.pieFadeMin;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: groupGapSm),
              child: Row(
                children: [
                  Container(
                    width: AppDimensions.chartLegendSwatch,
                    height: AppDimensions.chartLegendSwatch,
                    decoration: BoxDecoration(
                      color: neopopAccent.withValues(alpha: opacity),
                      borderRadius: BorderRadius.circular(groupRadiusXs),
                    ),
                  ),
                  const SizedBox(width: groupGapSm),
                  Expanded(
                    child: Text(
                      cat.key,
                      style: body2_text.copyWith(color: groupOnSurface),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    "${userCurrencySymbol()}${cat.value.toStringAsFixed(0)}",
                    style: body2_text.copyWith(
                      fontWeight: FontWeight.w600,
                      color: groupOnSurface,
                    ),
                  ),
                  const SizedBox(width: groupGapSm),
                  SizedBox(
                    width: AppDimensions.chartPercentColumnWidth,
                    child: Text(
                      "${percentage.toStringAsFixed(1)}${AppDisplaySymbols.percent}",
                      style: caption_text.copyWith(color: groupOnSurfaceMuted),
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
      final i = entry.key;
      final cat = entry.value;
      final isTouched = i == touchIndex;
      var opacity = 1.0 - (i * ChartOpacityRules.pieFadeStep);
      if (opacity < ChartOpacityRules.pieFadeMin) {
        opacity = ChartOpacityRules.pieFadeMin;
      }

      return PieChartSectionData(
        color: neopopAccent.withValues(alpha: opacity),
        value: cat.value,
        title: isTouched
            ? "${(cat.value / total * 100).toStringAsFixed(1)}${AppDisplaySymbols.percent}"
            : '',
        radius: isTouched
            ? AppDimensions.chartPieRadiusLg
            : AppDimensions.chartPieRadiusMd,
        titleStyle: body2_text.copyWith(
          color: groupOnSurface,
          fontWeight: FontWeight.w700,
        ),
        titlePositionPercentageOffset: ChartScaleFactors.pieTitleOffset,
        borderSide: isTouched
            ? const BorderSide(
                color: groupOnSurface,
                width: AppDimensions.borderWidthHairline,
              )
            : BorderSide(color: groupOnSurface.withValues(alpha: 0)),
      );
    }).toList();
  }
}
