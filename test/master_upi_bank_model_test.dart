import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Model/master_upi_bank_model.dart';

void main() {
  test('MasterUpiBank.fromJson parses row', () {
    final bank = MasterUpiBank.fromJson({
      SupabaseColumns.bankSlug: 'hdfc_bank',
      SupabaseColumns.bankName: 'HDFC Bank',
      SupabaseColumns.sortOrder: 22,
      SupabaseColumns.isActive: true,
    });

    expect(bank.bankSlug, 'hdfc_bank');
    expect(bank.bankName, 'HDFC Bank');
    expect(bank.sortOrder, 22);
    expect(bank.isActive, isTrue);
  });
}
