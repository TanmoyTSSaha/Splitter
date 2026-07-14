import 'package:splitr/Controller/settle_up_controller.dart';

/// Counterparty user id for a simplified debt relative to [currentUserId].
String counterpartyIdForDebt(SimplifiedDebt debt, String currentUserId) {
  return debt.fromID == currentUserId ? debt.toID : debt.fromID;
}

/// Finds an open debt between [currentUserId] and [counterpartyId], either direction.
SimplifiedDebt? findDebtForCounterparty({
  required List<SimplifiedDebt> debts,
  required String currentUserId,
  required String counterpartyId,
}) {
  for (final d in debts) {
    if (d.fromID == currentUserId && d.toID == counterpartyId) {
      return d;
    }
    if (d.fromID == counterpartyId && d.toID == currentUserId) {
      return d;
    }
  }
  return null;
}

/// True when [currentUserId] owes [counterpartyId] (payer → payee).
bool isCurrentUserDebtor({
  required List<SimplifiedDebt> debts,
  required String currentUserId,
  required String counterpartyId,
}) {
  return debts.any(
    (d) => d.fromID == currentUserId && d.toID == counterpartyId,
  );
}

/// Builds a settlement record preserving payer/payee from [relevantDebt].
SimplifiedDebt buildSettlementDebt({
  required SimplifiedDebt relevantDebt,
  required double amount,
}) {
  return SimplifiedDebt(
    fromID: relevantDebt.fromID,
    fromName: relevantDebt.fromName,
    toID: relevantDebt.toID,
    toName: relevantDebt.toName,
    amount: amount,
  );
}
