import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Services/upi_settle_service.dart';

void main() {
  group('UpiSettleService', () {
    test('buildLink includes sanitized tn note with payee', () {
      final uri = UpiSettleService.buildLink(
        payeeVpa: 'friend@okhdfc',
        payeeName: 'Alice',
        amountInr: 250,
        note: AppStringFormat.upiSettleNote('Alice'),
      );

      expect(uri.queryParameters[UpiQueryParams.note], isNotNull);
      expect(uri.queryParameters[UpiQueryParams.note]!, contains('Alice'));
      expect(
        uri.queryParameters[UpiQueryParams.note]!.length,
        lessThanOrEqualTo(UpiSettleService.maxNoteLength),
      );
    });

    test('sanitizeNote strips unsupported characters', () {
      expect(
        UpiSettleService.sanitizeNote('Splitr Pro — hi 🫡'),
        'Splitr Pro hi',
      );
    });
  });
}
