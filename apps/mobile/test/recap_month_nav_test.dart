import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Utils/recap_month_nav.dart';

void main() {
  final now = DateTime(2026, 7, 15);

  test('shift blocks future months', () {
    final current = RecapMonthNav.currentMonth(now);
    expect(RecapMonthNav.shift(current, 1, now), isNull);
  });

  test('shift allows previous month within history window', () {
    final current = RecapMonthNav.currentMonth(now);
    expect(
      RecapMonthNav.shift(current, -1, now),
      DateTime(2026, 6, 1),
    );
  });

  test('shift blocks months older than max history', () {
    final earliest = RecapMonthNav.earliestMonth(now);
    expect(RecapMonthNav.shift(earliest, -1, now), isNull);
  });
}
