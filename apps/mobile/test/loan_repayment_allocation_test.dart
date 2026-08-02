import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Model/loan_model.dart';
import 'package:splitr/Model/repayment_schedule.dart';

LoanModel _activeLoan({
  required double principal,
  required double rate,
  required double repaymentAmount,
  String interestType = LoanInterestTypes.simple,
}) {
  return LoanModel(
    lenderID: 'lender',
    borrowerID: 'borrower',
    principalAmount: principal,
    interestRate: rate,
    interestType: interestType,
    interestPeriod: LoanFrequencyValues.monthly,
    startDate: DateTime(2026, 1, 1),
    dueDate: DateTime(2026, 7, 1),
    status: LoanStatusValues.active,
    repaymentAmount: repaymentAmount,
    duration: 6,
    durationUnit: LoanDurationUnits.months,
  );
}

void main() {
  group('LoanRepaymentAllocation', () {
    test('total remaining includes principal and full-term interest', () {
      final loan = _activeLoan(principal: 10000, rate: 12, repaymentAmount: 0);
      final allocation = LoanScheduleCalculator.allocation(loan);

      expect(allocation.totalPayable, greaterThan(allocation.principal));
      expect(loan.currentAmountOwed, allocation.totalRemaining);
      expect(loan.totalContractPayable, allocation.totalPayable);
    });

    test('payments split proportionally into principal and interest paid', () {
      final loan = _activeLoan(
        principal: 10000,
        rate: 12,
        repaymentAmount: 300,
      );
      final allocation = LoanScheduleCalculator.allocation(loan);

      expect(allocation.principalPaid, greaterThan(0));
      expect(allocation.interestPaid, greaterThan(0));
      expect(
        allocation.principalPaid + allocation.interestPaid,
        closeTo(300, 0.01),
      );
      expect(allocation.totalRemaining,
          closeTo(allocation.totalPayable - 300, 0.01));
    });

    test('progress bar segments cover principal, interest, and remaining', () {
      final loan = LoanModel(
        lenderID: 'lender',
        borrowerID: 'borrower',
        principalAmount: 100000,
        interestRate: 7.5,
        interestType: LoanInterestTypes.simple,
        interestPeriod: LoanFrequencyValues.monthly,
        startDate: DateTime(2026, 1, 1),
        dueDate: DateTime(2027, 6, 30),
        status: LoanStatusValues.active,
        repaymentAmount: 31666,
        duration: 1,
        durationUnit: LoanDurationUnits.years,
      );
      final allocation = LoanScheduleCalculator.allocation(loan);

      expect(allocation.principalPaid, greaterThan(0));
      expect(allocation.interestPaid, greaterThan(0));
      expect(allocation.totalRemaining, greaterThan(0));
      expect(
        allocation.principalPaid +
            allocation.interestPaid +
            allocation.totalRemaining,
        closeTo(allocation.totalPayable, 0.01),
      );
    });
  });
}
