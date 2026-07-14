import 'package:flutter/material.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Model/financial_goal_model.dart';
import 'package:splitr/Services/SupabaseServices/goal_service.dart';
import 'package:splitr/Services/ai_service.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

import 'dart:async';

class CreateGoalController extends GetxController {
  final GoalService _goalService = GoalService();
  final AIService _aiService = AIService();
  final SupabaseAuth _supabaseAuth = SupabaseAuth();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController otherGoalTypeController = TextEditingController();

  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  RxString selectedIcon = GoalDefaults.defaultEmoji.obs;
  RxString selectedColor = GoalThemeColors.primary.obs;
  RxString aiFeasibilityMessage = "".obs;
  RxString aiReasoning = "".obs;
  RxString selectedGoalType = GoalTypeValues.travel.obs;
  RxBool isLoading = false.obs;
  RxBool isEstimating = false.obs;

  Timer? _debounce;
  final List<String> goalTypes = GoalTypeValues.all;

  @override
  void onInit() {
    super.onInit();
    // Auto-suggest icon based on title
    titleController.addListener(() {
      if (titleController.text.length >
          GoalInputThresholds.titleIconMinLength) {
        selectedIcon.value = _aiService.getIconForGoal(titleController.text);
      }
    });

    // Auto-estimate checking
    descriptionController.addListener(_onDescriptionChanged);

    // Check feasibility when amount or date changes
    amountController.addListener(_checkFeasibility);
    selectedDate.listen((_) => _checkFeasibility());
  }

  void _onDescriptionChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(AppMotion.goalEstimateDebounce, () {
      // Clear previous reasoning when description changes significantly
      if (descriptionController.text.isEmpty) {
        aiReasoning.value = "";
      }

      if (descriptionController.text.length >
              GoalInputThresholds.descriptionEstimateMinLength &&
          amountController.text.isEmpty) {
        _estimateAmount();
      }
    });
  }

  Future<void> _estimateAmount() async {
    isEstimating.value = true;
    String type = selectedGoalType.value == GoalTypeValues.other
        ? otherGoalTypeController.text
        : selectedGoalType.value;

    final result = await _aiService.getEstimatedAmount(
        titleController.text, descriptionController.text, type);

    if (result[AiResponseKeys.estimatedAmount] != null &&
        (result[AiResponseKeys.estimatedAmount] is int ||
            result[AiResponseKeys.estimatedAmount] is double) &&
        double.parse(result[AiResponseKeys.estimatedAmount].toString()) > 0) {
      if (amountController.text.isEmpty) {
        amountController.text =
            result[AiResponseKeys.estimatedAmount].toString();
        // Trigger feasibility check manually since setting text programmatically might not always trigger listeners depending on focus
        _checkFeasibility();

        // Store reasoning instead of showing snackbar
        aiReasoning.value = result[AiResponseKeys.reasoning] ??
            AppStrings.goals.estimatedAmountFallback;
      }
    }
    isEstimating.value = false;
  }

  void _checkFeasibility() async {
    if (amountController.text.isEmpty || selectedDate.value == null) {
      aiFeasibilityMessage.value = "";
      return;
    }

    double amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0) return;

    aiFeasibilityMessage.value =
        await _aiService.checkFeasibility(amount, selectedDate.value!);
  }

  Future<void> saveGoal() async {
    if (titleController.text.isEmpty ||
        amountController.text.isEmpty ||
        selectedDate.value == null) {
      SplitrToast.show(SplitrToast.join(AppStrings.errors.errorTitle, AppStrings.goals.fillAllFields));
      return;
    }

    if (selectedGoalType.value == GoalTypeValues.other &&
        otherGoalTypeController.text.isEmpty) {
      SplitrToast.show(SplitrToast.join(AppStrings.errors.errorTitle, AppStrings.goals.specifyGoalType));
      return;
    }

    try {
      isLoading.value = true;
      final String userId = _supabaseAuth.supabaseGetUserID();

      String finalType = selectedGoalType.value == GoalTypeValues.other
          ? otherGoalTypeController.text
          : selectedGoalType.value;

      FinancialGoalModel newGoal = FinancialGoalModel(
        userId: userId,
        title: titleController.text,
        description: descriptionController.text,
        goalType: finalType,
        targetAmount: double.parse(amountController.text),
        currentAmount: 0,
        deadline: selectedDate.value,
        icon: selectedIcon.value,
        colorHex: selectedColor.value,
        status: GoalStatusValues.active,
        createdAt: DateTime.now(),
      );

      await _goalService.addGoal(newGoal);
      Get.back(result: true); // Return true to refresh home
      SplitrToast.show(SplitrToast.join(AppStrings.goals.goalSuccess, AppStrings.goals.goalCreatedSuccess));
    } catch (e, stack) {
      AppErrorReporter.report(
        'CreateGoalController.saveGoal failed',
        error: e,
        stack: stack,
        context: {'feature': 'goals', 'operation': 'saveGoal'},
        showToastOnUserFacing: false,
      );
      SplitrToast.show(SplitrToast.join(AppStrings.errors.errorTitle, AppStrings.goals.failedCreateGoal));
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    otherGoalTypeController.dispose();
    _debounce?.cancel();
    super.onClose();
  }
}
