import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Model/loan_model.dart';
import 'package:splitr/Model/loan_payment_recap_row.dart';
import 'package:splitr/Services/monthly_recap_aggregator.dart';
void main() {
  test('computeLendingSnapshot returns inactive when no loans', () {
    final snapshot = MonthlyRecapAggregator.computeLendingSnapshot(
      [],
      'user-1',
      DateTime(2026, 7, 1),
    );

    expect(snapshot[RecapDataKeys.hasLendingActivity], isFalse);
  });

  test('computeLendingSnapshot surfaces active loan metrics', () {
    final month = DateTime(2026, 7, 15);
    final loan = LoanModel(
      id: 'loan-1',
      lenderID: 'user-1',
      borrowerID: 'user-2',
      principalAmount: 1000,
      repaymentAmount: 250,
      startDate: DateTime(2026, 1, 1),
      status: LoanStatusValues.active,
      borrowerName: 'Alex',
      updatedAt: DateTime(2026, 7, 10),
    );

    final snapshot = MonthlyRecapAggregator.computeLendingSnapshot(
      [loan],
      'user-1',
      month,
    );

    expect(snapshot[RecapDataKeys.hasLendingActivity], isTrue);
    expect(snapshot[RecapDataKeys.activeLoanCount], 1);
    expect(snapshot[RecapDataKeys.topLoanTitle], 'Alex');
    expect(snapshot[RecapDataKeys.loansWithPaymentThisMonth], 1);
  });

  test('computeLendingSnapshot sums payment rows and builds ledger', () {
    final month = DateTime(2026, 7, 15);
    final loan = LoanModel(
      id: 'loan-1',
      lenderID: 'user-1',
      borrowerID: 'user-2',
      principalAmount: 1000,
      repaymentAmount: 350,
      startDate: DateTime(2026, 1, 1),
      status: LoanStatusValues.active,
      borrowerName: 'Alex',
    );
    final payments = [
      LoanPaymentRecapRow(
        loanId: 'loan-1',
        counterparty: 'Alex',
        amount: 100,
        paidAt: DateTime(2026, 7, 5),
      ),
      LoanPaymentRecapRow(
        loanId: 'loan-1',
        counterparty: 'Alex',
        amount: 50,
        paidAt: DateTime(2026, 7, 20),
      ),
    ];

    final snapshot = MonthlyRecapAggregator.computeLendingSnapshot(
      [loan],
      'user-1',
      month,
      payments: payments,
    );

    expect(snapshot[RecapDataKeys.totalRepaidThisMonth], 150);
    final ledger = snapshot[RecapDataKeys.lendingLedgerRows] as List;
    expect(ledger.length, 2);
    expect(ledger.first['amount'], 50);
  });
}
