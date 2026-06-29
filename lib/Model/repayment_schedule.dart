import 'dart:math';

import 'package:splitter/Model/loan_model.dart';

enum InstallmentStatus { upcoming, partial, paid }

class RepaymentInstallment {
  final int index;
  final DateTime monthAnchor;
  final DateTime windowStart;
  final DateTime windowEnd;
  final double amount;
  final InstallmentStatus status;
  final double? paidAmount;

  const RepaymentInstallment({
    required this.index,
    required this.monthAnchor,
    required this.windowStart,
    required this.windowEnd,
    required this.amount,
    required this.status,
    this.paidAmount,
  });
}

class RepaymentSchedule {
  final double principal;
  final double totalInterest;
  final double totalPayable;
  final double monthlyEmi;
  final int monthCount;
  final List<RepaymentInstallment> installments;

  const RepaymentSchedule({
    required this.principal,
    required this.totalInterest,
    required this.totalPayable,
    required this.monthlyEmi,
    required this.monthCount,
    required this.installments,
  });
}

class LoanScheduleCalculator {
  static RepaymentSchedule build(
    LoanModel loan, {
    double? paidAggregate,
  }) {
    final principal = loan.principalAmount;
    final monthCount = _resolveMonthCount(loan);
    final totalInterest = _fullTermInterest(
      principal: principal,
      rate: loan.interestRate,
      interestType: loan.interestType,
      monthCount: monthCount,
    );
    final totalPayable = principal + totalInterest;
    final monthlyEmi =
        monthCount > 0 ? totalPayable / monthCount : totalPayable;

    final startDay = loan.repaymentStartDay ?? 1;
    final endDay = loan.repaymentEndDay ?? startDay;

    final rawInstallments = <RepaymentInstallment>[];
    for (var i = 0; i < monthCount; i++) {
      final anchor = _addCalendarMonths(loan.startDate, i);
      final monthAnchor = DateTime(anchor.year, anchor.month, 1);
      final windowStart = _dateWithClampedDay(anchor.year, anchor.month, startDay);
      final windowEnd = _dateWithClampedDay(anchor.year, anchor.month, endDay);

      rawInstallments.add(
        RepaymentInstallment(
          index: i + 1,
          monthAnchor: monthAnchor,
          windowStart: windowStart,
          windowEnd: windowEnd,
          amount: monthlyEmi,
          status: InstallmentStatus.upcoming,
        ),
      );
    }

    if (rawInstallments.isNotEmpty) {
      final roundedSum =
          monthlyEmi * (rawInstallments.length - 1);
      final lastAmount = totalPayable - roundedSum;
      final last = rawInstallments.last;
      rawInstallments[rawInstallments.length - 1] = RepaymentInstallment(
        index: last.index,
        monthAnchor: last.monthAnchor,
        windowStart: last.windowStart,
        windowEnd: last.windowEnd,
        amount: lastAmount,
        status: last.status,
      );
    }

    final aggregate = (paidAggregate ?? loan.repaymentAmount)
        .clamp(0, totalPayable)
        .toDouble();
    final installments = _markPaidStatus(rawInstallments, aggregate);

    return RepaymentSchedule(
      principal: principal,
      totalInterest: totalInterest,
      totalPayable: totalPayable,
      monthlyEmi: monthlyEmi,
      monthCount: monthCount,
      installments: installments,
    );
  }

  static int _resolveMonthCount(LoanModel loan) {
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

  static int _daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  static DateTime _dateWithClampedDay(int year, int month, int day) {
    final clamped = day.clamp(1, _daysInMonth(year, month));
    return DateTime(year, month, clamped);
  }

  static double _fullTermInterest({
    required double principal,
    required double rate,
    required String interestType,
    required int monthCount,
  }) {
    if (rate == 0 || monthCount <= 0) return 0;

    if (interestType == 'compound') {
      return principal * pow(1 + rate / 100, monthCount) - principal;
    }
    if (interestType == 'simple' || interestType == 'flat') {
      return principal * (rate / 100) * monthCount;
    }
    return 0;
  }

  static List<RepaymentInstallment> _markPaidStatus(
    List<RepaymentInstallment> installments,
    double paidAggregate,
  ) {
    var remaining = paidAggregate;
    return installments.map((inst) {
      if (remaining >= inst.amount) {
        remaining -= inst.amount;
        return RepaymentInstallment(
          index: inst.index,
          monthAnchor: inst.monthAnchor,
          windowStart: inst.windowStart,
          windowEnd: inst.windowEnd,
          amount: inst.amount,
          status: InstallmentStatus.paid,
        );
      }
      if (remaining > 0) {
        final partial = remaining;
        remaining = 0;
        return RepaymentInstallment(
          index: inst.index,
          monthAnchor: inst.monthAnchor,
          windowStart: inst.windowStart,
          windowEnd: inst.windowEnd,
          amount: inst.amount,
          status: InstallmentStatus.partial,
          paidAmount: partial,
        );
      }
      return inst;
    }).toList();
  }
}
