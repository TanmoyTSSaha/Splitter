import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Model/reminder_settings_model.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Persists per-group reminder preferences (Supabase with local fallback).
class ReminderSettingsService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<bool> isSilentMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PrefKeys.remindersSilentMode) ?? false;
  }

  Future<void> setSilentMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefKeys.remindersSilentMode, value);
  }

  Future<ReminderSettings> getSettings(String groupId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return ReminderSettings(groupId: groupId);
    }

    try {
      final row = await _supabase
          .from(SupabaseTables.reminderSettings)
          .select()
          .eq(SupabaseColumns.userId, userId)
          .eq(SupabaseColumns.groupId, groupId)
          .maybeSingle();

      if (row != null) {
        return ReminderSettings.fromJSON(row);
      }
    } catch (e, stack) {
      AppErrorReporter.report(
        'ReminderSettingsService.getSettings remote failed',
        error: e,
        stack: stack,
        context: {'feature': 'reminders', 'operation': 'getSettings'},
      );
    }

    return await _loadLocal(groupId) ?? ReminderSettings(groupId: groupId);
  }

  Future<void> saveSettings(ReminderSettings settings) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _saveLocal(settings);

    try {
      await _supabase.from(SupabaseTables.reminderSettings).upsert({
        SupabaseColumns.userId: userId,
        SupabaseColumns.groupId: settings.groupId,
        SupabaseColumns.cadence: settings.cadence.name,
        SupabaseColumns.tone: settings.tone.name,
        SupabaseColumns.mutedMemberIds: settings.mutedMemberIds,
        SupabaseColumns.updatedAt: DateTime.now().toIso8601String(),
      });
    } catch (e, stack) {
      AppErrorReporter.report(
        'ReminderSettingsService.saveSettings remote failed',
        error: e,
        stack: stack,
        context: {'feature': 'reminders', 'operation': 'saveSettings'},
      );
    }
  }

  Future<void> _saveLocal(ReminderSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${PrefKeys.reminderSettingsPrefix}${settings.groupId}',
      jsonEncode(settings.toJSON()),
    );
  }

  Future<ReminderSettings?> _loadLocal(String groupId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('${PrefKeys.reminderSettingsPrefix}$groupId');
    if (raw == null) return null;
    try {
      return ReminderSettings.fromJSON(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}

extension ReminderCadenceDuration on ReminderCadence {
  Duration? get delay {
    switch (this) {
      case ReminderCadence.off:
        return null;
      case ReminderCadence.daily:
        return AppMotion.reminderDaily;
      case ReminderCadence.weekly:
        return AppMotion.reminderWeekly;
      case ReminderCadence.biweekly:
        return AppMotion.reminderBiweekly;
      case ReminderCadence.monthly:
        return AppMotion.reminderMonthly;
    }
  }
}
