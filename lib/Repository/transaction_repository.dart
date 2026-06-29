import 'package:drift/drift.dart';
import 'package:splitter/Model/group_model.dart';
import 'package:splitter/Services/local/database.dart';
import 'package:splitter/Services/sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository layer for transactions — reads from local DB, writes to local + sync queue.
class TransactionRepository {
  final AppDatabase _db;
  final SyncService _syncService;
  final SupabaseClient _supabase = Supabase.instance.client;

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
          .from('master_product_category')
          .select('category, category_logo')
          .inFilter('category', categories.toList()),
      _supabase
          .from('users')
          .select('user_id, firstname, lastname')
          .inFilter('user_id', userIds.toList()),
    ]);

    final categoryLogoMap = <String, String>{};
    for (final row in results[0] as List<dynamic>) {
      categoryLogoMap[row['category'] as String] =
          row['category_logo'] as String;
    }

    final userNameMap = <String, String>{};
    for (final row in results[1] as List<dynamic>) {
      final first = row['firstname'] ?? '';
      final last = row['lastname'] ?? '';
      userNameMap[row['user_id'] as String] = '$first $last'.trim();
    }

    return localRows.map((row) {
      final paidByName = userNameMap[row.paidBy] ?? 'Unknown';
      final sharedWithName = userNameMap[row.sharedWith] ?? 'Unknown';
      final categoryLogo = categoryLogoMap[row.category ?? ''] ?? '';

      return GroupTransactionModel.fromJSON(
        {
          'transaction_id': row.transactionId,
          'transaction_group_id': row.transactionGroupId,
          'group_id': row.groupId,
          'paid_by': row.paidBy,
          'shared_with': row.sharedWith,
          'total_transaction_amount': row.totalTransactionAmount,
          'shared_transaction_amount': row.sharedTransactionAmount,
          'shared_percentage': row.sharedPercentage,
          'self_share_amount': row.selfShareAmount,
          'self_share_percentage': row.selfSharePercentage,
          'sharing_type': row.sharingType,
          'category': row.category,
          'description': row.description,
          'transaction_photo': row.transactionPhoto,
          'transaction_note': row.transactionNote,
          'is_settled_up': row.isSettledUp,
          'transaction_date': row.transactionDate?.toIso8601String() ??
              DateTime.now().toIso8601String(),
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
          .from('group_transaction')
          .select()
          .eq('group_id', groupId);

      for (final row in rows) {
        await _db
            .into(_db.localGroupTransactions)
            .insertOnConflictUpdate(LocalGroupTransactionsCompanion(
              transactionId: Value(row['transaction_id'] as String),
              transactionGroupId: Value(row['transaction_group_id'] as String),
              groupId: Value(row['group_id'] as String),
              paidBy: Value(row['paid_by'] as String),
              sharedWith: Value(row['shared_with'] as String),
              totalTransactionAmount: Value(
                  double.parse(row['total_transaction_amount'].toString())),
              sharedTransactionAmount: Value(
                  double.parse(row['shared_transaction_amount'].toString())),
              sharedPercentage:
                  Value(double.parse(row['shared_percentage'].toString())),
              selfShareAmount:
                  Value(double.parse(row['self_share_amount'].toString())),
              selfSharePercentage:
                  Value(double.parse(row['self_share_percentage'].toString())),
              sharingType: Value(row['sharing_type'] as String? ?? 'evenly'),
              category: Value(row['category'] as String?),
              description: Value(row['description'] as String?),
              transactionPhoto: Value(row['transaction_photo'] as String?),
              transactionNote: Value(row['transaction_note'] as String?),
              isSettledUp: Value(row['is_settled_up'] as bool? ?? false),
              transactionDate: Value(
                  DateTime.tryParse(row['transaction_date']?.toString() ?? '')),
              syncStatus: const Value('synced'),
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
    final now = transactionDate ?? DateTime.now();

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
          syncStatus: const Value('pending'),
        ));

    // Enqueue for sync
    await _syncService.enqueue(
      tableName: 'group_transaction',
      operation: 'INSERT',
      recordId: transactionId,
      payload: {
        'transaction_id': transactionId,
        'transaction_group_id': transactionGroupId,
        'group_id': groupId,
        'paid_by': paidBy,
        'shared_with': sharedWith,
        'total_transaction_amount': totalTransactionAmount,
        'shared_transaction_amount': sharedTransactionAmount,
        'shared_percentage': sharedPercentage,
        'self_share_amount': selfShareAmount,
        'self_share_percentage': selfSharePercentage,
        'sharing_type': sharingType,
        'category': category,
        'description': description,
        'transaction_photo': transactionPhoto,
        'transaction_note': transactionNote,
        'transaction_date': now.toIso8601String(),
      },
    );
  }
}
