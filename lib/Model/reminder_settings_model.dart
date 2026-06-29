/// Model for per-group reminder preferences.
class ReminderSettings {
  final String groupId;
  ReminderCadence cadence;
  List<String> mutedMemberIds; // Friends to skip reminders for
  ReminderTone tone;

  ReminderSettings({
    required this.groupId,
    this.cadence = ReminderCadence.weekly,
    this.mutedMemberIds = const [],
    this.tone = ReminderTone.friendly,
  });

  Map<String, dynamic> toJSON() => {
        'group_id': groupId,
        'cadence': cadence.name,
        'muted_member_ids': mutedMemberIds,
        'tone': tone.name,
      };

  factory ReminderSettings.fromJSON(Map<String, dynamic> json) {
    return ReminderSettings(
      groupId: json['group_id'] as String,
      cadence: ReminderCadence.values.firstWhere(
          (c) => c.name == json['cadence'],
          orElse: () => ReminderCadence.weekly),
      mutedMemberIds: List<String>.from(json['muted_member_ids'] ?? []),
      tone: ReminderTone.values.firstWhere((t) => t.name == json['tone'],
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
  friendly, // Default: "Coffee is on you! ☕"
  casual, // "Hey, don't forget!"
  formal, // "Please settle the outstanding balance."
}
