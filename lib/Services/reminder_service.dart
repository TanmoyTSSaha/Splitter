import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:splitter/Model/reminder_settings_model.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Smart reminder service with friendly, contextual language.
/// Defuses awkwardness around money with humor and warmth.
class ReminderService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final _random = Random();
  bool _tzReady = false;

  /// Initialize the notification plugin.
  Future<void> initialize() async {
    if (!_tzReady) {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
      _tzReady = true;
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  /// Request notification permission (Android 13+).
  Future<bool> requestPermission() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  /// Schedule a reminder notification after [delay].
  Future<void> scheduleReminder({
    required int id,
    required String groupName,
    required String debtorName,
    required double amount,
    required ReminderTone tone,
    required Duration delay,
  }) async {
    if (!_tzReady) await initialize();

    final message = _generateMessage(
      groupName: groupName,
      debtorName: debtorName,
      amount: amount,
      tone: tone,
    );

    final scheduled = tz.TZDateTime.now(tz.local).add(delay);
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'splito_reminders',
        'Settlement Reminders',
        channelDescription: 'Friendly reminders to settle up',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _notifications.zonedSchedule(
        id,
        'SplitO — $groupName',
        message,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('ReminderService.scheduleReminder: $e — showing immediately');
      await _notifications.show(id, 'SplitO — $groupName', message, details);
    }
  }

  /// Generate a contextual, friendly reminder message.
  String _generateMessage({
    required String groupName,
    required String debtorName,
    required double amount,
    required ReminderTone tone,
  }) {
    final amountStr = '₹${amount.toStringAsFixed(0)}';

    switch (tone) {
      case ReminderTone.friendly:
        return _randomPick(_friendlyTemplates)
            .replaceAll('{name}', debtorName)
            .replaceAll('{amount}', amountStr)
            .replaceAll('{group}', groupName);
      case ReminderTone.casual:
        return _randomPick(_casualTemplates)
            .replaceAll('{name}', debtorName)
            .replaceAll('{amount}', amountStr)
            .replaceAll('{group}', groupName);
      case ReminderTone.formal:
        return _randomPick(_formalTemplates)
            .replaceAll('{name}', debtorName)
            .replaceAll('{amount}', amountStr)
            .replaceAll('{group}', groupName);
    }
  }

  String _randomPick(List<String> list) => list[_random.nextInt(list.length)];

  static const _friendlyTemplates = [
    "You and {name} haven't settled up in a while. Coffee is on you! ☕",
    "{name} is probably wondering about that {amount}... just saying 😄",
    "Remember that {amount} in {group}? {name} remembers! 💭",
    "Settle up {amount} with {name} and keep the good vibes going ✨",
    "Quick reminder: {amount} → {name} in {group}. No rush, but also... 😉",
    "{name} didn't say anything, but that {amount} is still hanging! 🎈",
    "Friendship tip: settling {amount} with {name} = good karma ☀️",
    "That {amount} for {group} isn't going anywhere... might as well settle! 💸",
    "Pro tip: Pay {name} {amount} and earn infinite cool points 😎",
    "Hey! {amount} still pending with {name} in {group}. No biggie! 🤝",
    "Plot twist: You still owe {name} {amount}. Time to be the hero! 🦸",
    "Money fact: Settling {amount} with {name} feels amazing. Try it! 🎉",
    "{amount} to {name} in {group} — future you will thank present you! 🙏",
    "Gentle nudge: {name} + {amount} + {group} = time to settle! 💫",
    "Your wallet called. It said to pay {name} {amount}. Just kidding... or? 📞",
  ];

  static const _casualTemplates = [
    "Hey, don't forget about {amount} to {name} in {group}!",
    "Quick heads up — {amount} pending with {name} 👋",
    "Just a reminder: {amount} to {name} from {group}",
    "Yo! {amount} still open with {name}. Pay when you can! 🤙",
    "{amount} pending → {name}. {group} expenses, you know the drill!",
  ];

  static const _formalTemplates = [
    "Reminder: ₹{amount} is pending settlement with {name} in {group}.",
    "Please settle the outstanding balance of {amount} with {name}.",
    "Settlement reminder: {amount} to {name} from group {group}.",
    "You have an unsettled balance of {amount} with {name} in {group}.",
    "Kindly settle {amount} with {name} at your earliest convenience.",
  ];

  Future<void> cancelGroupReminders(String groupId) async {
    final baseId = groupId.hashCode.abs() % 10000;
    for (int i = 0; i < 50; i++) {
      await _notifications.cancel(baseId + i);
    }
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
