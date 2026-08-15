import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Services/app_logger.dart';
import 'package:splitr/Services/local/database.dart';
import 'package:splitr/Utils/sync_operation_planner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Max sync queue items processed per [SyncService.syncPendingItems] invocation.
const int SYNC_CHUNK_SIZE = 10;

/// Applies a planned sync mutation remotely (Supabase by default).
typedef SyncPlanExecutor = Future<void> Function(SyncOperationPlan plan);

/// Background sync service — pushes local mutations to Supabase
/// when connectivity is available.
class SyncService {
  final AppDatabase _db;
  final SupabaseClient? _supabaseOverride;
  final SyncPlanExecutor? _planExecutor;
  StreamSubscription? _connectivitySub;
  bool _isSyncing = false;

  /// Stream to notify UI of sync status changes.
  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatus => _syncStatusController.stream;

  SyncService(
    this._db, {
    SupabaseClient? supabaseClient,
    SyncPlanExecutor? planExecutor,
  })  : _supabaseOverride = supabaseClient,
        _planExecutor = planExecutor;

  SupabaseClient get _supabase => _supabaseOverride ?? Supabase.instance.client;

  /// Start listening for connectivity changes.
  void startListening() {
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection) {
        syncPendingItems();
      }
    });

    // Also try an initial sync
    syncPendingItems();
  }

  /// Process pending sync queue items in bounded chunks.
  Future<void> syncPendingItems() async {
    if (_isSyncing) return;
    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);

    var scheduleContinuation = false;
    try {
      final pendingItems = await _db.getPendingSyncItems();

      if (pendingItems.isEmpty) {
        _syncStatusController.add(SyncStatus.synced);
        return;
      }

      final chunk = pendingItems.take(SYNC_CHUNK_SIZE).toList();
      for (final item in chunk) {
        try {
          await _processSyncItem(item);
          await _db.markSynced(item.id);
        } catch (e, stack) {
          AppLogger.error(
            'Sync failed for queue item',
            error: e,
            stack: stack,
            data: {'sync_item_id': item.id},
          );
          await _db.markFailed(item.id);
        }
      }

      if (pendingItems.length > SYNC_CHUNK_SIZE) {
        scheduleContinuation = true;
      } else {
        _syncStatusController.add(SyncStatus.synced);
      }
    } catch (e, stack) {
      AppLogger.error('Sync queue processing failed', error: e, stack: stack);
      _syncStatusController.add(SyncStatus.error);
    } finally {
      _isSyncing = false;
      if (scheduleContinuation) {
        Future.microtask(syncPendingItems);
      }
    }
  }

  /// Process a single sync queue item.
  ///
  /// Conflict policy (strategy §6.2):
  /// - Amounts: server wins on refresh; failed amount UPDATEs surface as sync errors.
  /// - Notes: last-write-wins via queued local UPDATE payloads.
  Future<void> _processSyncItem(SyncQueueData item) async {
    final payload = jsonDecode(item.payload) as Map<String, dynamic>;
    final plan = planSyncOperation(
      targetTable: item.targetTable,
      operation: item.operation,
      recordId: item.recordId,
      payload: payload,
    );

    switch (plan.operation) {
      case SyncOperations.insert:
      case SyncOperations.update:
      case SyncOperations.delete:
        if (_planExecutor != null) {
          await _planExecutor!(plan);
          return;
        }
        break;
    }

    switch (plan.operation) {
      case SyncOperations.insert:
        await _supabase.from(plan.table).insert(plan.payload);
        break;
      case SyncOperations.update:
        await _supabase
            .from(plan.table)
            .update(plan.payload)
            .eq(plan.filterField!, plan.filterValue);
        break;
      case SyncOperations.delete:
        await _supabase
            .from(plan.table)
            .delete()
            .eq(plan.filterField!, plan.filterValue);
        break;
    }
  }

  /// Enqueue a mutation for sync.
  Future<void> enqueue({
    required String tableName,
    required String operation,
    required String recordId,
    required Map<String, dynamic> payload,
  }) async {
    await _db.addToSyncQueue(SyncQueueCompanion.insert(
      targetTable: tableName,
      operation: operation,
      recordId: recordId,
      payload: jsonEncode(payload),
    ));

    // Try to sync immediately if connected
    final connectivity = await Connectivity().checkConnectivity();
    final hasConnection = connectivity.any((r) => r != ConnectivityResult.none);
    if (hasConnection) {
      syncPendingItems();
    }
  }

  /// Full sync: pull latest data from Supabase into local DB.
  Future<void> fullSync(String userId) async {
    try {
      _syncStatusController.add(SyncStatus.syncing);

      // Sync groups
      final memberRows = await _supabase
          .from(SupabaseTables.groupMembers)
          .select()
          .eq(SupabaseColumns.userId, userId);

      for (final row in memberRows) {
        final groupId = row[SupabaseColumns.groupId] as String;

        // Save member
        await _db.into(_db.localGroupMembers).insertOnConflictUpdate(
              LocalGroupMembersCompanion.insert(
                groupId: groupId,
                userId: row[SupabaseColumns.userId] as String,
              ),
            );

        // Fetch and save group details
        final groupRow = await _supabase
            .from(SupabaseTables.groups)
            .select()
            .eq(SupabaseColumns.groupId, groupId)
            .single();

        await _db.upsertGroup(LocalGroupsCompanion(
          groupId: Value(groupId),
          groupName: Value(groupRow[SupabaseColumns.groupName] as String),
          groupBalance:
              Value(jsonEncode(groupRow[SupabaseColumns.groupBalance] ?? [])),
          createdBy: Value(groupRow[SupabaseColumns.createdBy] as String?),
          createdAt: Value(DateTime.tryParse(
              groupRow[SupabaseColumns.createdAt]?.toString() ?? '')),
          updatedOn: Value(DateTime.tryParse(
              groupRow[SupabaseColumns.updatedOn]?.toString() ?? '')),
          syncStatus: const Value(SyncStatusValues.synced),
        ));
      }

      _syncStatusController.add(SyncStatus.synced);
    } catch (e, stack) {
      AppLogger.error('Full sync failed', error: e, stack: stack);
      _syncStatusController.add(SyncStatus.error);
    }
  }

  void dispose() {
    _connectivitySub?.cancel();
    _syncStatusController.close();
  }
}

enum SyncStatus { synced, syncing, error }
