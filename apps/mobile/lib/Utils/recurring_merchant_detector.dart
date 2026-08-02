import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/domain_values.dart';

class RecurringMerchantHit {
  final String label;
  final double typicalAmount;
  final int occurrenceCount;
  final DateTime? nextExpected;

  const RecurringMerchantHit({
    required this.label,
    required this.typicalAmount,
    required this.occurrenceCount,
    this.nextExpected,
  });

  Map<String, dynamic> toJson() => {
        RecurringMerchantKeys.label: label,
        RecurringMerchantKeys.typicalAmount: typicalAmount,
        RecurringMerchantKeys.occurrenceCount: occurrenceCount,
        if (nextExpected != null)
          RecurringMerchantKeys.nextExpected: nextExpected!.toIso8601String(),
      };
}

String normalizeMerchantLabel(String title) {
  return title.trim().toLowerCase().replaceAll(
      RegExp(InputPatterns.whitespace), AppSeparators.monthYearJoiner);
}

bool amountsAreSimilar(
  double a,
  double b, {
  double tolerance = RecurringMerchantRules.amountTolerance,
}) {
  if (a <= 0 || b <= 0) return false;
  return (a - b).abs() <= a * tolerance;
}

double _medianAmount(List<double> values) {
  final sorted = List<double>.from(values)..sort();
  final mid = sorted.length ~/ 2;
  if (sorted.length.isOdd) return sorted[mid];
  return (sorted[mid - 1] + sorted[mid]) / 2;
}

String _titleCase(String value) {
  if (value.isEmpty) return value;
  return value
      .split(AppSeparators.monthYearJoiner)
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(AppSeparators.monthYearJoiner);
}

/// Detects personal merchants billed monthly at a stable amount.
List<RecurringMerchantHit> detectRecurringMerchants(
  List<Map<String, dynamic>> transactions,
) {
  final personal = transactions.where((txn) {
    if (txn[UnifiedTxnKeys.isCredit] == true) return false;
    if (txn[UnifiedTxnKeys.type] != TransactionTypes.personal) return false;
    final amount = (txn[UnifiedTxnKeys.amount] as num?)?.toDouble() ?? 0;
    return amount > 0;
  });

  final byMerchant = <String, List<({DateTime date, double amount})>>{};
  for (final txn in personal) {
    final label = normalizeMerchantLabel(
        txn[UnifiedTxnKeys.title]?.toString() ?? StringDefaults.empty);
    if (label.length < RecurringMerchantRules.minLabelLength) continue;
    byMerchant.putIfAbsent(label, () => []).add((
      date: txn[UnifiedTxnKeys.date] as DateTime,
      amount: (txn[UnifiedTxnKeys.amount] as num).toDouble(),
    ));
  }

  final hits = <RecurringMerchantHit>[];
  byMerchant.forEach((label, entries) {
    if (entries.length < RecurringMerchantRules.minOccurrences) return;

    entries.sort((a, b) => a.date.compareTo(b.date));
    final amounts = entries.map((e) => e.amount).toList();
    final typical = _medianAmount(amounts);
    final similarCount =
        amounts.where((a) => amountsAreSimilar(a, typical)).length;
    if (similarCount <
        (amounts.length * RecurringMerchantRules.similarAmountRatio).ceil()) {
      return;
    }

    var monthlyGaps = 0;
    for (var i = 1; i < entries.length; i++) {
      final gap = entries[i].date.difference(entries[i - 1].date).inDays;
      if (gap >= RecurringMerchantRules.monthlyGapMinDays &&
          gap <= RecurringMerchantRules.monthlyGapMaxDays) {
        monthlyGaps++;
      }
    }
    if (monthlyGaps < RecurringMerchantRules.minMonthlyGaps) return;

    final lastDate = entries.last.date;
    hits.add(
      RecurringMerchantHit(
        label: _titleCase(label),
        typicalAmount: typical,
        occurrenceCount: entries.length,
        nextExpected: DateTime(lastDate.year, lastDate.month + 1, lastDate.day),
      ),
    );
  });

  hits.sort((a, b) => b.typicalAmount.compareTo(a.typicalAmount));
  return hits.take(InsightsThresholds.topCategoryLimit).toList();
}
