import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Services/spending_intelligence_service.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GamificationService {
  final SpendingIntelligenceService _spendingService =
      SpendingIntelligenceService();
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _userId = SupabaseAuth().supabaseGetUserID();

  /// 0–100 promptness: higher when friend keeps low outstanding balance with you.
  Future<int> computeFriendPromptnessScore(String friendUserId) async {
    try {
      final balances = await _supabase
          .from(SupabaseTables.groupBalance)
          .select(
            '${SupabaseColumns.donorId}, ${SupabaseColumns.receiverId}, ${SupabaseColumns.amount}',
          )
          .or(
            'and(${SupabaseColumns.donorId}.eq.$_userId,${SupabaseColumns.receiverId}.eq.$friendUserId),'
            'and(${SupabaseColumns.donorId}.eq.$friendUserId,${SupabaseColumns.receiverId}.eq.$_userId)',
          );

      if (balances.isEmpty) return GamificationThresholds.defaultPromptness;

      double total = 0;
      double small = 0;
      for (final row in balances) {
        final amount =
            double.tryParse(row[SupabaseColumns.amount].toString()) ?? 0.0;
        total += amount;
        if (amount <= GamificationThresholds.defaultAmount) small += amount;
      }

      if (total <= 0) return GamificationThresholds.defaultPromptnessHigh;
      final ratio = small / total;
      return (PromptnessScoreTiers.good + ratio * PromptnessScoreTiers.good)
          .round()
          .clamp(0, 100);
    } catch (e, stack) {
      AppErrorReporter.unexpected(
        'GamificationService promptness score failed',
        error: e,
        stack: stack,
        context: {'feature': 'gamification'},
      );
      return GamificationThresholds.defaultPromptnessLow;
    }
  }

  Future<Map<String, dynamic>> generateRecap(DateTime month) async {
    final breakdown = await _spendingService.getCategoryBreakdown(month);
    final total = await _spendingService.getMonthlySpending(month);

    final prevMonth = DateTime(month.year, month.month - 1, month.day);
    final lastMonthTotal = await _spendingService.getMonthlySpending(prevMonth);

    final biggestExpenseData = await _spendingService.getBiggestExpense(month);
    final digest = await _spendingService.generateMonthlyDigest(month);

    String topCategory = DisplayFallbacks.none;
    double topAmount = 0.0;

    if (breakdown.isNotEmpty) {
      final sorted = breakdown.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topCategory = sorted.first.key;
      topAmount = sorted.first.value;
    }

    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final averageDailySpend = total / daysInMonth;

    return {
      'month': month,
      'totalSpent': total,
      'lastMonthTotal': lastMonthTotal,
      'topCategory': topCategory,
      'topCategoryAmount': topAmount,
      'categoryBreakdown': breakdown,
      'biggestExpenseAmount': biggestExpenseData?['amount'] ?? 0.0,
      'biggestExpenseTitle':
          biggestExpenseData?['title'] ?? DisplayFallbacks.nothing,
      'biggestExpenseCategory':
          biggestExpenseData?['category'] ?? CategoryDefaults.dash,
      'biggestExpenseDate': biggestExpenseData?['date'],
      'averageDailySpend': averageDailySpend,
      'message': digest,
    };
  }
}
