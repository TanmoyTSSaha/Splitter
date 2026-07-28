import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Services/reminder_service.dart';
/// Drop timing + viewed state for monthly recap exclusivity (F13).
class RecapDropService {
  static const dropWindowDays = 7;

  static String monthKey(DateTime month) {
    final normalized = DateTime(month.year, month.month, 1);
    final m = normalized.month.toString().padLeft(2, '0');
    return '${normalized.year}-$m';
  }

  /// v2: promo opens current calendar month recap only (F13).
  static DateTime dropMonth(DateTime now) =>
      DateTime(now.year, now.month, 1);

  static bool isDropWindow(DateTime now) => now.day <= dropWindowDays;

  static bool shouldShowDropPromo(DateTime now, String? lastViewedKey) {
    if (!isDropWindow(now)) return false;
    final dropKey = monthKey(dropMonth(now));
    return lastViewedKey != dropKey;
  }

  static bool profileDotVisible(DateTime now, String? lastViewedKey) {
    final currentKey = monthKey(dropMonth(now));
    return lastViewedKey != currentKey;
  }

  Future<String?> getLastViewedMonthKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefKeys.recapLastViewedMonth);
  }

  Future<bool> shouldShowHomePromo() async {
    final now = DateTime.now();
    final lastViewed = await getLastViewedMonthKey();
    return shouldShowDropPromo(now, lastViewed);
  }

  Future<bool> shouldShowProfileDot() async {
    final now = DateTime.now();
    final lastViewed = await getLastViewedMonthKey();
    return profileDotVisible(now, lastViewed);
  }

  Future<void> markViewed(DateTime month) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefKeys.recapLastViewedMonth, monthKey(month));
  }

  static bool introAutoEligible(bool introAutoPlayed) => !introAutoPlayed;

  Future<bool> shouldAutoAdvanceIntro() async {
    final prefs = await SharedPreferences.getInstance();
    return introAutoEligible(prefs.getBool(PrefKeys.recapDropSeen) ?? false);
  }

  Future<void> markIntroAutoPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefKeys.recapDropSeen, true);
  }

  String _dropNotifyPrefKey(DateTime now) =>
      '${PrefKeys.recapDropNotifiedPrefix}${monthKey(dropMonth(now))}';

  Future<void> maybeNotifyDrop({
    required ReminderService reminders,
    required String monthLabel,
  }) async {
    final now = DateTime.now();
    final lastViewed = await getLastViewedMonthKey();
    if (!shouldShowDropPromo(now, lastViewed)) return;

    final prefs = await SharedPreferences.getInstance();
    final notifyKey = _dropNotifyPrefKey(now);
    if (prefs.getBool(notifyKey) ?? false) return;

    final granted = await reminders.requestPermission();
    if (!granted) return;

    await reminders.showRecapDropNotification(monthLabel: monthLabel);
    await prefs.setBool(notifyKey, true);
  }
}
