import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/shared.dart';
import 'package:splitr/Widgets/insights_promo_card.dart';

import '../helpers/component_test_harness.dart';

void main() {
  tearDown(ComponentTestHarness.tearDownGetX);

  group('getInitials', () {
    test('returns first letter of each word', () {
      expect(getInitials('Alex Kim'), 'AK');
      expect(getInitials('Sam'), 'S');
    });
  });

  group('InsightsPromoCard', () {
    testWidgets('stays hidden when promo already shown this session',
        (tester) async {
      await ComponentTestHarness.mockSharedPreferences({
        'insights_promo_session_shown': true,
      });

      await ComponentTestHarness.pump(
        tester,
        const InsightsPromoCard(),
      );
      await tester.pump();

      expect(find.text('Expense Insights'), findsNothing);
    });

    testWidgets('stays hidden when dismissed within 24 hours', (tester) async {
      await ComponentTestHarness.mockSharedPreferences({
        'insights_promo_dismissed_at': DateTime.now().toIso8601String(),
      });

      await ComponentTestHarness.pump(
        tester,
        const InsightsPromoCard(),
      );
      await tester.pump();

      expect(find.text('Expense Insights'), findsNothing);
    });
  });
}
