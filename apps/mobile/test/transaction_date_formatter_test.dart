import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Utils/transaction_date_formatter.dart';

void main() {
  group('TransactionDateFormatter timezone helpers', () {
    test('toStorageIso writes UTC instant for local capture', () {
      final local = DateTime(2026, 7, 12, 21, 15);
      final iso = TransactionDateFormatter.toStorageIso(local);

      expect(iso.endsWith('Z'), isTrue);
      expect(iso.contains('T15:45:00'), isTrue);
    });

    test('parseStorage returns local wall clock from UTC storage', () {
      final parsed =
          TransactionDateFormatter.parseStorage('2026-07-12T15:45:00.000Z');

      expect(parsed, isNotNull);
      expect(parsed!.hour, 21);
      expect(parsed.minute, 15);
    });

    test('round-trip preserves local capture time', () {
      final capture = DateTime(2026, 3, 5, 9, 30);
      final roundTrip = TransactionDateFormatter.parseStorage(
        TransactionDateFormatter.toStorageIso(capture),
      );

      expect(roundTrip?.year, capture.year);
      expect(roundTrip?.month, capture.month);
      expect(roundTrip?.day, capture.day);
      expect(roundTrip?.hour, capture.hour);
      expect(roundTrip?.minute, capture.minute);
    });

    test('parseStorage accepts DateTime from drift', () {
      final utc = DateTime.utc(2026, 7, 12, 15, 45);
      final local = TransactionDateFormatter.parseStorage(utc);

      expect(local?.hour, 21);
      expect(local?.minute, 15);
    });
  });
}
