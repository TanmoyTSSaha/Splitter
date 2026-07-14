import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Model/loan_interest.dart';
import 'package:splitr/Model/loan_model.dart';

enum InstallmentStatus { upcoming, partial, paid, missed, prepaid }

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

/// Paid vs remaining split for contract totals and progress UI.
class LoanRepaymentAllocation {
  final double principal;
  final double totalInterest;
  final double totalPayable;
  final double principalPaid;
  final double interestPaid;

  const LoanRepaymentAllocation({
    required this.principal,
    required this.totalInterest,
    required this.totalPayable,
    required this.principalPaid,
    required this.interestPaid,
  });

  double get remainingPrincipal =>
      LoanScheduleCalculator.roundMoney(principal - principalPaid);

  double get remainingInterest =>
      LoanScheduleCalculator.roundMoney(totalInterest - interestPaid);

  double get totalRemaining =>
      LoanScheduleCalculator.roundMoney(remainingPrincipal + remainingInterest);

  double get totalPaid =>
      LoanScheduleCalculator.roundMoney(principalPaid + interestPaid);

  double get repaymentProgress {
    if (totalPayable <= 0) return 0;
    return (totalPaid / totalPayable).clamp(0.0, 1.0);
  }
}

class LoanScheduleCalculator {
  static double roundMoney(double value) =>
      (value * MoneyScale.cents).roundToDouble() / MoneyScale.cents;

  static RepaymentSchedule build(
    LoanModel loan, {
    double? paidAggregate,
    DateTime? asOf,
  }) {
    final principal = roundMoney(loan.principalAmount);
    final monthCount = LoanInterest.resolveMonthCount(loan);
    final totalInterest = roundMoney(
      LoanInterest.fullTermInterest(
        loan: loan,
        monthCount: monthCount,
      ),
    );
    final totalPayable = roundMoney(principal + totalInterest);
    final monthlyEmi = roundMoney(
      monthCount > 0 ? totalPayable / monthCount : totalPayable,
    );

    final startDay = loan.repaymentStartDay ?? LoanDefaults.paymentDayStart;
    final endDay = loan.repaymentEndDay ?? startDay;

    final rawInstallments = <RepaymentInstallment>[];
    // First repayment window is always the month after loan start.
    for (var i = 0; i < monthCount; i++) {
      final anchor = _addCalendarMonths(loan.startDate, i + 1);
      final monthAnchor = DateTime(anchor.year, anchor.month, 1);
      final windowStart =
          _dateWithClampedDay(anchor.year, anchor.month, startDay);
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
      final roundedSum = monthlyEmi * (rawInstallments.length - 1);
      final lastAmount = roundMoney(totalPayable - roundedSum);
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

    final aggregate = roundMoney(
      (paidAggregate ?? loan.repaymentAmount).clamp(0, totalPayable).toDouble(),
    );
    final installments = _applyPrepaidStatus(
      _applyCalendarStatus(
        _markPaidStatus(rawInstallments, aggregate),
        asOf ?? DateTime.now(),
      ),
      asOf ?? DateTime.now(),
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

  /// Splits aggregate repayments across principal and interest in proportion to
  /// each bucket's share of the full contract (principal + interest).
  static LoanRepaymentAllocation allocation(LoanModel loan) {
    final schedule = build(loan);
    final paid = roundMoney(
      loan.repaymentAmount.clamp(0, schedule.totalPayable).toDouble(),
    );

    if (schedule.totalPayable <= 0) {
      return LoanRepaymentAllocation(
        principal: schedule.principal,
        totalInterest: schedule.totalInterest,
        totalPayable: schedule.totalPayable,
        principalPaid: 0,
        interestPaid: 0,
      );
    }

    if (paid <= 0) {
      return LoanRepaymentAllocation(
        principal: schedule.principal,
        totalInterest: schedule.totalInterest,
        totalPayable: schedule.totalPayable,
        principalPaid: 0,
        interestPaid: 0,
      );
    }

    final principalPaid = roundMoney(
      paid * (schedule.principal / schedule.totalPayable),
    );
    var interestPaid = roundMoney(paid - principalPaid);

    // Guard against cent drift from independent rounding.
    if (interestPaid < 0) {
      interestPaid = 0;
    } else if (interestPaid > schedule.totalInterest) {
      interestPaid = roundMoney(schedule.totalInterest);
    }

    return LoanRepaymentAllocation(
      principal: schedule.principal,
      totalInterest: schedule.totalInterest,
      totalPayable: schedule.totalPayable,
      principalPaid: principalPaid,
      interestPaid: interestPaid,
    );
  }

  static bool isInPaymentWindow(RepaymentInstallment inst, DateTime today) {
    final start = DateTime(
        inst.windowStart.year, inst.windowStart.month, inst.windowStart.day);
    final end =
        DateTime(inst.windowEnd.year, inst.windowEnd.month, inst.windowEnd.day);
    final now = DateTime(today.year, today.month, today.day);
    return !now.isBefore(start) && !now.isAfter(end);
  }

  static double remainingDue(RepaymentInstallment inst) {
    if (inst.status == InstallmentStatus.paid ||
        inst.status == InstallmentStatus.prepaid) {
      return 0;
    }
    if (inst.status == InstallmentStatus.partial && inst.paidAmount != null) {
      return roundMoney(inst.amount - inst.paidAmount!);
    }
    return roundMoney(inst.amount);
  }

  static RepaymentInstallment? currentPayableInstallment(
    RepaymentSchedule schedule,
    DateTime today,
  ) {
    for (final inst in schedule.installments) {
      if ((inst.status == InstallmentStatus.upcoming ||
              inst.status == InstallmentStatus.partial) &&
          isInPaymentWindow(inst, today)) {
        return inst;
      }
    }
    return null;
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
    var remaining = roundMoney(paidAggregate);
    return installments.map((inst) {
      final due = roundMoney(inst.amount);
      if (remaining >= due || roundMoney(remaining) >= due) {
        remaining = roundMoney(remaining - inst.amount);
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
          inst.status == InstallmentStatus.prepaid ||
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

  /// Early payments before the installment window show as pre-paid.
  static List<RepaymentInstallment> _applyPrepaidStatus(
    List<RepaymentInstallment> installments,
    DateTime today,
  ) {
    final now = DateTime(today.year, today.month, today.day);
    return installments.map((inst) {
      final windowStart = DateTime(
        inst.windowStart.year,
        inst.windowStart.month,
        inst.windowStart.day,
      );
      if (!now.isBefore(windowStart)) return inst;

      if (inst.status == InstallmentStatus.paid) {
        return RepaymentInstallment(
          index: inst.index,
          monthAnchor: inst.monthAnchor,
          windowStart: inst.windowStart,
          windowEnd: inst.windowEnd,
          amount: inst.amount,
          status: InstallmentStatus.prepaid,
        );
      }

      if (inst.status == InstallmentStatus.partial &&
          inst.paidAmount != null &&
          inst.paidAmount! > 0) {
        return RepaymentInstallment(
          index: inst.index,
          monthAnchor: inst.monthAnchor,
          windowStart: inst.windowStart,
          windowEnd: inst.windowEnd,
          amount: inst.amount,
          status: InstallmentStatus.prepaid,
          paidAmount: inst.paidAmount,
        );
      }

      return inst;
    }).toList();
  }

  static bool isScheduleFullySettled(RepaymentSchedule schedule) {
    return schedule.installments.every(
      (inst) =>
          inst.status == InstallmentStatus.paid ||
          inst.status == InstallmentStatus.prepaid,
    );
  }
}
