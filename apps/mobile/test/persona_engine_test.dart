import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Utils/persona_engine.dart';

void main() {
  test('PersonaEngine picks settlement hero when enough settlements', () {
    final signals = RecapPersonaSignals(
      totalSpent: 10000,
      percentChange: 5,
      payerRatio: 20,
      goalsContributed: 0,
      groupCount: 1,
      settlementsThisMonth: 3,
    );

    final persona = PersonaEngine.resolve(signals);
    expect(persona.type, RecapPersonaTypes.settlementHero);
  });

  test('PersonaEngine picks goal grinder when savings share is high', () {
    final recap = {
      RecapDataKeys.totalSpent: 10000.0,
      RecapDataKeys.lastMonthTotal: 9000.0,
      RecapDataKeys.payerRatio: 10.0,
      RecapDataKeys.goalsContributedThisMonth: 1500.0,
      RecapDataKeys.groupCount: 0,
    };

    final signals =
        PersonaEngine.signalsFromRecap(recap, settlementsThisMonth: 0);
    final persona = PersonaEngine.resolve(signals);

    expect(persona.type, RecapPersonaTypes.goalGrinder);
  });

  test('PersonaEngine falls back to steady splitter', () {
    final signals = RecapPersonaSignals(
      totalSpent: 5000,
      percentChange: 2,
      payerRatio: 10,
      goalsContributed: 0,
      groupCount: 0,
      settlementsThisMonth: 0,
    );

    final persona = PersonaEngine.resolve(signals);
    expect(persona.type, RecapPersonaTypes.steadySplitter);
  });
}
