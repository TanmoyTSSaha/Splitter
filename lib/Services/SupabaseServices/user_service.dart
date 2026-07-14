import 'package:splitr/Constants/app_keys.dart';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Model/master_upi_bank_model.dart';
import 'package:splitr/Model/user_details_model.dart';
import 'package:splitr/Model/user_upi_account_model.dart';
import 'package:splitr/Utils/upi_vpa_utils.dart';

class UserService {
  final supabase = Supabase.instance.client;

  Future<UserDetails> getCurrentUserProfile({required String userID}) async {
    try {
      final data = await supabase
          .from(SupabaseTables.users)
          .select()
          .eq("user_id", userID)
          .single();
      return UserDetails.fromJSON(data);
    } catch (e, stack) {
      AppErrorReporter.report(
        'UserService.getCurrentUserProfile failed',
        error: e,
        stack: stack,
        context: {'feature': 'users', 'operation': 'getCurrentUserProfile'},
      );
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
        await supabase.from(SupabaseTables.users).upsert(newUser);
      } catch (upsertError, upsertStack) {
        AppErrorReporter.report(
          'UserService auto-create profile failed',
          error: upsertError,
          stack: upsertStack,
          context: {'feature': 'users', 'operation': 'autoCreateProfile'},
        );
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
          .from(SupabaseTables.users)
          .select('user_id, user_name, user_email, profile_picture_url')
          .inFilter('user_email', emails)
          .limit(50);
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stack) {
      AppErrorReporter.report(
        'UserService.searchUsersByEmails failed',
        error: e,
        stack: stack,
        context: {'feature': 'users', 'operation': 'searchUsersByEmails'},
      );
      return [];
    }
  }

  /// Searches for users by email (partial match).
  Future<List<Map<String, dynamic>>> searchUsersByEmail({
    required String email,
  }) async {
    try {
      final response = await supabase
          .from(SupabaseTables.users)
          .select('user_id, user_name, user_email, profile_picture_url')
          .ilike('user_email', '%$email%')
          .limit(10);

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stack) {
      AppErrorReporter.report(
        'UserService.searchUsersByEmail failed',
        error: e,
        stack: stack,
        context: {'feature': 'users', 'operation': 'searchUsersByEmail'},
      );
      return [];
    }
  }

  Future<UserDetails?> getUserByEmail(String email) async {
    try {
      final data = await supabase
          .from(SupabaseTables.users)
          .select()
          .eq('user_email', email)
          .maybeSingle();

      if (data == null) return null;
      return UserDetails.fromJSON(data);
    } catch (e, stack) {
      AppErrorReporter.report(
        'UserService.getUserByEmail failed',
        error: e,
        stack: stack,
        context: {'feature': 'users', 'operation': 'getUserByEmail'},
      );
      return null;
    }
  }

  /// Updates editable profile fields in the `users` table.
  Future<void> updateUserProfile({
    required String userID,
    required String userName,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      await supabase.from(SupabaseTables.users).update({
        'user_name': userName,
        'firstname': firstName,
        'lastname': lastName,
        'phone': phone,
      }).eq('user_id', userID);
    } catch (e, stack) {
      AppErrorReporter.report(
        'UserService.updateUserProfile failed',
        error: e,
        stack: stack,
        context: {'feature': 'users', 'operation': 'updateUserProfile'},
      );
      rethrow;
    }
  }

  Future<String> uploadProfilePhoto({
    required String userID,
    required File imageFile,
  }) async {
    final authUserId = supabase.auth.currentUser?.id;
    if (authUserId == null) {
      throw const AuthException('Not signed in');
    }
    if (authUserId != userID) {
      throw ArgumentError('Profile photo upload user mismatch');
    }

    final ext = imageFile.path.split('.').last.toLowerCase();
    final safeExt =
        const {'jpg', 'jpeg', 'png', 'webp'}.contains(ext) ? ext : 'jpg';
    final path = '$authUserId/avatar.$safeExt';

    await supabase.storage.from(SupabaseStorageBuckets.avatars).upload(
          path,
          imageFile,
          fileOptions: const FileOptions(upsert: true),
        );

    final publicUrl = supabase.storage
        .from(SupabaseStorageBuckets.avatars)
        .getPublicUrl(path);
    await supabase.from(SupabaseTables.users).update({
      'profile_picture_url': publicUrl,
    }).eq('user_id', userID);
    return publicUrl;
  }

  // ─── Master UPI banks ───────────────────────────────────────────────────────

  Future<List<MasterUpiBank>> listMasterUpiBanks() async {
    try {
      final rows = await supabase
          .from(SupabaseTables.masterUpiBank)
          .select()
          .eq(SupabaseColumns.isActive, true)
          .order(SupabaseColumns.sortOrder, ascending: true)
          .order(SupabaseColumns.bankName, ascending: true);
      return (rows as List)
          .map((e) => MasterUpiBank.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e, stack) {
      AppErrorReporter.report(
        'UserService.listMasterUpiBanks failed',
        error: e,
        stack: stack,
        context: {'feature': 'users', 'operation': 'listMasterUpiBanks'},
      );
      rethrow;
    }
  }

  // ─── UPI accounts ───────────────────────────────────────────────────────────

  Future<List<UserUpiAccount>> listUpiAccounts(String userId) async {
    try {
      final rows = await supabase
          .from(SupabaseTables.userUpiAccounts)
          .select()
          .eq(SupabaseColumns.userId, userId)
          .order(SupabaseColumns.isPrimary, ascending: false)
          .order(SupabaseColumns.createdAt, ascending: true);
      return (rows as List)
          .map((e) => UserUpiAccount.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e, stack) {
      AppErrorReporter.report(
        'UserService.listUpiAccounts failed',
        error: e,
        stack: stack,
        context: {'feature': 'users', 'operation': 'listUpiAccounts'},
      );
      rethrow;
    }
  }

  Future<List<UserUpiAccount>> listUpiAccountsForUsers(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) return [];
    try {
      final rows = await supabase
          .from(SupabaseTables.userUpiAccounts)
          .select()
          .inFilter(SupabaseColumns.userId, userIds)
          .order(SupabaseColumns.isPrimary, ascending: false)
          .order(SupabaseColumns.createdAt, ascending: true);
      return (rows as List)
          .map((e) => UserUpiAccount.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e, stack) {
      AppErrorReporter.report(
        'UserService.listUpiAccountsForUsers failed',
        error: e,
        stack: stack,
        context: {'feature': 'users', 'operation': 'listUpiAccountsForUsers'},
      );
      rethrow;
    }
  }

  Future<UserUpiAccount> upsertUpiAccount({
    required String userId,
    required String vpa,
    required String bankAlias,
    String? existingId,
    bool? isPrimary,
  }) async {
    final normalizedVpa = UpiVpaUtils.validateAndNormalize(vpa);
    if (normalizedVpa == null) {
      throw ArgumentError('Invalid UPI VPA');
    }
    final alias = bankAlias.trim();
    if (alias.length < UpiAccountRules.minCustomBankAliasLength) {
      throw ArgumentError('Bank alias too short');
    }

    try {
      if (existingId == null) {
        final existing = await listUpiAccounts(userId);
        if (existing.length >= UpiAccountRules.maxPerUser) {
          throw StateError('Maximum UPI accounts reached');
        }
      }

      final conflict = await supabase
          .from(SupabaseTables.userUpiAccounts)
          .select(SupabaseColumns.id)
          .eq(SupabaseColumns.userId, userId)
          .eq(SupabaseColumns.vpa, normalizedVpa)
          .maybeSingle();

      if (conflict != null &&
          conflict[SupabaseColumns.id] as String != existingId) {
        throw StateError(UpiAccountErrors.duplicateVpa);
      }

      final makePrimary = isPrimary ??
          (existingId == null
              ? (await listUpiAccounts(userId)).isEmpty
              : false);

      if (makePrimary) {
        await supabase
            .from(SupabaseTables.userUpiAccounts)
            .update({SupabaseColumns.isPrimary: false})
            .eq(SupabaseColumns.userId, userId);
      }

      final payload = {
        SupabaseColumns.userId: userId,
        SupabaseColumns.vpa: normalizedVpa,
        SupabaseColumns.bankAlias: alias,
        SupabaseColumns.isPrimary: makePrimary,
      };

      Map<String, dynamic> row;
      if (existingId != null) {
        row = await supabase
            .from(SupabaseTables.userUpiAccounts)
            .update(payload)
            .eq(SupabaseColumns.id, existingId)
            .eq(SupabaseColumns.userId, userId)
            .select()
            .single();
      } else {
        row = await supabase
            .from(SupabaseTables.userUpiAccounts)
            .insert(payload)
            .select()
            .single();
      }

      return UserUpiAccount.fromJson(Map<String, dynamic>.from(row));
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw StateError(UpiAccountErrors.duplicateVpa);
      }
      AppErrorReporter.report(
        'UserService.upsertUpiAccount failed',
        error: e,
        stack: StackTrace.current,
        context: {'feature': 'users', 'operation': 'upsertUpiAccount'},
      );
      rethrow;
    } catch (e, stack) {
      AppErrorReporter.report(
        'UserService.upsertUpiAccount failed',
        error: e,
        stack: stack,
        context: {'feature': 'users', 'operation': 'upsertUpiAccount'},
      );
      rethrow;
    }
  }

  Future<void> deleteUpiAccount({
    required String userId,
    required String accountId,
  }) async {
    try {
      final account = await supabase
          .from(SupabaseTables.userUpiAccounts)
          .select()
          .eq(SupabaseColumns.id, accountId)
          .eq(SupabaseColumns.userId, userId)
          .maybeSingle();

      if (account == null) return;

      final wasPrimary = account[SupabaseColumns.isPrimary] as bool? ?? false;

      await supabase
          .from(SupabaseTables.userUpiAccounts)
          .delete()
          .eq(SupabaseColumns.id, accountId)
          .eq(SupabaseColumns.userId, userId);

      if (wasPrimary) {
        final remaining = await listUpiAccounts(userId);
        if (remaining.isNotEmpty) {
          await setPrimaryUpiAccount(
            userId: userId,
            accountId: remaining.first.id,
          );
        }
      }
    } catch (e, stack) {
      AppErrorReporter.report(
        'UserService.deleteUpiAccount failed',
        error: e,
        stack: stack,
        context: {'feature': 'users', 'operation': 'deleteUpiAccount'},
      );
      rethrow;
    }
  }

  Future<void> setPrimaryUpiAccount({
    required String userId,
    required String accountId,
  }) async {
    try {
      await supabase
          .from(SupabaseTables.userUpiAccounts)
          .update({SupabaseColumns.isPrimary: false})
          .eq(SupabaseColumns.userId, userId);

      await supabase
          .from(SupabaseTables.userUpiAccounts)
          .update({SupabaseColumns.isPrimary: true})
          .eq(SupabaseColumns.id, accountId)
          .eq(SupabaseColumns.userId, userId);
    } catch (e, stack) {
      AppErrorReporter.report(
        'UserService.setPrimaryUpiAccount failed',
        error: e,
        stack: stack,
        context: {'feature': 'users', 'operation': 'setPrimaryUpiAccount'},
      );
      rethrow;
    }
  }
}
