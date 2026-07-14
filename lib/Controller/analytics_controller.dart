import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/shared.dart';
import 'package:splitr/Model/group_model.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

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
    } catch (e, stack) {
      AppErrorReporter.report(
        'AnalyticsController.fetchAnalyticsData failed',
        error: e,
        stack: stack,
        context: {'feature': 'analytics', 'operation': 'fetchAnalyticsData'},
        showToastOnUserFacing: false,
      );
      errorMessage.value = AppStrings.errors.loadAnalytics;
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
    final consolidated =
        _filterConsolidatedByDuration(_consolidatedTransactions);
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
        return now.subtract(AppMotion.analyticsWeek);
      case DurationLabel.monthly:
        return now.subtract(AppMotion.analyticsMonth);
      case DurationLabel.yearly:
        return now.subtract(AppMotion.analyticsYear);
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
    return transactions.where((tx) => _isInRange(tx.transactionDate)).toList();
  }

  List<GroupTransactionModel> _filterRawByDuration(
      List<GroupTransactionModel> transactions) {
    return transactions.where((tx) => _isInRange(tx.transactionDate)).toList();
  }

  void _processCategoryBreakdown(
      List<ConsolidatedGroupTransactionModel> transactions) {
    final breakdown = <String, double>{};

    for (final tx in transactions) {
      if (tx.sharingType == SharingTypeValues.settlement) continue;
      if (tx.category != null && tx.totalTransactionAmount != null) {
        breakdown[tx.category!] =
            (breakdown[tx.category!] ?? 0.0) + tx.totalTransactionAmount!;
      }
    }

    categoryBreakdown.value = breakdown;
  }

  void _processMemberContributions(
      List<GroupTransactionModel> rawTransactions) {
    final paidByMember = <String, double>{};
    final shareByMember = <String, double>{};
    final memberNames = <String, String>{};
    final seenPaidGroups = <String>{};

    for (final tx in rawTransactions) {
      if (tx.sharingType == SharingTypeValues.settlement) continue;

      final payerId = tx.paidByUUID;
      if (payerId != null &&
          tx.transactionGroupID != null &&
          tx.totalTransactionAmount != null) {
        memberNames[payerId] = tx.paidByName ?? DisplayFallbacks.unknown;
        final paidKey = AppStringFormat.payerGroupDedupeKey(
          payerId,
          tx.transactionGroupID!,
        );
        if (!seenPaidGroups.contains(paidKey)) {
          seenPaidGroups.add(paidKey);
          paidByMember[payerId] =
              (paidByMember[payerId] ?? 0.0) + tx.totalTransactionAmount!;
        }
      }

      final sharedWithId = tx.sharedWithUUID;
      if (sharedWithId != null && tx.sharedTransactionAmount != null) {
        memberNames[sharedWithId] =
            tx.sharedWithName ?? DisplayFallbacks.unknown;
        shareByMember[sharedWithId] =
            (shareByMember[sharedWithId] ?? 0.0) + tx.sharedTransactionAmount!;
      }
    }

    final contributions = <String, Map<String, double>>{};
    for (final memberId in memberNames.keys) {
      final name = memberNames[memberId]!;
      contributions[name] = {
        AnalyticsKeys.paid: paidByMember[memberId] ?? 0.0,
        AnalyticsKeys.share: double.parse((shareByMember[memberId] ?? 0.0)
            .toStringAsFixed(DefaultDecimalPlaces.amount)),
      };
    }

    memberContributions.value = contributions;
  }

  void _processMonthlyTrends(
      List<ConsolidatedGroupTransactionModel> transactions) {
    final trends = <String, double>{};
    const monthLabels = MonthAbbreviations.labels;

    for (final tx in transactions) {
      if (tx.sharingType == SharingTypeValues.settlement) continue;
      if (tx.transactionDate != null && tx.totalTransactionAmount != null) {
        final monthKey = AppStringFormat.monthYearLabel(
          monthLabels[tx.transactionDate!.month - 1],
          tx.transactionDate!.year,
        );
        trends[monthKey] =
            (trends[monthKey] ?? 0.0) + tx.totalTransactionAmount!;
      }
    }

    final sortedEntries = trends.entries.toList()
      ..sort((a, b) {
        final monthA = monthLabels.indexOf(
          a.key.split(AppSeparators.monthYearJoiner).first,
        );
        final yearA =
            int.tryParse(a.key.split(AppSeparators.monthYearJoiner).last) ?? 0;
        final monthB = monthLabels.indexOf(
          b.key.split(AppSeparators.monthYearJoiner).first,
        );
        final yearB =
            int.tryParse(b.key.split(AppSeparators.monthYearJoiner).last) ?? 0;
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
      if (tx.sharingType == SharingTypeValues.settlement) continue;
      if (tx.category == null ||
          tx.transactionGroupID == null ||
          tx.totalTransactionAmount == null) {
        continue;
      }

      final category = tx.category!;
      final groupKey = AppStringFormat.groupCategoryDedupeKey(
        tx.transactionGroupID!,
        category,
      );

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
        AnalyticsKeys.userAmount: userPaidByCategory[category] ?? 0.0,
        AnalyticsKeys.groupAvgAmount: double.parse(
          ((groupPaidByCategory[category] ?? 0.0) / _memberCount)
              .toStringAsFixed(DefaultDecimalPlaces.amount),
        ),
      };
    }

    categoryComparison.value = comparison;
  }

  void _processTopCategories() {
    final sorted = categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    topCategories.value =
        sorted.take(InsightsThresholds.topCategoryLimit).toList();
  }

  Future<void> _processMemberNetBalances(
      List<GroupMembersWithNameModel> members) async {
    final groupBalances =
        await SupabaseDatabase().getGroupBalancesForSettleUp(groupID: groupID);

    final netByUserId = _computeNetBalances(groupBalances);

    final balances = <Map<String, dynamic>>[];
    for (final member in members) {
      final id = member.userID;
      if (id == null) continue;
      balances.add({
        AnalyticsKeys.name: member.userName ?? DisplayFallbacks.unknown,
        AnalyticsKeys.userId: id,
        AnalyticsKeys.netBalance: double.parse((netByUserId[id] ?? 0.0)
            .toStringAsFixed(DefaultDecimalPlaces.amount)),
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
