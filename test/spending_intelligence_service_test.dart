import 'package:flutter_test/flutter_test.dart';
import 'package:splitter/Services/spending_intelligence_service.dart';

void main() {
  group('SpendingIntelligenceService calculations', () {
    test('calculateHealthScore returns 40 when spend up more than 50%', () {
      expect(SpendingIntelligenceService.calculateHealthScore(2000, 1000), 40);
    });

    test('calculateHealthScore returns 60 when spend up 20-50%', () {
      expect(SpendingIntelligenceService.calculateHealthScore(1300, 1000), 60);
    });

    test('calculateHealthScore returns 90 when spend decreased', () {
      expect(SpendingIntelligenceService.calculateHealthScore(800, 1000), 90);
    });

    test('calculateHealthScore returns 80 when steady or no prior month', () {
      expect(SpendingIntelligenceService.calculateHealthScore(1050, 1000), 80);
      expect(SpendingIntelligenceService.calculateHealthScore(500, 0), 80);
    });

    test('scoreLabel maps thresholds correctly', () {
      expect(SpendingIntelligenceService.scoreLabel(85), 'Good');
      expect(SpendingIntelligenceService.scoreLabel(65), 'Watch');
      expect(SpendingIntelligenceService.scoreLabel(30), 'Needs attention');
    });

    test('spendingExplanation reflects percent change', () {
      expect(
        SpendingIntelligenceService.spendingExplanation(55),
        contains('55%'),
      );
      expect(
        SpendingIntelligenceService.spendingExplanation(-15),
        contains('down'),
      );
      expect(
        SpendingIntelligenceService.spendingExplanation(5),
        contains('steady'),
      );
    });

    test('settleUpExplanation mentions open exposure when low score', () {
      final msg = SpendingIntelligenceService.settleUpExplanation(2000, 30);
      expect(msg, contains('2000'));
    });

    test('settleUpExplanation celebrates zero exposure', () {
      final msg = SpendingIntelligenceService.settleUpExplanation(0, 100);
      expect(msg, contains('settled'));
    });
  });

  group('month-end projection', () {
    test('projects month-end from daily burn', () {
      final now = DateTime(2026, 6, 15);
      final result =
          SpendingIntelligenceService.computeMonthEndProjection(1500, now);
      expect(result['dailyBurn'], 100.0);
      expect(result['projection'], 3000.0);
      expect(result['daysInMonth'], 30.0);
    });
  });
}
