/// Data models for Trip Mode — extends group concept with dates, destination, and per-day views.
library;

import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';

class TripModel {
  final String groupId; // Trip IS a group, reusing group infrastructure
  final String tripName;
  final String? destination;
  final DateTime startDate;
  final DateTime endDate;
  final String createdBy;
  final List<String> memberIds;
  final String? coverImageUrl;
  final String tripCurrency;

  TripModel({
    required this.groupId,
    required this.tripName,
    this.destination,
    required this.startDate,
    required this.endDate,
    required this.createdBy,
    this.memberIds = const [],
    this.coverImageUrl,
    this.tripCurrency = CurrencyDefaults.code,
  });

  int get totalDays => endDate.difference(startDate).inDays + 1;
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) &&
        now.isBefore(endDate.add(const Duration(days: 1)));
  }

  bool get isPast => DateTime.now().isAfter(endDate);
  bool get isUpcoming => DateTime.now().isBefore(startDate);

  Map<String, dynamic> toJSON() => {
        SupabaseColumns.groupId: groupId,
        SupabaseColumns.tripName: tripName,
        SupabaseColumns.destination: destination,
        SupabaseColumns.startDate: startDate.toIso8601String(),
        SupabaseColumns.endDate: endDate.toIso8601String(),
        SupabaseColumns.createdBy: createdBy,
        SupabaseColumns.memberIds: memberIds,
        SupabaseColumns.coverImageUrl: coverImageUrl,
        SupabaseColumns.tripCurrency: tripCurrency,
      };

  factory TripModel.fromJSON(Map<String, dynamic> json) {
    return TripModel(
      groupId: json[SupabaseColumns.groupId] as String,
      tripName: json[SupabaseColumns.tripName] as String,
      destination: json[SupabaseColumns.destination] as String?,
      startDate: DateTime.parse(json[SupabaseColumns.startDate] as String),
      endDate: DateTime.parse(json[SupabaseColumns.endDate] as String),
      createdBy: json[SupabaseColumns.createdBy] as String,
      memberIds: List<String>.from(json[SupabaseColumns.memberIds] ?? []),
      coverImageUrl: json[SupabaseColumns.coverImageUrl] as String?,
      tripCurrency: json[SupabaseColumns.tripCurrency] as String? ??
          CurrencyDefaults.code,
    );
  }
}

/// Per-day aggregation of expenses during a trip.
class TripDaySummary {
  final DateTime date;
  final int dayNumber; // Day 1, Day 2, ...
  final double totalSpent;
  final int transactionCount;
  final String? topCategory;
  final List<TripExpenseEntry> expenses;

  TripDaySummary({
    required this.date,
    required this.dayNumber,
    required this.totalSpent,
    required this.transactionCount,
    this.topCategory,
    this.expenses = const [],
  });
}

/// Lightweight expense entry for timeline display.
class TripExpenseEntry {
  final String transactionId;
  final String description;
  final double amount;
  final String paidByName;
  final String? paidByAvatarUrl;
  final String? category;
  final DateTime timestamp;

  TripExpenseEntry({
    required this.transactionId,
    required this.description,
    required this.amount,
    required this.paidByName,
    this.paidByAvatarUrl,
    this.category,
    required this.timestamp,
  });
}

/// Summary stats for a completed trip.
class TripSummaryStats {
  final double totalSpent;
  final double avgPerDay;
  final String biggestExpenseDesc;
  final double biggestExpenseAmount;
  final String mvpMemberName; // Who paid the most
  final double mvpAmount;
  final String topCategory;
  final int totalTransactions;

  TripSummaryStats({
    required this.totalSpent,
    required this.avgPerDay,
    required this.biggestExpenseDesc,
    required this.biggestExpenseAmount,
    required this.mvpMemberName,
    required this.mvpAmount,
    required this.topCategory,
    required this.totalTransactions,
  });
}
