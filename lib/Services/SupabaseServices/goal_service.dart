import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:splitter/Model/financial_goal_model.dart';

class GoalService {
  final supabase = Supabase.instance.client;

  Future<List<FinancialGoalModel>> getGoals({required String userID}) async {
    try {
      final data = await supabase
          .from("financial_goals")
          .select()
          .eq("user_id", userID)
          .order("deadline", ascending: true);

      List<FinancialGoalModel> goals = [];
      for (var element in data) {
        goals.add(FinancialGoalModel.fromJSON(element));
      }
      return goals;
    } catch (e) {
      debugPrint("GET GOALS EXCEPTION: $e");
      return [];
    }
  }

  Future<void> addGoal(FinancialGoalModel goal) async {
    try {
      await supabase.from("financial_goals").insert({
        "user_id": goal.userId,
        "title": goal.title,
        "target_amount": goal.targetAmount,
        "current_amount": goal.currentAmount,
        "deadline": goal.deadline?.toIso8601String(),
        "status": goal.status ?? "active",
        "icon": goal.icon,
        "color_hex": goal.colorHex,
        "icon_key": goal.iconKey,
        "smart_recommendation_id": goal.smartRecommendationId,
        "estimated_completion_date":
            goal.estimatedCompletionDate?.toIso8601String(),
        "description": goal.description,
        "goal_type": goal.goalType,
      });
    } catch (e) {
      debugPrint("ADD GOAL EXCEPTION: $e");
      rethrow;
    }
  }

  Future<void> updateGoalAmount(String goalId, double newAmount) async {
    try {
      await supabase
          .from("financial_goals")
          .update({"current_amount": newAmount}).eq("id", goalId);
    } catch (e) {
      debugPrint("UPDATE GOAL AMOUNT EXCEPTION: $e");
      rethrow;
    }
  }

  Future<void> updateGoalDetails(FinancialGoalModel goal) async {
    try {
      await supabase.from("financial_goals").update({
        "title": goal.title,
        "target_amount": goal.targetAmount,
        "deadline": goal.deadline?.toIso8601String(),
        "color_hex": goal.colorHex,
        "icon_key": goal.iconKey,
      }).eq("id", goal.id as Object);
    } catch (e) {
      debugPrint("UPDATE GOAL DETAILS EXCEPTION: $e");
      rethrow;
    }
  }

  Future<void> deleteGoal(String goalId) async {
    try {
      await supabase.from("financial_goals").delete().eq("id", goalId);
    } catch (e) {
      debugPrint("DELETE GOAL EXCEPTION: $e");
      rethrow;
    }
  }
}
