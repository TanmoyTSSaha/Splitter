import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Utils/upi_sms_parser.dart';

void main() {
  test('parses Rs amount and merchant', () {
    final draft = UpiSmsParser.parse(
      'Rs 1,250.50 spent at Swiggy on 10-Jul-26',
    );
    expect(draft, isNotNull);
    expect(draft!.amount, 1250.50);
    expect(draft.merchant, contains('Swiggy'));
  });

  test('parses INR debited pattern', () {
    final draft = UpiSmsParser.parse(
      'INR 499 debited from A/c **1234 paid to NETFLIX',
    );
    expect(draft?.amount, 499);
    expect(draft?.merchant, isNotNull);
  });

  test('returns null when no amount', () {
    expect(UpiSmsParser.parse('Payment successful'), isNull);
  });
}
