import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Model/group_model.dart';
import 'package:splitr/Utils/debt_simplifier.dart';

GroupBalanceModel _balance(String donor, String receiver, double amount) {
  return GroupBalanceModel(
    donorID: donor,
    receiverID: receiver,
    amount: amount,
  );
}

void main() {
  test('simplifyGroupDebts collapses triangle to two transfers', () {
    // A paid 100 for B, B paid 60 for C → net: A +100, B -40, C -60
    final balances = [
      _balance('A', 'B', 100),
      _balance('B', 'C', 60),
    ];

    final transfers = simplifyGroupDebts(balances);

    expect(transfers.length, 2);
    expect(transfers.map((t) => t.amount).reduce((a, b) => a + b), 100);
    expect(
      transfers.any((t) => t.fromId == 'C' && t.toId == 'A' && t.amount == 60),
      isTrue,
    );
    expect(
      transfers.any((t) => t.fromId == 'B' && t.toId == 'A' && t.amount == 40),
      isTrue,
    );
  });

  test('simplifyGroupDebts returns empty when balances net zero', () {
    final balances = [
      _balance('A', 'B', 50),
      _balance('B', 'A', 50),
    ];

    expect(simplifyGroupDebts(balances), isEmpty);
  });
}
