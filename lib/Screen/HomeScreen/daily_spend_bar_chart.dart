import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/category_style.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

class DailySpendBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> dailySpendData;
  final double monthlyTotal;

  const DailySpendBarChart({
    super.key,
    required this.dailySpendData,
    required this.monthlyTotal,
  });

  static TextStyle _headerMetaStyle(BuildContext context) =>
      caption_text.copyWith(
        color: groupOnSurfaceMuted,
        height: groupLineHeightTight,
        fontStyle: FontStyle.italic,
      );

  bool get _hasSpendData =>
      dailySpendData.any((d) => ((d['total'] as num?) ?? 0) > 0);

  String get _monthRangeLabel {
    final monthKeys = <String>[];
    final monthNames = <String>[];

    for (final entry in dailySpendData) {
      final year =
          entry['year'] as int? ?? DateTime.parse(entry['date'] as String).year;
      final month = entry['month'] as int? ??
          DateTime.parse(entry['date'] as String).month;
      final key = '${year}-${month}';
      if (!monthKeys.contains(key)) {
        monthKeys.add(key);
        monthNames.add(
            DateFormat(AppDateFormats.monthName).format(DateTime(year, month)));
      }
    }

    return monthNames.join(AppSeparators.monthJoiner);
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;

    if (!_hasSpendData) {
      return Container(
        height: homeSpendChartEmptyHeight,
        width: double.infinity,
        padding: const EdgeInsets.all(groupGutter),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(groupCardRadiusLg),
          border: Border.all(color: groupMutedBorder),
        ),
        child: Center(
          child: Text(
            AppStrings.home.chartNoData,
            style: body1_text.copyWith(color: groupOnSurfaceMuted),
          ),
        ),
      );
    }

    final peakDailySpend = dailySpendData
        .map((d) => (d['total'] as num?)?.toDouble() ?? 0)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final double maxY = peakDailySpend > 0
        ? peakDailySpend * homeSpendChartMaxYPaddingFactor
        : homeSpendChartMaxYFallback;

    return Container(
      height: homeSpendChartHeight,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        groupGutter,
        groupGapLg,
        groupGutter,
        groupGutter,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(groupCardRadiusXl),
        border: Border.all(color: groupMutedBorder),
        boxShadow: [
          BoxShadow(
            color: groupMutedFillFaint,
            blurRadius: homeSpendChartShadowBlur,
            offset: homeSpendChartShadowOffset,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Obx(() {
                final sym = Get.find<CurrencyController>().symbol;
                return Text(
                  '$sym${monthlyTotal.toStringAsFixed(0)}',
                  style: headline1_text.copyWith(
                    fontFamily: kFontAlbra,
                    color: groupOnSurface,
                  ),
                );
              }),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(AppStrings.home.chartTotalTrueSpend,
                      style: _headerMetaStyle(context)),
                  Text(_monthRangeLabel, style: _headerMetaStyle(context)),
                ],
              ),
            ],
          ),
          const SizedBox(height: groupGapSm),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                minY: 0,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: homeSpendChartAxisReservedSize,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= dailySpendData.length) {
                          return const SizedBox.shrink();
                        }
                        final day = dailySpendData[index]['day'];
                        return Padding(
                          padding: const EdgeInsets.only(top: groupGapXs),
                          child: Text(
                            '$day',
                            style: caption_text.copyWith(
                              color: groupMutedIconDim,
                              fontSize: groupFontMicro,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: _buildBarGroups(),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => groupCardFill,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      if (groupIndex < 0 ||
                          groupIndex >= dailySpendData.length) {
                        return null;
                      }
                      final dayData = dailySpendData[groupIndex];
                      final date = DateTime.parse(dayData['date'] as String);
                      final total = (dayData['total'] as num?)?.toDouble() ?? 0;
                      if (total <= 0) return null;

                      final sym = Get.find<CurrencyController>().symbol;
                      final categories = Map<String, dynamic>.from(
                        (dayData['categories'] as Map?) ?? {},
                      );
                      final lines = <String>[
                        DateFormat(AppDateFormats.shortDay).format(date),
                        AppStringFormat.daySpendTotal(
                          sym,
                          total.toStringAsFixed(0),
                        ),
                      ];

                      final sorted = categories.entries
                          .map((e) => MapEntry(
                                e.key,
                                (e.value as num).toDouble(),
                              ))
                          .where((e) => e.value > 0)
                          .toList()
                        ..sort((a, b) => b.value.compareTo(a.value));

                      for (final entry in sorted) {
                        final pct = (entry.value / total * 100).round();
                        lines.add(
                          AppStringFormat.categoryShareLine(
                            _formatCategory(entry.key),
                            sym,
                            entry.value.toStringAsFixed(0),
                            pct,
                          ),
                        );
                      }

                      return BarTooltipItem(
                        lines.join('\n'),
                        caption_text.copyWith(
                          color: groupOnSurface,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.normal,
                          height: groupLineHeightRelaxed,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(dailySpendData.length, (index) {
      final dayData = dailySpendData[index];
      final total = (dayData['total'] as num?)?.toDouble() ?? 0;
      final categories = Map<String, dynamic>.from(
        (dayData['categories'] as Map?) ?? {},
      );

      if (total <= 0) {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: 0,
              width: homeSpendChartBarWidth,
              color: groupTransparent,
            ),
          ],
        );
      }

      final stackItems = _buildStackItems(categories, total);

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: total,
            width: homeSpendChartBarWidth,
            color: stackItems.length == 1
                ? stackItems.first.color
                : categoryColor(CategoryDefaults.others),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(homeSpendChartBarRadius),
            ),
            rodStackItems: stackItems.length > 1 ? stackItems : null,
          ),
        ],
      );
    });
  }

  List<BarChartRodStackItem> _buildStackItems(
    Map<String, dynamic> categories,
    double total,
  ) {
    final entries = categories.entries
        .map((e) => MapEntry(e.key, (e.value as num).toDouble()))
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.length <= 1) {
      if (entries.isEmpty) return [];
      return [
        BarChartRodStackItem(
          0,
          total,
          categoryColor(entries.first.key),
        ),
      ];
    }

    double fromY = 0;
    final items = <BarChartRodStackItem>[];
    for (final entry in entries) {
      final toY = fromY + entry.value;
      items.add(
        BarChartRodStackItem(fromY, toY, categoryColor(entry.key)),
      );
      fromY = toY;
    }
    return items;
  }

  String _formatCategory(String category) {
    if (category.isEmpty) return CategoryDefaults.others;
    return category[0].toUpperCase() + category.substring(1);
  }
}
