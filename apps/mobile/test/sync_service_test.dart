import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Services/local/database.dart';
import 'package:splitr/Services/sync_service.dart';
import 'package:splitr/Utils/sync_operation_planner.dart';

void main() {
  late AppDatabase db;
  late SyncService service;

  setUp(() {
    db = AppDatabase.forTesting();
    service = SyncService(db);
  });

  tearDown(() async {
    service.dispose();
    await db.close();
  });

  test('syncPendingItems emits synced when queue empty', () async {
    final statusFuture = service.syncStatus.take(2).toList();
    await Future<void>.delayed(Duration.zero);

    await service.syncPendingItems();

    final statuses = await statusFuture;
    expect(statuses, [SyncStatus.syncing, SyncStatus.synced]);
  });

  group('syncPendingItems with planExecutor', () {
    late List<SyncOperationPlan> executedPlans;

    setUp(() {
      executedPlans = [];
      service.dispose();
      service = SyncService(
        db,
        planExecutor: (plan) async {
          executedPlans.add(plan);
        },
      );
    });

    Future<void> enqueue({
      required String operation,
      required String recordId,
      required Map<String, dynamic> payload,
    }) {
      return db.addToSyncQueue(
        SyncQueueCompanion.insert(
          targetTable: 'personal_transaction',
          operation: operation,
          recordId: recordId,
          payload: jsonEncode(payload),
        ),
      );
    }

    test('processes INSERT and marks queue item synced', () async {
      await enqueue(
        operation: 'INSERT',
        recordId: 'tx-new',
        payload: {'id': 'tx-new', 'amount': 50},
      );

      await service.syncPendingItems();

      expect(executedPlans, hasLength(1));
      expect(executedPlans.single.operation, 'INSERT');
      expect(executedPlans.single.table, 'personal_transaction');
      expect(executedPlans.single.payload['amount'], 50);
      expect(await db.getPendingSyncItems(), isEmpty);
    });

    test('processes UPDATE with id filter', () async {
      await enqueue(
        operation: 'UPDATE',
        recordId: 'tx-7',
        payload: {'id': 'tx-7', 'description': 'Updated'},
      );

      await service.syncPendingItems();

      final plan = executedPlans.single;
      expect(plan.operation, 'UPDATE');
      expect(plan.filterField, 'id');
      expect(plan.filterValue, 'tx-7');
      expect(plan.payload['description'], 'Updated');
      expect(await db.getPendingSyncItems(), isEmpty);
    });

    test('processes DELETE with record id filter', () async {
      await enqueue(
        operation: 'DELETE',
        recordId: 'tx-del',
        payload: {},
      );

      await service.syncPendingItems();

      final plan = executedPlans.single;
      expect(plan.operation, 'DELETE');
      expect(plan.filterField, 'id');
      expect(plan.filterValue, 'tx-del');
      expect(await db.getPendingSyncItems(), isEmpty);
    });

    test('marks failed when executor throws', () async {
      service.dispose();
      service = SyncService(
        db,
        planExecutor: (_) async => throw Exception('network down'),
      );

      await enqueue(
        operation: 'INSERT',
        recordId: 'tx-fail',
        payload: {'id': 'tx-fail'},
      );

      await service.syncPendingItems();

      expect(await db.getPendingSyncItems(), isEmpty);
      final rows = await db.select(db.syncQueue).get();
      expect(rows.single.status, 'failed');
    });

    test('processes large queue in SYNC_CHUNK_SIZE chunks', () async {
      for (var i = 0; i < 11; i++) {
        await enqueue(
          operation: 'INSERT',
          recordId: 'tx-$i',
          payload: {'id': 'tx-$i', 'amount': i},
        );
      }

      await service.syncPendingItems();
      expect(executedPlans, hasLength(SYNC_CHUNK_SIZE));

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(executedPlans, hasLength(11));
      expect(await db.getPendingSyncItems(), isEmpty);
    });
  });
}
