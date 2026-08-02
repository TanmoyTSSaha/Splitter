import 'dart:math';

import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Model/loan_model.dart';

class LoanInterest {
  static double fullTermInterest({
    required LoanModel loan,
    required int monthCount,
  }) {
    if (loan.interestRate == 0 || monthCount <= 0) return 0;

    final principal = loan.principalAmount;
    final rate = loan.interestRate;
    final timeUnits = _termUnits(monthCount, loan.interestPeriod);

    if (loan.interestType == LoanInterestTypes.compound) {
      return principal * pow(1 + rate / 100, timeUnits) - principal;
    }
    if (loan.interestType == LoanInterestTypes.simple ||
        loan.interestType == LoanInterestTypes.flat) {
      return principal * (rate / 100) * timeUnits;
    }
    return 0;
  }

  static double accruedInterest(LoanModel loan) {
    if (loan.interestRate == 0 || loan.status != LoanStatusValues.active) {
      return 0;
    }

    if (loan.interestType == LoanInterestTypes.flat) {
      final monthCount = resolveMonthCount(loan);
      return fullTermInterest(loan: loan, monthCount: monthCount);
    }

    final now = DateTime.now();
    final diff = now.difference(loan.startDate);
    double timeUnits = 0;

    if (loan.interestPeriod == LoanFrequencyValues.monthly) {
      timeUnits = diff.inDays / LoanInterestDays.daysPerMonth;
    } else if (loan.interestPeriod == LoanFrequencyValues.yearly) {
      timeUnits = diff.inDays / LoanInterestDays.daysPerYear;
    } else {
      timeUnits = 1;
    }

    if (timeUnits < 0) timeUnits = 0;

    final principal = loan.principalAmount;
    final rate = loan.interestRate;

    if (loan.interestType == LoanInterestTypes.simple) {
      return principal * (rate / 100) * timeUnits;
    }
    if (loan.interestType == LoanInterestTypes.compound) {
      return principal * pow(1 + rate / 100, timeUnits) - principal;
    }
    return 0;
  }

  static int resolveMonthCount(LoanModel loan) {
    final duration = loan.duration;
    final unit = loan.durationUnit;

    if (duration != null && duration > 0 && unit != null) {
      if (unit == LoanDurationUnits.months) return duration;
      if (unit == LoanDurationUnits.years) return duration * 12;
      if (unit == LoanDurationUnits.days && loan.dueDate != null) {
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
    if (interestPeriod == LoanFrequencyValues.yearly) return monthCount / 12.0;
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
