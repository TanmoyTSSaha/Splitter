import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Controllers/premium_subscription_controller.dart';

void main() {
  group('PremiumSubscriptionStatus', () {
    test('enum values cover subscription lifecycle', () {
      expect(PremiumSubscriptionStatus.values, contains(PremiumSubscriptionStatus.none));
      expect(PremiumSubscriptionStatus.values, contains(PremiumSubscriptionStatus.pending));
      expect(PremiumSubscriptionStatus.values, contains(PremiumSubscriptionStatus.active));
      expect(PremiumSubscriptionStatus.values, contains(PremiumSubscriptionStatus.cancelled));
    });
  });
}
