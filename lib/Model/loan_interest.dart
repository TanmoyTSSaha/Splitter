import 'dart:math';

import 'package:splitter/Model/loan_model.dart';

class LoanInterest {
  static double fullTermInterest({
    required LoanModel loan,
    required int monthCount,
  }) {
    if (loan.interestRate == 0 || monthCount <= 0) return 0;

    final principal = loan.principalAmount;
    final rate = loan.interestRate;
    final timeUnits = _termUnits(monthCount, loan.interestPeriod);

    if (loan.interestType == 'compound') {
      return principal * pow(1 + rate / 100, timeUnits) - principal;
    }
    if (loan.interestType == 'simple' || loan.interestType == 'flat') {
      return principal * (rate / 100) * timeUnits;
    }
    return 0;
  }

  static double accruedInterest(LoanModel loan) {
    if (loan.interestRate == 0 || loan.status != 'active') return 0;

    if (loan.interestType == 'flat') {
      final monthCount = resolveMonthCount(loan);
      return fullTermInterest(loan: loan, monthCount: monthCount);
    }

    final now = DateTime.now();
    final diff = now.difference(loan.startDate);
    double timeUnits = 0;

    if (loan.interestPeriod == 'monthly') {
      timeUnits = diff.inDays / 30.0;
    } else if (loan.interestPeriod == 'yearly') {
      timeUnits = diff.inDays / 365.0;
    } else {
      timeUnits = 1;
    }

    if (timeUnits < 0) timeUnits = 0;

    final principal = loan.principalAmount;
    final rate = loan.interestRate;

    if (loan.interestType == 'simple') {
      return principal * (rate / 100) * timeUnits;
    }
    if (loan.interestType == 'compound') {
      return principal * pow(1 + rate / 100, timeUnits) - principal;
    }
    return 0;
  }

  static int resolveMonthCount(LoanModel loan) {
    final duration = loan.duration;
    final unit = loan.durationUnit;

    if (duration != null && duration > 0 && unit != null) {
      if (unit == 'months') return duration;
      if (unit == 'years') return duration * 12;
      if (unit == 'days' && loan.dueDate != null) {
        return _calendarMonthsInclusive(loan.startDate, loan.dueDate!);
      }
    }

    if (loan.dueDate != null) {
      final count = _calendarMonthsInclusive(loan.startDate, loan.dueDate!);
      if (count > 0) return count;
    }

    return 1;
  }

  static double _termUnits(int monthCount, String interestPeriod) {
    if (interestPeriod == 'yearly') return monthCount / 12.0;
    return monthCount.toDouble();
  }

  static int _calendarMonthsInclusive(DateTime start, DateTime end) {
    if (!end.isAfter(start)) return 1;
    var count = 0;
    var cursor = DateTime(start.year, start.month, 1);
    final endAnchor = DateTime(end.year, end.month, 1);
    while (!cursor.isAfter(endAnchor)) {
      count++;
      cursor = _addCalendarMonths(cursor, 1);
    }
    return count > 0 ? count : 1;
  }

  static DateTime _addCalendarMonths(DateTime date, int months) {
    final totalMonths = date.month - 1 + months;
    final year = date.year + totalMonths ~/ 12;
    final month = totalMonths % 12 + 1;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final day = date.day.clamp(1, daysInMonth);
    return DateTime(year, month, day);
  }
}
