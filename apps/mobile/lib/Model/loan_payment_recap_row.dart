/// Month-scoped loan payment row for recap ledger (F8).
class LoanPaymentRecapRow {
  const LoanPaymentRecapRow({
    required this.loanId,
    required this.counterparty,
    required this.amount,
    required this.paidAt,
  });

  final String loanId;
  final String counterparty;
  final double amount;
  final DateTime paidAt;

  Map<String, dynamic> toLedgerMap() => {
        'loanId': loanId,
        'counterparty': counterparty,
        'amount': amount,
        'paidAt': paidAt.toIso8601String(),
      };

  static LoanPaymentRecapRow fromLedgerMap(Map<String, dynamic> map) {
    return LoanPaymentRecapRow(
      loanId: map['loanId'] as String? ?? '',
      counterparty: map['counterparty'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      paidAt: DateTime.tryParse(map['paidAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
