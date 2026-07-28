import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/business_rules.dart';

/// Caches AI insights briefing locally (7-day TTL or spend shift >10%).
class InsightsBriefingCache {
  static Future<Map<String, dynamic>?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(PrefKeys.insightsBriefingPayload);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> isFresh({
    required double currentMonthSpend,
    Duration maxAge = AppMotion.insightsBriefingMaxAge,
    double spendShiftThreshold = CacheTtls.insightsBriefingSpendShift,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final generatedStr = prefs.getString(PrefKeys.insightsBriefingGeneratedAt);
    if (generatedStr == null) return false;

    final generatedAt = DateTime.tryParse(generatedStr);
    if (generatedAt == null) return false;
    if (DateTime.now().difference(generatedAt) > maxAge) return false;

    final snapshot =
        prefs.getDouble(PrefKeys.insightsBriefingSpendSnapshot) ?? 0;
    if (snapshot <= 0 && currentMonthSpend <= 0) return true;
    if (snapshot <= 0) return false;

    final shift = (currentMonthSpend - snapshot).abs() / snapshot;
    return shift <= spendShiftThreshold;
  }

  static Future<void> write({
    required Map<String, dynamic> briefing,
    required double monthSpendSnapshot,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        PrefKeys.insightsBriefingPayload, jsonEncode(briefing));
    await prefs.setString(
        PrefKeys.insightsBriefingGeneratedAt, DateTime.now().toIso8601String());
    await prefs.setDouble(
        PrefKeys.insightsBriefingSpendSnapshot, monthSpendSnapshot);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PrefKeys.insightsBriefingPayload);
    await prefs.remove(PrefKeys.insightsBriefingGeneratedAt);
    await prefs.remove(PrefKeys.insightsBriefingSpendSnapshot);
  }
}
