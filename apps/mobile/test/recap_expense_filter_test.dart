import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Services/SupabaseServices/transaction_service.dart';

void main() {
  test('countsAsRecapExpense excludes income and settlement categories', () {
    expect(TransactionService.countsAsRecapExpense('salary'), isFalse);
    expect(TransactionService.countsAsRecapExpense('income'), isFalse);
    expect(TransactionService.countsAsRecapExpense('refund'), isFalse);
    expect(TransactionService.countsAsRecapExpense('cashback'), isFalse);
    expect(
      TransactionService.countsAsRecapExpense(CategoryDefaults.settlement),
      isFalse,
    );
    expect(TransactionService.countsAsRecapExpense('Food'), isTrue);
    expect(TransactionService.countsAsRecapExpense('travel'), isTrue);
  });
}
