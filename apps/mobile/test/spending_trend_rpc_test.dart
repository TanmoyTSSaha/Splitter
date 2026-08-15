import 'package:flutter_test/flutter_test.dart';

/// Verifies RPC response shape used by [TransactionService.getMultiMonthSpendTotals].
void main() {
  group('get_multi_month_spend_totals response shape', () {
    List<Map<String, dynamic>> parseRpcRows(
      List<dynamic> rows, {
      double inrToSelected = 1.0,
    }) {
      return rows.map((row) {
        final map = Map<String, dynamic>.from(row as Map);
        final monthStr = map['month_start'] as String;
        final parts = monthStr.split('-');
        final month = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          1,
        );
        final totalInr = (map['total_inr'] as num).toDouble();
        return {
          'month': month,
          'total': totalInr * inrToSelected,
        };
      }).toList();
    }

    test('maps month_start and total_inr to trend row', () {
      final parsed = parseRpcRows([
        {'month_start': '2026-01-01', 'total_inr': 1000},
        {'month_start': '2026-02-01', 'total_inr': 2500.5},
      ]);

      expect(parsed.length, 2);
      expect(parsed[0]['month'], DateTime(2026, 1, 1));
      expect(parsed[0]['total'], 1000.0);
      expect(parsed[1]['month'], DateTime(2026, 2, 1));
      expect(parsed[1]['total'], 2500.5);
    });

    test('applies currency conversion multiplier', () {
      final parsed = parseRpcRows(
        [
          {'month_start': '2026-03-01', 'total_inr': 100},
        ],
        inrToSelected: 0.012,
      );

      expect(parsed.first['total'], closeTo(1.2, 0.0001));
    });
  });
}
