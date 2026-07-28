import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Utils/transaction_date_formatter.dart';

enum TransactionSectionGranularity { daily, weekly, monthly, yearly }

class TransactionSection {
  final String header;
  final TransactionSectionGranularity granularity;
  final List<Map<String, dynamic>> transactions;

  const TransactionSection({
    required this.header,
    required this.granularity,
    required this.transactions,
  });
}

/// Assigns rolling section headers based on transaction age from today.
class TransactionSectionGrouper {
  TransactionSectionGrouper._();

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  static int _daysAgo(DateTime date, DateTime reference) {
    return _dateOnly(reference).difference(_dateOnly(date.toLocal())).inDays;
  }

  static DateTime _mondayOfWeek(DateTime date) {
    final d = _dateOnly(date);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  static TransactionSectionGranularity _granularityFor(int daysAgo) {
    if (daysAgo <= TransactionSectionRules.dailyMaxDaysAgo) {
      return TransactionSectionGranularity.daily;
    }
    if (daysAgo <= TransactionSectionRules.weeklyMaxDaysAgo) {
      return TransactionSectionGranularity.weekly;
    }
    if (daysAgo <= TransactionSectionRules.monthlyMaxDaysAgo) {
      return TransactionSectionGranularity.monthly;
    }
    return TransactionSectionGranularity.yearly;
  }

  static String _sectionKey(DateTime date, DateTime reference) {
    final daysAgo = _daysAgo(date, reference);
    final d = _dateOnly(date.toLocal());
    final gran = _granularityFor(daysAgo);

    switch (gran) {
      case TransactionSectionGranularity.daily:
        return '${SectionKeyPrefixes.daily}${d.year}_${d.month}_${d.day}';
      case TransactionSectionGranularity.weekly:
        final monday = _mondayOfWeek(d);
        return '${SectionKeyPrefixes.weekly}${monday.year}_${monday.month}_${monday.day}';
      case TransactionSectionGranularity.monthly:
        return '${SectionKeyPrefixes.monthly}${d.year}_${d.month}';
      case TransactionSectionGranularity.yearly:
        return '${SectionKeyPrefixes.yearly}${d.year}';
    }
  }

  static String _headerForKey(
    String key,
    TransactionSectionGranularity gran,
    DateTime reference,
  ) {
    final parts = key.split(AppSeparators.compositeKeyJoiner);
    switch (gran) {
      case TransactionSectionGranularity.daily:
        final date = DateTime(
          int.parse(parts[1]),
          int.parse(parts[2]),
          int.parse(parts[3]),
        );
        return TransactionDateFormatter.formatRelative(date,
            reference: reference);
      case TransactionSectionGranularity.weekly:
        final monday = DateTime(
          int.parse(parts[1]),
          int.parse(parts[2]),
          int.parse(parts[3]),
        );
        final sunday = monday.add(
          Duration(days: TransactionSectionRules.weekSpanDays),
        );
        return TransactionDateFormatter.formatWeekRange(monday, sunday);
      case TransactionSectionGranularity.monthly:
        final date = DateTime(int.parse(parts[1]), int.parse(parts[2]));
        return TransactionDateFormatter.formatMonth(date);
      case TransactionSectionGranularity.yearly:
        return parts[1];
    }
  }

  /// Groups [transactions] preserving their input order within each section.
  static List<TransactionSection> group(
    List<Map<String, dynamic>> transactions, {
    DateTime? reference,
  }) {
    if (transactions.isEmpty) return [];

    final ref = reference ?? DateTime.now();
    final orderedKeys = <String>[];
    final buckets = <String, List<Map<String, dynamic>>>{};
    final granularities = <String, TransactionSectionGranularity>{};

    for (final txn in transactions) {
      final date = txn[UnifiedTxnKeys.date] as DateTime;
      final daysAgo = _daysAgo(date, ref);
      final gran = _granularityFor(daysAgo);
      final key = _sectionKey(date, ref);

      granularities.putIfAbsent(key, () => gran);
      if (!buckets.containsKey(key)) {
        orderedKeys.add(key);
        buckets[key] = [];
      }
      buckets[key]!.add(txn);
    }

    return orderedKeys
        .map((key) => TransactionSection(
              header: _headerForKey(key, granularities[key]!, ref),
              granularity: granularities[key]!,
              transactions: buckets[key]!,
            ))
        .toList();
  }
}
