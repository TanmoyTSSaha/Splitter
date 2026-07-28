import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Controller/settle_up_controller.dart';
import 'package:splitr/Utils/settle_debt_resolver.dart';

void main() {
  group('settle_debt_resolver', () {
    const alice = 'alice';
    const bob = 'bob';

    final debtorDebt = SimplifiedDebt(
      fromID: alice,
      fromName: 'Alice',
      toID: bob,
      toName: 'Bob',
      amount: 250,
    );

    final creditorDebt = SimplifiedDebt(
      fromID: bob,
      fromName: 'Bob',
      toID: alice,
      toName: 'Alice',
      amount: 180,
    );

    test('counterpartyIdForDebt returns payee when user is debtor', () {
      expect(counterpartyIdForDebt(debtorDebt, alice), bob);
    });

    test('counterpartyIdForDebt returns payer when user is creditor', () {
      expect(counterpartyIdForDebt(creditorDebt, alice), bob);
    });

    test('findDebtForCounterparty resolves debtor direction', () {
      final found = findDebtForCounterparty(
        debts: [debtorDebt],
        currentUserId: alice,
        counterpartyId: bob,
      );
      expect(found, debtorDebt);
    });

    test('findDebtForCounterparty resolves creditor direction', () {
      final found = findDebtForCounterparty(
        debts: [creditorDebt],
        currentUserId: alice,
        counterpartyId: bob,
      );
      expect(found, creditorDebt);
    });

    test('isCurrentUserDebtor true only when user owes counterparty', () {
      expect(
        isCurrentUserDebtor(
          debts: [debtorDebt],
          currentUserId: alice,
          counterpartyId: bob,
        ),
        isTrue,
      );
      expect(
        isCurrentUserDebtor(
          debts: [creditorDebt],
          currentUserId: alice,
          counterpartyId: bob,
        ),
        isFalse,
      );
    });

    test('buildSettlementDebt preserves payer and payee', () {
      final built = buildSettlementDebt(
        relevantDebt: creditorDebt,
        amount: 100,
      );
      expect(built.fromID, bob);
      expect(built.toID, alice);
      expect(built.amount, 100);
    });
  });
}
