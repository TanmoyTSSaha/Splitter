import 'package:flutter/foundation.dart';
import 'package:splitter/Model/badge_model.dart';
import 'package:splitter/Services/spending_intelligence_service.dart';
import 'package:splitter/Services/supabase_service.dart';
import 'package:splitter/Services/trip_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GamificationService {
  final SpendingIntelligenceService _spendingService =
      SpendingIntelligenceService();
  final TripService _tripService = TripService();
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _userId = SupabaseAuth().supabaseGetUserID();

  final List<BadgeModel> _allBadges = [
    BadgeModel(
      id: 'first_trip',
      name: 'Explorer',
      description: 'Create your first trip.',
      iconPath: 'assets/badges/explorer.png',
      requirementType: 'create_trip',
      requirementValue: 1,
    ),
    BadgeModel(
      id: 'big_spender',
      name: 'Big Spender',
      description: 'Spend more than ₹1000 in total.',
      iconPath: 'assets/badges/money_bag.png',
      requirementType: 'total_spent',
      requirementValue: 1000.0,
    ),
    BadgeModel(
      id: 'settlement_hero',
      name: 'Settlement Hero',
      description: 'Settle up 5 times.',
      iconPath: 'assets/badges/handshake.png',
      requirementType: 'settlements_count',
      requirementValue: 5,
    ),
    BadgeModel(
      id: 'early_bird',
      name: 'Early Bird',
      description: 'Add an expense before 8 AM.',
      iconPath: 'assets/badges/sun.png',
      requirementType: 'early_expense',
      requirementValue: 1,
    ),
  ];

  Future<int> _getTripsCreated() async {
    try {
      final trips = await _tripService.getTrips(_userId);
      return trips.length;
    } catch (e) {
      debugPrint('trips count: $e');
      return 0;
    }
  }

  Future<int> _getSettlementsCount() async {
    try {
      final rows = await _supabase
          .from('group_transaction')
          .select('transaction_id')
          .eq('sharing_type', 'settlement')
          .or('paid_by.eq.$_userId,shared_with.eq.$_userId');
      return rows.length;
    } catch (e) {
      debugPrint('settlements count: $e');
      return 0;
    }
  }

  Future<bool> _hasEarlyExpense() async {
    try {
      final rows = await _supabase
          .from('group_transaction')
          .select('transaction_date')
          .eq('paid_by', _userId)
          .limit(200);
      for (final row in rows) {
        final date = DateTime.tryParse(row['transaction_date']?.toString() ?? '');
        if (date != null && date.hour < 8) return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> _getMetrics() async {
    final stats = await _spendingService.getLifetimeStats();
    return {
      'totalSpent': stats['totalSpent'] ?? 0.0,
      'tripsCreated': await _getTripsCreated(),
      'settlementsCount': await _getSettlementsCount(),
      'hasEarlyExpense': await _hasEarlyExpense(),
    };
  }

  Future<List<BadgeModel>> getBadges() async {
    final metrics = await _getMetrics();
    final totalSpent = metrics['totalSpent'] as double;
    final tripsCreated = metrics['tripsCreated'] as int;
    final settlementsCount = metrics['settlementsCount'] as int;
    final hasEarlyExpense = metrics['hasEarlyExpense'] as bool;

    return _allBadges.map((badge) {
      double progress = 0.0;
      bool isUnlocked = false;

      switch (badge.requirementType) {
        case 'total_spent':
          progress =
              (totalSpent / (badge.requirementValue as double)).clamp(0.0, 1.0);
          isUnlocked = totalSpent >= (badge.requirementValue as double);
          break;
        case 'create_trip':
          progress = (tripsCreated / (badge.requirementValue as int))
              .clamp(0.0, 1.0);
          isUnlocked = tripsCreated >= (badge.requirementValue as int);
          break;
        case 'settlements_count':
          progress = (settlementsCount / (badge.requirementValue as int))
              .clamp(0.0, 1.0);
          isUnlocked = settlementsCount >= (badge.requirementValue as int);
          break;
        case 'early_expense':
          progress = hasEarlyExpense ? 1.0 : 0.0;
          isUnlocked = hasEarlyExpense;
          break;
        default:
          progress = 0.0;
          isUnlocked = false;
      }

      return badge.copyWith(isUnlocked: isUnlocked, progress: progress);
    }).toList();
  }

  /// Returns badges that became unlocked since the last check.
  Future<List<BadgeModel>> checkNewlyUnlocked(
      List<BadgeModel> previousBadges) async {
    final current = await getBadges();
    final newlyUnlocked = <BadgeModel>[];
    for (final badge in current) {
      if (!badge.isUnlocked) continue;
      final wasUnlocked = previousBadges
          .any((b) => b.id == badge.id && b.isUnlocked);
      if (!wasUnlocked) newlyUnlocked.add(badge);
    }
    return newlyUnlocked;
  }

  /// 0–100 promptness: higher when friend keeps low outstanding balance with you.
  Future<int> computeFriendPromptnessScore(String friendUserId) async {
    try {
      final balances = await _supabase
          .from('group_balance')
          .select('donor_id, receiver_id, amount')
          .or(
            'and(donor_id.eq.$_userId,receiver_id.eq.$friendUserId),'
            'and(donor_id.eq.$friendUserId,receiver_id.eq.$_userId)',
          );

      if (balances.isEmpty) return 85;

      double total = 0;
      double small = 0;
      for (final row in balances) {
        final amount =
            double.tryParse(row['amount'].toString()) ?? 0.0;
        total += amount;
        if (amount <= 100) small += amount;
      }

      if (total <= 0) return 90;
      final ratio = small / total;
      return (50 + ratio * 50).round().clamp(0, 100);
    } catch (e) {
      debugPrint('promptness score: $e');
      return 70;
    }
  }

  Future<Map<String, dynamic>> generateRecap(DateTime month) async {
    final breakdown = await _spendingService.getCategoryBreakdown(month);
    final total = await _spendingService.getMonthlySpending(month);

    final prevMonth = DateTime(month.year, month.month - 1, month.day);
    final lastMonthTotal = await _spendingService.getMonthlySpending(prevMonth);

    final biggestExpenseData = await _spendingService.getBiggestExpense(month);
    final digest = await _spendingService.generateMonthlyDigest(month);

    String topCategory = "None";
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
      'biggestExpenseTitle': biggestExpenseData?['title'] ?? 'Nothing',
      'biggestExpenseCategory': biggestExpenseData?['category'] ?? '-',
      'biggestExpenseDate': biggestExpenseData?['date'],
      'averageDailySpend': averageDailySpend,
      'message': digest,
    };
  }
}
