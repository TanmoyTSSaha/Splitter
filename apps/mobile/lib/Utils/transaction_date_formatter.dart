import 'package:intl/intl.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_strings.dart';

/// Smart relative date labels for transaction tiles and section headers.
class TransactionDateFormatter {
  TransactionDateFormatter._();

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  /// Today → "Today", Yesterday → "Yesterday",
  /// same year → "Mon, Jan 15", older → "Jan 15, 2026"
  static String formatRelative(DateTime date, {DateTime? reference}) {
    final ref = _dateOnly(reference ?? DateTime.now());
    final d = _dateOnly(date.toLocal());
    final diff = ref.difference(d).inDays;

    if (diff == 0) return AppStrings.dates.today;
    if (diff == 1) return AppStrings.dates.yesterday;
    if (d.year == ref.year) {
      return DateFormat(AppDateFormats.weekdayShortMonthDay).format(d);
    }
    return DateFormat(AppDateFormats.shortDayYear).format(d);
  }

  /// Weekly section header: "Jan 6 – Jan 12"
  static String formatWeekRange(DateTime weekStart, DateTime weekEnd) {
    final start = _dateOnly(weekStart);
    final end = _dateOnly(weekEnd);
    if (start.year == end.year) {
      if (start.month == end.month) {
        return '${DateFormat(AppDateFormats.shortDay).format(start)}${AppSeparators.weekRange}${DateFormat(AppDateFormats.dayOnly).format(end)}';
      }
      return '${DateFormat(AppDateFormats.shortDay).format(start)}${AppSeparators.weekRange}${DateFormat(AppDateFormats.shortDay).format(end)}';
    }
    return '${DateFormat(AppDateFormats.shortDayYear).format(start)}${AppSeparators.weekRange}${DateFormat(AppDateFormats.shortDayYear).format(end)}';
  }

  /// Monthly section header: "January 2026"
  static String formatMonth(DateTime date) =>
      DateFormat(AppDateFormats.monthYear).format(_dateOnly(date));

  /// Start of local day for inclusive range lower bound (SQL >=).
  static DateTime startOfDay(DateTime date) {
    final local = date.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  /// End of local day for inclusive range upper bound (SQL <=).
  static DateTime endOfDay(DateTime date) {
    final local = date.toLocal();
    return DateTime(local.year, local.month, local.day, 23, 59, 59, 999);
  }

  static DateTime get today => startOfDay(DateTime.now());

  /// Local wall-clock time when capturing a new transaction.
  static DateTime nowForTransaction() => DateTime.now();

  /// Parse timestamptz from API/drift into local time for app use.
  static DateTime? parseStorage(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw.toLocal();
    final parsed = DateTime.tryParse(raw.toString());
    return parsed?.toLocal();
  }

  /// Serialize local capture time for Postgres timestamptz (UTC with offset).
  static String toStorageIso(DateTime dateTime) =>
      dateTime.toUtc().toIso8601String();

  /// Format time-of-day in the viewer's local timezone.
  static String formatTime(DateTime dateTime) =>
      DateFormat(AppDateFormats.time24hComment).format(dateTime.toLocal());

  /// Format full date-time in the viewer's local timezone (exports, activity).
  static String formatDateTime(DateTime dateTime) =>
      DateFormat(AppDateFormats.exportDateTime).format(dateTime.toLocal());
}
