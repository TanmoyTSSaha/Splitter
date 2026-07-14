import 'package:splitr/Constants/app_keys.dart';

/// Primary key column names for Supabase tables in the sync queue.
String syncPrimaryKeyField(String tableName) {
  switch (tableName) {
    case SupabaseTables.groups:
      return SupabaseColumns.groupId;
    case SupabaseTables.groupTransaction:
      return SupabaseColumns.transactionId;
    case SupabaseTables.personalTransaction:
      return SupabaseColumns.id;
    case SupabaseTables.friends:
      return SupabaseColumns.id;
    default:
      return SupabaseColumns.id;
  }
}
