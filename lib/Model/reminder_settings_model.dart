import 'package:splitr/Constants/app_keys.dart';

/// Model for per-group reminder preferences.
class ReminderSettings {
  final String groupId;
  ReminderCadence cadence;
  List<String> mutedMemberIds;
  ReminderTone tone;

  ReminderSettings({
    required this.groupId,
    this.cadence = ReminderCadence.weekly,
    this.mutedMemberIds = const [],
    this.tone = ReminderTone.friendly,
  });

  Map<String, dynamic> toJSON() => {
        SupabaseColumns.groupId: groupId,
        SupabaseColumns.cadence: cadence.name,
        SupabaseColumns.mutedMemberIds: mutedMemberIds,
        SupabaseColumns.tone: tone.name,
      };

  factory ReminderSettings.fromJSON(Map<String, dynamic> json) {
    return ReminderSettings(
      groupId: json[SupabaseColumns.groupId] as String,
      cadence: ReminderCadence.values.firstWhere(
          (c) => c.name == json[SupabaseColumns.cadence],
          orElse: () => ReminderCadence.weekly),
      mutedMemberIds:
          List<String>.from(json[SupabaseColumns.mutedMemberIds] ?? []),
      tone: ReminderTone.values.firstWhere(
          (t) => t.name == json[SupabaseColumns.tone],
          orElse: () => ReminderTone.friendly),
    );
  }
}

enum ReminderCadence {
  off,
  daily,
  weekly,
  biweekly,
  monthly,
}

enum ReminderTone {
  friendly,
  casual,
  formal,
}

/// Aggressive / escalated cadences reserved for Splitr Pro.
bool reminderCadenceRequiresPro(ReminderCadence cadence) =>
    cadence == ReminderCadence.daily || cadence == ReminderCadence.biweekly;

/// Professional tone reserved for Splitr Pro.
bool reminderToneRequiresPro(ReminderTone tone) => tone == ReminderTone.formal;
