/// Month bounds for recap month picker (F12).
abstract final class RecapMonthNav {
  static const maxHistoryMonths = 12;

  static DateTime normalize(DateTime month) =>
      DateTime(month.year, month.month, 1);

  static DateTime currentMonth(DateTime now) => DateTime(now.year, now.month, 1);

  static DateTime earliestMonth(DateTime now) =>
      DateTime(now.year, now.month - (maxHistoryMonths - 1), 1);

  static bool canGoOlder(DateTime selected, DateTime now) =>
      normalize(selected).isAfter(earliestMonth(now));

  static bool canGoNewer(DateTime selected, DateTime now) =>
      normalize(selected).isBefore(currentMonth(now));

  static DateTime? shift(DateTime selected, int delta, DateTime now) {
    final next = DateTime(selected.year, selected.month + delta, 1);
    if (next.isAfter(currentMonth(now))) return null;
    if (next.isBefore(earliestMonth(now))) return null;
    return next;
  }
}
