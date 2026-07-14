import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Model/group_model.dart';

/// One directed settlement after greedy debt minimization.
class DebtTransfer {
  final String fromId;
  final String toId;
  final double amount;

  const DebtTransfer({
    required this.fromId,
    required this.toId,
    required this.amount,
  });
}

/// Greedy debt simplification: net balances, match largest creditor/debtor.
List<DebtTransfer> simplifyGroupDebts(List<GroupBalanceModel> balances) {
  final netBalance = <String, double>{};

  for (final balance in balances) {
    final donorID = balance.donorID!;
    final receiverID = balance.receiverID!;
    final amount = balance.amount!;

    netBalance[donorID] = (netBalance[donorID] ?? 0.0) + amount;
    netBalance[receiverID] = (netBalance[receiverID] ?? 0.0) - amount;
  }

  final creditors = <MapEntry<String, double>>[];
  final debtors = <MapEntry<String, double>>[];

  netBalance.forEach((id, amount) {
    final rounded = double.parse(amount.toStringAsFixed(2));
    if (rounded > MoneyEpsilon.balanceSettled) {
      creditors.add(MapEntry(id, rounded));
    } else if (rounded < -MoneyEpsilon.balanceSettled) {
      debtors.add(MapEntry(id, rounded.abs()));
    }
  });

  creditors.sort((a, b) => b.value.compareTo(a.value));
  debtors.sort((a, b) => b.value.compareTo(a.value));

  final result = <DebtTransfer>[];
  var i = 0;
  var j = 0;

  while (i < creditors.length && j < debtors.length) {
    final settleAmount = creditors[i].value <= debtors[j].value
        ? creditors[i].value
        : debtors[j].value;

    result.add(DebtTransfer(
      fromId: debtors[j].key,
      toId: creditors[i].key,
      amount: double.parse(settleAmount.toStringAsFixed(2)),
    ));

    creditors[i] = MapEntry(
      creditors[i].key,
      double.parse((creditors[i].value - settleAmount).toStringAsFixed(2)),
    );
    debtors[j] = MapEntry(
      debtors[j].key,
      double.parse((debtors[j].value - settleAmount).toStringAsFixed(2)),
    );

    if (creditors[i].value < MoneyEpsilon.balanceSettled) i++;
    if (debtors[j].value < MoneyEpsilon.balanceSettled) j++;
  }

  return result;
}
