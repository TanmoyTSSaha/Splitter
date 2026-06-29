import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Model/financial_goal_model.dart';
import 'package:splitter/Services/SupabaseServices/goal_service.dart';
import 'package:splitter/Services/ai_service.dart';
import 'package:splitter/Services/supabase_service.dart';

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
  RxString selectedIcon = "🎯".obs;
  RxString selectedColor = "0xFFFE885D".obs; // neopopPrimary
  RxString aiFeasibilityMessage = "".obs;
  RxString aiReasoning = "".obs;
  RxString selectedGoalType = "Travel".obs;
  RxBool isLoading = false.obs;
  RxBool isEstimating = false.obs;

  Timer? _debounce;
  final List<String> goalTypes = [
    "Travel",
    "Gadget",
    "Vehicle",
    "Home",
    "Education",
    "Emergency",
    "Investment",
    "Other"
  ];

  @override
  void onInit() {
    super.onInit();
    // Auto-suggest icon based on title
    titleController.addListener(() {
      if (titleController.text.length > 3) {
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
    _debounce = Timer(const Duration(seconds: 4), () {
      // Clear previous reasoning when description changes significantly
      if (descriptionController.text.isEmpty) {
        aiReasoning.value = "";
      }

      if (descriptionController.text.length > 5 &&
          amountController.text.isEmpty) {
        _estimateAmount();
      }
    });
  }

  Future<void> _estimateAmount() async {
    isEstimating.value = true;
    String type = selectedGoalType.value == "Other"
        ? otherGoalTypeController.text
        : selectedGoalType.value;

    final result = await _aiService.getEstimatedAmount(
        titleController.text, descriptionController.text, type);

    if (result["estimated_amount"] != null &&
        (result["estimated_amount"] is int ||
            result["estimated_amount"] is double) &&
        double.parse(result["estimated_amount"].toString()) > 0) {
      if (amountController.text.isEmpty) {
        amountController.text = result["estimated_amount"].toString();
        // Trigger feasibility check manually since setting text programmatically might not always trigger listeners depending on focus
        _checkFeasibility();

        // Store reasoning instead of showing snackbar
        aiReasoning.value =
            result["reasoning"] ?? "Estimated amount based on description";
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
      Get.snackbar("Error", "Please fill all fields",
          backgroundColor: neopopError, colorText: Colors.white);
      return;
    }

    if (selectedGoalType.value == "Other" &&
        otherGoalTypeController.text.isEmpty) {
      Get.snackbar("Error", "Please specify the goal type",
          backgroundColor: neopopError, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      final String userId = _supabaseAuth.supabaseGetUserID();

      String finalType = selectedGoalType.value == "Other"
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
        status: "active",
        createdAt: DateTime.now(),
      );

      await _goalService.addGoal(newGoal);
      Get.back(result: true); // Return true to refresh home
      Get.snackbar("Success", "Goal created successfully!",
          backgroundColor: neopopAccent, colorText: Colors.black);
    } catch (e) {
      debugPrint(e.toString());
      Get.snackbar("Error", "Failed to create goal",
          backgroundColor: neopopError, colorText: Colors.white);
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
