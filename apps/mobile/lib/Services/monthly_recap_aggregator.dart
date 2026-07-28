import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Model/loan_payment_recap_row.dart';
import 'package:splitr/Model/monthly_recap_payload.dart';
import 'package:splitr/Model/financial_goal_model.dart';
import 'package:splitr/Model/loan_model.dart';
import 'package:splitr/Services/SupabaseServices/goal_service.dart';
import 'package:splitr/Services/SupabaseServices/loan_service.dart';
import 'package:splitr/Services/achievement_service.dart';
import 'package:splitr/Services/gamification_service.dart';
import 'package:splitr/Services/spending_intelligence_service.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Utils/persona_engine.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Injectable slice providers for [MonthlyRecapAggregator.load] unit tests (F12).
@immutable
class MonthlyRecapAggregatorTestHooks {
  const MonthlyRecapAggregatorTestHooks({
    this.userId = 'test-user-id',
    this.generateBaseRecap,
    this.fetchSpendingTrend,
    this.fetchWeekdayHabit,
    this.fetchSocialTrust,
    this.fetchLendingSnapshot,
    this.fetchGoalsSnapshot,
    this.fetchGroupActivity,
    this.fetchPersonaSlice,
    this.fetchSettleUpHealthScore,
    this.fetchSettlementsClosed,
  });

  final String userId;
  final Future<Map<String, dynamic>> Function(DateTime month)? generateBaseRecap;
  final Future<List<Map<String, dynamic>>> Function(DateTime month)?
      fetchSpendingTrend;
  final Future<Map<String, dynamic>> Function(DateTime month)? fetchWeekdayHabit;
  final Future<Map<String, dynamic>> Function()? fetchSocialTrust;
  final Future<Map<String, dynamic>> Function(DateTime month)?
      fetchLendingSnapshot;
  final Future<Map<String, dynamic>> Function(DateTime month)?
      fetchGoalsSnapshot;
  final Future<Map<String, dynamic>> Function(DateTime month)?
      fetchGroupActivity;
  final Future<Map<String, dynamic>> Function(
    DateTime month,
    Map<String, dynamic> recap,
  )? fetchPersonaSlice;
  final Future<int> Function()? fetchSettleUpHealthScore;
  final Future<int> Function(DateTime month)? fetchSettlementsClosed;
}

/// Loads personal recap data plus trend + habit slices for story slides.
class MonthlyRecapAggregator {
  MonthlyRecapAggregator({
    GamificationService? gamification,
    SpendingIntelligenceService? spending,
    LoanService? loans,
    GoalService? goals,
    AchievementService? achievements,
    @visibleForTesting MonthlyRecapAggregatorTestHooks? testHooks,
  })  : _gamification = gamification,
        _spending = spending,
        _loans = loans,
        _goals = goals,
        _achievements = achievements,
        _testHooks = testHooks;

  GamificationService? _gamification;
  SpendingIntelligenceService? _spending;
  LoanService? _loans;
  GoalService? _goals;
  AchievementService? _achievements;
  final MonthlyRecapAggregatorTestHooks? _testHooks;

  GamificationService get _gamificationLive =>
      _gamification ??= GamificationService();

  SpendingIntelligenceService get _spendingLive =>
      _spending ??= SpendingIntelligenceService();

  LoanService get _loansLive => _loans ??= LoanService();

  GoalService get _goalsLive => _goals ??= GoalService();

  AchievementService get _achievementsLive =>
      _achievements ??= AchievementService();

  String get _userId =>
      _testHooks?.userId ?? SupabaseAuth().supabaseGetUserID();

  static const _sliceTimeout = Duration(seconds: 8);

  Future<T> _sliceOrLive<T>(Future<T>? hooked, Future<T> Function() live) {
    return (hooked ?? live()).timeout(_sliceTimeout);
  }

  Future<Map<String, dynamic>> load(DateTime month) async {
    final hooks = _testHooks;
    final base = hooks?.generateBaseRecap != null
        ? await hooks!.generateBaseRecap!(month)
        : await _gamificationLive.generateRecap(month);

    var trend = <Map<String, dynamic>>[];
    var habit = <String, dynamic>{
      RecapDataKeys.habitType: RecapHabitTypes.quietMonth,
      RecapDataKeys.habitTransactionCount: 0,
    };
    var social = <String, dynamic>{
      RecapDataKeys.groupCount: 0,
      RecapDataKeys.openExposure: 0.0,
      RecapDataKeys.settlementAvgDays: 0,
    };
    var lending = <String, dynamic>{
      RecapDataKeys.hasLendingActivity: false,
    };
    var goals = <String, dynamic>{
      RecapDataKeys.hasGoalsActivity: false,
    };
    var monthlyGroup = <String, dynamic>{
      RecapDataKeys.hasGroupActivity: false,
    };

    try {
      final results = await Future.wait([
        _sliceOrLive(
          hooks?.fetchSpendingTrend?.call(month),
          () => _spendingLive.getSpendingTrendEndingAt(month),
        ),
        _sliceOrLive(
          hooks?.fetchWeekdayHabit?.call(month),
          () => _spendingLive.computeWeekdaySpendPattern(month),
        ),
        _sliceOrLive(
          hooks?.fetchSocialTrust?.call(),
          () => _spendingLive.getSocialTrustInsights(),
        ),
        _sliceOrLive(
          hooks?.fetchLendingSnapshot?.call(month),
          () => getMonthlyLendingSnapshot(month),
        ),
        _sliceOrLive(
          hooks?.fetchGoalsSnapshot?.call(month),
          () => getMonthlyGoalsSnapshot(month),
        ),
        _sliceOrLive(
          hooks?.fetchGroupActivity?.call(month),
          () => getMonthlyGroupActivity(month),
        ),
      ]);
      trend = List<Map<String, dynamic>>.from(results[0] as List);
      habit = Map<String, dynamic>.from(results[1] as Map);
      social = Map<String, dynamic>.from(results[2] as Map);
      lending = Map<String, dynamic>.from(results[3] as Map);
      goals = Map<String, dynamic>.from(results[4] as Map);
      monthlyGroup = Map<String, dynamic>.from(results[5] as Map);
    } on TimeoutException {
      // Keep defaults above.
    }

    Map<String, dynamic> persona;
    try {
      persona = await _sliceOrLive(
        hooks?.fetchPersonaSlice != null
            ? hooks!.fetchPersonaSlice!(month, Map<String, dynamic>.from(base))
            : null,
        () => getMonthlyPersonaSlice(month, base),
      );
    } on TimeoutException {
      persona = PersonaEngine.fallbackPayload();
    }

    var settleScore = InsightsLimits.settleHealthDefault;
    try {
      settleScore = await _sliceOrLive(
        hooks?.fetchSettleUpHealthScore?.call(),
        () => _spendingLive.getSettleUpHealthScore(),
      );
    } on TimeoutException {
      settleScore = InsightsLimits.settleHealthDefault;
    }

    var settlementsClosed = 0;
    try {
      settlementsClosed = await _sliceOrLive(
        hooks?.fetchSettlementsClosed?.call(month),
        () => _countSettlementsInMonth(month),
      );
    } on TimeoutException {
      settlementsClosed = 0;
    }

    return mergeSlicesForTest(
      base: base,
      trend: trend,
      habit: habit,
      social: social,
      lending: lending,
      goals: goals,
      monthlyGroup: monthlyGroup,
      persona: persona,
      settleUpHealthScore: settleScore,
      settlementsClosedCount: settlementsClosed,
    );
  }

  /// Merges fetched slices into base recap — test hook without Supabase IO.
  @visibleForTesting
  static Map<String, dynamic> mergeSlicesForTest({
    required Map<String, dynamic> base,
    required List<Map<String, dynamic>> trend,
    required Map<String, dynamic> habit,
    required Map<String, dynamic> social,
    required Map<String, dynamic> lending,
    required Map<String, dynamic> goals,
    required Map<String, dynamic> monthlyGroup,
    required Map<String, dynamic> persona,
    int settleUpHealthScore = InsightsLimits.settleHealthDefault,
    int settlementsClosedCount = 0,
  }) {
    base[RecapDataKeys.spendingTrend] = trend;
    base[RecapDataKeys.habitType] =
        habit[RecapDataKeys.habitType] ?? RecapHabitTypes.quietMonth;
    base[RecapDataKeys.habitTransactionCount] =
        habit[RecapDataKeys.habitTransactionCount] ?? 0;

    final hasMonthlyGroup =
        monthlyGroup[RecapDataKeys.hasGroupActivity] == true;
    base[RecapDataKeys.hasGroupActivity] = hasMonthlyGroup;
    if (hasMonthlyGroup) {
      base[RecapDataKeys.groupCount] =
          monthlyGroup[RecapDataKeys.groupCount] ?? 0;
      base[RecapDataKeys.payerRatio] =
          monthlyGroup[RecapDataKeys.payerRatio] ?? 0.0;
      base[RecapDataKeys.topFriendName] =
          monthlyGroup[RecapDataKeys.topFriendName];
      base[RecapDataKeys.groupFriendPeers] =
          monthlyGroup[RecapDataKeys.groupFriendPeers];
    } else {
      base[RecapDataKeys.groupCount] = social[RecapDataKeys.groupCount] ?? 0;
      base[RecapDataKeys.payerRatio] = social[RecapDataKeys.payerRatio] ?? 0.0;
    }

    base[RecapDataKeys.openExposure] =
        social[RecapDataKeys.openExposure] ?? 0.0;
    base[RecapDataKeys.topGroupName] = social['topGroupName'];
    base[RecapDataKeys.settlementAvgDays] =
        social[RecapDataKeys.settlementAvgDays] ?? 0;
    base.addAll(lending);
    base.addAll(goals);
    base[RecapDataKeys.topCategoryRank] = _topCategoryRank(
      base[RecapDataKeys.categoryBreakdown] as Map<String, double>? ?? {},
      base[RecapDataKeys.topCategory] as String? ?? DisplayFallbacks.none,
    );
    base.addAll(persona);
    base[RecapDataKeys.settleUpHealthScore] = settleUpHealthScore;
    base[RecapDataKeys.expenseTotal] =
        (base[RecapDataKeys.totalSpent] as num?)?.toDouble() ?? 0.0;
    base[RecapDataKeys.settlementsClosedCount] = settlementsClosedCount;
    return base;
  }

  Future<MonthlyRecapPayload> loadPayload(DateTime month) async {
    final map = await load(month);
    return MonthlyRecapPayload.fromMap(map);
  }

  Future<Map<String, dynamic>> getMonthlyPersonaSlice(
    DateTime month,
    Map<String, dynamic> recap,
  ) async {
    final userId = _userId;
    final settlements = await _countSettlementsInMonth(month);
    final signals = PersonaEngine.signalsFromRecap(
      recap,
      settlementsThisMonth: settlements,
    );
    final persona = PersonaEngine.resolve(signals);
    final badges = await _achievementsLive.fetchUnlocksInMonth(userId, month);
    final badge = badges.isEmpty ? null : badges.first;
    return PersonaEngine.toRecapPayload(
      persona,
      badgeName: badge?.name,
      badgeDescription: badge?.description,
    );
  }

  Future<int> _countSettlementsInMonth(DateTime month) async {
    try {
      final userId = _userId;
      final monthStart = DateTime(month.year, month.month, 1);
      final monthEnd = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
      final rows = await Supabase.instance.client
          .from(SupabaseTables.groupTransaction)
          .select(SupabaseColumns.transactionId)
          .eq(SupabaseColumns.category, CategoryDefaults.settlement)
          .or('paid_by.eq.$userId,shared_with.eq.$userId')
          .gte(SupabaseColumns.transactionDate, monthStart.toIso8601String())
          .lte(SupabaseColumns.transactionDate, monthEnd.toIso8601String());
      return (rows as List).length;
    } catch (_) {
      return 0;
    }
  }

  Future<Map<String, dynamic>> getMonthlyLendingSnapshot(
    DateTime month,
  ) async {
    final userId = _userId;
    final loans = await _loansLive.getLoans(userID: userId);
    final payments =
        await _loansLive.getPaymentsInMonth(userID: userId, month: month);
    return computeLendingSnapshot(
      loans,
      userId,
      month,
      payments: payments,
    );
  }

  Future<Map<String, dynamic>> getMonthlyGoalsSnapshot(
    DateTime month,
  ) async {
    final userId = _userId;
    final goals = await _goalsLive.getGoals(userID: userId);
    final contributed = await _goalsLive.sumGoalDepositsInMonth(
      userID: userId,
      month: month,
    );
    return computeGoalsSnapshot(goals, contributed, month);
  }

  Future<Map<String, dynamic>> getMonthlyGroupActivity(DateTime month) async {
    try {
      final userId = _userId;
      final monthStart = DateTime(month.year, month.month, 1);
      final monthEnd = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
      final rows = await Supabase.instance.client
          .from(SupabaseTables.groupTransaction)
          .select(
            '${SupabaseColumns.groupId}, ${SupabaseColumns.paidBy}, '
            '${SupabaseColumns.sharedWith}, '
            '${SupabaseColumns.sharedTransactionAmount}, '
            '${SupabaseColumns.category}',
          )
          .or(
            '${SupabaseColumns.paidBy}.eq.$userId,'
            '${SupabaseColumns.sharedWith}.eq.$userId',
          )
          .gte(SupabaseColumns.transactionDate, monthStart.toIso8601String())
          .lte(SupabaseColumns.transactionDate, monthEnd.toIso8601String())
          .neq(SupabaseColumns.category, CategoryDefaults.settlement);

      final computed = computeMonthlyGroupSocial(
        List<Map<String, dynamic>>.from(rows as List),
        userId,
      );
      if (computed[RecapDataKeys.hasGroupActivity] != true) {
        return computed;
      }

      final peerIds =
          computed[RecapDataKeys.groupFriendPeerIds] as List<String>? ?? [];
      if (peerIds.isEmpty) return computed;

      final userRows = await Supabase.instance.client
          .from(SupabaseTables.users)
          .select(
            '${SupabaseColumns.userId}, ${SupabaseColumns.firstname}, '
            '${SupabaseColumns.lastname}, ${SupabaseColumns.userName}, '
            '${SupabaseColumns.profilePictureUrl}',
          )
          .inFilter(SupabaseColumns.userId, peerIds);

      final userById = <String, Map<String, dynamic>>{};
      for (final row in userRows as List) {
        final id = row[SupabaseColumns.userId] as String?;
        if (id != null) userById[id] = Map<String, dynamic>.from(row);
      }

      final peers = <Map<String, dynamic>>[];
      for (final id in peerIds) {
        final user = userById[id];
        final name = _displayName(user);
        peers.add({
          'id': id,
          'name': name,
          'imageUrl': user?[SupabaseColumns.profilePictureUrl],
        });
        if (id == computed[RecapDataKeys.topFriendId]) {
          computed[RecapDataKeys.topFriendName] = name;
        }
      }

      computed[RecapDataKeys.groupFriendPeers] = peers;
      computed.remove(RecapDataKeys.topFriendId);
      computed.remove(RecapDataKeys.groupFriendPeerIds);
      return computed;
    } catch (_) {
      return {RecapDataKeys.hasGroupActivity: false};
    }
  }

  /// Month-scoped group spend + top split buddy for recap (F7/F12).
  static Map<String, dynamic> computeMonthlyGroupSocial(
    List<Map<String, dynamic>> rows,
    String userId,
  ) {
    final groupsInMonth = <String>{};
    var userPaid = 0.0;
    var totalSpend = 0.0;
    final friendSpend = <String, double>{};

    for (final row in rows) {
      final category = row[SupabaseColumns.category] as String?;
      if (category == CategoryDefaults.settlement) continue;

      final groupId = row[SupabaseColumns.groupId] as String?;
      if (groupId != null && groupId.isNotEmpty) {
        groupsInMonth.add(groupId);
      }

      final amount = double.tryParse(
            row[SupabaseColumns.sharedTransactionAmount]?.toString() ?? '0',
          ) ??
          0.0;
      if (amount <= 0) continue;
      totalSpend += amount;

      final paidBy = row[SupabaseColumns.paidBy] as String?;
      if (paidBy == userId) {
        userPaid += amount;
      }

      final sharedWith = row[SupabaseColumns.sharedWith] as String?;
      if (sharedWith != null && sharedWith != userId) {
        friendSpend[sharedWith] = (friendSpend[sharedWith] ?? 0) + amount;
      }
      if (paidBy != null && paidBy != userId) {
        friendSpend[paidBy] = (friendSpend[paidBy] ?? 0) + amount;
      }
    }

    if (groupsInMonth.isEmpty && totalSpend <= 0) {
      return {RecapDataKeys.hasGroupActivity: false};
    }

    final sortedPeers = friendSpend.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topFriendId =
        sortedPeers.isEmpty ? null : sortedPeers.first.key;
    final peerIds = sortedPeers.take(3).map((e) => e.key).toList();

    return {
      RecapDataKeys.hasGroupActivity: true,
      RecapDataKeys.groupCount: groupsInMonth.length,
      RecapDataKeys.payerRatio:
          totalSpend > 0 ? (userPaid / totalSpend) * 100 : 0.0,
      RecapDataKeys.topFriendId: topFriendId,
      RecapDataKeys.groupFriendPeerIds: peerIds,
    };
  }

  static String _displayName(Map<String, dynamic>? user) {
    if (user == null) return DisplayFallbacks.aFriend;
    final userName = user[SupabaseColumns.userName] as String?;
    if (userName != null && userName.trim().isNotEmpty) return userName;
    final first = user[SupabaseColumns.firstname] as String? ?? '';
    final last = user[SupabaseColumns.lastname] as String? ?? '';
    final full = '$first $last'.trim();
    return full.isEmpty ? DisplayFallbacks.aFriend : full;
  }

  /// Pure goals recap math for tests and UI.
  static Map<String, dynamic> computeGoalsSnapshot(
    List<FinancialGoalModel> goals,
    double contributedThisMonth,
    DateTime month,
  ) {
    final active = goals
        .where((goal) => goal.status == GoalStatusValues.active)
        .toList();

    if (active.isEmpty && contributedThisMonth <= 0) {
      return {RecapDataKeys.hasGoalsActivity: false};
    }

    FinancialGoalModel? bestGoal;
    var bestProgress = -1.0;
    for (final goal in active) {
      final target = goal.targetAmount ?? 0;
      if (target <= 0) continue;
      final progress = (goal.currentAmount ?? 0) / target;
      if (progress > bestProgress) {
        bestProgress = progress;
        bestGoal = goal;
      }
    }

    var motivationKey = RecapGoalMotivation.onTrack;
    var goalsAtTarget = 0;
    var completedInMonth = false;

    for (final goal in active) {
      final target = goal.targetAmount ?? 0;
      if (target <= 0) continue;
      final current = goal.currentAmount ?? 0;
      if (current < target) continue;
      goalsAtTarget++;
      if (contributedThisMonth > 0) {
        final beforeMonth = current - contributedThisMonth;
        if (beforeMonth < target) completedInMonth = true;
      }
    }

    if (bestGoal != null) {
      final target = bestGoal.targetAmount ?? 0;
      final progress = target > 0 ? (bestGoal.currentAmount ?? 0) / target : 0;
      final deadline = bestGoal.deadline;
      if (deadline != null &&
          deadline.isBefore(DateTime.now().add(AppMotion.goalDeadlineWindow)) &&
          progress < InsightsLimits.goalProgressAttention) {
        motivationKey = RecapGoalMotivation.needsPush;
      }
    }

    return {
      RecapDataKeys.hasGoalsActivity: true,
      RecapDataKeys.activeGoalsCount: active.length,
      RecapDataKeys.bestGoalTitle: bestGoal?.title ?? DisplayFallbacks.goal,
      RecapDataKeys.bestGoalProgress: bestProgress < 0 ? 0.0 : bestProgress,
      RecapDataKeys.goalsContributedThisMonth: contributedThisMonth,
      RecapDataKeys.goalsMotivationLine: motivationKey,
      RecapDataKeys.goalsAtTargetCount: goalsAtTarget,
      RecapDataKeys.goalCompletedInMonth: completedInMonth,
    };
  }

  /// Pure lending recap math for tests and UI.
  static Map<String, dynamic> computeLendingSnapshot(
    List<LoanModel> loans,
    String userId,
    DateTime month, {
    List<LoanPaymentRecapRow> payments = const [],
  }) {
    if (loans.isEmpty && payments.isEmpty) {
      return {RecapDataKeys.hasLendingActivity: false};
    }

    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    bool inMonth(DateTime? date) {
      if (date == null) return false;
      return !date.isBefore(monthStart) && !date.isAfter(monthEnd);
    }

    final active = loans
        .where((loan) => loan.status == LoanStatusValues.active)
        .toList();

    var outstanding = 0.0;
    LoanModel? topLoan;
    var topOwed = 0.0;
    for (final loan in active) {
      final owed = loan.currentAmountOwed;
      outstanding += owed;
      if (owed > topOwed) {
        topOwed = owed;
        topLoan = loan;
      }
    }

    var paymentLoans = 0;
    var repaidThisMonth = 0.0;
    var completedThisMonth = 0;
    final ledgerRows = <Map<String, dynamic>>[];

    if (payments.isNotEmpty) {
      final paidLoanIds = <String>{};
      for (final payment in payments) {
        repaidThisMonth += payment.amount;
        paidLoanIds.add(payment.loanId);
      }
      paymentLoans = paidLoanIds.length;

      final sortedPayments = List<LoanPaymentRecapRow>.from(payments)
        ..sort((a, b) => b.paidAt.compareTo(a.paidAt));
      for (final payment in sortedPayments.take(3)) {
        ledgerRows.add(payment.toLedgerMap());
      }

      for (final loan in loans) {
        if (!inMonth(loan.updatedAt)) continue;
        if (loan.status == LoanStatusValues.completed) {
          completedThisMonth++;
        }
      }
    } else {
      for (final loan in loans) {
        if (!inMonth(loan.updatedAt)) continue;
        if (loan.status == LoanStatusValues.completed) {
          completedThisMonth++;
          repaidThisMonth += loan.repaymentAmount;
        } else if (loan.repaymentAmount > 0) {
          paymentLoans++;
        }
      }
    }

    final hasActivity = active.isNotEmpty ||
        paymentLoans > 0 ||
        completedThisMonth > 0 ||
        repaidThisMonth > 0 ||
        payments.isNotEmpty;

    if (!hasActivity) {
      return {RecapDataKeys.hasLendingActivity: false};
    }

    return {
      RecapDataKeys.hasLendingActivity: true,
      RecapDataKeys.activeLoanCount: active.length,
      RecapDataKeys.totalLoanOutstanding: outstanding,
      RecapDataKeys.loansWithPaymentThisMonth:
          paymentLoans + completedThisMonth,
      RecapDataKeys.totalRepaidThisMonth: repaidThisMonth,
      RecapDataKeys.topLoanTitle: topLoan == null
          ? DisplayFallbacks.untitled
          : _loanCounterpartyLabel(topLoan, userId),
      RecapDataKeys.topLoanProgress: topLoan?.repaymentProgress ?? 0.0,
      RecapDataKeys.loansCompletedThisMonth: completedThisMonth,
      if (ledgerRows.isNotEmpty)
        RecapDataKeys.lendingLedgerRows: ledgerRows,
    };
  }

  static String _loanCounterpartyLabel(LoanModel loan, String userId) {
    if (loan.lenderID == userId) {
      return loan.borrowerName ?? DisplayFallbacks.aFriend;
    }
    return loan.lenderName ?? DisplayFallbacks.aFriend;
  }

  static int _topCategoryRank(
    Map<String, double> breakdown,
    String topCategory,
  ) {
    if (breakdown.isEmpty || topCategory == DisplayFallbacks.none) return 1;
    final sorted = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final index = sorted.indexWhere((e) => e.key == topCategory);
    return index < 0 ? 1 : index + 1;
  }
}
