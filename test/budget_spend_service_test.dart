import 'package:flutter_test/flutter_test.dart';

double aggregateSpendFromAnalytics(
  Map<String, double> analytics, {
  required bool isOverall,
  String? category,
}) {
  if (isOverall) return analytics['total'] ?? 0;
  return analytics[category] ?? 0;
}

void main() {
  test('aggregateSpendFromAnalytics overall and category', () {
    final analytics = {
      'total': 500.0,
      'Food': 200.0,
      'Entertainment': 100.0,
    };
    expect(aggregateSpendFromAnalytics(analytics, isOverall: true), 500);
    expect(
      aggregateSpendFromAnalytics(
        analytics,
        isOverall: false,
        category: 'Food',
      ),
      200,
    );
    expect(
      aggregateSpendFromAnalytics(
        analytics,
        isOverall: false,
        category: 'Missing',
      ),
      0,
    );
  });
}
