import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:splitter/Model/user_details_model.dart';

class UserService {
  final supabase = Supabase.instance.client;

  Future<UserDetails> getCurrentUserProfile({required String userID}) async {
    try {
      final data =
          await supabase.from("users").select().eq("user_id", userID).single();
      return UserDetails.fromJSON(data);
    } catch (e) {
      debugPrint("FETCH USER PROFILE EXCEPTION: $e");
      debugPrint("Stacktrace: ${StackTrace.current}");
      // If user is missing in public.users (e.g. old signup or trigger failure),
      // create a default profile on the fly.
      final user = supabase.auth.currentUser;
      final defaultName = user?.userMetadata?['user_name'] ?? "User";

      final newUser = {
        'user_id': userID,
        'user_name': defaultName,
        'user_email': user?.email ?? "",
        'firstname': defaultName,
        'lastname': "",
        'created_at': DateTime.now().toIso8601String(),
      };

      try {
        await supabase.from("users").upsert(newUser);
      } catch (upsertError) {
        debugPrint("AUTO-CREATE PROFILE FAILED: $upsertError");
      }

      return UserDetails.fromJSON(newUser);
    }
  }

  /// Batch lookup users by exact email addresses.
  Future<List<Map<String, dynamic>>> searchUsersByEmails({
    required List<String> emails,
  }) async {
    if (emails.isEmpty) return [];
    try {
      final response = await supabase
          .from('users')
          .select('user_id, user_name, user_email, profile_picture_url')
          .inFilter('user_email', emails)
          .limit(50);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('SEARCH USERS BY EMAILS EXCEPTION: $e');
      return [];
    }
  }

  /// Searches for users by email (partial match).
  Future<List<Map<String, dynamic>>> searchUsersByEmail({
    required String email,
  }) async {
    try {
      final response = await supabase
          .from('users')
          .select('user_id, user_name, user_email, profile_picture_url')
          .ilike('user_email', '%$email%')
          .limit(10);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('SEARCH USERS EXCEPTION: $e');
      return [];
    }
  }

  Future<UserDetails?> getUserByEmail(String email) async {
    try {
      final data = await supabase
          .from('users')
          .select()
          .eq('user_email', email)
          .maybeSingle();

      if (data == null) return null;
      return UserDetails.fromJSON(data);
    } catch (e) {
      debugPrint('GET USER BY EMAIL EXCEPTION: $e');
      return null;
    }
  }

  /// Updates editable profile fields in the `users` table.
  Future<void> updateUserProfile({
    required String userID,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      await supabase.from('users').update({
        'firstname': firstName,
        'lastname': lastName,
        'phone': phone,
      }).eq('user_id', userID);
    } catch (e) {
      debugPrint('UPDATE USER PROFILE EXCEPTION: $e');
      rethrow;
    }
  }
}
