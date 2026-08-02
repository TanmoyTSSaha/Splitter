import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Utils/sync_table_keys.dart';

void main() {
  test('syncPrimaryKeyField maps known tables', () {
    expect(syncPrimaryKeyField('groups'), 'group_id');
    expect(syncPrimaryKeyField('group_transaction'), 'transaction_id');
    expect(syncPrimaryKeyField('personal_transaction'), 'id');
    expect(syncPrimaryKeyField('friends'), 'id');
  });

  test('syncPrimaryKeyField defaults to id', () {
    expect(syncPrimaryKeyField('unknown_table'), 'id');
  });
}
