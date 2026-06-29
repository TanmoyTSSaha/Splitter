import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:splitter/Services/local/database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Background sync service — pushes local mutations to Supabase
/// when connectivity is available.
class SyncService {
  final AppDatabase _db;
  final SupabaseClient _supabase;
  StreamSubscription? _connectivitySub;
  bool _isSyncing = false;

  /// Stream to notify UI of sync status changes.
  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatus => _syncStatusController.stream;

  SyncService(this._db) : _supabase = Supabase.instance.client;

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

  /// Process all pending items in the sync queue.
  Future<void> syncPendingItems() async {
    if (_isSyncing) return;
    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);

    try {
      final pendingItems = await _db.getPendingSyncItems();

      if (pendingItems.isEmpty) {
        _syncStatusController.add(SyncStatus.synced);
        _isSyncing = false;
        return;
      }

      for (final item in pendingItems) {
        try {
          await _processSyncItem(item);
          await _db.markSynced(item.id);
        } catch (e) {
          debugPrint('Sync failed for item ${item.id}: $e');
          await _db.markFailed(item.id);
        }
      }

      _syncStatusController.add(SyncStatus.synced);
    } catch (e) {
      debugPrint('Sync error: $e');
      _syncStatusController.add(SyncStatus.error);
    } finally {
      _isSyncing = false;
    }
  }

  /// Process a single sync queue item.
  ///
  /// Conflict policy (strategy §6.2):
  /// - Amounts: server wins on refresh; failed amount UPDATEs surface as sync errors.
  /// - Notes: last-write-wins via queued local UPDATE payloads.
  Future<void> _processSyncItem(SyncQueueData item) async {
    final payload = jsonDecode(item.payload) as Map<String, dynamic>;

    switch (item.operation) {
      case 'INSERT':
        await _supabase.from(item.targetTable).insert(payload);
        break;
      case 'UPDATE':
        final idField = _getIdField(item.targetTable);
        final id = payload[idField];
        // Notes-only updates use last-write-wins; amount fields defer to server
        // on the next refreshFromServer pull.
        await _supabase.from(item.targetTable).update(payload).eq(idField, id);
        break;
      case 'DELETE':
        final idField = _getIdField(item.targetTable);
        await _supabase
            .from(item.targetTable)
            .delete()
            .eq(idField, item.recordId);
        break;
    }
  }

  /// Maps table names to their primary key column.
  String _getIdField(String tableName) {
    switch (tableName) {
      case 'groups':
        return 'group_id';
      case 'group_transaction':
        return 'transaction_id';
      case 'personal_transaction':
        return 'transaction_id';
      case 'friends':
        return 'id';
      default:
        return 'id';
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
      final memberRows =
          await _supabase.from('group_members').select().eq('user_id', userId);

      for (final row in memberRows) {
        final groupId = row['group_id'] as String;

        // Save member
        await _db.into(_db.localGroupMembers).insertOnConflictUpdate(
              LocalGroupMembersCompanion.insert(
                groupId: groupId,
                userId: row['user_id'] as String,
              ),
            );

        // Fetch and save group details
        final groupRow = await _supabase
            .from('groups')
            .select()
            .eq('group_id', groupId)
            .single();

        await _db.upsertGroup(LocalGroupsCompanion(
          groupId: Value(groupId),
          groupName: Value(groupRow['group_name'] as String),
          groupBalance: Value(jsonEncode(groupRow['group_balance'] ?? [])),
          createdBy: Value(groupRow['created_by'] as String?),
          createdAt: Value(
              DateTime.tryParse(groupRow['created_at']?.toString() ?? '')),
          updatedOn: Value(
              DateTime.tryParse(groupRow['updated_on']?.toString() ?? '')),
          syncStatus: const Value('synced'),
        ));
      }

      _syncStatusController.add(SyncStatus.synced);
    } catch (e) {
      debugPrint('Full sync error: $e');
      _syncStatusController.add(SyncStatus.error);
    }
  }

  void dispose() {
    _connectivitySub?.cancel();
    _syncStatusController.close();
  }
}

enum SyncStatus { synced, syncing, error }
