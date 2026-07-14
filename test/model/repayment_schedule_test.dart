import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Model/loan_model.dart';
import 'package:splitr/Model/repayment_schedule.dart';

LoanModel _testLoan({
  double principal = 475000,
  int duration = 30,
  double repaymentAmount = 0,
  DateTime? startDate,
  int repaymentStartDay = 1,
  int repaymentEndDay = 15,
  double interestRate = 0,
}) {
  final start = startDate ?? DateTime(2026, 1, 1);
  return LoanModel(
    lenderID: 'lender',
    borrowerID: 'borrower',
    principalAmount: principal,
    interestRate: interestRate,
    interestType: 'simple',
    interestPeriod: 'monthly',
    startDate: start,
    dueDate: DateTime(start.year + 2, start.month, start.day),
    status: 'active',
    repaymentAmount: repaymentAmount,
    duration: duration,
    durationUnit: 'months',
    repaymentStartDay: repaymentStartDay,
    repaymentEndDay: repaymentEndDay,
  );
}

void main() {
  group('LoanScheduleCalculator.roundMoney', () {
    test('rounds to two decimal places', () {
      expect(LoanScheduleCalculator.roundMoney(15833.333333), 15833.33);
      expect(LoanScheduleCalculator.roundMoney(15833.336), 15833.34);
    });
  });

  group('LoanScheduleCalculator paid status', () {
    test('paying displayed EMI marks installment as paid, not partial', () {
      final loan = _testLoan();
      final schedule = LoanScheduleCalculator.build(
        loan,
        paidAggregate: 15833.33,
      );

      expect(schedule.monthlyEmi, 15833.33);
      expect(schedule.installments.first.status, InstallmentStatus.paid);
      expect(schedule.installments.first.paidAmount, isNull);
    });

    test('paying less than EMI marks installment as partial', () {
      final loan = _testLoan();
      final schedule = LoanScheduleCalculator.build(
        loan,
        paidAggregate: 8000,
      );

      final first = schedule.installments.first;
      expect(first.status, InstallmentStatus.partial);
      expect(first.paidAmount, 8000);
      expect(LoanScheduleCalculator.remainingDue(first), 7833.33);
    });

    test('paying more than one EMI applies waterfall to next installment', () {
      final loan = _testLoan();
      final emi = LoanScheduleCalculator.build(loan).monthlyEmi;
      final schedule = LoanScheduleCalculator.build(
        loan,
        paidAggregate: emi + 5000,
      );

      expect(schedule.installments[0].status, InstallmentStatus.paid);
      expect(schedule.installments[1].status, InstallmentStatus.partial);
      expect(schedule.installments[1].paidAmount, 5000);
    });

    test('installment amounts sum to total payable', () {
      final loan = _testLoan(principal: 100000, duration: 12);
      final schedule = LoanScheduleCalculator.build(loan);
      final sum = schedule.installments
          .fold<double>(0, (total, inst) => total + inst.amount);

      expect(LoanScheduleCalculator.roundMoney(sum), schedule.totalPayable);
    });
  });

  group('LoanScheduleCalculator calendar status', () {
    test('unpaid installment past window end is missed', () {
      final loan = _testLoan(
        startDate: DateTime(2025, 1, 1),
        repaymentStartDay: 1,
        repaymentEndDay: 10,
      );
      final asOf = DateTime(2026, 7, 3);
      final schedule = LoanScheduleCalculator.build(loan, asOf: asOf);

      expect(schedule.installments.first.status, InstallmentStatus.missed);
    });

    test('isInPaymentWindow is true when today is inside window', () {
      final loan = _testLoan(
        startDate: DateTime(2026, 5, 1),
        repaymentStartDay: 1,
        repaymentEndDay: 15,
      );
      final asOf = DateTime(2026, 7, 3);
      final schedule = LoanScheduleCalculator.build(loan, asOf: asOf);
      final current = schedule.installments[1];

      expect(
        LoanScheduleCalculator.isInPaymentWindow(current, asOf),
        isTrue,
      );
      expect(
        LoanScheduleCalculator.currentPayableInstallment(schedule, asOf),
        current,
      );
    });

    test('isInPaymentWindow is false outside window', () {
      final loan = _testLoan(
        startDate: DateTime(2026, 5, 1),
        repaymentStartDay: 1,
        repaymentEndDay: 15,
      );
      final asOf = DateTime(2026, 8, 20);
      final schedule = LoanScheduleCalculator.build(loan, asOf: asOf);
      final first = schedule.installments.first;

      expect(
        LoanScheduleCalculator.isInPaymentWindow(first, asOf),
        isFalse,
      );
    });

    test('early full payment before window shows pre-paid', () {
      final loan = _testLoan(
        startDate: DateTime(2026, 1, 1),
        repaymentStartDay: 1,
        repaymentEndDay: 15,
      );
      final emi = LoanScheduleCalculator.build(loan).monthlyEmi;
      final asOf = DateTime(2026, 1, 20);
      final schedule = LoanScheduleCalculator.build(
        loan,
        paidAggregate: emi,
        asOf: asOf,
      );

      expect(schedule.installments.first.status, InstallmentStatus.prepaid);
    });

    test('early partial payment before window shows pre-paid', () {
      final loan = _testLoan(
        startDate: DateTime(2026, 1, 1),
        repaymentStartDay: 1,
        repaymentEndDay: 15,
      );
      final asOf = DateTime(2026, 1, 20);
      final schedule = LoanScheduleCalculator.build(
        loan,
        paidAggregate: 8000,
        asOf: asOf,
      );

      expect(schedule.installments.first.status, InstallmentStatus.prepaid);
      expect(schedule.installments.first.paidAmount, 8000);
    });
  });
}
