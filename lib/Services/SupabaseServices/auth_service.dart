import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Services/local/database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  Future<void> _clearLocalUserCache() async {
    if (Get.isRegistered<AppDatabase>()) {
      await Get.find<AppDatabase>().clearAllUserData();
    }
  }

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

      await _clearLocalUserCache();

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
      await supabase.auth.signOut();
      await _clearLocalUserCache();
      Fluttertoast.showToast(
        msg: "Logged out successfully.",
        textColor: neopopBackground,
        backgroundColor: neopopYellow,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        textColor: neopopBackground,
        backgroundColor: neopopYellow,
      );
    }
  }

  Future<bool> supabaseSignUp({
    required String userEmail,
    required String userPassword,
    required String userName,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: userEmail,
        password: userPassword,
        data: {
          'user_name': userName,
          'first_name': firstName,
          'last_name': lastName,
        },
        emailRedirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );

      final User? user = response.user;

      if (user == null) {
        Fluttertoast.showToast(
          msg: "Sign up failed! Please try again.",
          textColor: neopopBackground,
          backgroundColor: neopopYellow,
        );
        return false;
      }

      // Explicitly check/create user profile in public.users to ensure data consistency
      // in case backend triggers are missing.
      if (response.session != null) {
        try {
          await supabase.from('users').upsert({
            'user_id': user.id,
            'user_name': userName,
            'firstname': firstName,
            'lastname': lastName,
            'user_email': userEmail,
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          debugPrint("Profile creation warning: $e");
          // Proceeding as Auth was successful.
          // If trigger worked, update might fail due to RLS if session is missing, which is fine.
        }
      } else {
        debugPrint(
            "Session is null (Email confirmation enabled?). Relying on DB Trigger for profile creation.");
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
        msg: "An unexpected error occurred.",
        textColor: neopopBackground,
        backgroundColor: neopopYellow,
      );
      return false;
    }
  }

  Future<bool> googleSignIn() async {
    try {
      // Using signInWithOAuth which handles the browser flow on mobile.
      final bool result = await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );

      return result;
    } catch (e) {
      debugPrint("Google Sign In Error: $e");
      Fluttertoast.showToast(
        msg: "Google Sign In failed.",
        textColor: neopopBackground,
        backgroundColor: neopopYellow,
      );
      return false;
    }
  }

  bool supabaseRetrieveSession() {
    try {
      final Session? session = supabase.auth.currentSession;

      if (session == null) {
        debugPrint("SESSION STATUS: $session");
        return false;
      }

      if (session.isExpired) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
