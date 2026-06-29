import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Controllers/currency_controller.dart';
import 'package:splitter/Model/financial_goal_model.dart';
import 'package:splitter/Model/goal_transaction_model.dart';
import 'package:splitter/Services/SupabaseServices/goal_service.dart';
import 'package:splitter/Services/SupabaseServices/goal_transaction_service.dart';
import 'package:splitter/Constants/constants.dart';

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
        if (t.type == 'deposit') current += t.amount ?? 0;
        if (t.type == 'withdraw') current -= t.amount ?? 0;
      }
      goal.currentAmount = current;
      update(); // trigger UI update if using GetBuilder for goal object
    } catch (e) {
      debugPrint("Error fetching transactions: $e");
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
      double newAmount =
          (goal.currentAmount ?? 0) + (type == 'deposit' ? amount : -amount);
      await _goalService.updateGoalAmount(goal.id!, newAmount);

      dataChanged = true;
      await fetchTransactions();
      Get.back(); // close dialog
      Get.snackbar("Success", "Transaction added",
          backgroundColor: neopopAccent, colorText: Colors.black);
    } catch (e) {
      Get.snackbar("Error", "Failed to add transaction",
          backgroundColor: neopopError, colorText: Colors.white);
    }
  }

  Future<void> deleteGoal() async {
    try {
      await _goalService.deleteGoal(goal.id!);
      dataChanged = true;
      Get.back(result: true);
      Get.snackbar("Deleted", "Goal deleted successfully",
          backgroundColor: neopopGrey, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Failed to delete goal",
          backgroundColor: neopopError, colorText: Colors.white);
    }
  }
}
