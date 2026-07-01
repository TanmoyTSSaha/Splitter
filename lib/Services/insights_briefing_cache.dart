import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Caches AI insights briefing locally (7-day TTL or spend shift >10%).
class InsightsBriefingCache {
  static const _keyPayload = 'insights_briefing_payload';
  static const _keyGeneratedAt = 'insights_briefing_generated_at';
  static const _keySpendSnapshot = 'insights_briefing_spend_snapshot';

  static Future<Map<String, dynamic>?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyPayload);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> isFresh({
    required double currentMonthSpend,
    Duration maxAge = const Duration(days: 7),
    double spendShiftThreshold = 0.10,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final generatedStr = prefs.getString(_keyGeneratedAt);
    if (generatedStr == null) return false;

    final generatedAt = DateTime.tryParse(generatedStr);
    if (generatedAt == null) return false;
    if (DateTime.now().difference(generatedAt) > maxAge) return false;

    final snapshot = prefs.getDouble(_keySpendSnapshot) ?? 0;
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
    await prefs.setString(_keyPayload, jsonEncode(briefing));
    await prefs.setString(
        _keyGeneratedAt, DateTime.now().toIso8601String());
    await prefs.setDouble(_keySpendSnapshot, monthSpendSnapshot);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPayload);
    await prefs.remove(_keyGeneratedAt);
    await prefs.remove(_keySpendSnapshot);
  }
}
