import 'package:get/get.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/Utils/currency_utils.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Repository/transaction_repository.dart';
import 'package:splitr/Model/group_model.dart';
import 'package:splitr/Services/biometric_auth_service.dart';
import 'package:splitr/Services/reminder_trigger_helper.dart';
import 'package:splitr/Services/SupabaseServices/notification_service.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Utils/debt_simplifier.dart';

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
        for (var m in members)
          if (m.userID != null && m.userName != null)
            m.userID!: DisplayFormatters.stripMemberYouSuffix(m.userName!),
      };

      // Run debt simplification
      final transfers = simplifyGroupDebts(groupBalances);
      simplifiedDebts.value = transfers
          .map(
            (t) => SimplifiedDebt(
              fromID: t.fromId,
              fromName: realNameMap[t.fromId] ?? DisplayFallbacks.unknown,
              toID: t.toId,
              toName: realNameMap[t.toId] ?? DisplayFallbacks.unknown,
              amount: t.amount,
            ),
          )
          .toList();
      isLoading.value = false;
    } catch (e, stack) {
      AppErrorReporter.report(
        'SettleUpController.fetchAndSimplifyDebts failed',
        error: e,
        stack: stack,
        context: {'feature': 'settle_up', 'operation': 'fetchAndSimplifyDebts'},
        showToastOnUserFacing: false,
      );
      errorMessage.value = AppStrings.errors.loadBalancesPullToRetry;
      isLoading.value = false;
    }
  }

  /// Records a settlement in the database and refreshes the debt list.
  Future<bool> recordSettlement(SimplifiedDebt debt,
      {bool requireBiometric = false}) async {
    try {
      if (requireBiometric) {
        final biometric = BiometricAuthService();
        if (await biometric.isEnabled()) {
          final ok = await biometric.authenticate(
            reason: AppStringFormat.confirmSettlement(
              userCurrencySymbol(),
              debt.amount.toStringAsFixed(2),
            ),
          );
          if (!ok.isSuccess) return false;
        }
      }

      isSettling.value = true;

      final currency = Get.find<CurrencyController>().code;
      await Get.find<TransactionRepository>().recordSettlement(
        groupID: groupID,
        fromUserID: debt.fromID,
        toUserID: debt.toID,
        amount: debt.amount,
        currency: currency,
      );

      try {
        await NotificationService().createNotification(
          userId: debt.toID,
          type: NotificationTypes.settlement,
          title: AppStrings.settle.paymentReceived,
          body: AppStringFormat.settlementRecorded(
            debt.fromName,
            userCurrencySymbol(),
            debt.amount.toStringAsFixed(2),
          ),
          metadata: {
            SupabaseColumns.groupId: groupID,
            MetadataKeys.fromUserId: debt.fromID,
            SupabaseColumns.amount: debt.amount,
            SupabaseColumns.currency: currency,
          },
        );
      } catch (e, stack) {
        AppErrorReporter.report(
          'SettleUpController.recordSettlement notification failed',
          error: e,
          stack: stack,
          context: {'feature': 'settle_up', 'operation': 'recordSettlement.notification'},
        );
      }

      try {
        await ReminderTriggerHelper.onSettlementRecorded(
          groupId: groupID,
          groupName: groupName,
          fromUserId: debt.fromID,
          fromName: debt.fromName,
          amount: debt.amount,
        );
      } catch (e, stack) {
        AppErrorReporter.report(
          'SettleUpController.recordSettlement reminder failed',
          error: e,
          stack: stack,
          context: {'feature': 'settle_up', 'operation': 'recordSettlement.reminder'},
        );
      }

      try {
        await fetchAndSimplifyDebts(showLoading: false);
      } catch (e, stack) {
        AppErrorReporter.report(
          'SettleUpController.recordSettlement refresh failed',
          error: e,
          stack: stack,
          context: {'feature': 'settle_up', 'operation': 'recordSettlement.refresh'},
        );
      }

      isSettling.value = false;
      return true;
    } catch (e, stack) {
      AppErrorReporter.report(
        'SettleUpController.recordSettlement failed',
        error: e,
        stack: stack,
        context: {'feature': 'settle_up', 'operation': 'recordSettlement'},
      );
      isSettling.value = false;
      return false;
    }
  }
}
