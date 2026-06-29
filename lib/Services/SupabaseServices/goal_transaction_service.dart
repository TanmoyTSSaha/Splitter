import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:splitter/Model/goal_transaction_model.dart';
import 'package:splitter/Services/currency_service.dart';

class GoalTransactionService {
  final supabase = Supabase.instance.client;

  Future<void> addTransaction(GoalTransactionModel transaction) async {
    try {
      final String currency = transaction.currency ?? 'INR';
      final double exchangeRate =
          await CurrencyService().getExchangeRateToInr(currency);
      await supabase.from("goal_transactions").insert({
        "goal_id": transaction.goalId,
        "amount": transaction.amount,
        "type": transaction.type,
        "note": transaction.note,
        "currency": currency,
        "exchange_rate_to_inr": exchangeRate,
        "transaction_date": transaction.transactionDate?.toIso8601String(),
      });
    } catch (e) {
      debugPrint("ADD GOAL TRANSACTION EXCEPTION: $e");
      rethrow;
    }
  }

  Future<List<GoalTransactionModel>> getTransactionsForGoal(
      String goalId) async {
    try {
      final data = await supabase
          .from("goal_transactions")
          .select()
          .eq("goal_id", goalId)
          .order("transaction_date", ascending: false);

      List<GoalTransactionModel> transactions = [];
      for (var element in data) {
        transactions.add(GoalTransactionModel.fromJSON(element));
      }
      return transactions;
    } catch (e) {
      debugPrint("GET GOAL TRANSACTIONS EXCEPTION: $e");
      return [];
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await supabase.from("goal_transactions").delete().eq("id", transactionId);
    } catch (e) {
      debugPrint("DELETE GOAL TRANSACTION EXCEPTION: $e");
      rethrow;
    }
  }
}
