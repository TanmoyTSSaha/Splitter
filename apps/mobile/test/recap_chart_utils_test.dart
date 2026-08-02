import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Utils/recap_chart_utils.dart';

void main() {
  test('recapTrendChart maps monthly totals to spots', () {
    final chart = recapTrendChart([
      {'total': 1000.0},
      {'total': 2000.0},
      {'total': 1500.0},
    ]);
    expect(chart.spots.length, 3);
    expect(chart.spots.last.y, 1500.0);
    expect(chart.maxY, greaterThan(2000.0));
  });

  test('recapTrendChart empty trend returns safe defaults', () {
    final chart = recapTrendChart([]);
    expect(chart.spots, isNotEmpty);
    expect(chart.maxY, 1);
  });

  test('habit type constants are stable', () {
    expect(RecapHabitTypes.weekendSplurger, isNotEmpty);
    expect(RecapHabitTypes.quietMonth, isNotEmpty);
  });
}
