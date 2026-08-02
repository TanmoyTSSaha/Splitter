import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Model/personal_budget_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PersonalBudgetService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<PersonalBudget>> listBudgets(String userId) async {
    final rows = await _supabase
        .from(SupabaseTables.personalBudgets)
        .select()
        .eq('user_id', userId)
        .order('category', ascending: true);
    return (rows as List)
        .map((r) => PersonalBudget.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  Future<void> upsertBudget({
    required String userId,
    String? id,
    String? category,
    String period = BudgetDefaults.defaultPeriod,
    required double limitAmount,
    double alertThreshold = 0.9,
    bool includeGroupExpenses = true,
  }) async {
    final payload = {
      'user_id': userId,
      'category': (category == null || category.isEmpty) ? null : category,
      'period': period,
      'limit_amount': limitAmount,
      'alert_threshold': alertThreshold,
      'include_group_expenses': includeGroupExpenses,
    };
    try {
      if (id != null && id.isNotEmpty) {
        await _supabase
            .from(SupabaseTables.personalBudgets)
            .update(payload)
            .eq('id', id);
      } else {
        await _supabase.from(SupabaseTables.personalBudgets).insert(payload);
      }
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw BudgetDuplicateException();
      }
      rethrow;
    }
  }

  Future<void> deleteBudget(String id) async {
    await _supabase.from(SupabaseTables.personalBudgets).delete().eq('id', id);
  }
}

class BudgetDuplicateException implements Exception {}
