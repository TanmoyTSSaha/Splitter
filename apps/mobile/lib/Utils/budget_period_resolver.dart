import 'package:intl/intl.dart';
import 'package:splitr/Constants/domain_values.dart';

class BudgetPeriodWindow {
  final DateTime start;
  final DateTime end;
  final String periodKey;
  final String displayLabel;

  const BudgetPeriodWindow({
    required this.start,
    required this.end,
    required this.periodKey,
    required this.displayLabel,
  });
}

abstract final class BudgetPeriodResolver {
  static BudgetPeriodWindow resolve(String period, DateTime now) {
    switch (period) {
      case BudgetPeriodValues.daily:
        return _daily(now);
      case BudgetPeriodValues.weekly:
        return _weekly(now);
      case BudgetPeriodValues.monthly:
        return _monthly(now);
      case BudgetPeriodValues.quarterly:
        return _quarterly(now);
      case BudgetPeriodValues.halfYearly:
        return _halfYearly(now);
      case BudgetPeriodValues.yearly:
        return _yearly(now);
      default:
        return _monthly(now);
    }
  }

  static BudgetPeriodWindow _daily(DateTime now) {
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    final key = DateFormat('yyyy-MM-dd').format(start);
    final label = DateFormat('MMM d').format(start);
    return BudgetPeriodWindow(
      start: start,
      end: end,
      periodKey: key,
      displayLabel: label,
    );
  }

  /// Monday-start week (ISO-style).
  static BudgetPeriodWindow _weekly(DateTime now) {
    final weekday = now.weekday; // Mon=1 .. Sun=7
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: weekday - 1));
    final end = DateTime(
      start.year,
      start.month,
      start.day + 6,
      23,
      59,
      59,
      999,
    );
    final weekNum = _isoWeekNumber(start);
    final key = '${start.year}-W${weekNum.toString().padLeft(2, '0')}';
    final label =
        '${DateFormat('MMM d').format(start)} – ${DateFormat('MMM d').format(end)}';
    return BudgetPeriodWindow(
      start: start,
      end: end,
      periodKey: key,
      displayLabel: label,
    );
  }

  static BudgetPeriodWindow _monthly(DateTime now) {
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
    final key = DateFormat('yyyy-MM').format(start);
    final label = DateFormat('MMMM yyyy').format(start);
    return BudgetPeriodWindow(
      start: start,
      end: end,
      periodKey: key,
      displayLabel: label,
    );
  }

  static BudgetPeriodWindow _quarterly(DateTime now) {
    final q = ((now.month - 1) ~/ 3) + 1;
    final startMonth = (q - 1) * 3 + 1;
    final start = DateTime(now.year, startMonth, 1);
    final end = DateTime(now.year, startMonth + 3, 0, 23, 59, 59, 999);
    final key = '${now.year}-Q$q';
    final label = 'Q$q ${now.year}';
    return BudgetPeriodWindow(
      start: start,
      end: end,
      periodKey: key,
      displayLabel: label,
    );
  }

  static BudgetPeriodWindow _halfYearly(DateTime now) {
    final h = now.month <= 6 ? 1 : 2;
    final startMonth = h == 1 ? 1 : 7;
    final start = DateTime(now.year, startMonth, 1);
    final end = DateTime(now.year, startMonth + 6, 0, 23, 59, 59, 999);
    final key = '${now.year}-H$h';
    final label = h == 1 ? 'Jan–Jun ${now.year}' : 'Jul–Dec ${now.year}';
    return BudgetPeriodWindow(
      start: start,
      end: end,
      periodKey: key,
      displayLabel: label,
    );
  }

  static BudgetPeriodWindow _yearly(DateTime now) {
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year, 12, 31, 23, 59, 59, 999);
    final key = now.year.toString();
    final label = now.year.toString();
    return BudgetPeriodWindow(
      start: start,
      end: end,
      periodKey: key,
      displayLabel: label,
    );
  }

  static int _isoWeekNumber(DateTime mondayStart) {
    final thursday = mondayStart.add(const Duration(days: 3));
    final yearStart = DateTime(thursday.year, 1, 1);
    final firstThursday = yearStart.add(
      Duration(days: (11 - yearStart.weekday) % 7),
    );
    if (thursday.isBefore(firstThursday)) {
      return _isoWeekNumber(DateTime(thursday.year - 1, 12, 28));
    }
    return 1 + thursday.difference(firstThursday).inDays ~/ 7;
  }

  static String periodDisplayLabel(String period) {
    switch (period) {
      case BudgetPeriodValues.daily:
        return 'Daily';
      case BudgetPeriodValues.weekly:
        return 'Weekly';
      case BudgetPeriodValues.monthly:
        return 'Monthly';
      case BudgetPeriodValues.quarterly:
        return 'Quarterly';
      case BudgetPeriodValues.halfYearly:
        return 'Half-yearly';
      case BudgetPeriodValues.yearly:
        return 'Yearly';
      default:
        return period;
    }
  }
}
