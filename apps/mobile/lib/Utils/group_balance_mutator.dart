import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/domain_values.dart';

/// Pure helpers for mutating group_balance JSON arrays offline.
List<Map<String, dynamic>> cloneBalances(List<Map<String, dynamic>> balances) =>
    balances.map((e) => Map<String, dynamic>.from(e)).toList();

void applyDebtEntry(
  List<Map<String, dynamic>> balances, {
  required String donorId,
  required String receiverId,
  required double amountToAdd,
}) {
  if (amountToAdd <= 0 || donorId == receiverId) return;

  final index = balances.indexWhere(
    (element) =>
        element[GroupBalanceKeys.donorId] == donorId &&
        element[GroupBalanceKeys.receiverId] == receiverId,
  );

  if (index != -1) {
    final newAmount =
        double.parse(balances[index][GroupBalanceKeys.amount].toString()) +
            amountToAdd;
    balances[index][GroupBalanceKeys.amount] =
        double.parse(newAmount.toStringAsFixed(2));
    return;
  }

  final reverseIndex = balances.indexWhere(
    (element) =>
        element[GroupBalanceKeys.donorId] == receiverId &&
        element[GroupBalanceKeys.receiverId] == donorId,
  );

  if (reverseIndex != -1) {
    final reverseAmount = double.parse(
        balances[reverseIndex][GroupBalanceKeys.amount].toString());

    if (amountToAdd > reverseAmount) {
      final diff = amountToAdd - reverseAmount;
      balances.removeAt(reverseIndex);
      balances.add({
        GroupBalanceKeys.donor: '${BalanceDisplayPrefixes.userId}$donorId',
        GroupBalanceKeys.donorId: donorId,
        GroupBalanceKeys.receiver:
            '${BalanceDisplayPrefixes.userId}$receiverId',
        GroupBalanceKeys.receiverId: receiverId,
        GroupBalanceKeys.amount: double.parse(diff.toStringAsFixed(2)),
      });
    } else if (amountToAdd < reverseAmount) {
      final remaining = reverseAmount - amountToAdd;
      balances[reverseIndex][GroupBalanceKeys.amount] =
          double.parse(remaining.toStringAsFixed(2));
    } else {
      balances.removeAt(reverseIndex);
    }
    return;
  }

  balances.add({
    GroupBalanceKeys.donor: '${BalanceDisplayPrefixes.userId}$donorId',
    GroupBalanceKeys.donorId: donorId,
    GroupBalanceKeys.receiver: '${BalanceDisplayPrefixes.userId}$receiverId',
    GroupBalanceKeys.receiverId: receiverId,
    GroupBalanceKeys.amount: double.parse(amountToAdd.toStringAsFixed(2)),
  });
}

List<Map<String, dynamic>> applySplitDebts({
  required List<Map<String, dynamic>> balances,
  required String payerId,
  required Map<String, double> splits,
}) {
  final result = cloneBalances(balances);
  splits.forEach((userId, amount) {
    if (userId != payerId && amount > 0) {
      applyDebtEntry(
        result,
        donorId: payerId,
        receiverId: userId,
        amountToAdd: amount,
      );
    }
  });
  return result;
}

List<Map<String, dynamic>> applySettlement({
  required List<Map<String, dynamic>> balances,
  required String fromUserId,
  required String toUserId,
  required double amount,
}) {
  final result = <Map<String, dynamic>>[];

  for (final elm in balances) {
    final donorId = elm[GroupBalanceKeys.donorId].toString();
    final receiverId = elm[GroupBalanceKeys.receiverId].toString();
    final existingAmount =
        double.parse(elm[GroupBalanceKeys.amount].toString());

    if (donorId == toUserId && receiverId == fromUserId) {
      final remaining = existingAmount - amount;
      if (remaining > MoneyEpsilon.balanceSettled) {
        result.add({
          GroupBalanceKeys.donor: elm[GroupBalanceKeys.donor],
          GroupBalanceKeys.donorId: donorId,
          GroupBalanceKeys.receiver: elm[GroupBalanceKeys.receiver],
          GroupBalanceKeys.receiverId: receiverId,
          GroupBalanceKeys.amount: double.parse(remaining.toStringAsFixed(2)),
        });
      }
    } else {
      result.add(Map<String, dynamic>.from(elm));
    }
  }

  return result;
}
