import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Model/user_upi_account_model.dart';

void main() {
  group('UserUpiAccount', () {
    test('fromJson and toJson round-trip', () {
      final json = {
        SupabaseColumns.id: 'id-1',
        SupabaseColumns.userId: 'user-1',
        SupabaseColumns.vpa: 'rahul@okhdfcbank',
        SupabaseColumns.bankAlias: 'HDFC Bank',
        SupabaseColumns.isPrimary: true,
        SupabaseColumns.createdAt: '2026-07-11T12:00:00.000Z',
      };

      final account = UserUpiAccount.fromJson(json);
      expect(account.id, 'id-1');
      expect(account.userId, 'user-1');
      expect(account.vpa, 'rahul@okhdfcbank');
      expect(account.bankAlias, 'HDFC Bank');
      expect(account.isPrimary, isTrue);
      expect(account.createdAt, isNotNull);

      final out = account.toJson();
      expect(out[SupabaseColumns.vpa], 'rahul@okhdfcbank');
      expect(out[SupabaseColumns.bankAlias], 'HDFC Bank');
      expect(out[SupabaseColumns.isPrimary], isTrue);
    });
  });
}
