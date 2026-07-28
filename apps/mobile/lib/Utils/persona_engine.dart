import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Utils/num_parsing.dart';

class RecapPersonaSignals {
  const RecapPersonaSignals({
    required this.totalSpent,
    required this.percentChange,
    required this.payerRatio,
    required this.goalsContributed,
    required this.groupCount,
    required this.settlementsThisMonth,
  });

  final double totalSpent;
  final double percentChange;
  final double payerRatio;
  final double goalsContributed;
  final int groupCount;
  final int settlementsThisMonth;
}

class PersonaResult {
  const PersonaResult({
    required this.type,
    required this.statOneLabelKey,
    required this.statOneValue,
    required this.statTwoLabelKey,
    required this.statTwoValue,
  });

  final String type;
  final String statOneLabelKey;
  final String statOneValue;
  final String statTwoLabelKey;
  final String statTwoValue;
}

/// Rule-based monthly recap persona — no AI.
abstract final class PersonaEngine {
  static const _goalSpendShare = 0.10;
  static const _groupHostPayerRatio = 60.0;
  static const _socialSplitterPayerRatio = 30.0;
  static const _quietMonthDropPct = -15.0;
  static const _settlementHeroMin = 3;
  static const _socialSplitterMinGroups = 2;

  static RecapPersonaSignals signalsFromRecap(
    Map<String, dynamic> recap, {
    required int settlementsThisMonth,
  }) {
    final totalSpent = asDouble(recap[RecapDataKeys.totalSpent]);
    final lastMonth = asDouble(recap[RecapDataKeys.lastMonthTotal]);
    var percentChange = 0.0;
    if (lastMonth > 0) {
      percentChange = ((totalSpent - lastMonth) / lastMonth) * 100;
    }

    return RecapPersonaSignals(
      totalSpent: totalSpent,
      percentChange: percentChange,
      payerRatio: asDouble(recap[RecapDataKeys.payerRatio]),
      goalsContributed:
          asDouble(recap[RecapDataKeys.goalsContributedThisMonth]),
      groupCount: asInt(recap[RecapDataKeys.groupCount]),
      settlementsThisMonth: settlementsThisMonth,
    );
  }

  static PersonaResult resolve(RecapPersonaSignals signals) {
    if (signals.settlementsThisMonth >= _settlementHeroMin) {
      return PersonaResult(
        type: RecapPersonaTypes.settlementHero,
        statOneLabelKey: RecapPersonaStatKeys.settlements,
        statOneValue: signals.settlementsThisMonth.toString(),
        statTwoLabelKey: RecapPersonaStatKeys.groups,
        statTwoValue: signals.groupCount.toString(),
      );
    }

    if (signals.goalsContributed > 0 &&
        signals.totalSpent > 0 &&
        signals.goalsContributed / signals.totalSpent >= _goalSpendShare) {
      return PersonaResult(
        type: RecapPersonaTypes.goalGrinder,
        statOneLabelKey: RecapPersonaStatKeys.saved,
        statOneValue: signals.goalsContributed.toStringAsFixed(0),
        statTwoLabelKey: RecapPersonaStatKeys.spendShare,
        statTwoValue:
            '${((signals.goalsContributed / signals.totalSpent) * 100).round()}%',
      );
    }

    if (signals.payerRatio >= _groupHostPayerRatio) {
      return PersonaResult(
        type: RecapPersonaTypes.groupHost,
        statOneLabelKey: RecapPersonaStatKeys.fronted,
        statOneValue: '${signals.payerRatio.round()}%',
        statTwoLabelKey: RecapPersonaStatKeys.groups,
        statTwoValue: signals.groupCount.toString(),
      );
    }

    if (signals.percentChange <= _quietMonthDropPct) {
      return PersonaResult(
        type: RecapPersonaTypes.quietMonth,
        statOneLabelKey: RecapPersonaStatKeys.spendChange,
        statOneValue: '${signals.percentChange.round()}%',
        statTwoLabelKey: RecapPersonaStatKeys.spent,
        statTwoValue: signals.totalSpent.toStringAsFixed(0),
      );
    }

    if (signals.groupCount >= _socialSplitterMinGroups &&
        signals.payerRatio >= _socialSplitterPayerRatio) {
      return PersonaResult(
        type: RecapPersonaTypes.socialSplitter,
        statOneLabelKey: RecapPersonaStatKeys.groups,
        statOneValue: signals.groupCount.toString(),
        statTwoLabelKey: RecapPersonaStatKeys.fronted,
        statTwoValue: '${signals.payerRatio.round()}%',
      );
    }

    return PersonaResult(
      type: RecapPersonaTypes.steadySplitter,
      statOneLabelKey: RecapPersonaStatKeys.spent,
      statOneValue: signals.totalSpent.toStringAsFixed(0),
      statTwoLabelKey: RecapPersonaStatKeys.spendChange,
      statTwoValue: '${signals.percentChange.round()}%',
    );
  }

  static Map<String, dynamic> toRecapPayload(
    PersonaResult persona, {
    String? badgeName,
    String? badgeDescription,
  }) {
    return {
      RecapDataKeys.hasPersonaSlide: true,
      RecapDataKeys.personaType: persona.type,
      RecapDataKeys.personaStatOneLabel: persona.statOneLabelKey,
      RecapDataKeys.personaStatOneValue: persona.statOneValue,
      RecapDataKeys.personaStatTwoLabel: persona.statTwoLabelKey,
      RecapDataKeys.personaStatTwoValue: persona.statTwoValue,
      RecapDataKeys.hasMonthlyBadge: badgeName != null && badgeName.isNotEmpty,
      RecapDataKeys.monthlyBadgeName: badgeName,
      RecapDataKeys.monthlyBadgeDescription: badgeDescription,
    };
  }

  static Map<String, dynamic> fallbackPayload() => toRecapPayload(
        const PersonaResult(
          type: RecapPersonaTypes.steadySplitter,
          statOneLabelKey: RecapPersonaStatKeys.spent,
          statOneValue: '0',
          statTwoLabelKey: RecapPersonaStatKeys.spendChange,
          statTwoValue: '0%',
        ),
      );
}
