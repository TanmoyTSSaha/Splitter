import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:splitter/Constants/category_style.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Controllers/currency_controller.dart';

class DailySpendBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> dailySpendData;
  final double monthlyTotal;

  const DailySpendBarChart({
    super.key,
    required this.dailySpendData,
    required this.monthlyTotal,
  });

  static const TextStyle _headerMetaStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    fontStyle: FontStyle.italic,
    color: Colors.white54,
    height: 1.3,
  );

  bool get _hasSpendData =>
      dailySpendData.any((d) => ((d['total'] as num?) ?? 0) > 0);

  String get _monthRangeLabel {
    final monthKeys = <String>[];
    final monthNames = <String>[];

    for (final entry in dailySpendData) {
      final year = entry['year'] as int? ??
          DateTime.parse(entry['date'] as String).year;
      final month = entry['month'] as int? ??
          DateTime.parse(entry['date'] as String).month;
      final key = '$year-$month';
      if (!monthKeys.contains(key)) {
        monthKeys.add(key);
        monthNames.add(DateFormat('MMMM').format(DateTime(year, month)));
      }
    }

    return monthNames.join(' & ');
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasSpendData) {
      return Container(
        height: 200,
        width: double.infinity,
        padding: EdgeInsets.all(height_16),
        decoration: BoxDecoration(
          color: neopopBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'No Data Yet',
            style: body1_text.copyWith(color: Colors.white),
          ),
        ),
      );
    }

    final peakDailySpend = dailySpendData
        .map((d) => (d['total'] as num?)?.toDouble() ?? 0)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final double maxY = peakDailySpend > 0 ? peakDailySpend * 1.2 : 100;

    return Container(
      height: 220,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(width_16, height_16 * 1.5, width_16, height_16),
      decoration: BoxDecoration(
        color: neopopBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: neopopBackground.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  style: const TextStyle(
                    fontFamily: 'Albra',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Total true spend', style: _headerMetaStyle),
                  Text(_monthRangeLabel, style: _headerMetaStyle),
                ],
              ),
            ],
          ),
          SizedBox(height: height_10),
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
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= dailySpendData.length) {
                          return const SizedBox.shrink();
                        }
                        final day = dailySpendData[index]['day'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '$day',
                            style: caption_text.copyWith(
                              color: Colors.white54,
                              fontSize: 10,
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
                    getTooltipColor: (_) => Colors.white,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      if (groupIndex < 0 ||
                          groupIndex >= dailySpendData.length) {
                        return null;
                      }
                      final dayData = dailySpendData[groupIndex];
                      final date = DateTime.parse(dayData['date'] as String);
                      final total =
                          (dayData['total'] as num?)?.toDouble() ?? 0;
                      if (total <= 0) return null;

                      final sym = Get.find<CurrencyController>().symbol;
                      final categories = Map<String, dynamic>.from(
                        (dayData['categories'] as Map?) ?? {},
                      );
                      final lines = <String>[
                        DateFormat('MMM d').format(date),
                        '$sym${total.toStringAsFixed(0)} spent',
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
                          '${_formatCategory(entry.key)}: $sym${entry.value.toStringAsFixed(0)} ($pct%)',
                        );
                      }

                      return BarTooltipItem(
                        lines.join('\n'),
                        const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          height: 1.35,
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
              width: 8,
              color: Colors.transparent,
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
            width: 8,
            color: stackItems.length == 1
                ? stackItems.first.color
                : categoryColor('Others'),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
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
    if (category.isEmpty) return 'Others';
    return category[0].toUpperCase() + category.substring(1);
  }
}
