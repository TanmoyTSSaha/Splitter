import 'package:drift/drift.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Model/personal_transaction_model.dart';
import 'package:splitr/Services/local/database.dart';
import 'package:splitr/Services/sync_service.dart';
import 'package:splitr/Utils/transaction_date_formatter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Local cache + server refresh for personal transactions.
class PersonalTransactionRepository {
  final AppDatabase _db;
  final SyncService _syncService;
  final SupabaseClient _supabase = Supabase.instance.client;

  PersonalTransactionRepository(this._db, this._syncService);

  Stream<List<LocalPersonalTransaction>> watchForUser(String userId) =>
      _db.watchPersonalTransactionsForUser(userId);

  Future<List<LocalPersonalTransaction>> getForUser(String userId) =>
      _db.getPersonalTransactionsForUser(userId);

  PersonalTransactionModel toModel(LocalPersonalTransaction row) {
    return PersonalTransactionModel(
      transactionID: row.transactionId,
      userID: row.userId,
      amount: row.amount,
      category: row.category,
      transactionDescription: row.transactionDescription,
      currency: row.currency,
      paymentMethod: row.paymentMethod,
      transactionDate: row.transactionDate,
    );
  }

  /// Pull personal transactions from Supabase into Drift.
  Future<void> refreshFromServer(String userId) async {
    try {
      final rows = await _supabase
          .from(SupabaseTables.personalTransaction)
          .select()
          .eq(SupabaseColumns.userId, userId)
          .order(SupabaseColumns.transactionDate, ascending: false);

      await _db.deletePersonalTransactionsForUser(userId);

      for (final row in rows) {
        final dateRaw = row[SupabaseColumns.transactionDate];
        DateTime? txDate;
        if (dateRaw is String) {
          txDate = DateTime.tryParse(dateRaw)?.toLocal();
        }

        await _db.upsertPersonalTransaction(
          LocalPersonalTransactionsCompanion(
            transactionId: Value((row[SupabaseColumns.id] ??
                row[SupabaseColumns.transactionId]) as String),
            userId: Value(userId),
            amount: Value(
              double.tryParse(row[SupabaseColumns.amount]?.toString() ??
                      AppAmountHints.zero) ??
                  0,
            ),
            category: Value(row[SupabaseColumns.category] as String?),
            transactionDescription:
                Value(row[SupabaseColumns.transactionDescription] as String?),
            currency: Value(row[SupabaseColumns.currency] as String? ??
                CurrencyDefaults.code),
            paymentMethod: Value(row[SupabaseColumns.paymentMethod] as String?),
            isCredit: Value(row[SupabaseColumns.isCredit] == true),
            transactionDate: Value(txDate),
            syncStatus: const Value(SyncStatusValues.synced),
          ),
        );
      }
    } catch (e) {
      // Keep cached rows when offline; sync service may retry later.
      _syncService;
    }
  }

  /// Add a personal transaction locally and enqueue for Supabase sync.
  Future<void> addTransaction({
    required String transactionId,
    required String userId,
    required double amount,
    required String description,
    required String category,
    required DateTime date,
    required String paymentMethod,
    required String currency,
    double exchangeRateToInr = CurrencyDefaults.exchangeRateToInr,
    bool isCredit = false,
  }) async {
    await _db.upsertPersonalTransaction(
      LocalPersonalTransactionsCompanion(
        transactionId: Value(transactionId),
        userId: Value(userId),
        amount: Value(amount),
        category: Value(category),
        transactionDescription: Value(description),
        currency: Value(currency),
        paymentMethod: Value(paymentMethod),
        isCredit: Value(isCredit),
        transactionDate: Value(date),
        syncStatus: const Value(SyncStatusValues.pending),
      ),
    );

    await _syncService.enqueue(
      tableName: SupabaseTables.personalTransaction,
      operation: SyncOperations.insert,
      recordId: transactionId,
      payload: {
        SupabaseColumns.id: transactionId,
        SupabaseColumns.userId: userId,
        SupabaseColumns.amount: amount,
        SupabaseColumns.transactionDescription: description,
        SupabaseColumns.category: category,
        SupabaseColumns.transactionDate:
            TransactionDateFormatter.toStorageIso(date),
        SupabaseColumns.paymentMethod: paymentMethod,
        SupabaseColumns.currency: currency,
        SupabaseColumns.exchangeRateToInr: exchangeRateToInr,
        SupabaseColumns.isCredit: isCredit,
      },
    );
  }

  /// Update a personal transaction locally and enqueue for Supabase sync.
  Future<void> updateTransaction({
    required String transactionId,
    required String userId,
    required double amount,
    required String description,
    required String category,
    required DateTime date,
    required String paymentMethod,
    required String currency,
    double exchangeRateToInr = CurrencyDefaults.exchangeRateToInr,
    bool isCredit = false,
  }) async {
    await _db.upsertPersonalTransaction(
      LocalPersonalTransactionsCompanion(
        transactionId: Value(transactionId),
        userId: Value(userId),
        amount: Value(amount),
        category: Value(category),
        transactionDescription: Value(description),
        currency: Value(currency),
        paymentMethod: Value(paymentMethod),
        isCredit: Value(isCredit),
        transactionDate: Value(date),
        syncStatus: const Value(SyncStatusValues.pending),
      ),
    );

    await _syncService.enqueue(
      tableName: SupabaseTables.personalTransaction,
      operation: SyncOperations.update,
      recordId: transactionId,
      payload: {
        SupabaseColumns.id: transactionId,
        SupabaseColumns.userId: userId,
        SupabaseColumns.amount: amount,
        SupabaseColumns.transactionDescription: description,
        SupabaseColumns.category: category,
        SupabaseColumns.transactionDate:
            TransactionDateFormatter.toStorageIso(date),
        SupabaseColumns.paymentMethod: paymentMethod,
        SupabaseColumns.currency: currency,
        SupabaseColumns.exchangeRateToInr: exchangeRateToInr,
        SupabaseColumns.isCredit: isCredit,
      },
    );
  }

  /// Delete a personal transaction locally and enqueue for Supabase sync.
  Future<void> deleteTransaction({required String transactionId}) async {
    await _db.deletePersonalTransaction(transactionId);

    await _syncService.enqueue(
      tableName: SupabaseTables.personalTransaction,
      operation: SyncOperations.delete,
      recordId: transactionId,
      payload: {SupabaseColumns.id: transactionId},
    );
  }
}
