import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Model/group_model.dart';
import 'package:splitr/Services/SupabaseServices/group_service.dart';
import 'package:splitr/Services/local/database.dart';
import 'package:splitr/Services/sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository layer for groups — reads from local DB, writes to local + sync queue.
class GroupRepository {
  final AppDatabase _db;
  final SyncService _syncService;
  final SupabaseClient _supabase = Supabase.instance.client;
  final GroupService _groupService = GroupService();

  GroupRepository(this._db, this._syncService);

  /// Map a Drift row to the domain [GroupModel].
  GroupModel toGroupModel(LocalGroup local,
      {bool isTrip = false, bool isArchived = false}) {
    final balanceJson = jsonDecode(local.groupBalance) as List<dynamic>;
    final balances = balanceJson
        .map((e) =>
            GroupBalanceModel.fromJSON(Map<String, dynamic>.from(e as Map)))
        .toList();

    return GroupModel(
      groupID: local.groupId,
      groupName: local.groupName,
      groupBalance: balances,
      createdAt: local.createdAt,
      updatedOn: local.updatedOn,
      createdBy: local.createdBy,
      isTrip: isTrip,
      isArchived: isArchived,
    );
  }

  Future<Set<String>> fetchArchivedGroupIds(List<String> groupIds) async {
    if (groupIds.isEmpty) return {};
    final rows = await _supabase
        .from(SupabaseTables.groups)
        .select('${SupabaseColumns.groupId}, ${SupabaseColumns.isArchived}')
        .inFilter(SupabaseColumns.groupId, groupIds);
    return rows
        .where((r) => r[SupabaseColumns.isArchived] == true)
        .map((r) => r[SupabaseColumns.groupId] as String)
        .toSet();
  }

  Future<void> setGroupArchived(String groupId, bool archived) async {
    await _supabase
        .from(SupabaseTables.groups)
        .update({SupabaseColumns.isArchived: archived}).eq(
            SupabaseColumns.groupId, groupId);
  }

  /// Returns group IDs that have trip metadata on the server.
  Future<Set<String>> fetchTripGroupIds(List<String> groupIds) async {
    if (groupIds.isEmpty) return {};
    final tripData = await _supabase
        .from(SupabaseTables.tripMetadata)
        .select(SupabaseColumns.groupId)
        .inFilter(SupabaseColumns.groupId, groupIds);
    return tripData
        .map<String>((e) => e[SupabaseColumns.groupId] as String)
        .toSet();
  }

  /// Watch all groups reactively (Drift → Stream → GetX Obx).
  Stream<List<LocalGroup>> watchGroups() => _db.watchAllGroups();

  /// Get all groups for [userId] (one-shot).
  Future<List<LocalGroup>> getGroups(String userId) =>
      _db.getGroupsForUser(userId);

  Future<List<Map<String, dynamic>>> getDistinctGroups(String userId) =>
      _groupService.getDistinctGroups(userID: userId);

  Future<GroupModel?> getGroupModel(String groupId) =>
      _groupService.getGroupModel(groupId);

  Future<List<GroupMembersWithNameModel>> getGroupMembers({
    required String groupId,
    required String currentUserId,
  }) =>
      _groupService.getGroupMembers(
        groupID: groupId,
        currentUserID: currentUserId,
      );

  /// Refresh groups from Supabase into local DB.
  Future<void> refreshFromServer(String userId) async {
    try {
      final memberRows = await _supabase
          .from(SupabaseTables.groupMembers)
          .select()
          .eq(SupabaseColumns.userId, userId);

      final serverGroupIds = memberRows
          .map((row) => row[SupabaseColumns.groupId] as String)
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
        final groupId = row[SupabaseColumns.groupId] as String;

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
              groupRow[SupabaseColumns.createdAt]?.toString() ??
                  StringDefaults.empty)),
          updatedOn: Value(DateTime.tryParse(
              groupRow[SupabaseColumns.updatedOn]?.toString() ??
                  StringDefaults.empty)),
          syncStatus: const Value(SyncStatusValues.synced),
        ));

        await _db.into(_db.localGroupMembers).insertOnConflictUpdate(
              LocalGroupMembersCompanion.insert(
                groupId: groupId,
                userId: row[SupabaseColumns.userId] as String,
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
      syncStatus: const Value(SyncStatusValues.pending),
    ));

    // Enqueue for sync
    await _syncService.enqueue(
      tableName: SupabaseTables.groups,
      operation: SyncOperations.insert,
      recordId: groupId,
      payload: {
        SupabaseColumns.groupId: groupId,
        SupabaseColumns.groupName: groupName,
        SupabaseColumns.createdBy: createdBy,
        SupabaseColumns.groupBalance: groupBalance,
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
      syncStatus: const Value(SyncStatusValues.pending),
    ));

    await _syncService.enqueue(
      tableName: SupabaseTables.groups,
      operation: SyncOperations.update,
      recordId: groupId,
      payload: {
        SupabaseColumns.groupId: groupId,
        SupabaseColumns.groupBalance: groupBalance,
        SupabaseColumns.updatedOn: DateTime.now().toIso8601String(),
      },
    );
  }

  /// Creates or reuses a 2-member group for a 1:1 friend split.
  Future<GroupModel> getOrCreateDirectSplitGroup({
    required String userId,
    required String friendUserId,
    required String friendName,
  }) async {
    final group = await _groupService.getOrCreateDirectSplitGroup(
      userID: userId,
      friendUserId: friendUserId,
      friendName: friendName,
    );
    await refreshFromServer(userId);
    return group;
  }

  Future<void> leaveGroup(String groupId) async {
    await _supabase.rpc(SupabaseRpc.leaveGroup,
        params: {SupabaseColumns.pGroupId: groupId});
  }

  Future<void> removeMember({
    required String groupId,
    required String memberId,
  }) async {
    await _supabase.rpc(SupabaseRpc.removeGroupMember, params: {
      SupabaseColumns.pGroupId: groupId,
      SupabaseRpc.pMemberId: memberId,
    });
  }
}
