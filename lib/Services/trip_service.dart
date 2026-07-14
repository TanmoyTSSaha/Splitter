import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Model/trip_model.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/Utils/transaction_date_formatter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for Trip Mode — CRUD, per-day bucketing, summary stats.
/// Trips are stored as groups with an `is_trip` flag in metadata.
class TripService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Create a new trip (uses RPC to bypass RLS).
  Future<TripModel> createTrip({
    required String tripName,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required String createdBy,
    required List<String> memberIds,
    String tripCurrency = CurrencyDefaults.code,
  }) async {
    final result =
        await _supabase.rpc(SupabaseRpc.createTripWithMember, params: {
      'p_trip_name': tripName,
      'p_destination': destination,
      'p_start_date': startDate.toIso8601String(),
      'p_end_date': endDate.toIso8601String(),
      'p_trip_currency': tripCurrency,
    });

    final groupId = result['group_id'] as String;

    return TripModel(
      groupId: groupId,
      tripName: tripName,
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      createdBy: createdBy,
      memberIds: memberIds,
      tripCurrency: tripCurrency,
    );
  }

  /// Fetch all trips for a user.
  Future<List<TripModel>> getTrips(String userId) async {
    try {
      final memberRows = await _supabase
          .from(SupabaseTables.groupMembers)
          .select('group_id')
          .eq('user_id', userId);

      final groupIds = memberRows.map((r) => r['group_id'] as String).toList();

      if (groupIds.isEmpty) return [];

      final tripRows = await _supabase
          .from(SupabaseTables.tripMetadata)
          .select()
          .inFilter('group_id', groupIds)
          .order('start_date', ascending: false);

      return tripRows.map((r) => TripModel.fromJSON(r)).toList();
    } catch (e, stack) {
      AppErrorReporter.report(
        'TripService.getTrips failed',
        error: e,
        stack: stack,
        context: {'feature': 'trips', 'operation': 'getTrips'},
      );
      return [];
    }
  }

  /// Fetch consolidated expense rows for a trip (one per transaction group).
  Future<List<Map<String, dynamic>>> getTripTransactions(String groupId) async {
    try {
      final response = await _supabase
          .from(SupabaseTables.groupTransaction)
          .select()
          .eq('group_id', groupId)
          .neq(SupabaseColumns.sharingType, SharingTypeValues.settlement)
          .order('transaction_date', ascending: false);

      final seen = <String>{};
      final consolidated = <Map<String, dynamic>>[];

      for (final row in response) {
        final groupKey = row['transaction_group_id'] as String? ??
            row['transaction_id'] as String? ??
            '';
        if (groupKey.isEmpty || seen.contains(groupKey)) continue;
        seen.add(groupKey);
        consolidated.add(Map<String, dynamic>.from(row));
      }

      return consolidated;
    } catch (e, stack) {
      AppErrorReporter.report(
        'TripService.getTripTransactions failed',
        error: e,
        stack: stack,
        context: {'feature': 'trips', 'operation': 'getTripTransactions'},
      );
      return [];
    }
  }

  /// Fetch members of a trip for name mapping.
  Future<List<Map<String, dynamic>>> getTripMembers(String groupId) async {
    try {
      final memberRows = await _supabase
          .from(SupabaseTables.groupMembers)
          .select('user_id')
          .eq('group_id', groupId);

      final userIds = memberRows.map((r) => r['user_id'] as String).toList();
      if (userIds.isEmpty) return [];

      final users = await _supabase
          .from(SupabaseTables.users)
          .select('user_id, firstname, lastname')
          .inFilter('user_id', userIds);

      return users.map((u) {
        final name = '${u['firstname'] ?? ''} ${u['lastname'] ?? ''}'.trim();
        return {
          'id': u['user_id'] as String,
          'name': name.isEmpty ? DisplayFallbacks.unknown : name,
        };
      }).toList();
    } catch (e, stack) {
      AppErrorReporter.report(
        'TripService.getTripMembers failed',
        error: e,
        stack: stack,
        context: {'feature': 'trips', 'operation': 'getTripMembers'},
      );
      return [];
    }
  }

  /// Bucket transactions by day for a trip's date range.
  List<TripDaySummary> bucketByDay({
    required TripModel trip,
    required List<Map<String, dynamic>> transactions,
    required Map<String, String> userNameMap,
  }) {
    final days = <TripDaySummary>[];

    for (int i = 0; i < trip.totalDays; i++) {
      final day = trip.startDate.add(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(AppMotion.reminderDaily);

      final dayTxns = transactions.where((t) {
        final txDate = TransactionDateFormatter.parseStorage(
            t['transaction_date']);
        if (txDate == null) return false;
        final local = txDate.toLocal();
        final localDay = DateTime(local.year, local.month, local.day);
        return !localDay.isBefore(dayStart) && localDay.isBefore(dayEnd);
      }).toList();

      double total = 0;
      final Map<String, double> categoryTotals = {};
      final entries = <TripExpenseEntry>[];

      for (final t in dayTxns) {
        final amount =
            double.tryParse(t['total_transaction_amount'].toString()) ?? 0;
        total += amount;

        final cat = t['category'] as String? ?? CategoryDefaults.other;
        categoryTotals[cat] = (categoryTotals[cat] ?? 0) + amount;

        final paidBy = t['paid_by'] as String? ?? '';
        entries.add(TripExpenseEntry(
          transactionId: t['transaction_id'] as String? ?? '',
          description: t['description'] as String? ?? CategoryDefaults.expense,
          amount: amount,
          paidByName: userNameMap[paidBy] ?? DisplayFallbacks.unknown,
          category: cat,
          timestamp: TransactionDateFormatter.parseStorage(
                  t['transaction_date']) ??
              day,
        ));
      }

      // Find top category
      String? topCat;
      if (categoryTotals.isNotEmpty) {
        topCat = categoryTotals.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
      }

      days.add(TripDaySummary(
        date: day,
        dayNumber: i + 1,
        totalSpent: total,
        transactionCount: dayTxns.length,
        topCategory: topCat,
        expenses: entries,
      ));
    }

    return days;
  }

  /// Compute summary stats for a trip.
  TripSummaryStats computeSummary({
    required TripModel trip,
    required List<Map<String, dynamic>> transactions,
    required Map<String, String> userNameMap,
  }) {
    double totalSpent = 0;
    double biggestAmount = 0;
    String biggestDesc = '';
    final Map<String, double> memberTotals = {};
    final Map<String, double> categoryTotals = {};

    for (final t in transactions) {
      final amount =
          double.tryParse(t['total_transaction_amount'].toString()) ?? 0;
      totalSpent += amount;

      if (amount > biggestAmount) {
        biggestAmount = amount;
        biggestDesc = t['description'] as String? ?? CategoryDefaults.expense;
      }

      final paidBy = t['paid_by'] as String? ?? '';
      memberTotals[paidBy] = (memberTotals[paidBy] ?? 0) + amount;

      final cat = t['category'] as String? ?? CategoryDefaults.other;
      categoryTotals[cat] = (categoryTotals[cat] ?? 0) + amount;
    }

    // MVP: who paid the most
    String mvpId = '';
    double mvpAmount = 0;
    memberTotals.forEach((id, total) {
      if (total > mvpAmount) {
        mvpId = id;
        mvpAmount = total;
      }
    });

    // Top category
    String topCat = CategoryDefaults.other;
    if (categoryTotals.isNotEmpty) {
      topCat = categoryTotals.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }

    return TripSummaryStats(
      totalSpent: totalSpent,
      avgPerDay: trip.totalDays > 0 ? totalSpent / trip.totalDays : 0,
      biggestExpenseDesc: biggestDesc,
      biggestExpenseAmount: biggestAmount,
      mvpMemberName: userNameMap[mvpId] ?? DisplayFallbacks.unknown,
      mvpAmount: mvpAmount,
      topCategory: topCat,
      totalTransactions: transactions.length,
    );
  }
}
