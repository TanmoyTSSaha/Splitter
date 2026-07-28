import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Utils/transaction_date_formatter.dart';
import 'package:uuid/uuid.dart';

class BuiltGroupExpenseRow {
  final String transactionId;
  final String transactionGroupId;
  final String groupId;
  final String paidBy;
  final String sharedWith;
  final double totalTransactionAmount;
  final double sharedTransactionAmount;
  final double sharedPercentage;
  final double selfShareAmount;
  final double selfSharePercentage;
  final String sharingType;
  final String? category;
  final String? description;
  final String? transactionNote;
  final DateTime transactionDate;
  final Map<String, dynamic> syncPayload;

  const BuiltGroupExpenseRow({
    required this.transactionId,
    required this.transactionGroupId,
    required this.groupId,
    required this.paidBy,
    required this.sharedWith,
    required this.totalTransactionAmount,
    required this.sharedTransactionAmount,
    required this.sharedPercentage,
    required this.selfShareAmount,
    required this.selfSharePercentage,
    required this.sharingType,
    required this.category,
    required this.description,
    required this.transactionNote,
    required this.transactionDate,
    required this.syncPayload,
  });
}

class GroupExpenseBuilder {
  static const _uuid = Uuid();

  static List<BuiltGroupExpenseRow> buildExpenseRows({
    required String groupId,
    required String paidByUserId,
    required double totalAmount,
    required String description,
    required String category,
    required Map<String, double> splits,
    required String currency,
    double exchangeRateToInr = CurrencyDefaults.exchangeRateToInr,
    String? note,
    String sharingType = SharingTypeValues.evenly,
    DateTime? transactionDate,
  }) {
    final transactionGroupId = IdFormatters.transactionGroupId(groupId);
    final txDate = transactionDate ?? DateTime.now();
    final sharedSum = splits.values
        .fold<double>(0, (previous, current) => previous + current);
    final selfShare = totalAmount - sharedSum;

    final rawRows = <Map<String, dynamic>>[];

    splits.forEach((sharedWithUserId, amount) {
      if (amount > 0) {
        rawRows.add({
          SupabaseColumns.sharedWith: sharedWithUserId,
          SupabaseColumns.sharedTransactionAmount: amount,
          SupabaseColumns.sharedPercentage:
              totalAmount > 0 ? (amount / totalAmount) * 100 : 0,
          SupabaseColumns.isSettledUp: false,
        });
      }
    });

    if (rawRows.isEmpty) {
      rawRows.add({
        SupabaseColumns.sharedWith: paidByUserId,
        SupabaseColumns.sharedTransactionAmount: 0.0,
        SupabaseColumns.sharedPercentage: 0.0,
        SupabaseColumns.isSettledUp: true,
      });
    }

    return rawRows.map((row) {
      final transactionId = _uuid.v4();
      final sharedWith = row[SupabaseColumns.sharedWith] as String;
      final sharedAmount =
          (row[SupabaseColumns.sharedTransactionAmount] as num).toDouble();
      final payload = {
        SupabaseColumns.transactionId: transactionId,
        SupabaseColumns.transactionGroupId: transactionGroupId,
        SupabaseColumns.groupId: groupId,
        SupabaseColumns.paidBy: paidByUserId,
        SupabaseColumns.sharedWith: sharedWith,
        SupabaseColumns.totalTransactionAmount: totalAmount,
        SupabaseColumns.sharedTransactionAmount: sharedAmount,
        SupabaseColumns.sharedPercentage: row[SupabaseColumns.sharedPercentage],
        SupabaseColumns.selfShareAmount: selfShare,
        SupabaseColumns.selfSharePercentage:
            totalAmount > 0 ? (selfShare / totalAmount) * 100 : 0,
        SupabaseColumns.sharingType: sharingType,
        SupabaseColumns.category: category,
        SupabaseColumns.description: description,
        SupabaseColumns.transactionNote: note,
        SupabaseColumns.currency: currency,
        SupabaseColumns.exchangeRateToInr: exchangeRateToInr,
        SupabaseColumns.isSettledUp: row[SupabaseColumns.isSettledUp],
        SupabaseColumns.transactionDate:
            TransactionDateFormatter.toStorageIso(txDate),
      };

      return BuiltGroupExpenseRow(
        transactionId: transactionId,
        transactionGroupId: transactionGroupId,
        groupId: groupId,
        paidBy: paidByUserId,
        sharedWith: sharedWith,
        totalTransactionAmount: totalAmount,
        sharedTransactionAmount: sharedAmount,
        sharedPercentage:
            (row[SupabaseColumns.sharedPercentage] as num).toDouble(),
        selfShareAmount: selfShare,
        selfSharePercentage:
            totalAmount > 0 ? (selfShare / totalAmount) * 100 : 0,
        sharingType: sharingType,
        category: category,
        description: description,
        transactionNote: note,
        transactionDate: txDate,
        syncPayload: payload,
      );
    }).toList();
  }

  static BuiltGroupExpenseRow buildSettlementRow({
    required String groupId,
    required String fromUserId,
    required String toUserId,
    required double amount,
    required String currency,
    double exchangeRateToInr = CurrencyDefaults.exchangeRateToInr,
    DateTime? transactionDate,
  }) {
    final transactionGroupId = IdFormatters.transactionGroupId(groupId);
    final transactionId = _uuid.v4();
    final txDate = transactionDate ?? DateTime.now();
    final payload = {
      SupabaseColumns.transactionId: transactionId,
      SupabaseColumns.transactionGroupId: transactionGroupId,
      SupabaseColumns.groupId: groupId,
      SupabaseColumns.paidBy: fromUserId,
      SupabaseColumns.sharedWith: toUserId,
      SupabaseColumns.totalTransactionAmount: amount,
      SupabaseColumns.sharedTransactionAmount: amount,
      SupabaseColumns.sharedPercentage: 100.0,
      SupabaseColumns.selfShareAmount: 0.0,
      SupabaseColumns.selfSharePercentage: 0.0,
      SupabaseColumns.sharingType: SharingTypeValues.settlement,
      SupabaseColumns.category: CategoryDefaults.settlement,
      SupabaseColumns.description: CategoryDefaults.settlementPayment,
      SupabaseColumns.currency: currency,
      SupabaseColumns.exchangeRateToInr: exchangeRateToInr,
      SupabaseColumns.isSettledUp: true,
      SupabaseColumns.transactionDate:
          TransactionDateFormatter.toStorageIso(txDate),
    };

    return BuiltGroupExpenseRow(
      transactionId: transactionId,
      transactionGroupId: transactionGroupId,
      groupId: groupId,
      paidBy: fromUserId,
      sharedWith: toUserId,
      totalTransactionAmount: amount,
      sharedTransactionAmount: amount,
      sharedPercentage: 100,
      selfShareAmount: 0,
      selfSharePercentage: 0,
      sharingType: SharingTypeValues.settlement,
      category: CategoryDefaults.settlement,
      description: CategoryDefaults.settlementPayment,
      transactionNote: null,
      transactionDate: txDate,
      syncPayload: payload,
    );
  }
}
