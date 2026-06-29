import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Controllers/currency_controller.dart';
import 'package:splitter/Services/gamification_service.dart';
import 'package:splitter/Widgets/badge_unlock_toast.dart';
import 'package:splitter/Model/group_model.dart';
import 'package:splitter/Services/biometric_auth_service.dart';
import 'package:splitter/Services/reminder_trigger_helper.dart';
import 'package:splitter/Services/SupabaseServices/notification_service.dart';
import 'package:splitter/Services/supabase_service.dart';

/// Represents a simplified debt after the minimization algorithm.
class SimplifiedDebt {
  final String fromID;
  final String fromName;
  final String toID;
  final String toName;
  final double amount;

  SimplifiedDebt({
    required this.fromID,
    required this.fromName,
    required this.toID,
    required this.toName,
    required this.amount,
  });
}

class SettleUpController extends GetxController {
  final String groupID;
  final String userID;
  final String groupName;

  SettleUpController({
    required this.groupID,
    required this.userID,
    required this.groupName,
  });

  RxBool isLoading = true.obs;
  RxBool isSettling = false.obs;
  RxBool hasBalanceData = false.obs;
  RxList<SimplifiedDebt> simplifiedDebts = <SimplifiedDebt>[].obs;
  RxString errorMessage = ''.obs;

  RxList<GroupMembersWithNameModel> groupMembers =
      <GroupMembersWithNameModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAndSimplifyDebts();
  }

  /// Fetches group balance data and runs the debt simplification algorithm.
  Future<void> fetchAndSimplifyDebts({bool showLoading = true}) async {
    try {
      if (showLoading) isLoading.value = true;
      errorMessage.value = '';

      final groupBalances = await SupabaseDatabase()
          .getGroupBalancesForSettleUp(groupID: groupID);

      // Fetch group members to get real names
      final members = await SupabaseDatabase().getGroupMembers(
        groupID: groupID,
        currentUserID: userID,
      );
      groupMembers.value = members;

      if (groupBalances.isEmpty) {
        hasBalanceData.value = false;
        simplifiedDebts.clear();
        isLoading.value = false;
        return;
      }

      hasBalanceData.value = true;

      final Map<String, String> realNameMap = {
        for (var m in members) m.userID!: m.userName!
      };

      // Run debt simplification
      final debts = _simplifyDebts(groupBalances, realNameMap);
      simplifiedDebts.value = debts;
      isLoading.value = false;
    } catch (e) {
      debugPrint("SETTLE UP EXCEPTION: $e");
      errorMessage.value = "Failed to load balances. Pull to retry.";
      isLoading.value = false;
    }
  }

  /// Greedy debt simplification algorithm.
  ///
  /// Computes net balances for all members, then repeatedly matches the
  /// largest creditor with the largest debtor to minimize the total number
  /// of transfers.
  List<SimplifiedDebt> _simplifyDebts(
      List<GroupBalanceModel> balances, Map<String, String> realNameMap) {
    // Step 1: Compute net balance per person.
    // Positive = is owed money (creditor), Negative = owes money (debtor).
    Map<String, double> netBalance = {};

    for (var balance in balances) {
      final donorID = balance.donorID!;
      final receiverID = balance.receiverID!;
      final amount = balance.amount!;

      // Donor is the CREDITOR (paid), so their balance INCREASES
      netBalance[donorID] = (netBalance[donorID] ?? 0.0) + amount;
      // Receiver is the DEBTOR (consumed), so their balance DECREASES
      netBalance[receiverID] = (netBalance[receiverID] ?? 0.0) - amount;
    }

    // Step 2: Split into creditors and debtors
    List<MapEntry<String, double>> creditors = [];
    List<MapEntry<String, double>> debtors = [];

    netBalance.forEach((id, amount) {
      // Round to 2 decimal places to avoid floating point noise
      double rounded = double.parse(amount.toStringAsFixed(2));
      if (rounded > 0.01) {
        creditors.add(MapEntry(id, rounded));
      } else if (rounded < -0.01) {
        debtors.add(MapEntry(id, rounded.abs()));
      }
    });

    // Sort descending by amount
    creditors.sort((a, b) => b.value.compareTo(a.value));
    debtors.sort((a, b) => b.value.compareTo(a.value));

    // Step 3: Greedy matching
    List<SimplifiedDebt> result = [];
    int i = 0, j = 0;

    while (i < creditors.length && j < debtors.length) {
      double settleAmount;
      if (creditors[i].value <= debtors[j].value) {
        settleAmount = creditors[i].value;
      } else {
        settleAmount = debtors[j].value;
      }

      result.add(SimplifiedDebt(
        fromID: debtors[j].key,
        fromName: realNameMap[debtors[j].key] ?? 'Unknown',
        toID: creditors[i].key,
        toName: realNameMap[creditors[i].key] ?? 'Unknown',
        amount: double.parse(settleAmount.toStringAsFixed(2)),
      ));

      creditors[i] = MapEntry(
        creditors[i].key,
        double.parse((creditors[i].value - settleAmount).toStringAsFixed(2)),
      );
      debtors[j] = MapEntry(
        debtors[j].key,
        double.parse((debtors[j].value - settleAmount).toStringAsFixed(2)),
      );

      if (creditors[i].value < 0.01) i++;
      if (debtors[j].value < 0.01) j++;
    }

    return result;
  }

  /// Records a settlement in the database and refreshes the debt list.
  Future<bool> recordSettlement(SimplifiedDebt debt,
      {bool requireBiometric = false}) async {
    try {
      if (requireBiometric) {
        final biometric = BiometricAuthService();
        if (await biometric.isEnabled()) {
          final ok = await biometric.authenticate(
            reason: 'Confirm settlement of ₹${debt.amount.toStringAsFixed(2)}',
          );
          if (!ok.isSuccess) return false;
        }
      }

      isSettling.value = true;

      final gamification = GamificationService();
      final badgesBefore = await gamification.getBadges();

      final currency = Get.find<CurrencyController>().code;
      await SupabaseDatabase().recordSettlement(
        groupID: groupID,
        fromUserID: debt.fromID,
        toUserID: debt.toID,
        amount: debt.amount,
        currency: currency,
      );

      await NotificationService().createNotification(
        userId: debt.toID,
        type: 'settlement',
        title: 'Payment received',
        body:
            '${debt.fromName} recorded a settlement of ₹${debt.amount.toStringAsFixed(2)}',
        metadata: {
          'group_id': groupID,
          'from_user_id': debt.fromID,
          'amount': debt.amount,
          'currency': currency,
        },
      );

      await ReminderTriggerHelper.onSettlementRecorded(
        groupId: groupID,
        groupName: groupName,
        fromUserId: debt.fromID,
        fromName: debt.fromName,
        amount: debt.amount,
      );

      await fetchAndSimplifyDebts();

      final newlyUnlocked =
          await gamification.checkNewlyUnlocked(badgesBefore);
      for (final badge in newlyUnlocked) {
        showBadgeUnlockToast(badge);
      }

      isSettling.value = false;
      return true;
    } catch (e) {
      debugPrint("SETTLEMENT EXCEPTION: $e");
      isSettling.value = false;
      return false;
    }
  }
}
