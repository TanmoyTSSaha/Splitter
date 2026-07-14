import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Model/financial_goal_model.dart';
import 'package:splitr/Model/goal_transaction_model.dart';
import 'package:splitr/Services/SupabaseServices/goal_service.dart';
import 'package:splitr/Services/SupabaseServices/goal_transaction_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

class GoalDetailsController extends GetxController {
  final GoalService _goalService = GoalService();
  final GoalTransactionService _transactionService = GoalTransactionService();

  late FinancialGoalModel goal;
  RxList<GoalTransactionModel> transactions = <GoalTransactionModel>[].obs;
  RxBool isLoading = true.obs;
  bool dataChanged = false;

  @override
  void onInit() {
    super.onInit();
    goal = Get.arguments as FinancialGoalModel;
    dataChanged = false;
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      isLoading.value = true;
      transactions.assignAll(
          await _transactionService.getTransactionsForGoal(goal.id!));

      // Update local goal amount just in case
      double current = 0;
      for (var t in transactions) {
        if (t.type == GoalTransactionTypes.deposit) current += t.amount ?? 0;
        if (t.type == GoalTransactionTypes.withdraw) current -= t.amount ?? 0;
      }
      goal.currentAmount = current;
      update(); // trigger UI update if using GetBuilder for goal object
    } catch (e, stack) {
      AppErrorReporter.report(
        'GoalDetailsController.fetchTransactions failed',
        error: e,
        stack: stack,
        context: {'feature': 'goals', 'operation': 'fetchTransactions'},
        showToastOnUserFacing: false,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTransaction(double amount, String type, String note) async {
    try {
      GoalTransactionModel trx = GoalTransactionModel(
        goalId: goal.id,
        amount: amount,
        type: type,
        note: note,
        currency: Get.find<CurrencyController>().code,
        transactionDate: DateTime.now(),
      );

      await _transactionService.addTransaction(trx);

      // Update Goal Current Amount directly in DB
      double newAmount = (goal.currentAmount ?? 0) +
          (type == GoalTransactionTypes.deposit ? amount : -amount);
      await _goalService.updateGoalAmount(goal.id!, newAmount);

      dataChanged = true;
      await fetchTransactions();
      Get.back(); // close dialog
      SplitrToast.show(SplitrToast.join(AppStrings.goals.goalSuccess, AppStrings.goals.transactionAdded));
    } catch (e, stack) {
      AppErrorReporter.report(
        'GoalDetailsController.addTransaction failed',
        error: e,
        stack: stack,
        context: {'feature': 'goals', 'operation': 'addTransaction'},
        showToastOnUserFacing: false,
      );
      SplitrToast.show(SplitrToast.join(AppStrings.errors.errorTitle, AppStrings.goals.failedAddTransaction));
    }
  }

  Future<void> deleteGoal() async {
    try {
      await _goalService.deleteGoal(goal.id!);
      dataChanged = true;
      Get.back(result: true);
      SplitrToast.show(SplitrToast.join(AppStrings.goals.goalDeleted, AppStrings.goals.goalDeletedSuccess));
    } catch (e, stack) {
      AppErrorReporter.report(
        'GoalDetailsController.deleteGoal failed',
        error: e,
        stack: stack,
        context: {'feature': 'goals', 'operation': 'deleteGoal'},
        showToastOnUserFacing: false,
      );
      SplitrToast.show(SplitrToast.join(AppStrings.errors.errorTitle, AppStrings.goals.failedDeleteGoal));
    }
  }
}
