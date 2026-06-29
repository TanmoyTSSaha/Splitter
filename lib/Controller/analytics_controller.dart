import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/shared.dart';
import 'package:splitter/Model/group_model.dart';
import 'package:splitter/Services/supabase_service.dart';

class AnalyticsController extends GetxController {
  final String groupID;
  final String userID;

  AnalyticsController({required this.groupID, required this.userID});

  RxBool isLoading = true.obs;
  RxString errorMessage = ''.obs;
  Rx<DurationLabel> selectedDuration = DurationLabel.weekly.obs;

  /// Category → total amount (for pie chart)
  RxMap<String, double> categoryBreakdown = <String, double>{}.obs;

  /// MemberName → {paid, share} (for contribution bar chart)
  RxMap<String, Map<String, double>> memberContributions =
      <String, Map<String, double>>{}.obs;

  /// Month label → total amount (for line chart)
  RxMap<String, double> monthlyTrends = <String, double>{}.obs;

  /// Category → {userAmount, groupAvgAmount} (for grouped bar)
  RxMap<String, Map<String, double>> categoryComparison =
      <String, Map<String, double>>{}.obs;

  /// Top categories sorted by total amount (for donut chart)
  RxList<MapEntry<String, double>> topCategories =
      <MapEntry<String, double>>[].obs;

  /// Member net balances: {name, user_id, netBalance}
  RxList<Map<String, dynamic>> memberBalances = <Map<String, dynamic>>[].obs;

  List<GroupTransactionModel> _rawTransactions = [];
  List<ConsolidatedGroupTransactionModel> _consolidatedTransactions = [];
  int _memberCount = 1;

  @override
  void onInit() {
    super.onInit();
    fetchAnalyticsData();
  }

  void setDuration(DurationLabel duration) {
    if (selectedDuration.value == duration) return;
    selectedDuration.value = duration;
    _reprocessAll();
  }

  Future<void> fetchAnalyticsData({bool showLoading = true}) async {
    try {
      if (showLoading) isLoading.value = true;
      errorMessage.value = '';

      _rawTransactions = await SupabaseDatabase()
          .getGroupTransactionsData(userID: userID, groupID: groupID);

      if (_rawTransactions.isEmpty) {
        _clearProcessedData();
        isLoading.value = false;
        return;
      }

      _consolidatedTransactions = SupabaseDatabase()
          .getConsolidatedGroupTransactionData(
              groupTransactionList: _rawTransactions);

      final members = await SupabaseDatabase().getGroupMembers(
        groupID: groupID,
        currentUserID: userID,
      );
      _memberCount = members.isNotEmpty ? members.length : 1;

      _reprocessAll();
      await _processMemberNetBalances(members);

      isLoading.value = false;
    } catch (e) {
      debugPrint("ANALYTICS EXCEPTION: $e");
      errorMessage.value = "Failed to load analytics data.";
      isLoading.value = false;
    }
  }

  void _clearProcessedData() {
    categoryBreakdown.clear();
    memberContributions.clear();
    monthlyTrends.clear();
    categoryComparison.clear();
    topCategories.clear();
    memberBalances.clear();
  }

  void _reprocessAll() {
    final consolidated = _filterConsolidatedByDuration(_consolidatedTransactions);
    final raw = _filterRawByDuration(_rawTransactions);

    _processCategoryBreakdown(consolidated);
    _processMemberContributions(raw);
    _processMonthlyTrends(consolidated);
    _processCategoryComparison(raw);
    _processTopCategories();
  }

  DateTime? _cutoffFor(DurationLabel duration) {
    final now = DateTime.now();
    switch (duration) {
      case DurationLabel.daily:
        return DateTime(now.year, now.month, now.day);
      case DurationLabel.weekly:
        return now.subtract(const Duration(days: 7));
      case DurationLabel.monthly:
        return now.subtract(const Duration(days: 30));
      case DurationLabel.yearly:
        return now.subtract(const Duration(days: 365));
    }
  }

  bool _isInRange(DateTime? date) {
    if (date == null) return false;
    final cutoff = _cutoffFor(selectedDuration.value);
    if (cutoff == null) return true;
    return !date.isBefore(cutoff);
  }

  List<ConsolidatedGroupTransactionModel> _filterConsolidatedByDuration(
      List<ConsolidatedGroupTransactionModel> transactions) {
    return transactions
        .where((tx) => _isInRange(tx.transactionDate))
        .toList();
  }

  List<GroupTransactionModel> _filterRawByDuration(
      List<GroupTransactionModel> transactions) {
    return transactions
        .where((tx) => _isInRange(tx.transactionDate))
        .toList();
  }

  void _processCategoryBreakdown(
      List<ConsolidatedGroupTransactionModel> transactions) {
    final breakdown = <String, double>{};

    for (final tx in transactions) {
      if (tx.sharingType == 'settlement') continue;
      if (tx.category != null && tx.totalTransactionAmount != null) {
        breakdown[tx.category!] =
            (breakdown[tx.category!] ?? 0.0) + tx.totalTransactionAmount!;
      }
    }

    categoryBreakdown.value = breakdown;
  }

  void _processMemberContributions(List<GroupTransactionModel> rawTransactions) {
    final paidByMember = <String, double>{};
    final shareByMember = <String, double>{};
    final memberNames = <String, String>{};
    final seenPaidGroups = <String>{};

    for (final tx in rawTransactions) {
      if (tx.sharingType == 'settlement') continue;

      final payerId = tx.paidByUUID;
      if (payerId != null &&
          tx.transactionGroupID != null &&
          tx.totalTransactionAmount != null) {
        memberNames[payerId] = tx.paidByName ?? 'Unknown';
        final paidKey = '${payerId}_${tx.transactionGroupID}';
        if (!seenPaidGroups.contains(paidKey)) {
          seenPaidGroups.add(paidKey);
          paidByMember[payerId] =
              (paidByMember[payerId] ?? 0.0) + tx.totalTransactionAmount!;
        }
      }

      final sharedWithId = tx.sharedWithUUID;
      if (sharedWithId != null && tx.sharedTransactionAmount != null) {
        memberNames[sharedWithId] = tx.sharedWithName ?? 'Unknown';
        shareByMember[sharedWithId] = (shareByMember[sharedWithId] ?? 0.0) +
            tx.sharedTransactionAmount!;
      }
    }

    final contributions = <String, Map<String, double>>{};
    for (final memberId in memberNames.keys) {
      final name = memberNames[memberId]!;
      contributions[name] = {
        'paid': paidByMember[memberId] ?? 0.0,
        'share': double.parse(
            (shareByMember[memberId] ?? 0.0).toStringAsFixed(2)),
      };
    }

    memberContributions.value = contributions;
  }

  void _processMonthlyTrends(
      List<ConsolidatedGroupTransactionModel> transactions) {
    final trends = <String, double>{};
    const monthLabels = [
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
      'Dec',
    ];

    for (final tx in transactions) {
      if (tx.sharingType == 'settlement') continue;
      if (tx.transactionDate != null && tx.totalTransactionAmount != null) {
        final monthKey =
            '${monthLabels[tx.transactionDate!.month - 1]} ${tx.transactionDate!.year}';
        trends[monthKey] =
            (trends[monthKey] ?? 0.0) + tx.totalTransactionAmount!;
      }
    }

    final sortedEntries = trends.entries.toList()
      ..sort((a, b) {
        final monthA = monthLabels.indexOf(a.key.split(' ')[0]);
        final yearA = int.tryParse(a.key.split(' ').last) ?? 0;
        final monthB = monthLabels.indexOf(b.key.split(' ')[0]);
        final yearB = int.tryParse(b.key.split(' ').last) ?? 0;
        final cmp = yearA.compareTo(yearB);
        if (cmp != 0) return cmp;
        return monthA.compareTo(monthB);
      });

    monthlyTrends.value = Map.fromEntries(sortedEntries);
  }

  void _processCategoryComparison(List<GroupTransactionModel> rawTransactions) {
    final userPaidByCategory = <String, double>{};
    final groupPaidByCategory = <String, double>{};
    final seenGroupPaid = <String>{};
    final seenUserPaid = <String>{};

    for (final tx in rawTransactions) {
      if (tx.sharingType == 'settlement') continue;
      if (tx.category == null ||
          tx.transactionGroupID == null ||
          tx.totalTransactionAmount == null) {
        continue;
      }

      final category = tx.category!;
      final groupKey = '${tx.transactionGroupID}_$category';

      if (!seenGroupPaid.contains(groupKey)) {
        seenGroupPaid.add(groupKey);
        groupPaidByCategory[category] =
            (groupPaidByCategory[category] ?? 0.0) + tx.totalTransactionAmount!;
      }

      if (tx.paidByUUID == userID && !seenUserPaid.contains(groupKey)) {
        seenUserPaid.add(groupKey);
        userPaidByCategory[category] =
            (userPaidByCategory[category] ?? 0.0) + tx.totalTransactionAmount!;
      }
    }

    final comparison = <String, Map<String, double>>{};
    for (final category in groupPaidByCategory.keys) {
      comparison[category] = {
        'userAmount': userPaidByCategory[category] ?? 0.0,
        'groupAvgAmount': double.parse(
          ((groupPaidByCategory[category] ?? 0.0) / _memberCount)
              .toStringAsFixed(2),
        ),
      };
    }

    categoryComparison.value = comparison;
  }

  void _processTopCategories() {
    final sorted = categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    topCategories.value = sorted.take(5).toList();
  }

  Future<void> _processMemberNetBalances(
      List<GroupMembersWithNameModel> members) async {
    final groupBalances = await SupabaseDatabase()
        .getGroupBalancesForSettleUp(groupID: groupID);

    final netByUserId = _computeNetBalances(groupBalances);

    final balances = <Map<String, dynamic>>[];
    for (final member in members) {
      final id = member.userID;
      if (id == null) continue;
      balances.add({
        'name': member.userName ?? 'Unknown',
        'user_id': id,
        'netBalance': double.parse(
            (netByUserId[id] ?? 0.0).toStringAsFixed(2)),
      });
    }

    memberBalances.value = balances;
  }

  Map<String, double> _computeNetBalances(List<GroupBalanceModel> balances) {
    final netBalance = <String, double>{};

    for (final balance in balances) {
      final donorId = balance.donorID;
      final receiverId = balance.receiverID;
      final amount = balance.amount ?? 0.0;

      if (donorId == null || receiverId == null) continue;

      netBalance[donorId] = (netBalance[donorId] ?? 0.0) + amount;
      netBalance[receiverId] = (netBalance[receiverId] ?? 0.0) - amount;
    }

    return netBalance;
  }
}
