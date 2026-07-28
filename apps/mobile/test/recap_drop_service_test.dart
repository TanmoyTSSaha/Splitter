import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Services/recap_drop_service.dart';

void main() {
  test('dropMonth returns current calendar month', () {
    expect(
      RecapDropService.dropMonth(DateTime(2026, 2, 10)),
      DateTime(2026, 2, 1),
    );
    expect(
      RecapDropService.dropMonth(DateTime(2026, 1, 5)),
      DateTime(2026, 1, 1),
    );
  });

  test('shouldShowDropPromo only in first week when current month unviewed',
      () {
    final now = DateTime(2026, 2, 3);
    expect(
      RecapDropService.shouldShowDropPromo(now, '2026-01'),
      isTrue,
    );
    expect(
      RecapDropService.shouldShowDropPromo(now, '2026-02'),
      isFalse,
    );
    expect(
      RecapDropService.shouldShowDropPromo(DateTime(2026, 2, 10), '2026-02'),
      isFalse,
    );
  });

  test('shouldShowProfileDot when current month unviewed', () {
    final now = DateTime(2026, 3, 15);
    expect(
      RecapDropService.profileDotVisible(now, '2026-02'),
      isTrue,
    );
    expect(
      RecapDropService.profileDotVisible(now, '2026-03'),
      isFalse,
    );
  });

  test('introAutoEligible only before first intro auto-play', () {
    expect(RecapDropService.introAutoEligible(false), isTrue);
    expect(RecapDropService.introAutoEligible(true), isFalse);
  });
}
