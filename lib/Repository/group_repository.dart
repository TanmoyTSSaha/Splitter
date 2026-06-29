import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:splitter/Model/group_model.dart';
import 'package:splitter/Services/local/database.dart';
import 'package:splitter/Services/sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository layer for groups — reads from local DB, writes to local + sync queue.
class GroupRepository {
  final AppDatabase _db;
  final SyncService _syncService;
  final SupabaseClient _supabase = Supabase.instance.client;

  GroupRepository(this._db, this._syncService);

  /// Map a Drift row to the domain [GroupModel].
  GroupModel toGroupModel(LocalGroup local, {bool isTrip = false}) {
    final balanceJson = jsonDecode(local.groupBalance) as List<dynamic>;
    final balances = balanceJson
        .map((e) => GroupBalanceModel.fromJSON(
            Map<String, dynamic>.from(e as Map)))
        .toList();

    return GroupModel(
      groupID: local.groupId,
      groupName: local.groupName,
      groupBalance: balances,
      createdAt: local.createdAt,
      updatedOn: local.updatedOn,
      createdBy: local.createdBy,
      isTrip: isTrip,
    );
  }

  /// Returns group IDs that have trip metadata on the server.
  Future<Set<String>> fetchTripGroupIds(List<String> groupIds) async {
    if (groupIds.isEmpty) return {};
    final tripData = await _supabase
        .from('trip_metadata')
        .select('group_id')
        .inFilter('group_id', groupIds);
    return tripData.map<String>((e) => e['group_id'] as String).toSet();
  }

  /// Watch all groups reactively (Drift → Stream → GetX Obx).
  Stream<List<LocalGroup>> watchGroups() => _db.watchAllGroups();

  /// Get all groups for [userId] (one-shot).
  Future<List<LocalGroup>> getGroups(String userId) =>
      _db.getGroupsForUser(userId);

  /// Refresh groups from Supabase into local DB.
  Future<void> refreshFromServer(String userId) async {
    try {
      final memberRows =
          await _supabase.from('group_members').select().eq('user_id', userId);

      final serverGroupIds = memberRows
          .map((row) => row['group_id'] as String)
          .toSet();

      // Drop groups cached from a previous account or removed memberships.
      final staleGroups = await _db.getAllGroups();
      for (final group in staleGroups) {
        if (!serverGroupIds.contains(group.groupId)) {
          await (_db.delete(_db.localGroups)
                ..where((g) => g.groupId.equals(group.groupId)))
              .go();
          await (_db.delete(_db.localGroupTransactions)
                ..where((t) => t.groupId.equals(group.groupId)))
              .go();
          await (_db.delete(_db.localGroupMembers)
                ..where((m) => m.groupId.equals(group.groupId)))
              .go();
        }
      }

      await (_db.delete(_db.localGroupMembers)
            ..where((m) => m.userId.equals(userId)))
          .go();

      for (final row in memberRows) {
        final groupId = row['group_id'] as String;

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

        await _db.into(_db.localGroupMembers).insertOnConflictUpdate(
              LocalGroupMembersCompanion.insert(
                groupId: groupId,
                userId: row['user_id'] as String,
              ),
            );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Create a group locally + enqueue sync.
  Future<void> createGroup({
    required String groupId,
    required String groupName,
    required String createdBy,
    required List<Map<String, dynamic>> groupBalance,
  }) async {
    // Save locally
    await _db.upsertGroup(LocalGroupsCompanion(
      groupId: Value(groupId),
      groupName: Value(groupName),
      groupBalance: Value(jsonEncode(groupBalance)),
      createdBy: Value(createdBy),
      createdAt: Value(DateTime.now()),
      updatedOn: Value(DateTime.now()),
      syncStatus: const Value('pending'),
    ));

    // Enqueue for sync
    await _syncService.enqueue(
      tableName: 'groups',
      operation: 'INSERT',
      recordId: groupId,
      payload: {
        'group_id': groupId,
        'group_name': groupName,
        'created_by': createdBy,
        'group_balance': groupBalance,
      },
    );
  }

  /// Update group balance locally + enqueue sync.
  Future<void> updateGroupBalance(
      String groupId, List<Map<String, dynamic>> groupBalance) async {
    await _db.upsertGroup(LocalGroupsCompanion(
      groupId: Value(groupId),
      groupBalance: Value(jsonEncode(groupBalance)),
      updatedOn: Value(DateTime.now()),
      syncStatus: const Value('pending'),
    ));

    await _syncService.enqueue(
      tableName: 'groups',
      operation: 'UPDATE',
      recordId: groupId,
      payload: {
        'group_id': groupId,
        'group_balance': groupBalance,
        'updated_on': DateTime.now().toIso8601String(),
      },
    );
  }
}
