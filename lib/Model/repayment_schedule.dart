import 'package:splitter/Model/loan_interest.dart';
import 'package:splitter/Model/loan_model.dart';

enum InstallmentStatus { upcoming, partial, paid, missed }

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
    final monthCount = LoanInterest.resolveMonthCount(loan);
    final totalInterest = LoanInterest.fullTermInterest(
      loan: loan,
      monthCount: monthCount,
    );
    final totalPayable = principal + totalInterest;
    final monthlyEmi =
        monthCount > 0 ? totalPayable / monthCount : totalPayable;

    final startDay = loan.repaymentStartDay ?? 1;
    final endDay = loan.repaymentEndDay ?? startDay;

    final rawInstallments = <RepaymentInstallment>[];
    // First repayment window is always the month after loan start.
    for (var i = 0; i < monthCount; i++) {
      final anchor = _addCalendarMonths(loan.startDate, i + 1);
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
    final installments = _applyCalendarStatus(
      _markPaidStatus(rawInstallments, aggregate),
      DateTime.now(),
    );

    return RepaymentSchedule(
      principal: principal,
      totalInterest: totalInterest,
      totalPayable: totalPayable,
      monthlyEmi: monthlyEmi,
      monthCount: monthCount,
      installments: installments,
    );
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

  static List<RepaymentInstallment> _applyCalendarStatus(
    List<RepaymentInstallment> installments,
    DateTime today,
  ) {
    return installments.map((inst) {
      if (inst.status == InstallmentStatus.paid ||
          inst.status == InstallmentStatus.partial) {
        return inst;
      }
      if (_isPastDue(inst.windowEnd, today)) {
        return RepaymentInstallment(
          index: inst.index,
          monthAnchor: inst.monthAnchor,
          windowStart: inst.windowStart,
          windowEnd: inst.windowEnd,
          amount: inst.amount,
          status: InstallmentStatus.missed,
        );
      }
      return inst;
    }).toList();
  }

  static bool _isPastDue(DateTime windowEnd, DateTime today) {
    final end = DateTime(windowEnd.year, windowEnd.month, windowEnd.day);
    final now = DateTime(today.year, today.month, today.day);
    return end.isBefore(now);
  }
}
