import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:splitter/Controllers/currency_controller.dart';
import 'package:splitter/Services/SupabaseServices/goal_service.dart';
import 'package:splitter/Services/SupabaseServices/transaction_service.dart';
import 'package:splitter/Services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SpendingIntelligenceService {
  final supabase = Supabase.instance.client;
  final String _currentUserId = SupabaseAuth().supabaseGetUserID();
  final TransactionService _txService = TransactionService();

  String get _currency => Get.isRegistered<CurrencyController>()
      ? Get.find<CurrencyController>().code
      : 'INR';

  /// Calculates total spending for a given month.
  Future<double> getMonthlySpending(DateTime month) async {
    final analytics = await _txService.getMonthlySpendAnalytics(
        userID: _currentUserId, selectedCurrency: _currency, month: month);
    return analytics['total'] ?? 0.0;
  }

  /// Breakdown of spending by category for a given month.
  Future<Map<String, double>> getCategoryBreakdown(DateTime month) async {
    final analytics = await _txService.getMonthlySpendAnalytics(
        userID: _currentUserId, selectedCurrency: _currency, month: month);
    final breakdown = Map<String, double>.from(analytics);
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
    const labels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return labels[month.month - 1];
  }

  /// Flags expenses with z-score > 2 vs category mean for the month.
  Future<List<Map<String, dynamic>>> detectUnusualExpenses(
      DateTime month) async {
    try {
      final allTxns = await _txService.getUnifiedTransactions(
          userID: _currentUserId, limit: 1000, selectedCurrency: _currency);

      final monthTxns = allTxns.where((txn) {
        final date = txn['date'] as DateTime;
        return date.year == month.year &&
            date.month == month.month &&
            txn['is_credit'] == false;
      }).toList();

      if (monthTxns.length < 3) return [];

      final byCategory = <String, List<double>>{};
      for (final txn in monthTxns) {
        final cat = txn['category'] as String? ?? 'Other';
        byCategory.putIfAbsent(cat, () => []).add(txn['amount'] as double);
      }

      final unusual = <Map<String, dynamic>>[];
      for (final txn in monthTxns) {
        final cat = txn['category'] as String? ?? 'Other';
        final amounts = byCategory[cat] ?? [];
        if (amounts.length < 2) continue;

        final mean = amounts.reduce((a, b) => a + b) / amounts.length;
        final variance =
            amounts.map((a) => math.pow(a - mean, 2)).reduce((a, b) => a + b) /
                amounts.length;
        final stdDev = math.sqrt(variance);
        if (stdDev < 1) continue;

        final amount = txn['amount'] as double;
        final zScore = (amount - mean) / stdDev;
        if (zScore > 2) {
          unusual.add({
            'title': txn['title'],
            'amount': amount,
            'category': cat,
            'date': txn['date'],
            'zScore': zScore,
          });
        }
      }

      unusual.sort((a, b) =>
          (b['zScore'] as double).compareTo(a['zScore'] as double));
      return unusual.take(5).toList();
    } catch (e) {
      debugPrint('detectUnusualExpenses: $e');
      return [];
    }
  }

  /// 0–100 score: share of group balances involving the user that are near zero.
  Future<int> getSettleUpHealthScore() async {
    try {
      final memberRows = await supabase
          .from('group_members')
          .select('group_id')
          .eq('user_id', _currentUserId);

      final groupIds =
          memberRows.map((r) => r['group_id'] as String).toList();
      if (groupIds.isEmpty) return 100;

      final balances = await supabase
          .from('group_balance')
          .select('donor_id, receiver_id, amount')
          .inFilter('group_id', groupIds);

      if (balances.isEmpty) return 100;

      double userExposure = 0;
      double settledExposure = 0;
      const threshold = 50.0;

      for (final row in balances) {
        final donor = row['donor_id'] as String?;
        final receiver = row['receiver_id'] as String?;
        final amount =
            double.tryParse(row['amount'].toString()) ?? 0.0;
        if (donor != _currentUserId && receiver != _currentUserId) continue;

        userExposure += amount;
        if (amount <= threshold) settledExposure += amount;
      }

      if (userExposure <= 0) return 100;
      return ((settledExposure / userExposure) * 100).round().clamp(0, 100);
    } catch (e) {
      debugPrint('getSettleUpHealthScore: $e');
      return 75;
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
      return 'No tracked spending this month — your wallet stayed quiet.';
    }

    String topCat = 'miscellaneous';
    if (breakdown.isNotEmpty) {
      final sorted = breakdown.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topCat = sorted.first.key;
    }

    final change = prevTotal > 0 ? ((total - prevTotal) / prevTotal) * 100 : 0;
    final changeText = change > 5
        ? 'up ${change.toStringAsFixed(0)}% from last month'
        : change < -5
            ? 'down ${change.abs().toStringAsFixed(0)}% from last month'
            : 'steady vs last month';

    final buffer = StringBuffer(
      'You spent ${_currencySymbol()}${total.toStringAsFixed(0)} in ${_monthLabel(month)} — $changeText. '
      'Top category: $topCat. ',
    );

    if (settleHealth >= 80) {
      buffer.write('Group balances look healthy. ');
    } else if (settleHealth < 50) {
      buffer.write('Several group balances are still open — consider settling up. ');
    }

    if (unusual.isNotEmpty) {
      final top = unusual.first;
      buffer.write(
        'Unusual spike: ${top['title']} (${_currencySymbol()}${(top['amount'] as double).toStringAsFixed(0)}).',
      );
    }

    return buffer.toString();
  }

  String _currencySymbol() {
    if (Get.isRegistered<CurrencyController>()) {
      return Get.find<CurrencyController>().symbol;
    }
    return '₹';
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

    final miniTrend = await getSpendingTrend(months: 3);
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
    final percentChange = lite['percentChange'] as double;
    final openAmount = social['openExposure'] as double;
    final groupCount = social['groupCount'] as int;

    String message;
    String hookType;

    if (openAmount >= 500 && groupCount > 0) {
      hookType = 'settle_up';
      message =
          '${_currencySymbol()}${openAmount.toStringAsFixed(0)} unsettled across $groupCount group${groupCount == 1 ? '' : 's'} — see your trust score';
    } else if (percentChange > 15) {
      hookType = 'spending_up';
      message =
          'Spending up ${percentChange.toStringAsFixed(0)}% this month — see what\'s driving it';
    } else if (percentChange < -15) {
      hookType = 'spending_down';
      message =
          'Spending down ${percentChange.abs().toStringAsFixed(0)}% — see your full breakdown';
    } else {
      hookType = 'generic';
      message = 'New: AI spending briefing — tap to preview your insights';
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
    final prev = await getCategoryBreakdown(
        DateTime(month.year, month.month - 1, 1));

    final allCats = {...current.keys, ...prev.keys};
    final deltas = <Map<String, dynamic>>[];

    for (final cat in allCats) {
      final cur = current[cat] ?? 0;
      final prevAmt = prev[cat] ?? 0;
      double pct = 0;
      if (prevAmt > 0) {
        pct = ((cur - prevAmt) / prevAmt) * 100;
      } else if (cur > 0) {
        pct = 100;
      }
      deltas.add({
        'category': cat,
        'current': cur,
        'previous': prevAmt,
        'percentChange': pct,
      });
    }

    deltas.sort((a, b) =>
        (b['current'] as double).compareTo(a['current'] as double));
    return deltas;
  }

  /// Social trust signals from group balances and transactions.
  Future<Map<String, dynamic>> getSocialTrustInsights() async {
    try {
      final memberRows = await supabase
          .from('group_members')
          .select('group_id')
          .eq('user_id', _currentUserId);

      final groupIds =
          memberRows.map((r) => r['group_id'] as String).toList();

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
          .from('group_balance')
          .select('group_id, donor_id, receiver_id, amount')
          .inFilter('group_id', groupIds);

      double openExposure = 0;
      final groupsWithBalance = <String>{};
      String? topGroupId;
      double topGroupAmount = 0;

      for (final row in balances) {
        final donor = row['donor_id'] as String?;
        final receiver = row['receiver_id'] as String?;
        final amount =
            double.tryParse(row['amount'].toString()) ?? 0.0;
        if (amount < 1) continue;
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
            .from('group_transaction')
            .select('paid_by, shared_transaction_amount, transaction_date')
            .or('paid_by.eq.$_currentUserId,shared_with.eq.$_currentUserId')
            .gte('transaction_date',
                DateTime(now.year, now.month, 1).toIso8601String())
            .neq('category', 'Settlement');

        double userPaid = 0;
        double totalGroupSpend = 0;
        for (final txn in groupTxns) {
          final amt = double.tryParse(
                  txn['shared_transaction_amount']?.toString() ?? '0') ??
              0;
          totalGroupSpend += amt;
          if (txn['paid_by'] == _currentUserId) userPaid += amt;
        }
        if (totalGroupSpend > 0) {
          payerRatio = (userPaid / totalGroupSpend) * 100;
        }
      } catch (e) {
        debugPrint('payerRatio: $e');
      }

      // Settlement latency: avg days from expense to settlement (last 90 days).
      int settlementAvgDays = 0;
      int staleBalanceCount = 0;
      double staleBalanceAmount = 0;
      try {
        final cutoff = DateTime.now().subtract(const Duration(days: 90));
        final settlements = await supabase
            .from('group_transaction')
            .select('transaction_date, group_id')
            .eq('category', 'Settlement')
            .or('paid_by.eq.$_currentUserId,shared_with.eq.$_currentUserId')
            .gte('transaction_date', cutoff.toIso8601String())
            .order('transaction_date', ascending: false)
            .limit(50);

        final latencies = <int>[];
        for (final s in settlements) {
          final settleDate = DateTime.tryParse(
              s['transaction_date']?.toString() ?? '');
          final gid = s['group_id'] as String?;
          if (settleDate == null || gid == null) continue;

          final priorExpense = await supabase
              .from('group_transaction')
              .select('transaction_date')
              .eq('group_id', gid)
              .neq('category', 'Settlement')
              .lt('transaction_date', settleDate.toIso8601String())
              .order('transaction_date', ascending: false)
              .limit(1);

          if (priorExpense.isNotEmpty) {
            final expDate = DateTime.tryParse(
                priorExpense.first['transaction_date']?.toString() ?? '');
            if (expDate != null) {
              latencies.add(settleDate.difference(expDate).inDays.clamp(0, 365));
            }
          }
        }
        if (latencies.isNotEmpty) {
          settlementAvgDays =
              (latencies.reduce((a, b) => a + b) / latencies.length).round();
        }

        // Stale: open balances in groups with no settlement in 30 days.
        final staleCutoff = DateTime.now().subtract(const Duration(days: 30));
        for (final gid in groupsWithBalance) {
          final recentSettle = await supabase
              .from('group_transaction')
              .select('transaction_id')
              .eq('group_id', gid)
              .eq('category', 'Settlement')
              .gte('transaction_date', staleCutoff.toIso8601String())
              .limit(1);
          if (recentSettle.isEmpty) {
            staleBalanceCount++;
            for (final row in balances) {
              if (row['group_id'] != gid) continue;
              final amt =
                  double.tryParse(row['amount'].toString()) ?? 0.0;
              final donor = row['donor_id'] as String?;
              final receiver = row['receiver_id'] as String?;
              if (donor == _currentUserId || receiver == _currentUserId) {
                staleBalanceAmount += amt;
              }
            }
          }
        }
      } catch (e) {
        debugPrint('settlement latency: $e');
      }

      String? topGroupName;
      if (topGroupId != null) {
        try {
          final g = await supabase
              .from('groups')
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
    } catch (e) {
      debugPrint('getSocialTrustInsights: $e');
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
      if ((d['percentChange'] as double) > 20 &&
          (d['current'] as double) > 100) {
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
      'categoryDeltas': deltas.take(5).toList(),
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
        'explanation':
            'Average of spending and settle-up scores. Higher means healthier finances.',
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
    if (score >= 80) return 'Good';
    if (score >= 50) return 'Watch';
    return 'Needs attention';
  }

  static String spendingExplanation(double percentChange) {
    if (percentChange > 50) {
      return 'Spending jumped ${percentChange.toStringAsFixed(0)}% vs last month.';
    }
    if (percentChange > 20) {
      return 'Spending is up ${percentChange.toStringAsFixed(0)}% — review top categories.';
    }
    if (percentChange < -10) {
      return 'Spending is down ${percentChange.abs().toStringAsFixed(0)}% — nice restraint.';
    }
    return 'Spending is steady compared to last month.';
  }

  static String settleUpExplanation(double openExposure, int score) {
    if (openExposure <= 0) return 'No open group balances — you\'re all settled.';
    if (score < 50) {
      return '${openExposure.toStringAsFixed(0)} in open balances — settling up improves trust.';
    }
    return 'Most balances are small — keep settling regularly.';
  }

  /// Prioritized actionable items for Pro users.
  Future<List<Map<String, dynamic>>> getActionQueue(DateTime month) async {
    final actions = <Map<String, dynamic>>[];
    final social = await getSocialTrustInsights();
    final deltas = await getCategoryDeltas(month);
    final unusual = await detectUnusualExpenses(month);
    final goals = await GoalService().getGoals(userID: _currentUserId);

    final staleAmt = social['staleBalanceAmount'] as double;
    final staleCount = social['staleBalanceCount'] as int;
    if (staleAmt >= 500 && staleCount > 0) {
      actions.add({
        'priority': 1,
        'title': 'Settle stale balances',
        'reason':
            '${_currencySymbol()}${staleAmt.toStringAsFixed(0)} open for 30+ days',
        'action_type': 'settle_up',
        'group_id': social['topGroupId'],
        'group_name': social['topGroupName'],
      });
    } else if ((social['openExposure'] as double) >= 500) {
      actions.add({
        'priority': 2,
        'title': 'Clear open balances',
        'reason':
            '${_currencySymbol()}${(social['openExposure'] as double).toStringAsFixed(0)} across ${social['groupCount']} groups',
        'action_type': 'settle_up',
        'group_id': social['topGroupId'],
        'group_name': social['topGroupName'],
      });
    }

    for (final d in deltas) {
      final pct = d['percentChange'] as double;
      final cur = d['current'] as double;
      if (pct > 30 && cur > 200) {
        actions.add({
          'priority': 3,
          'title': 'Review ${d['category']}',
          'reason':
              'Up ${pct.toStringAsFixed(0)}% this month (${_currencySymbol()}${cur.toStringAsFixed(0)})',
          'action_type': 'review_category',
          'category': d['category'],
        });
        break;
      }
    }

    if (unusual.isNotEmpty) {
      final top = unusual.first;
      actions.add({
        'priority': 4,
        'title': 'Check unusual spend',
        'reason': '${top['title']} — ${_currencySymbol()}${(top['amount'] as double).toStringAsFixed(0)}',
        'action_type': 'view_expense',
        'category': top['category'],
      });
    }

    for (final goal in goals) {
      if (goal.status != 'active') continue;
      final target = goal.targetAmount ?? 0;
      final current = goal.currentAmount ?? 0;
      if (target <= 0) continue;
      final progress = current / target;
      final deadline = goal.deadline;
      if (deadline != null &&
          deadline.isBefore(DateTime.now().add(const Duration(days: 60))) &&
          progress < 0.5) {
        actions.add({
          'priority': 5,
          'title': 'Goal needs attention',
          'reason': '${goal.title} is ${(progress * 100).toStringAsFixed(0)}% funded',
          'action_type': 'view_goal',
          'goal_id': goal.id,
          'goal': goal,
        });
        break;
      }
    }

    actions.sort((a, b) =>
        (a['priority'] as int).compareTo(b['priority'] as int));
    return actions.take(5).toList();
  }

  /// Structured context for AI briefing (no raw PII beyond category names).
  Future<Map<String, dynamic>> buildAIBriefingContext() async {
    final now = DateTime.now();
    final full = await getInsights();
    final coach = await getSpendingCoachInsights(now);
    final social = await getSocialTrustInsights();
    final goals = await GoalService().getGoals(userID: _currentUserId);
    final goalSummaries = goals
        .where((g) => g.status == 'active')
        .take(3)
        .map((g) => {
              'title': g.title,
              'progress_pct': g.targetAmount != null && g.targetAmount! > 0
                  ? ((g.currentAmount ?? 0) / g.targetAmount! * 100)
                      .round()
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
    String topCategory = "-";
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
      openExposure: social['openExposure'] as double,
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
    if (previous == 0) return 80;
    if (current > previous * 1.5) return 40;
    if (current > previous * 1.2) return 60;
    if (current < previous) return 90;
    return 80;
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
          userID: _currentUserId, limit: 1000, selectedCurrency: _currency);

      final monthTxns = allTxns.where((txn) {
        final date = txn['date'] as DateTime;
        return date.year == month.year &&
            date.month == month.month &&
            txn['is_credit'] == false;
      }).toList();

      for (var txn in monthTxns) {
        checkBigger(txn['amount'] as double, txn['title'] as String,
            txn['category'] as String, txn['date'] as DateTime);
      }
    } catch (e) {
      debugPrint('Error getting biggest expense: $e');
    }

    return biggest;
  }

  /// Calculates lifetime stats: Total Spent, Total Received.
  Future<Map<String, double>> getLifetimeStats() async {
    final stats = await _txService.getLifetimeStats(userID: _currentUserId);
    return {
      'totalSpent': stats['totalSpent'] ?? 0.0,
      'totalReceived': stats['totalReceived'] ?? 0.0,
      'overallTransaction':
          (stats['totalSpent'] ?? 0.0) + (stats['totalReceived'] ?? 0.0),
    };
  }
}
