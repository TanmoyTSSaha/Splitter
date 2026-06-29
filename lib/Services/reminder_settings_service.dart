import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitter/Model/reminder_settings_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Persists per-group reminder preferences (Supabase with local fallback).
class ReminderSettingsService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const _silentKey = 'reminders_silent_mode';
  static const _localPrefix = 'reminder_settings_';

  Future<bool> isSilentMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_silentKey) ?? false;
  }

  Future<void> setSilentMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_silentKey, value);
  }

  Future<ReminderSettings> getSettings(String groupId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return ReminderSettings(groupId: groupId);
    }

    try {
      final row = await _supabase
          .from('reminder_settings')
          .select()
          .eq('user_id', userId)
          .eq('group_id', groupId)
          .maybeSingle();

      if (row != null) {
        return ReminderSettings.fromJSON(row);
      }
    } catch (e) {
      debugPrint('ReminderSettingsService.getSettings remote: $e');
    }

    return await _loadLocal(groupId) ?? ReminderSettings(groupId: groupId);
  }

  Future<void> saveSettings(ReminderSettings settings) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _saveLocal(settings);

    try {
      await _supabase.from('reminder_settings').upsert({
        'user_id': userId,
        'group_id': settings.groupId,
        'cadence': settings.cadence.name,
        'tone': settings.tone.name,
        'muted_member_ids': settings.mutedMemberIds,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('ReminderSettingsService.saveSettings remote: $e');
    }
  }

  Future<void> _saveLocal(ReminderSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_localPrefix${settings.groupId}',
      jsonEncode(settings.toJSON()),
    );
  }

  Future<ReminderSettings?> _loadLocal(String groupId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_localPrefix$groupId');
    if (raw == null) return null;
    try {
      return ReminderSettings.fromJSON(
          jsonDecode(raw) as Map<String, dynamic>);
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
        return const Duration(days: 1);
      case ReminderCadence.weekly:
        return const Duration(days: 7);
      case ReminderCadence.biweekly:
        return const Duration(days: 14);
      case ReminderCadence.monthly:
        return const Duration(days: 30);
    }
  }
}
