import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

part 'database.g.dart';

// ──────── Table Definitions ────────

/// Local cache of groups.
class LocalGroups extends Table {
  TextColumn get groupId => text()();
  TextColumn get groupName => text()();
  TextColumn get groupBalance => text().withDefault(const Constant('[]'))();
  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedOn => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(
      const Constant(SyncStatusValues.synced))(); // synced|pending|failed

  @override
  Set<Column> get primaryKey => {groupId};
}

/// Local cache of group members.
class LocalGroupMembers extends Table {
  TextColumn get groupId => text()();
  TextColumn get userId => text()();

  @override
  Set<Column> get primaryKey => {groupId, userId};
}

/// Local cache of group transactions.
class LocalGroupTransactions extends Table {
  TextColumn get transactionId => text()();
  TextColumn get transactionGroupId => text()();
  TextColumn get groupId => text()();
  TextColumn get paidBy => text()();
  TextColumn get sharedWith => text()();
  RealColumn get totalTransactionAmount => real()();
  RealColumn get sharedTransactionAmount => real()();
  RealColumn get sharedPercentage => real().withDefault(const Constant(0))();
  RealColumn get selfShareAmount => real().withDefault(const Constant(0))();
  RealColumn get selfSharePercentage => real().withDefault(const Constant(0))();
  TextColumn get sharingType =>
      text().withDefault(const Constant(SharingTypeValues.evenly))();
  TextColumn get category => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get transactionPhoto => text().nullable()();
  TextColumn get transactionNote => text().nullable()();
  BoolColumn get isSettledUp => boolean().withDefault(const Constant(false))();
  DateTimeColumn get transactionDate => dateTime().nullable()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant(SyncStatusValues.synced))();

  @override
  Set<Column> get primaryKey => {transactionId};
}

/// Local cache of personal transactions.
class LocalPersonalTransactions extends Table {
  TextColumn get transactionId => text()();
  TextColumn get userId => text()();
  RealColumn get amount => real()();
  TextColumn get category => text().nullable()();
  TextColumn get transactionDescription => text().nullable()();
  TextColumn get currency =>
      text().withDefault(const Constant(CurrencyDefaults.code))();
  TextColumn get paymentMethod => text().nullable()();
  BoolColumn get isCredit => boolean().withDefault(const Constant(false))();
  DateTimeColumn get transactionDate => dateTime().nullable()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant(SyncStatusValues.synced))();

  @override
  Set<Column> get primaryKey => {transactionId};
}

/// Local cache of friends.
class LocalFriends extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get friendId => text()();
  TextColumn get status =>
      text().withDefault(const Constant(FriendStatusValues.pending))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant(SyncStatusValues.synced))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local user cache (read-only, for display purposes).
class LocalUsersCache extends Table {
  TextColumn get userId => text()();
  TextColumn get firstName => text().nullable()();
  TextColumn get lastName => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get profilePictureUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {userId};
}

/// Queue of mutations pending sync to Supabase.
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get targetTable => text()();
  TextColumn get operation => text()(); // INSERT | UPDATE | DELETE
  TextColumn get recordId => text()();
  TextColumn get payload => text()(); // JSON-encoded row data
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(
      const Constant(SyncStatusValues.pending))(); // pending|processing|failed
}

// ──────── Database ────────

@DriftDatabase(tables: [
  LocalGroups,
  LocalGroupMembers,
  LocalGroupTransactions,
  LocalPersonalTransactions,
  LocalFriends,
  LocalUsersCache,
  SyncQueue,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// In-memory database for unit/integration tests.
  AppDatabase.forTesting([QueryExecutor? executor])
      : super(executor ?? NativeDatabase.memory());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(localPersonalTransactions);
          }
          if (from < 3) {
            await m.addColumn(
              localPersonalTransactions,
              localPersonalTransactions.isCredit,
            );
          }
        },
      );

  // ─── Group operations ───
  Future<List<LocalGroup>> getAllGroups() => select(localGroups).get();

  Stream<List<LocalGroup>> watchAllGroups() => select(localGroups).watch();

  Future<void> upsertGroup(LocalGroupsCompanion group) =>
      into(localGroups).insertOnConflictUpdate(group);

  Future<LocalGroup?> getGroupById(String groupId) =>
      (select(localGroups)..where((g) => g.groupId.equals(groupId)))
          .getSingleOrNull();

  // ─── Transaction operations ───
  Future<List<LocalGroupTransaction>> getTransactionsForGroup(String groupId) =>
      (select(localGroupTransactions)
            ..where((t) => t.groupId.equals(groupId))
            ..orderBy([
              (t) => OrderingTerm(
                    expression: t.transactionDate,
                    mode: OrderingMode.desc,
                  ),
              (t) => OrderingTerm(
                    expression: t.transactionId,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .get();

  Stream<List<LocalGroupTransaction>> watchTransactionsForGroup(
          String groupId) =>
      (select(localGroupTransactions)
            ..where((t) => t.groupId.equals(groupId))
            ..orderBy([
              (t) => OrderingTerm(
                    expression: t.transactionDate,
                    mode: OrderingMode.desc,
                  ),
              (t) => OrderingTerm(
                    expression: t.transactionId,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .watch();

  // ─── Personal transaction operations ───
  Future<List<LocalPersonalTransaction>> getPersonalTransactionsForUser(
          String userId) =>
      (select(localPersonalTransactions)
            ..where((t) => t.userId.equals(userId))
            ..orderBy([
              (t) => OrderingTerm(
                    expression: t.transactionDate,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .get();

  Stream<List<LocalPersonalTransaction>> watchPersonalTransactionsForUser(
          String userId) =>
      (select(localPersonalTransactions)
            ..where((t) => t.userId.equals(userId))
            ..orderBy([
              (t) => OrderingTerm(
                    expression: t.transactionDate,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .watch();

  Future<void> upsertPersonalTransaction(
          LocalPersonalTransactionsCompanion row) =>
      into(localPersonalTransactions).insertOnConflictUpdate(row);

  Future<void> deletePersonalTransactionsForUser(String userId) =>
      (delete(localPersonalTransactions)..where((t) => t.userId.equals(userId)))
          .go();

  Future<void> deletePersonalTransaction(String transactionId) =>
      (delete(localPersonalTransactions)
            ..where((t) => t.transactionId.equals(transactionId)))
          .go();

  // ─── Friend operations ───
  Future<List<LocalFriend>> getFriendsForUser(String userId) =>
      (select(localFriends)
            ..where(
              (f) => f.userId.equals(userId) | f.friendId.equals(userId),
            ))
          .get();

  Stream<List<LocalFriend>> watchFriendsForUser(String userId) =>
      (select(localFriends)
            ..where(
              (f) => f.userId.equals(userId) | f.friendId.equals(userId),
            ))
          .watch();

  Future<void> upsertFriend(LocalFriendsCompanion row) =>
      into(localFriends).insertOnConflictUpdate(row);

  Future<void> replaceFriendsForUser(
    String userId,
    List<LocalFriendsCompanion> rows,
  ) async {
    await (delete(localFriends)
          ..where(
            (f) => f.userId.equals(userId) | f.friendId.equals(userId),
          ))
        .go();
    for (final row in rows) {
      await upsertFriend(row);
    }
  }

  // ─── Sync queue operations ───
  Future<List<SyncQueueData>> getPendingSyncItems() => (select(syncQueue)
        ..where((s) => s.status.equals(SyncStatusValues.pending)))
      .get();

  Future<void> addToSyncQueue(SyncQueueCompanion item) =>
      into(syncQueue).insert(item);

  Future<void> markSynced(int id) => (update(syncQueue)
        ..where((s) => s.id.equals(id)))
      .write(const SyncQueueCompanion(status: Value(SyncStatusValues.synced)));

  Future<void> markFailed(int id) =>
      (update(syncQueue)..where((s) => s.id.equals(id))).write(
          const SyncQueueCompanion(
              status: Value(SyncStatusValues.failed), retryCount: Value(0)));

  // ─── User cache operations ───
  Future<void> upsertUser(LocalUsersCacheCompanion user) =>
      into(localUsersCache).insertOnConflictUpdate(user);

  Future<LocalUsersCacheData?> getUser(String userId) =>
      (select(localUsersCache)..where((u) => u.userId.equals(userId)))
          .getSingleOrNull();

  /// Groups the given user belongs to (via local membership cache).
  Future<List<LocalGroup>> getGroupsForUser(String userId) async {
    final memberships = await (select(localGroupMembers)
          ..where((m) => m.userId.equals(userId)))
        .get();
    if (memberships.isEmpty) return [];

    final groupIds = memberships.map((m) => m.groupId).toList();
    return (select(localGroups)..where((g) => g.groupId.isIn(groupIds))).get();
  }

  /// Wipe all cached user data — required when switching accounts on one device.
  Future<void> clearAllUserData() async {
    await delete(localGroupTransactions).go();
    await delete(localGroupMembers).go();
    await delete(localGroups).go();
    await delete(localPersonalTransactions).go();
    await delete(localFriends).go();
    await delete(localUsersCache).go();
    await delete(syncQueue).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final newPath = p.join(dbFolder.path, AppBranding.localDbFileName);
    final legacyPath = p.join(dbFolder.path, AppBranding.legacyLocalDbFileName);

    final newFile = File(newPath);
    final legacyFile = File(legacyPath);

    if (!await newFile.exists() && await legacyFile.exists()) {
      try {
        await legacyFile.rename(newPath);
        debugPrint(
            'AppDatabase: migrated ${AppBranding.legacyLocalDbFileName} → ${AppBranding.localDbFileName}');
      } catch (e, stack) {
        AppErrorReporter.report(
          'AppDatabase legacy DB rename failed, opening legacy file',
          error: e,
          stack: stack,
          context: {'feature': 'database', 'operation': 'legacyDbRename'},
        );
        return NativeDatabase.createInBackground(legacyFile);
      }
    }

    return NativeDatabase.createInBackground(newFile);
  });
}
