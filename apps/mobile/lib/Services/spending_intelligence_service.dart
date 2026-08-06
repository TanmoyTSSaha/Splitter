import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'dart:math' as math;

import 'package:splitr/Utils/num_parsing.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/Services/currency_service.dart';
import 'package:get/get.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Services/SupabaseServices/goal_service.dart';
import 'package:splitr/Services/SupabaseServices/transaction_service.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Utils/recurring_merchant_detector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SpendingIntelligenceService {
  final supabase = Supabase.instance.client;
  final String _currentUserId = SupabaseAuth().supabaseGetUserID();
  final TransactionService _txService = TransactionService();

  String get _currency => Get.isRegistered<CurrencyController>()
      ? Get.find<CurrencyController>().code
      : CurrencyDefaults.code;

  /// Calculates total spending for a given month.
  Future<double> getMonthlySpending(DateTime month) async {
    final analytics = await _txService.getMonthlySpendAnalytics(
        userID: _currentUserId, selectedCurrency: _currency, month: month);
    return asDouble(analytics['total']);
  }

  /// Breakdown of spending by category for a given month.
  Future<Map<String, double>> getCategoryBreakdown(DateTime month) async {
    final analytics = await _txService.getMonthlySpendAnalytics(
        userID: _currentUserId, selectedCurrency: _currency, month: month);
    final breakdown = asDoubleMap(Map<String, dynamic>.from(analytics));
    breakdown.remove('total');
    return breakdown;
  }

  /// Last N months of total spend for trend charts.
  Future<List<Map<String, dynamic>>> getSpendingTrend({int months = 6}) async {
    final now = DateTime.now();
    final trend = <Map<String, dynamic>>[];
    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final total = await getMonthlySpending(month);
      trend.add({
        'month': month,
        'label': _monthLabel(month),
        'total': total,
      });
    }
    return trend;
  }

  String _monthLabel(DateTime month) {
    return MonthAbbreviations.labels[month.month - 1];
  }

  /// Personal merchants that look like monthly subscriptions.
  Future<List<Map<String, dynamic>>> detectRecurringSubscriptions() async {
    try {
      final allTxns = await _txService.getUnifiedTransactions(
        userID: _currentUserId,
        limit: InsightsLimits.unifiedTxnFetch,
        selectedCurrency: _currency,
      );
      return detectRecurringMerchants(allTxns)
          .map((hit) => hit.toJson())
          .toList();
    } catch (e, stack) {
      AppErrorReporter.unexpected(
        'detectRecurringSubscriptions failed',
        error: e,
        stack: stack,
        context: {'feature': 'insights'},
      );
      return [];
    }
  }

  /// Flags expenses with z-score > 2 vs category mean for the month.
  Future<List<Map<String, dynamic>>> detectUnusualExpenses(
      DateTime month) async {
    try {
      final allTxns = await _txService.getUnifiedTransactions(
          userID: _currentUserId,
          limit: InsightsLimits.unifiedTxnFetch,
          selectedCurrency: _currency);

      final monthTxns = allTxns.where((txn) {
        final date = txn['date'] as DateTime;
        return date.year == month.year &&
            date.month == month.month &&
            txn['is_credit'] == false;
      }).toList();

      if (monthTxns.length < InsightsLimits.minTxnsForAnomaly) return [];

      final byCategory = <String, List<double>>{};
      for (final txn in monthTxns) {
        final cat = txn['category'] as String? ?? CategoryDefaults.other;
        byCategory.putIfAbsent(cat, () => []).add(asDouble(txn['amount']));
      }

      final unusual = <Map<String, dynamic>>[];
      for (final txn in monthTxns) {
        final cat = txn['category'] as String? ?? CategoryDefaults.other;
        final amounts = byCategory[cat] ?? [];
        if (amounts.length < InsightsLimits.minCategoryAmounts) continue;

        final mean = amounts.reduce((a, b) => a + b) / amounts.length;
        final variance =
            amounts.map((a) => math.pow(a - mean, 2)).reduce((a, b) => a + b) /
                amounts.length;
        final stdDev = math.sqrt(variance);
        if (stdDev < InsightsLimits.minStdDev) continue;

        final amount = asDouble(txn['amount']);
        final zScore = (amount - mean) / stdDev;
        if (zScore > InsightsLimits.zScoreAnomaly) {
          unusual.add({
            'title': txn['title'],
            'amount': amount,
            'category': cat,
            'date': txn['date'],
            'zScore': zScore,
          });
        }
      }

      unusual.sort(
          (a, b) => asDouble(b['zScore']).compareTo(asDouble(a['zScore'])));
      return unusual.take(InsightsLimits.unusualExpenseLimit).toList();
    } catch (e, stack) {
      AppErrorReporter.unexpected(
        'detectUnusualExpenses failed',
        error: e,
        stack: stack,
        context: {'feature': 'insights'},
      );
      return [];
    }
  }

  /// 0–100 score: share of group balances involving the user that are near zero.
  Future<int> getSettleUpHealthScore() async {
    try {
      final memberRows = await supabase
          .from(SupabaseTables.groupMembers)
          .select('group_id')
          .eq('user_id', _currentUserId);

      final groupIds = memberRows.map((r) => r['group_id'] as String).toList();
      if (groupIds.isEmpty) return InsightsLimits.settleHealthMax;

      final balances = await supabase
          .from(SupabaseTables.groupBalance)
          .select('donor_id, receiver_id, amount')
          .inFilter('group_id', groupIds);

      if (balances.isEmpty) return InsightsLimits.settleHealthMax;

      double userExposure = 0;
      double settledExposure = 0;
      const threshold = SettleUpThresholds.nearSettledInr;

      for (final row in balances) {
        final donor = row['donor_id'] as String?;
        final receiver = row['receiver_id'] as String?;
        final amount = double.tryParse(row['amount'].toString()) ?? 0.0;
        if (donor != _currentUserId && receiver != _currentUserId) continue;

        userExposure += amount;
        if (amount <= threshold) settledExposure += amount;
      }

      if (userExposure <= 0) return InsightsLimits.settleHealthMax;
      return ((settledExposure / userExposure) * 100)
          .round()
          .clamp(0, InsightsLimits.settleHealthMax);
    } catch (e, stack) {
      AppErrorReporter.unexpected(
        'getSettleUpHealthScore failed',
        error: e,
        stack: stack,
        context: {'feature': 'insights'},
      );
      return InsightsLimits.settleHealthDefault;
    }
  }

  /// Short narrative digest for the month.
  Future<String> generateMonthlyDigest(DateTime month) async {
    final total = await getMonthlySpending(month);
    final prev = DateTime(month.year, month.month - 1, 1);
    final prevTotal = await getMonthlySpending(prev);
    final breakdown = await getCategoryBreakdown(month);
    final unusual = await detectUnusualExpenses(month);
    final settleHealth = await getSettleUpHealthScore();

    if (total <= 0) {
      return AppStrings.services.insights.noSpendingDigest;
    }

    String topCat = CategoryDefaults.miscellaneous;
    if (breakdown.isNotEmpty) {
      final sorted = breakdown.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topCat = sorted.first.key;
    }

    final change = prevTotal > 0 ? ((total - prevTotal) / prevTotal) * 100 : 0;
    final changeText = change > InsightsLimits.digestChangeUpPct
        ? '${AppStrings.services.insights.upFromLastMonth}${change.toStringAsFixed(0)}${AppStrings.services.insights.percentFromLastMonth}'
        : change < -InsightsLimits.digestChangeDownPct
            ? '${AppStrings.services.insights.downFromLastMonth}${change.abs().toStringAsFixed(0)}${AppStrings.services.insights.percentFromLastMonth}'
            : AppStrings.services.insights.steadyVsLastMonth;

    final buffer = StringBuffer(
      '${AppStrings.services.insights.spentPrefix}${_currencySymbol()}${total.toStringAsFixed(0)}${AppStrings.services.insights.inMonth}${_monthLabel(month)} — $changeText. '
      '${AppStrings.services.insights.topCategoryPrefix}$topCat. ',
    );

    if (settleHealth >= InsightsThresholds.scoreStrong) {
      buffer.write(AppStrings.services.insights.balancesHealthy);
    } else if (settleHealth < InsightsLimits.settleScoreLow) {
      buffer.write(AppStrings.services.insights.balancesOpen);
    }

    if (unusual.isNotEmpty) {
      final top = unusual.first;
      buffer.write(
        '${AppStrings.services.insights.unusualSpikePrefix}${top['title']} (${_currencySymbol()}${asDouble(top['amount']).toStringAsFixed(0)}).',
      );
    }

    return buffer.toString();
  }

  String _currencySymbol() {
    if (Get.isRegistered<CurrencyController>()) {
      return Get.find<CurrencyController>().symbol;
    }
    return CurrencyService.symbolFor(CurrencyDefaults.code);
  }

  /// Lightweight data for free tier and promo card.
  Future<Map<String, dynamic>> getInsightsLite() async {
    final now = DateTime.now();
    final thisMonthAmount = await getMonthlySpending(now);
    final prevMonth = DateTime(now.year, now.month - 1, 1);
    final lastMonthAmount = await getMonthlySpending(prevMonth);

    double percentChange = 0;
    if (lastMonthAmount > 0) {
      percentChange =
          ((thisMonthAmount - lastMonthAmount) / lastMonthAmount) * 100;
    }

    final miniTrend =
        await getSpendingTrend(months: InsightsLimits.trendMonthsMini);
    final digest = await generateMonthlyDigest(now);

    return {
      'thisMonthTotal': thisMonthAmount,
      'lastMonthTotal': lastMonthAmount,
      'percentChange': percentChange,
      'miniTrend': miniTrend,
      'monthlyDigest': digest,
    };
  }

  /// Contextual hook for home-screen promo card (minimal queries).
  Future<Map<String, dynamic>> getPromoHook() async {
    final lite = await getInsightsLite();
    final social = await getSocialTrustInsights();
    final percentChange = asDouble(lite['percentChange']);
    final openAmount = asDouble(social['openExposure']);
    final groupCount = asInt(social['groupCount']);

    String message;
    String hookType;

    if (openAmount >= InsightsThresholds.settleUpExposureInr &&
        groupCount > 0) {
      hookType = PromoHookTypes.settleUp;
      message =
          '${_currencySymbol()}${openAmount.toStringAsFixed(0)}${AppStrings.services.insights.unsettledAcrossPrefix}$groupCount${groupCount == 1 ? AppStrings.services.insights.groupSingular : AppStrings.services.insights.groupPlural}${AppStrings.services.insights.trustScoreSuffix}';
    } else if (percentChange > InsightsThresholds.spendChangePercent) {
      hookType = PromoHookTypes.spendingUp;
      message =
          '${AppStrings.services.insights.spendingUpPrefix}${percentChange.toStringAsFixed(0)}${AppStrings.services.insights.spendingUpSuffix}';
    } else if (percentChange < -InsightsThresholds.spendChangePercent) {
      hookType = PromoHookTypes.spendingDown;
      message =
          '${AppStrings.services.insights.spendingDownPrefix}${percentChange.abs().toStringAsFixed(0)}${AppStrings.services.insights.spendingDownSuffix}';
    } else {
      hookType = PromoHookTypes.generic;
      message = AppStrings.services.insights.promoGeneric;
    }

    return {
      'message': message,
      'hookType': hookType,
      'percentChange': percentChange,
      'openExposure': openAmount,
      'groupCount': groupCount,
    };
  }

  /// Month-end spend projection from daily burn rate.
  Map<String, double> getMonthEndProjection(double monthSpend, DateTime now) {
    return computeMonthEndProjection(monthSpend, now);
  }

  /// Pure projection math for tests and UI.
  static Map<String, double> computeMonthEndProjection(
    double monthSpend,
    DateTime now,
  ) {
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysElapsed = math.max(now.day, 1);
    final dailyBurn = monthSpend / daysElapsed;
    final projection = dailyBurn * daysInMonth;
    return {
      'dailyBurn': dailyBurn,
      'projection': projection,
      'daysElapsed': daysElapsed.toDouble(),
      'daysInMonth': daysInMonth.toDouble(),
    };
  }

  /// Per-category month-over-month deltas.
  Future<List<Map<String, dynamic>>> getCategoryDeltas(DateTime month) async {
    final current = await getCategoryBreakdown(month);
    final prev =
        await getCategoryBreakdown(DateTime(month.year, month.month - 1, 1));

    final allCats = {...current.keys, ...prev.keys};
    final deltas = <Map<String, dynamic>>[];

    for (final cat in allCats) {
      final cur = current[cat] ?? 0;
      final prevAmt = prev[cat] ?? 0;
      double pct = 0;
      if (prevAmt > 0) {
        pct = ((cur - prevAmt) / prevAmt) * 100;
      } else if (cur > 0) {
        pct = InsightsLimits.percentNewCategory.toDouble();
      }
      deltas.add({
        'category': cat,
        'current': cur,
        'previous': prevAmt,
        'percentChange': pct,
      });
    }

    deltas.sort(
        (a, b) => asDouble(b['current']).compareTo(asDouble(a['current'])));
    return deltas;
  }

  /// Social trust signals from group balances and transactions.
  Future<Map<String, dynamic>> getSocialTrustInsights() async {
    try {
      final memberRows = await supabase
          .from(SupabaseTables.groupMembers)
          .select('group_id')
          .eq('user_id', _currentUserId);

      final groupIds = memberRows.map((r) => r['group_id'] as String).toList();

      if (groupIds.isEmpty) {
        return {
          'openExposure': 0.0,
          'groupCount': 0,
          'staleBalanceAmount': 0.0,
          'staleBalanceCount': 0,
          'payerRatio': 0.0,
          'settlementAvgDays': 0,
          'topGroupId': null,
          'topGroupName': null,
        };
      }

      final balances = await supabase
          .from(SupabaseTables.groupBalance)
          .select('group_id, donor_id, receiver_id, amount')
          .inFilter('group_id', groupIds);

      double openExposure = 0;
      final groupsWithBalance = <String>{};
      String? topGroupId;
      double topGroupAmount = 0;

      for (final row in balances) {
        final donor = row['donor_id'] as String?;
        final receiver = row['receiver_id'] as String?;
        final amount = double.tryParse(row['amount'].toString()) ?? 0.0;
        if (amount < InsightsLimits.minOpenBalance) continue;
        if (donor != _currentUserId && receiver != _currentUserId) continue;

        openExposure += amount;
        final gid = row['group_id'] as String;
        groupsWithBalance.add(gid);
        if (amount > topGroupAmount) {
          topGroupAmount = amount;
          topGroupId = gid;
        }
      }

      // Payer ratio: share of group expenses user fronted this month.
      double payerRatio = 0;
      try {
        final now = DateTime.now();
        final groupTxns = await supabase
            .from(SupabaseTables.groupTransaction)
            .select('paid_by, shared_transaction_amount, transaction_date')
            .or('paid_by.eq.$_currentUserId,shared_with.eq.$_currentUserId')
            .gte('transaction_date',
                DateTime(now.year, now.month, 1).toIso8601String())
            .neq(SupabaseColumns.category, CategoryDefaults.settlement);

        double userPaid = 0;
        double totalGroupSpend = 0;
        for (final txn in groupTxns) {
          final amt = double.tryParse(
                  txn['shared_transaction_amount']?.toString() ??
                      AppAmountHints.zero) ??
              0;
          totalGroupSpend += amt;
          if (txn['paid_by'] == _currentUserId) userPaid += amt;
        }
        if (totalGroupSpend > 0) {
          payerRatio = (userPaid / totalGroupSpend) * 100;
        }
      } catch (e, stack) {
        AppErrorReporter.unexpected(
          'payerRatio calculation failed',
          error: e,
          stack: stack,
          context: {'feature': 'insights'},
        );
      }

      // Settlement latency: avg days from expense to settlement (last 90 days).
      int settlementAvgDays = 0;
      int staleBalanceCount = 0;
      double staleBalanceAmount = 0;
      try {
        final cutoff = DateTime.now().subtract(AppMotion.insightsLookback);
        final settlements = await supabase
            .from(SupabaseTables.groupTransaction)
            .select('transaction_date, group_id')
            .eq(SupabaseColumns.category, CategoryDefaults.settlement)
            .or('paid_by.eq.$_currentUserId,shared_with.eq.$_currentUserId')
            .gte('transaction_date', cutoff.toIso8601String())
            .order('transaction_date', ascending: false)
            .limit(50);

        final latencies = <int>[];
        for (final s in settlements) {
          final settleDate =
              DateTime.tryParse(s['transaction_date']?.toString() ?? '');
          final gid = s['group_id'] as String?;
          if (settleDate == null || gid == null) continue;

          final priorExpense = await supabase
              .from(SupabaseTables.groupTransaction)
              .select('transaction_date')
              .eq('group_id', gid)
              .neq(SupabaseColumns.category, CategoryDefaults.settlement)
              .lt('transaction_date', settleDate.toIso8601String())
              .order('transaction_date', ascending: false)
              .limit(1);

          if (priorExpense.isNotEmpty) {
            final expDate = DateTime.tryParse(
                priorExpense.first['transaction_date']?.toString() ?? '');
            if (expDate != null) {
              latencies.add(settleDate
                  .difference(expDate)
                  .inDays
                  .clamp(0, InsightsLimits.settlementLatencyMaxDays));
            }
          }
        }
        if (latencies.isNotEmpty) {
          settlementAvgDays =
              (latencies.reduce((a, b) => a + b) / latencies.length).round();
        }

        // Stale: open balances in groups with no settlement in 30 days.
        final staleCutoff =
            DateTime.now().subtract(AppMotion.insightsStaleCutoff);
        for (final gid in groupsWithBalance) {
          final recentSettle = await supabase
              .from(SupabaseTables.groupTransaction)
              .select('transaction_id')
              .eq('group_id', gid)
              .eq(SupabaseColumns.category, CategoryDefaults.settlement)
              .gte('transaction_date', staleCutoff.toIso8601String())
              .limit(1);
          if (recentSettle.isEmpty) {
            staleBalanceCount++;
            for (final row in balances) {
              if (row['group_id'] != gid) continue;
              final amt = double.tryParse(row['amount'].toString()) ?? 0.0;
              final donor = row['donor_id'] as String?;
              final receiver = row['receiver_id'] as String?;
              if (donor == _currentUserId || receiver == _currentUserId) {
                staleBalanceAmount += amt;
              }
            }
          }
        }
      } catch (e, stack) {
        AppErrorReporter.unexpected(
          'settlement latency calculation failed',
          error: e,
          stack: stack,
          context: {'feature': 'insights'},
        );
      }

      String? topGroupName;
      if (topGroupId != null) {
        try {
          final g = await supabase
              .from(SupabaseTables.groups)
              .select('group_name')
              .eq('group_id', topGroupId)
              .maybeSingle();
          topGroupName = g?['group_name'] as String?;
        } catch (_) {}
      }

      return {
        'openExposure': openExposure,
        'groupCount': groupsWithBalance.length,
        'staleBalanceAmount': staleBalanceAmount,
        'staleBalanceCount': staleBalanceCount,
        'payerRatio': payerRatio,
        'settlementAvgDays': settlementAvgDays,
        'topGroupId': topGroupId,
        'topGroupName': topGroupName,
      };
    } catch (e, stack) {
      AppErrorReporter.unexpected(
        'getSocialTrustInsights failed',
        error: e,
        stack: stack,
        context: {'feature': 'insights'},
      );
      return {
        'openExposure': 0.0,
        'groupCount': 0,
        'staleBalanceAmount': 0.0,
        'staleBalanceCount': 0,
        'payerRatio': 0.0,
        'settlementAvgDays': 0,
        'topGroupId': null,
        'topGroupName': null,
      };
    }
  }

  /// Spending coach cards data.
  Future<Map<String, dynamic>> getSpendingCoachInsights(DateTime month) async {
    final monthSpend = await getMonthlySpending(month);
    final projection = getMonthEndProjection(monthSpend, month);
    final deltas = await getCategoryDeltas(month);
    final biggest = await getBiggestExpense(month);

    Map<String, dynamic>? topLeak;
    for (final d in deltas) {
      if (asDouble(d[UnifiedTxnResponseKeys.percentChange]) >
              InsightsLimits.topLeakPctThreshold &&
          asDouble(d[UnifiedTxnResponseKeys.current]) >
              InsightsLimits.topLeakAmountThreshold) {
        topLeak = d;
        break;
      }
    }
    if (topLeak == null && deltas.isNotEmpty) {
      topLeak = deltas.first;
    }

    return {
      'monthSpend': monthSpend,
      'dailyBurn': projection['dailyBurn'],
      'projection': projection['projection'],
      'categoryDeltas': deltas.take(InsightsLimits.categoryDeltaLimit).toList(),
      'topLeak': topLeak,
      'biggestExpense': biggest,
    };
  }

  /// Human-readable score labels and breakdowns.
  Map<String, dynamic> getScoreBreakdown({
    required int overall,
    required int spending,
    required int settleUp,
    required double percentChange,
    required double openExposure,
  }) {
    return {
      'overall': {
        'score': overall,
        'label': scoreLabel(overall),
        'explanation': AppStrings.services.insights.overallExplanation,
      },
      'spending': {
        'score': spending,
        'label': scoreLabel(spending),
        'explanation': spendingExplanation(percentChange),
      },
      'settleUp': {
        'score': settleUp,
        'label': scoreLabel(settleUp),
        'explanation': settleUpExplanation(openExposure, settleUp),
      },
    };
  }

  /// 0–100 label for display.
  static String scoreLabel(int score) {
    if (score >= InsightsThresholds.scoreStrong) {
      return InsightScoreLabels.good;
    }
    if (score >= PromptnessScoreTiers.good) return InsightScoreLabels.watch;
    return InsightScoreLabels.needsAttention;
  }

  static String spendingExplanation(double percentChange) {
    if (percentChange > InsightsLimits.spendingExplainHigh) {
      return '${AppStrings.services.insights.spendingJumped}${percentChange.toStringAsFixed(0)}%${AppStrings.services.insights.vsLastMonth}';
    }
    if (percentChange > InsightsLimits.spendingExplainMed) {
      return '${AppStrings.services.insights.spendingUpReview}${percentChange.toStringAsFixed(0)}${AppStrings.services.insights.reviewTopCategories}';
    }
    if (percentChange < InsightsLimits.spendingExplainLow) {
      return '${AppStrings.services.insights.spendingDownNice}${percentChange.abs().toStringAsFixed(0)}${AppStrings.services.insights.niceRestraint}';
    }
    return AppStrings.services.insights.spendingSteady;
  }

  static String settleUpExplanation(double openExposure, int score) {
    if (openExposure <= 0) return AppStrings.services.insights.noOpenBalances;
    if (score < InsightsLimits.settleScoreLow) {
      return '${openExposure.toStringAsFixed(0)}${AppStrings.services.insights.openBalancesTrust}';
    }
    return AppStrings.services.insights.balancesSmall;
  }

  /// Prioritized actionable items for Pro users.
  Future<List<Map<String, dynamic>>> getActionQueue(DateTime month) async {
    final actions = <Map<String, dynamic>>[];
    final social = await getSocialTrustInsights();
    final deltas = await getCategoryDeltas(month);
    final unusual = await detectUnusualExpenses(month);
    final goals = await GoalService().getGoals(userID: _currentUserId);

    final staleAmt = asDouble(social['staleBalanceAmount']);
    final staleCount = asInt(social['staleBalanceCount']);
    if (staleAmt >= InsightsThresholds.settleUpExposureInr && staleCount > 0) {
      actions.add({
        'priority': 1,
        'title': InsightActionTitles.settleStaleBalances,
        'reason':
            '${_currencySymbol()}${staleAmt.toStringAsFixed(0)}${AppStrings.services.insights.staleOpenPrefix}',
        'action_type': InsightActionTypes.settleUp,
        'group_id': social['topGroupId'],
        'group_name': social['topGroupName'],
      });
    } else if (asDouble(social['openExposure']) >=
        InsightsThresholds.settleUpExposureInr) {
      actions.add({
        'priority': 2,
        'title': InsightActionTitles.clearOpenBalances,
        'reason':
            '${_currencySymbol()}${asDouble(social['openExposure']).toStringAsFixed(0)}${AppStrings.services.insights.acrossGroupsPrefix}${social['groupCount']}${AppStrings.services.insights.groupsSuffix}',
        'action_type': InsightActionTypes.settleUp,
        'group_id': social['topGroupId'],
        'group_name': social['topGroupName'],
      });
    }

    for (final d in deltas) {
      final pct = asDouble(d['percentChange']);
      final cur = asDouble(d['current']);
      if (pct > InsightsLimits.actionCategoryPctThreshold &&
          cur > InsightsLimits.actionCategoryAmountThreshold) {
        actions.add({
          'priority': 3,
          'title':
              '${InsightActionTitles.reviewCategoryPrefix}${d['category']}',
          'reason':
              '${AppStrings.services.insights.upThisMonthPrefix}${pct.toStringAsFixed(0)}${AppStrings.services.insights.thisMonthSuffix}${_currencySymbol()}${cur.toStringAsFixed(0)})',
          'action_type': InsightActionTypes.reviewCategory,
          'category': d['category'],
        });
        break;
      }
    }

    if (unusual.isNotEmpty) {
      final top = unusual.first;
      actions.add({
        'priority': 4,
        'title': InsightActionTitles.checkUnusualSpend,
        'reason':
            '${top['title']}${AppStrings.services.insights.checkUnusualPrefix}${_currencySymbol()}${asDouble(top['amount']).toStringAsFixed(0)}',
        'action_type': InsightActionTypes.viewExpense,
        'category': top['category'],
      });
    }

    for (final goal in goals) {
      if (goal.status != GoalStatusValues.active) continue;
      final target = goal.targetAmount ?? 0;
      final current = goal.currentAmount ?? 0;
      if (target <= 0) continue;
      final progress = current / target;
      final deadline = goal.deadline;
      if (deadline != null &&
          deadline.isBefore(DateTime.now().add(AppMotion.goalDeadlineWindow)) &&
          progress < InsightsLimits.goalProgressAttention) {
        actions.add({
          'priority': 5,
          'title': InsightActionTitles.goalNeedsAttention,
          'reason':
              '${goal.title}${AppStrings.services.insights.goalFundedPrefix}${(progress * 100).toStringAsFixed(0)}${AppStrings.services.insights.goalFundedSuffix}',
          'action_type': InsightActionTypes.viewGoal,
          'goal_id': goal.id,
          'goal': goal,
        });
        break;
      }
    }

    actions
        .sort((a, b) => asInt(a['priority']).compareTo(asInt(b['priority'])));
    return actions.take(InsightsLimits.actionQueueLimit).toList();
  }

  /// Structured context for AI briefing (no raw PII beyond category names).
  Future<Map<String, dynamic>> buildAIBriefingContext() async {
    final now = DateTime.now();
    final full = await getInsights();
    final coach = await getSpendingCoachInsights(now);
    final social = await getSocialTrustInsights();
    final goals = await GoalService().getGoals(userID: _currentUserId);
    final goalSummaries = goals
        .where((g) => g.status == GoalStatusValues.active)
        .take(3)
        .map((g) => {
              'title': g.title,
              'progress_pct': g.targetAmount != null && g.targetAmount! > 0
                  ? ((g.currentAmount ?? 0) / g.targetAmount! * 100).round()
                  : 0,
              'deadline': g.deadline?.toIso8601String().split('T').first,
            })
        .toList();

    return {
      'currency': _currencySymbol(),
      'month': _monthLabel(now),
      'this_month_total': full['thisMonthTotal'],
      'percent_change': full['percentChange'],
      'top_category': full['topCategory'],
      'top_category_amount': full['topCategoryAmount'],
      'health_scores': {
        'overall': full['healthScore'],
        'spending': full['spendingHealthScore'],
        'settle_up': full['settleUpHealthScore'],
      },
      'month_end_projection': coach['projection'],
      'daily_burn': coach['dailyBurn'],
      'category_deltas': (coach['categoryDeltas'] as List)
          .take(3)
          .map((d) => {
                'category': d['category'],
                'change_pct': d['percentChange'],
                'amount': d['current'],
              })
          .toList(),
      'open_exposure': social['openExposure'],
      'group_count': social['groupCount'],
      'payer_ratio_pct': social['payerRatio'],
      'settlement_avg_days': social['settlementAvgDays'],
      'unusual_count': (full['unusualExpenses'] as List).length,
      'goals': goalSummaries,
    };
  }

  /// Returns key insights: month-over-month change check, top category, etc.
  Future<Map<String, dynamic>> getInsights() async {
    final now = DateTime.now();
    final thisMonthAmount = await getMonthlySpending(now);
    final prevMonth = DateTime(now.year, now.month - 1, now.day);
    final lastMonthAmount = await getMonthlySpending(prevMonth);

    double percentChange = 0;
    if (lastMonthAmount > 0) {
      percentChange =
          ((thisMonthAmount - lastMonthAmount) / lastMonthAmount) * 100;
    }

    final categoryBreakdown = await getCategoryBreakdown(now);
    String topCategory = CategoryDefaults.dash;
    double topCatAmount = 0;
    if (categoryBreakdown.isNotEmpty) {
      final sorted = categoryBreakdown.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topCategory = sorted.first.key;
      topCatAmount = sorted.first.value;
    }

    final spendingHealth =
        _calculateHealthScore(thisMonthAmount, lastMonthAmount);
    final settleHealth = await getSettleUpHealthScore();
    final combinedHealth = ((spendingHealth + settleHealth) / 2).round();
    final unusual = await detectUnusualExpenses(now);
    final recurring = await detectRecurringSubscriptions();
    final digest = await generateMonthlyDigest(now);
    final trend = await getSpendingTrend();
    final coach = await getSpendingCoachInsights(now);
    final social = await getSocialTrustInsights();
    final actions = await getActionQueue(now);
    final scoreBreakdown = getScoreBreakdown(
      overall: combinedHealth,
      spending: spendingHealth,
      settleUp: settleHealth,
      percentChange: percentChange,
      openExposure: asDouble(social['openExposure']),
    );

    return {
      'thisMonthTotal': thisMonthAmount,
      'lastMonthTotal': lastMonthAmount,
      'percentChange': percentChange,
      'topCategory': topCategory,
      'topCategoryAmount': topCatAmount,
      'healthScore': combinedHealth,
      'spendingHealthScore': spendingHealth,
      'settleUpHealthScore': settleHealth,
      'scoreBreakdown': scoreBreakdown,
      'unusualExpenses': unusual,
      'recurringSubscriptions': recurring,
      'monthlyDigest': digest,
      'spendingTrend': trend,
      'spendingCoach': coach,
      'socialTrust': social,
      'actionQueue': actions,
      'monthsWithData': trend.where((t) => (t['total'] as num) > 0).length,
    };
  }

  /// @visibleForTesting
  static int calculateHealthScore(double current, double previous) {
    return _calculateHealthScoreStatic(current, previous);
  }

  int _calculateHealthScore(double current, double previous) {
    return _calculateHealthScoreStatic(current, previous);
  }

  static int _calculateHealthScoreStatic(double current, double previous) {
    if (previous == 0) return InsightsThresholds.scoreStrong;
    if (current > previous * 1.5) return InsightsThresholds.scoreGood;
    if (current > previous * 1.2) return InsightsThresholds.scoreWatch;
    if (current < previous) return InsightsThresholds.scoreExcellent;
    return InsightsThresholds.scoreStrong;
  }

  /// Finds the single biggest expense for a given month
  Future<Map<String, dynamic>?> getBiggestExpense(DateTime month) async {
    Map<String, dynamic>? biggest;

    void checkBigger(
        double amount, String title, String category, DateTime? date) {
      if (biggest == null || amount > biggest!['amount']) {
        biggest = {
          'amount': amount,
          'title': title,
          'category': category,
          'date': date,
        };
      }
    }

    try {
      final allTxns = await _txService.getUnifiedTransactions(
          userID: _currentUserId,
          limit: InsightsLimits.unifiedTxnFetch,
          selectedCurrency: _currency);

      final monthTxns = allTxns.where((txn) {
        final date = txn['date'] as DateTime;
        return date.year == month.year &&
            date.month == month.month &&
            txn['is_credit'] == false;
      }).toList();

      for (var txn in monthTxns) {
        checkBigger(asDouble(txn['amount']), txn['title'] as String,
            txn['category'] as String, txn['date'] as DateTime);
      }
    } catch (e, stack) {
      AppErrorReporter.unexpected(
        'getBiggestExpense failed',
        error: e,
        stack: stack,
        context: {'feature': 'insights'},
      );
    }

    return biggest;
  }

  /// Calculates lifetime stats: Total Spent, Total Received.
  Future<Map<String, double>> getLifetimeStats() async {
    final stats = await _txService.getLifetimeStats(userID: _currentUserId);
    return {
      'totalSpent': asDouble(stats['totalSpent']),
      'totalReceived': asDouble(stats['totalReceived']),
      'overallTransaction':
          asDouble(stats['totalSpent']) + asDouble(stats['totalReceived']),
    };
  }

  /// Last [months] of spend ending at [anchorMonth] (inclusive).
  Future<List<Map<String, dynamic>>> getSpendingTrendEndingAt(
    DateTime anchorMonth, {
    int months = InsightsLimits.trendMonthsDefault,
  }) async {
    final trend = <Map<String, dynamic>>[];
    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(anchorMonth.year, anchorMonth.month - i, 1);
      final total = await getMonthlySpending(month);
      trend.add({
        'month': month,
        'label': _monthLabel(month),
        'total': total,
      });
    }
    return trend;
  }

  /// Weekday vs weekend spend for recap habit slide.
  Future<Map<String, dynamic>> computeWeekdaySpendPattern(
      DateTime month) async {
    try {
      final allTxns = await _txService.getUnifiedTransactions(
        userID: _currentUserId,
        limit: InsightsLimits.unifiedTxnFetch,
        selectedCurrency: _currency,
      );

      final monthTxns = allTxns.where((txn) {
        final date = txn['date'] as DateTime;
        return date.year == month.year &&
            date.month == month.month &&
            txn['is_credit'] == false;
      }).toList();

      if (monthTxns.length < InsightsLimits.minTxnsForHabit) {
        return {
          RecapDataKeys.habitType: RecapHabitTypes.quietMonth,
          RecapDataKeys.habitTransactionCount: monthTxns.length,
        };
      }

      double weekdaySpend = 0;
      double weekendSpend = 0;
      for (final txn in monthTxns) {
        final amount = asDouble(txn['amount']);
        final weekday = (txn['date'] as DateTime).weekday;
        if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
          weekendSpend += amount;
        } else {
          weekdaySpend += amount;
        }
      }

      String habitType;
      if (weekdaySpend <= 0 && weekendSpend > 0) {
        habitType = RecapHabitTypes.weekendSplurger;
      } else if (weekendSpend <= 0 && weekdaySpend > 0) {
        habitType = RecapHabitTypes.weekdayGrinder;
      } else if (weekdaySpend > 0) {
        final weekendRatio = weekendSpend / weekdaySpend;
        final weekdayRatio = weekdaySpend / weekendSpend;
        if (weekendRatio >= RecapHabitThresholds.weekendSplurgeRatio) {
          habitType = RecapHabitTypes.weekendSplurger;
        } else if (weekdayRatio >= RecapHabitThresholds.weekdayGrindRatio) {
          habitType = RecapHabitTypes.weekdayGrinder;
        } else {
          habitType = RecapHabitTypes.steadySpender;
        }
      } else {
        habitType = RecapHabitTypes.quietMonth;
      }

      return {
        RecapDataKeys.habitType: habitType,
        RecapDataKeys.habitTransactionCount: monthTxns.length,
        'weekdaySpend': weekdaySpend,
        'weekendSpend': weekendSpend,
      };
    } catch (e, stack) {
      AppErrorReporter.unexpected(
        'computeWeekdaySpendPattern failed',
        error: e,
        stack: stack,
        context: {'feature': 'recap'},
      );
      return {
        RecapDataKeys.habitType: RecapHabitTypes.quietMonth,
        RecapDataKeys.habitTransactionCount: 0,
      };
    }
  }
}
