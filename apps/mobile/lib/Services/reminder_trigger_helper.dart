import 'package:get/get.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Services/reminder_service.dart';
import 'package:splitr/Services/reminder_settings_service.dart';

/// Schedules contextual debt reminders after expenses and settlements.
class ReminderTriggerHelper {
  static Future<void> onExpenseAdded({
    required String groupId,
    required String groupName,
    required Map<String, double> splits,
    required Map<String, String> memberNames,
    required String payerUserId,
  }) async {
    final settingsService = Get.find<ReminderSettingsService>();
    if (await settingsService.isSilentMode()) return;

    final settings = await settingsService.getSettings(groupId);
    final delay = settings.cadence.delay;
    if (delay == null) return;

    final reminderService = Get.find<ReminderService>();
    await reminderService.requestPermission();

    int notifIndex = 0;
    for (final entry in splits.entries) {
      if (entry.key == payerUserId) continue;
      if (entry.value <= 0) continue;
      if (settings.mutedMemberIds.contains(entry.key)) continue;

      final debtorName = memberNames[entry.key] ?? DisplayFallbacks.someone;
      await reminderService.scheduleReminder(
        id: _notificationId(groupId, notifIndex++),
        groupName: groupName,
        debtorName: debtorName,
        amount: entry.value,
        tone: settings.tone,
        delay: delay,
      );
    }
  }

  static Future<void> onSettlementRecorded({
    required String groupId,
    required String groupName,
    required String fromUserId,
    required String fromName,
    required double amount,
  }) async {
    final settingsService = Get.find<ReminderSettingsService>();
    if (await settingsService.isSilentMode()) return;

    final settings = await settingsService.getSettings(groupId);
    final delay = settings.cadence.delay;
    if (delay == null) return;
    if (settings.mutedMemberIds.contains(fromUserId)) return;

    await Get.find<ReminderService>().scheduleReminder(
      id: _notificationId(groupId, 99),
      groupName: groupName,
      debtorName: fromName,
      amount: amount,
      tone: settings.tone,
      delay: AppMotion.reminderSettlementDelay,
    );
  }

  static int _notificationId(String groupId, int index) {
    return (groupId.hashCode.abs() % 10000) + index;
  }
}
