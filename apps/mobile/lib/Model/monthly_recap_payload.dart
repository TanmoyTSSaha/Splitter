import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Model/loan_payment_recap_row.dart';
import 'package:splitr/Utils/num_parsing.dart';

/// Typed view over [RecapDataKeys] map from [MonthlyRecapAggregator.load].
class MonthlyRecapPayload {
  MonthlyRecapPayload(this.data);

  final Map<String, dynamic> data;

  factory MonthlyRecapPayload.fromMap(Map<String, dynamic> map) =>
      MonthlyRecapPayload(Map<String, dynamic>.from(map));

  Map<String, dynamic> toMap() => Map<String, dynamic>.from(data);

  DateTime get month => data[RecapDataKeys.month] as DateTime;

  double get totalSpent => asDouble(data[RecapDataKeys.totalSpent]);

  double get lastMonthTotal => asDouble(data[RecapDataKeys.lastMonthTotal]);

  String get topCategory =>
      data[RecapDataKeys.topCategory] as String? ?? DisplayFallbacks.none;

  double get topCategoryAmount =>
      asDouble(data[RecapDataKeys.topCategoryAmount]);

  int get topCategoryRank => asInt(data[RecapDataKeys.topCategoryRank], 1);

  String get habitType =>
      data[RecapDataKeys.habitType] as String? ?? RecapHabitTypes.quietMonth;

  int get habitTransactionCount =>
      asInt(data[RecapDataKeys.habitTransactionCount]);

  bool get hasGroupActivity =>
      data[RecapDataKeys.hasGroupActivity] == true;

  int get groupCount => asInt(data[RecapDataKeys.groupCount]);

  String? get topGroupName => data[RecapDataKeys.topGroupName] as String?;

  double get payerRatio => asDouble(data[RecapDataKeys.payerRatio]);

  int get settlementAvgDays => asInt(data[RecapDataKeys.settlementAvgDays]);

  int get settleUpHealthScore =>
      asInt(data[RecapDataKeys.settleUpHealthScore], InsightsLimits.settleHealthDefault);

  String? get topFriendName => data[RecapDataKeys.topFriendName] as String?;

  List<Map<String, dynamic>> get groupFriendPeers {
    final raw = data[RecapDataKeys.groupFriendPeers];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  bool get hasLendingActivity =>
      data[RecapDataKeys.hasLendingActivity] == true;

  int get activeLoanCount => asInt(data[RecapDataKeys.activeLoanCount]);

  double get totalLoanOutstanding =>
      asDouble(data[RecapDataKeys.totalLoanOutstanding]);

  int get loansWithPaymentThisMonth =>
      asInt(data[RecapDataKeys.loansWithPaymentThisMonth]);

  double get totalRepaidThisMonth =>
      asDouble(data[RecapDataKeys.totalRepaidThisMonth]);

  int get loansCompletedThisMonth =>
      asInt(data[RecapDataKeys.loansCompletedThisMonth]);

  String get topLoanTitle =>
      data[RecapDataKeys.topLoanTitle] as String? ?? DisplayFallbacks.untitled;

  double get topLoanProgress => asDouble(data[RecapDataKeys.topLoanProgress]);

  List<LoanPaymentRecapRow> get lendingLedgerRows {
    final raw = data[RecapDataKeys.lendingLedgerRows];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => LoanPaymentRecapRow.fromLedgerMap(
              Map<String, dynamic>.from(e),
            ))
        .toList();
  }

  bool get hasGoalsActivity => data[RecapDataKeys.hasGoalsActivity] == true;

  int get activeGoalsCount => asInt(data[RecapDataKeys.activeGoalsCount]);

  String get bestGoalTitle =>
      data[RecapDataKeys.bestGoalTitle] as String? ?? DisplayFallbacks.goal;

  double get bestGoalProgress => asDouble(data[RecapDataKeys.bestGoalProgress]);

  double get goalsContributedThisMonth =>
      asDouble(data[RecapDataKeys.goalsContributedThisMonth]);

  String? get goalsMotivationLine =>
      data[RecapDataKeys.goalsMotivationLine] as String?;

  int get goalsAtTargetCount => asInt(data[RecapDataKeys.goalsAtTargetCount]);

  bool get goalCompletedInMonth =>
      data[RecapDataKeys.goalCompletedInMonth] == true;

  bool get hasPersonaSlide => data[RecapDataKeys.hasPersonaSlide] == true;

  String get personaType =>
      data[RecapDataKeys.personaType] as String? ?? DisplayFallbacks.none;

  List<Map<String, dynamic>> get spendingTrend {
    final raw = data[RecapDataKeys.spendingTrend];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  bool get hasSpendingData => totalSpent > 0;
}
