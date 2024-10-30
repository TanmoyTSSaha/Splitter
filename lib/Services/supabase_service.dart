import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Model/personal_transaction_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuth {
  final supabase = Supabase.instance.client;

  String supabaseGetUserID() {
    final currentUser = supabase.auth.currentUser;

    if (currentUser == null) {
      Fluttertoast.showToast(
        msg: "Something went wrong.",
        textColor: neopopBackground,
        backgroundColor: neopopYellow,
      );

      return "";
    }

    return currentUser.id;
  }

  Future<bool> supabaseEmailPassSignIn(
      {required String userEmail, required String userPassword}) async {
    try {
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: userEmail,
        password: userPassword,
      );

      final Session? session = response.session;
      final User? user = response.user;

      debugPrint("Session: $session |\t User: $user");

      if (user == null) {
        Fluttertoast.showToast(
          msg: "Invalid user details!",
          textColor: neopopBackground,
          backgroundColor: neopopYellow,
        );

        return false;
      }

      return true;
    } on AuthException catch (e) {
      debugPrint(e.toString());
      Fluttertoast.showToast(
        msg: e.message.toString(),
        textColor: neopopBackground,
        backgroundColor: neopopYellow,
      );
      return false;
    } catch (e) {
      debugPrint(e.toString());
      Fluttertoast.showToast(
        msg: e.toString(),
        textColor: neopopBackground,
        backgroundColor: neopopYellow,
      );
      return false;
    }
  }

  void supabaseSignOut() async {
    try {
      await supabase.auth.signOut().then(
        (value) {
          Fluttertoast.showToast(
            msg: "Logged out successfully.",
            textColor: neopopBackground,
            backgroundColor: neopopYellow,
          );
        },
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        textColor: neopopBackground,
        backgroundColor: neopopYellow,
      );
    }
  }

  bool supabaseRetrieveSession() {
    try {
      final Session? session = supabase.auth.currentSession;

      if (session == null) {
        return false;
      }

      if (session.isExpired) {
        Fluttertoast.showToast(
          msg: "Session expired! Please login again.",
          textColor: neopopBackground,
          backgroundColor: neopopYellow,
        );

        return false;
      }

      return true;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "$e. Please login again.",
        textColor: neopopBackground,
        backgroundColor: neopopYellow,
      );

      return false;
    }
  }
}

class SupabaseDatabase {
  final supabase = Supabase.instance.client;

  Future<List<PersonalTransaction>> getHomePhaseExpenseHistory(
      {required String userID}) async {
    final data = await supabase.from("personal_transactions").select();

    List<PersonalTransaction> personalTransactions = [];

    for (final singleData in data) {
      PersonalTransaction personalTransaction;

      personalTransaction = PersonalTransaction.fromJson(singleData);

      personalTransactions.add(personalTransaction);
    }

    debugPrint("Personal Transactions: $personalTransactions");

    return personalTransactions;
  }
}
