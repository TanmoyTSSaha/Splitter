import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Services/local/database.dart';
import 'package:splitr/Utils/sync_operation_planner.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting();
  });

  tearDown(() async {
    await db.close();
  });

  test('addToSyncQueue enqueues pending personal transaction INSERT', () async {
    await db.addToSyncQueue(
      SyncQueueCompanion.insert(
        targetTable: 'personal_transaction',
        operation: 'INSERT',
        recordId: 'tx-1',
        payload: jsonEncode({
          'id': 'tx-1',
          'amount': 120,
          'description': 'Coffee',
        }),
      ),
    );

    final pending = await db.getPendingSyncItems();
    expect(pending, hasLength(1));
    expect(pending.first.targetTable, 'personal_transaction');
    expect(pending.first.operation, 'INSERT');
    expect(pending.first.recordId, 'tx-1');
    expect(pending.first.status, 'pending');
  });

  test('markSynced removes item from pending queue', () async {
    await db.addToSyncQueue(
      SyncQueueCompanion.insert(
        targetTable: 'group_transaction',
        operation: 'UPDATE',
        recordId: 'gt-9',
        payload:
            jsonEncode({'transaction_id': 'gt-9', 'description': 'Dinner'}),
      ),
    );

    final item = (await db.getPendingSyncItems()).single;
    await db.markSynced(item.id);

    expect(await db.getPendingSyncItems(), isEmpty);
  });

  test('markFailed keeps item out of pending list', () async {
    await db.addToSyncQueue(
      SyncQueueCompanion.insert(
        targetTable: 'personal_transaction',
        operation: 'DELETE',
        recordId: 'tx-del',
        payload: jsonEncode({}),
      ),
    );

    final item = (await db.getPendingSyncItems()).single;
    await db.markFailed(item.id);

    expect(await db.getPendingSyncItems(), isEmpty);

    final rows = await db.select(db.syncQueue).get();
    expect(rows, hasLength(1));
    expect(rows.first.status, 'failed');
  });

  test('getPendingSyncItems returns only pending rows', () async {
    await db.addToSyncQueue(
      SyncQueueCompanion.insert(
        targetTable: 'personal_transaction',
        operation: 'INSERT',
        recordId: 'a',
        payload: jsonEncode({'id': 'a'}),
      ),
    );
    await db.addToSyncQueue(
      SyncQueueCompanion.insert(
        targetTable: 'personal_transaction',
        operation: 'INSERT',
        recordId: 'b',
        payload: jsonEncode({'id': 'b'}),
      ),
    );

    final first = (await db.getPendingSyncItems()).first;
    await db.markSynced(first.id);

    final stillPending = await db.getPendingSyncItems();
    expect(stillPending, hasLength(1));
    expect(stillPending.single.recordId, 'b');
  });

  test('queued UPDATE payload maps to sync plan filter', () async {
    await db.addToSyncQueue(
      SyncQueueCompanion.insert(
        targetTable: 'personal_transaction',
        operation: 'UPDATE',
        recordId: 'tx-42',
        payload: jsonEncode({
          'id': 'tx-42',
          'amount': 99,
          'description': 'Lunch',
        }),
      ),
    );

    final item = (await db.getPendingSyncItems()).single;
    final payload = jsonDecode(item.payload) as Map<String, dynamic>;
    final plan = planSyncOperation(
      targetTable: item.targetTable,
      operation: item.operation,
      recordId: item.recordId,
      payload: payload,
    );

    expect(plan.filterField, 'id');
    expect(plan.filterValue, 'tx-42');
    expect(plan.payload['amount'], 99);
  });

  test('clearAllUserData wipes sync queue', () async {
    await db.addToSyncQueue(
      SyncQueueCompanion.insert(
        targetTable: 'personal_transaction',
        operation: 'INSERT',
        recordId: 'wipe-me',
        payload: jsonEncode({'id': 'wipe-me'}),
      ),
    );

    await db.clearAllUserData();

    expect(await db.getPendingSyncItems(), isEmpty);
    expect(await db.select(db.syncQueue).get(), isEmpty);
  });
}
