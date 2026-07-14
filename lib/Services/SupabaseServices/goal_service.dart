import 'package:splitr/Constants/app_keys.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/Model/financial_goal_model.dart';

class GoalService {
  final supabase = Supabase.instance.client;

  Future<List<FinancialGoalModel>> getGoals({required String userID}) async {
    try {
      final data = await supabase
          .from(SupabaseTables.financialGoals)
          .select()
          .eq("user_id", userID)
          .order("deadline", ascending: true);

      List<FinancialGoalModel> goals = [];
      for (var element in data) {
        goals.add(FinancialGoalModel.fromJSON(element));
      }
      return goals;
    } catch (e, stack) {
      AppErrorReporter.report(
        'GoalService.getGoals failed',
        error: e,
        stack: stack,
        context: {'feature': 'goals', 'operation': 'getGoals'},
      );
      return [];
    }
  }

  Future<void> addGoal(FinancialGoalModel goal) async {
    try {
      await supabase.from(SupabaseTables.financialGoals).insert({
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
    } catch (e, stack) {
      AppErrorReporter.report(
        'GoalService.addGoal failed',
        error: e,
        stack: stack,
        context: {'feature': 'goals', 'operation': 'addGoal'},
      );
      rethrow;
    }
  }

  Future<void> updateGoalAmount(String goalId, double newAmount) async {
    try {
      await supabase
          .from(SupabaseTables.financialGoals)
          .update({"current_amount": newAmount}).eq("id", goalId);
    } catch (e, stack) {
      AppErrorReporter.report(
        'GoalService.updateGoalAmount failed',
        error: e,
        stack: stack,
        context: {'feature': 'goals', 'operation': 'updateGoalAmount'},
      );
      rethrow;
    }
  }

  Future<void> updateGoalDetails(FinancialGoalModel goal) async {
    try {
      await supabase.from(SupabaseTables.financialGoals).update({
        "title": goal.title,
        "target_amount": goal.targetAmount,
        "deadline": goal.deadline?.toIso8601String(),
        "color_hex": goal.colorHex,
        "icon_key": goal.iconKey,
      }).eq("id", goal.id as Object);
    } catch (e, stack) {
      AppErrorReporter.report(
        'GoalService.updateGoalDetails failed',
        error: e,
        stack: stack,
        context: {'feature': 'goals', 'operation': 'updateGoalDetails'},
      );
      rethrow;
    }
  }

  Future<void> deleteGoal(String goalId) async {
    try {
      await supabase
          .from(SupabaseTables.financialGoals)
          .delete()
          .eq("id", goalId);
    } catch (e, stack) {
      AppErrorReporter.report(
        'GoalService.deleteGoal failed',
        error: e,
        stack: stack,
        context: {'feature': 'goals', 'operation': 'deleteGoal'},
      );
      rethrow;
    }
  }
}
