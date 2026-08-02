import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Persists FCM device tokens per user/device.
class DeviceTokenService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> upsertToken({
    required String userId,
    required String token,
    String platform = 'android',
  }) async {
    try {
      await _supabase.rpc('ensure_push_preferences', params: {
        'p_user_id': userId,
      });
      await _supabase.from(SupabaseTables.deviceTokens).upsert({
        SupabaseColumns.userId: userId,
        'token': token,
        'platform': platform,
        SupabaseColumns.updatedAt: DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,token');
    } catch (e, stack) {
      if (!AppErrorReporter.shouldSkipSentry(e)) {
        AppErrorReporter.report(
          'DeviceTokenService.upsertToken failed',
          error: e,
          stack: stack,
          context: {'feature': 'push', 'operation': 'upsertToken'},
          showToastOnUserFacing: false,
        );
      }
    }
  }

  Future<void> deleteToken({
    required String userId,
    required String token,
  }) async {
    try {
      await _supabase
          .from(SupabaseTables.deviceTokens)
          .delete()
          .eq(SupabaseColumns.userId, userId)
          .eq('token', token);
    } catch (e, stack) {
      AppErrorReporter.report(
        'DeviceTokenService.deleteToken failed',
        error: e,
        stack: stack,
        context: {'feature': 'push', 'operation': 'deleteToken'},
        showToastOnUserFacing: false,
      );
    }
  }

  Future<void> deleteAllForUser(String userId) async {
    try {
      await _supabase
          .from(SupabaseTables.deviceTokens)
          .delete()
          .eq(SupabaseColumns.userId, userId);
    } catch (e, stack) {
      AppErrorReporter.report(
        'DeviceTokenService.deleteAllForUser failed',
        error: e,
        stack: stack,
        context: {'feature': 'push', 'operation': 'deleteAllForUser'},
        showToastOnUserFacing: false,
      );
    }
  }
}
