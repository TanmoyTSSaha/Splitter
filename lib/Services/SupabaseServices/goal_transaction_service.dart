import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/Model/goal_transaction_model.dart';
import 'package:splitr/Services/currency_service.dart';

class GoalTransactionService {
  final supabase = Supabase.instance.client;

  Future<void> addTransaction(GoalTransactionModel transaction) async {
    try {
      final String currency = transaction.currency ?? CurrencyDefaults.code;
      final double exchangeRate =
          await CurrencyService().getExchangeRateToInr(currency);
      await supabase.from(SupabaseTables.goalTransactions).insert({
        "goal_id": transaction.goalId,
        "amount": transaction.amount,
        "type": transaction.type,
        "note": transaction.note,
        "currency": currency,
        "exchange_rate_to_inr": exchangeRate,
        "transaction_date": transaction.transactionDate?.toIso8601String(),
      });
    } catch (e, stack) {
      AppErrorReporter.report(
        'GoalTransactionService.addTransaction failed',
        error: e,
        stack: stack,
        context: {'feature': 'goals', 'operation': 'addTransaction'},
      );
      rethrow;
    }
  }

  Future<List<GoalTransactionModel>> getTransactionsForGoal(
      String goalId) async {
    try {
      final data = await supabase
          .from(SupabaseTables.goalTransactions)
          .select()
          .eq("goal_id", goalId)
          .order("transaction_date", ascending: false);

      List<GoalTransactionModel> transactions = [];
      for (var element in data) {
        transactions.add(GoalTransactionModel.fromJSON(element));
      }
      return transactions;
    } catch (e, stack) {
      AppErrorReporter.report(
        'GoalTransactionService.getTransactionsForGoal failed',
        error: e,
        stack: stack,
        context: {'feature': 'goals', 'operation': 'getTransactionsForGoal'},
      );
      return [];
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await supabase
          .from(SupabaseTables.goalTransactions)
          .delete()
          .eq("id", transactionId);
    } catch (e, stack) {
      AppErrorReporter.report(
        'GoalTransactionService.deleteTransaction failed',
        error: e,
        stack: stack,
        context: {'feature': 'goals', 'operation': 'deleteTransaction'},
      );
      rethrow;
    }
  }
}
