import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Model/group_model.dart';
import 'package:splitr/Model/product_category_model.dart';
import 'package:splitr/Services/local/database.dart';
import 'package:splitr/Services/sync_service.dart';
import 'package:splitr/Services/SupabaseServices/group_service.dart';
import 'package:splitr/Services/SupabaseServices/transaction_service.dart';
import 'package:splitr/Utils/group_balance_mutator.dart';
import 'package:splitr/Utils/group_expense_builder.dart';
import 'package:splitr/Utils/transaction_date_formatter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository layer for transactions — reads from local DB, writes to local + sync queue.
class TransactionRepository {
  final AppDatabase _db;
  final SyncService _syncService;
  final SupabaseClient _supabase = Supabase.instance.client;
  final GroupService _groupService = GroupService();
  final TransactionService _transactionService = TransactionService();

  TransactionRepository(this._db, this._syncService);

  /// Enrich local rows with user names and category logos for UI display.
  Future<List<GroupTransactionModel>> toGroupTransactionModels(
      List<LocalGroupTransaction> localRows) async {
    if (localRows.isEmpty) return [];

    final categories = <String>{};
    final userIds = <String>{};
    for (final row in localRows) {
      if (row.category != null) categories.add(row.category!);
      userIds.add(row.paidBy);
      userIds.add(row.sharedWith);
    }

    final results = await Future.wait([
      _supabase
          .from(SupabaseTables.masterProductCategory)
          .select(
              '${SupabaseColumns.category}, ${SupabaseColumns.categoryLogo}')
          .inFilter(SupabaseColumns.category, categories.toList()),
      _supabase
          .from(SupabaseTables.users)
          .select(
              '${SupabaseColumns.userId}, ${SupabaseColumns.firstname}, ${SupabaseColumns.lastname}')
          .inFilter(SupabaseColumns.userId, userIds.toList()),
    ]);

    final categoryLogoMap = <String, String>{};
    for (final row in results[0] as List<dynamic>) {
      categoryLogoMap[row[SupabaseColumns.category] as String] =
          row[SupabaseColumns.categoryLogo] as String;
    }

    final userNameMap = <String, String>{};
    for (final row in results[1] as List<dynamic>) {
      final first = row[SupabaseColumns.firstname] ?? StringDefaults.empty;
      final last = row[SupabaseColumns.lastname] ?? StringDefaults.empty;
      userNameMap[row[SupabaseColumns.userId] as String] =
          DisplayFormatters.joinFirstLast(first, last);
    }

    return localRows.map((row) {
      final paidByName = userNameMap[row.paidBy] ?? DisplayFallbacks.unknown;
      final sharedWithName =
          userNameMap[row.sharedWith] ?? DisplayFallbacks.unknown;
      final categoryLogo =
          categoryLogoMap[row.category ?? StringDefaults.empty] ??
              StringDefaults.empty;

      return GroupTransactionModel.fromJSON(
        {
          SupabaseColumns.transactionId: row.transactionId,
          SupabaseColumns.transactionGroupId: row.transactionGroupId,
          SupabaseColumns.groupId: row.groupId,
          SupabaseColumns.paidBy: row.paidBy,
          SupabaseColumns.sharedWith: row.sharedWith,
          SupabaseColumns.totalTransactionAmount: row.totalTransactionAmount,
          SupabaseColumns.sharedTransactionAmount: row.sharedTransactionAmount,
          SupabaseColumns.sharedPercentage: row.sharedPercentage,
          SupabaseColumns.selfShareAmount: row.selfShareAmount,
          SupabaseColumns.selfSharePercentage: row.selfSharePercentage,
          SupabaseColumns.sharingType: row.sharingType,
          SupabaseColumns.category: row.category,
          SupabaseColumns.description: row.description,
          SupabaseColumns.transactionPhoto: row.transactionPhoto,
          SupabaseColumns.transactionNote: row.transactionNote,
          SupabaseColumns.isSettledUp: row.isSettledUp,
          SupabaseColumns.transactionDate: row.transactionDate ??
              TransactionDateFormatter.nowForTransaction(),
        },
        paidByName,
        sharedWithName,
        categoryLogo,
      );
    }).toList();
  }

  /// Watch group transactions reactively.
  Stream<List<LocalGroupTransaction>> watchTransactions(String groupId) =>
      _db.watchTransactionsForGroup(groupId);

  /// Get all transactions for a group (one-shot).
  Future<List<LocalGroupTransaction>> getTransactions(String groupId) =>
      _db.getTransactionsForGroup(groupId);

  /// Refresh transactions from Supabase for a group.
  Future<void> refreshFromServer(String groupId) async {
    try {
      final rows = await _supabase
          .from(SupabaseTables.groupTransaction)
          .select()
          .eq(SupabaseColumns.groupId, groupId);

      for (final row in rows) {
        await _db
            .into(_db.localGroupTransactions)
            .insertOnConflictUpdate(LocalGroupTransactionsCompanion(
              transactionId:
                  Value(row[SupabaseColumns.transactionId] as String),
              transactionGroupId:
                  Value(row[SupabaseColumns.transactionGroupId] as String),
              groupId: Value(row[SupabaseColumns.groupId] as String),
              paidBy: Value(row[SupabaseColumns.paidBy] as String),
              sharedWith: Value(row[SupabaseColumns.sharedWith] as String),
              totalTransactionAmount: Value(double.parse(
                  row[SupabaseColumns.totalTransactionAmount].toString())),
              sharedTransactionAmount: Value(double.parse(
                  row[SupabaseColumns.sharedTransactionAmount].toString())),
              sharedPercentage: Value(double.parse(
                  row[SupabaseColumns.sharedPercentage].toString())),
              selfShareAmount: Value(double.parse(
                  row[SupabaseColumns.selfShareAmount].toString())),
              selfSharePercentage: Value(double.parse(
                  row[SupabaseColumns.selfSharePercentage].toString())),
              sharingType: Value(row[SupabaseColumns.sharingType] as String? ??
                  SharingTypeValues.evenly),
              category: Value(row[SupabaseColumns.category] as String?),
              description: Value(row[SupabaseColumns.description] as String?),
              transactionPhoto:
                  Value(row[SupabaseColumns.transactionPhoto] as String?),
              transactionNote:
                  Value(row[SupabaseColumns.transactionNote] as String?),
              isSettledUp:
                  Value(row[SupabaseColumns.isSettledUp] as bool? ?? false),
              transactionDate: Value(TransactionDateFormatter.parseStorage(
                  row[SupabaseColumns.transactionDate])),
              syncStatus: const Value(SyncStatusValues.synced),
            ));
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Add a group transaction locally + enqueue sync.
  Future<void> addTransaction({
    required String transactionId,
    required String transactionGroupId,
    required String groupId,
    required String paidBy,
    required String sharedWith,
    required double totalTransactionAmount,
    required double sharedTransactionAmount,
    required double sharedPercentage,
    required double selfShareAmount,
    required double selfSharePercentage,
    required String sharingType,
    String? category,
    String? description,
    String? transactionPhoto,
    String? transactionNote,
    DateTime? transactionDate,
  }) async {
    final now = transactionDate ?? TransactionDateFormatter.nowForTransaction();

    // Save locally
    await _db
        .into(_db.localGroupTransactions)
        .insertOnConflictUpdate(LocalGroupTransactionsCompanion(
          transactionId: Value(transactionId),
          transactionGroupId: Value(transactionGroupId),
          groupId: Value(groupId),
          paidBy: Value(paidBy),
          sharedWith: Value(sharedWith),
          totalTransactionAmount: Value(totalTransactionAmount),
          sharedTransactionAmount: Value(sharedTransactionAmount),
          sharedPercentage: Value(sharedPercentage),
          selfShareAmount: Value(selfShareAmount),
          selfSharePercentage: Value(selfSharePercentage),
          sharingType: Value(sharingType),
          category: Value(category),
          description: Value(description),
          transactionPhoto: Value(transactionPhoto),
          transactionNote: Value(transactionNote),
          isSettledUp: const Value(false),
          transactionDate: Value(now),
          syncStatus: const Value(SyncStatusValues.pending),
        ));

    // Enqueue for sync
    await _syncService.enqueue(
      tableName: SupabaseTables.groupTransaction,
      operation: SyncOperations.insert,
      recordId: transactionId,
      payload: {
        SupabaseColumns.transactionId: transactionId,
        SupabaseColumns.transactionGroupId: transactionGroupId,
        SupabaseColumns.groupId: groupId,
        SupabaseColumns.paidBy: paidBy,
        SupabaseColumns.sharedWith: sharedWith,
        SupabaseColumns.totalTransactionAmount: totalTransactionAmount,
        SupabaseColumns.sharedTransactionAmount: sharedTransactionAmount,
        SupabaseColumns.sharedPercentage: sharedPercentage,
        SupabaseColumns.selfShareAmount: selfShareAmount,
        SupabaseColumns.selfSharePercentage: selfSharePercentage,
        SupabaseColumns.sharingType: sharingType,
        SupabaseColumns.category: category,
        SupabaseColumns.description: description,
        SupabaseColumns.transactionPhoto: transactionPhoto,
        SupabaseColumns.transactionNote: transactionNote,
        SupabaseColumns.transactionDate:
            TransactionDateFormatter.toStorageIso(now),
      },
    );
  }

  /// Create a split expense on the server and refresh the local group cache.
  Future<void> addGroupExpense({
    required String groupID,
    required String paidByUserID,
    required double totalAmount,
    required String description,
    required String category,
    required Map<String, double> splits,
    required String currency,
    String? note,
    String sharingType = SharingTypeValues.evenly,
    DateTime? transactionDate,
  }) async {
    final txDate =
        transactionDate ?? TransactionDateFormatter.nowForTransaction();
    if (await _hasConnectivity()) {
      try {
        await _groupService.addGroupExpense(
          groupID: groupID,
          paidByUserID: paidByUserID,
          totalAmount: totalAmount,
          description: description,
          category: category,
          splits: splits,
          currency: currency,
          note: note,
          sharingType: sharingType,
          transactionDate: txDate,
        );
        await refreshFromServer(groupID);
        return;
      } catch (_) {
        // Queue locally when the network call fails.
      }
    }

    await _queueGroupExpense(
      groupID: groupID,
      paidByUserID: paidByUserID,
      totalAmount: totalAmount,
      description: description,
      category: category,
      splits: splits,
      currency: currency,
      note: note,
      sharingType: sharingType,
      transactionDate: txDate,
    );
  }

  /// Record a settlement locally and enqueue sync when offline or on failure.
  Future<void> recordSettlement({
    required String groupID,
    required String fromUserID,
    required String toUserID,
    required double amount,
    required String currency,
    double exchangeRateToInr = CurrencyDefaults.exchangeRateToInr,
    DateTime? transactionDate,
  }) async {
    final txDate =
        transactionDate ?? TransactionDateFormatter.nowForTransaction();
    if (await _hasConnectivity()) {
      var serverRecorded = false;
      try {
        await _groupService.recordSettlement(
          groupID: groupID,
          fromUserID: fromUserID,
          toUserID: toUserID,
          amount: amount,
          currency: currency,
          transactionDate: txDate,
        );
        serverRecorded = true;
        try {
          await refreshFromServer(groupID);
        } catch (_) {
          // Settlement already persisted; local cache refresh is best-effort.
        }
        return;
      } catch (_) {
        if (serverRecorded) return;
        // Queue locally when the network call fails.
      }
    }

    final row = GroupExpenseBuilder.buildSettlementRow(
      groupId: groupID,
      fromUserId: fromUserID,
      toUserId: toUserID,
      amount: amount,
      currency: currency,
      exchangeRateToInr: exchangeRateToInr,
      transactionDate: txDate,
    );

    await addTransaction(
      transactionId: row.transactionId,
      transactionGroupId: row.transactionGroupId,
      groupId: row.groupId,
      paidBy: row.paidBy,
      sharedWith: row.sharedWith,
      totalTransactionAmount: row.totalTransactionAmount,
      sharedTransactionAmount: row.sharedTransactionAmount,
      sharedPercentage: row.sharedPercentage,
      selfShareAmount: row.selfShareAmount,
      selfSharePercentage: row.selfSharePercentage,
      sharingType: row.sharingType,
      category: row.category,
      description: row.description,
      transactionDate: row.transactionDate,
    );

    final balances = await _readLocalBalances(groupID);
    final updated = applySettlement(
      balances: balances,
      fromUserId: fromUserID,
      toUserId: toUserID,
      amount: amount,
    );
    await _enqueueGroupBalanceUpdate(groupID, updated);
  }

  Future<bool> _hasConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<List<Map<String, dynamic>>> _readLocalBalances(String groupId) async {
    final local = await _db.getGroupById(groupId);
    if (local == null || local.groupBalance.isEmpty) return [];
    final decoded = jsonDecode(local.groupBalance);
    if (decoded is! List) return [];
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> _queueGroupExpense({
    required String groupID,
    required String paidByUserID,
    required double totalAmount,
    required String description,
    required String category,
    required Map<String, double> splits,
    required String currency,
    String? note,
    String sharingType = SharingTypeValues.evenly,
    DateTime? transactionDate,
  }) async {
    final rows = GroupExpenseBuilder.buildExpenseRows(
      groupId: groupID,
      paidByUserId: paidByUserID,
      totalAmount: totalAmount,
      description: description,
      category: category,
      splits: splits,
      currency: currency,
      note: note,
      sharingType: sharingType,
      transactionDate: transactionDate,
    );

    for (final row in rows) {
      await addTransaction(
        transactionId: row.transactionId,
        transactionGroupId: row.transactionGroupId,
        groupId: row.groupId,
        paidBy: row.paidBy,
        sharedWith: row.sharedWith,
        totalTransactionAmount: row.totalTransactionAmount,
        sharedTransactionAmount: row.sharedTransactionAmount,
        sharedPercentage: row.sharedPercentage,
        selfShareAmount: row.selfShareAmount,
        selfSharePercentage: row.selfSharePercentage,
        sharingType: row.sharingType,
        category: row.category,
        description: row.description,
        transactionNote: row.transactionNote,
        transactionDate: row.transactionDate,
      );
    }

    final balances = await _readLocalBalances(groupID);
    final updated = applySplitDebts(
      balances: balances,
      payerId: paidByUserID,
      splits: splits,
    );
    await _enqueueGroupBalanceUpdate(groupID, updated);
  }

  Future<void> _enqueueGroupBalanceUpdate(
    String groupId,
    List<Map<String, dynamic>> balances,
  ) async {
    final existing = await _db.getGroupById(groupId);
    await _db.upsertGroup(LocalGroupsCompanion(
      groupId: Value(groupId),
      groupName: Value(existing?.groupName ?? DisplayFallbacks.group),
      groupBalance: Value(jsonEncode(balances)),
      createdBy: Value(existing?.createdBy),
      createdAt: Value(existing?.createdAt),
      updatedOn: Value(DateTime.now()),
      syncStatus: const Value(SyncStatusValues.pending),
    ));

    await _syncService.enqueue(
      tableName: SupabaseTables.groups,
      operation: SyncOperations.update,
      recordId: groupId,
      payload: {
        SupabaseColumns.groupId: groupId,
        SupabaseColumns.groupBalance: balances,
        SupabaseColumns.updatedOn: DateTime.now().toIso8601String(),
      },
    );
  }

  /// Delete a transaction group on the server and refresh local cache.
  Future<void> deleteGroupTransaction({
    required String transactionGroupID,
    required String groupID,
  }) async {
    await _transactionService.deleteGroupTransaction(
      transactionGroupID: transactionGroupID,
    );
    await (_db.delete(_db.localGroupTransactions)
          ..where((t) => t.transactionGroupId.equals(transactionGroupID)))
        .go();
    await refreshFromServer(groupID);
  }

  Future<List<CategoryOnlyModel>> getProductCategories(String? groupId) =>
      _transactionService.getProductCategories(groupID: groupId);

  Future<void> addCustomCategory({
    required String groupId,
    required String categoryName,
    required String iconSvgContent,
    required String userId,
  }) =>
      _transactionService.addCustomCategory(
        groupID: groupId,
        categoryName: categoryName,
        iconSvgContent: iconSvgContent,
        userID: userId,
      );
}
