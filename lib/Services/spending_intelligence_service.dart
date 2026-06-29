import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:splitter/Controllers/currency_controller.dart';
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

    return {
      'thisMonthTotal': thisMonthAmount,
      'lastMonthTotal': lastMonthAmount,
      'percentChange': percentChange,
      'topCategory': topCategory,
      'topCategoryAmount': topCatAmount,
      'healthScore': combinedHealth,
      'spendingHealthScore': spendingHealth,
      'settleUpHealthScore': settleHealth,
      'unusualExpenses': unusual,
      'monthlyDigest': digest,
      'spendingTrend': trend,
    };
  }

  int _calculateHealthScore(double current, double previous) {
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
