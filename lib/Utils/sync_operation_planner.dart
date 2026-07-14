import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Utils/sync_table_keys.dart';

/// Describes how a queued mutation should be applied to Supabase.
class SyncOperationPlan {
  final String table;
  final String operation;
  final Map<String, dynamic> payload;
  final String? filterField;
  final dynamic filterValue;

  const SyncOperationPlan({
    required this.table,
    required this.operation,
    required this.payload,
    this.filterField,
    this.filterValue,
  });
}

SyncOperationPlan planSyncOperation({
  required String targetTable,
  required String operation,
  required String recordId,
  required Map<String, dynamic> payload,
}) {
  switch (operation) {
    case SyncOperations.insert:
      return SyncOperationPlan(
        table: targetTable,
        operation: operation,
        payload: payload,
      );
    case SyncOperations.update:
      final idField = syncPrimaryKeyField(targetTable);
      return SyncOperationPlan(
        table: targetTable,
        operation: operation,
        payload: payload,
        filterField: idField,
        filterValue: payload[idField],
      );
    case SyncOperations.delete:
      final idField = syncPrimaryKeyField(targetTable);
      return SyncOperationPlan(
        table: targetTable,
        operation: operation,
        payload: payload,
        filterField: idField,
        filterValue: recordId,
      );
    default:
      throw ArgumentError(AppStrings.errors.unknownSyncOperation(operation));
  }
}
