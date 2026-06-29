/// Data models for Trip Mode — extends group concept with dates, destination, and per-day views.

class TripModel {
  final String groupId; // Trip IS a group, reusing group infrastructure
  final String tripName;
  final String? destination;
  final DateTime startDate;
  final DateTime endDate;
  final String createdBy;
  final List<String> memberIds;
  final String? coverImageUrl;

  TripModel({
    required this.groupId,
    required this.tripName,
    this.destination,
    required this.startDate,
    required this.endDate,
    required this.createdBy,
    this.memberIds = const [],
    this.coverImageUrl,
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
        'group_id': groupId,
        'trip_name': tripName,
        'destination': destination,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'created_by': createdBy,
        'member_ids': memberIds,
        'cover_image_url': coverImageUrl,
      };

  factory TripModel.fromJSON(Map<String, dynamic> json) {
    return TripModel(
      groupId: json['group_id'] as String,
      tripName: json['trip_name'] as String,
      destination: json['destination'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      createdBy: json['created_by'] as String,
      memberIds: List<String>.from(json['member_ids'] ?? []),
      coverImageUrl: json['cover_image_url'] as String?,
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
