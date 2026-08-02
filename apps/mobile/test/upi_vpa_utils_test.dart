import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Utils/upi_vpa_utils.dart';

void main() {
  group('UpiVpaUtils.validateAndNormalize', () {
    test('accepts valid VPA', () {
      expect(
        UpiVpaUtils.validateAndNormalize('Rahul@OkHDFCBank'),
        'rahul@okhdfcbank',
      );
    });

    test('rejects invalid VPA', () {
      expect(UpiVpaUtils.validateAndNormalize('not-a-vpa'), isNull);
      expect(UpiVpaUtils.validateAndNormalize(''), isNull);
      expect(UpiVpaUtils.validateAndNormalize('@bank'), isNull);
    });
  });

  group('UpiVpaUtils.maskVpa', () {
    test('masks local part', () {
      expect(
        UpiVpaUtils.maskVpa('rahul@okhdfcbank'),
        'ra***@okhdfcbank',
      );
    });

    test('handles short local part', () {
      expect(UpiVpaUtils.maskVpa('ab@paytm'), 'a***@paytm');
    });
  });
}
