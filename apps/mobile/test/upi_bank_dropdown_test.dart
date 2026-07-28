import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Model/master_upi_bank_model.dart';
import 'package:splitr/Utils/upi_bank_dropdown_utils.dart';

void main() {
  final banks = [
    const MasterUpiBank(bankSlug: 'hdfc_bank', bankName: 'HDFC Bank'),
    const MasterUpiBank(bankSlug: 'hdfc_bank', bankName: 'HDFC Duplicate'),
    const MasterUpiBank(bankSlug: 'icici_bank', bankName: 'ICICI Bank'),
  ];

  group('upi_bank_dropdown_utils', () {
    test('dedupeMasterUpiBanks keeps first slug only', () {
      final deduped = dedupeMasterUpiBanks(banks);
      expect(deduped, hasLength(2));
      expect(deduped.first.bankName, 'HDFC Bank');
    });

    test('resolveUpiBankDropdownSlug maps known alias', () {
      expect(
        resolveUpiBankDropdownSlug(bankAlias: 'ICICI Bank', banks: banks),
        'icici_bank',
      );
    });

    test('resolveUpiBankDropdownSlug maps custom alias to other', () {
      expect(
        resolveUpiBankDropdownSlug(bankAlias: 'My Wallet', banks: banks),
        UpiBankDropdownSentinel.other,
      );
    });

    test('bankAliasForSlug uses master name or custom text', () {
      expect(
        bankAliasForSlug(
          selectedSlug: 'hdfc_bank',
          banks: banks,
          customBankName: '',
        ),
        'HDFC Bank',
      );
      expect(
        bankAliasForSlug(
          selectedSlug: UpiBankDropdownSentinel.other,
          banks: banks,
          customBankName: '  My Bank  ',
        ),
        'My Bank',
      );
    });
  });
}
