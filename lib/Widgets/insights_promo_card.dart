import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/glass_card.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitter/Screen/Insights/expense_insights_screen.dart';
import 'package:splitter/Services/spending_intelligence_service.dart';

/// Contextual home-screen card promoting Expense Insights (Cursor-style).
class InsightsPromoCard extends StatefulWidget {
  const InsightsPromoCard({super.key});

  @override
  State<InsightsPromoCard> createState() => _InsightsPromoCardState();
}

class _InsightsPromoCardState extends State<InsightsPromoCard> {
  static const _prefDismissedAt = 'insights_promo_dismissed_at';
  static const _prefSessionShown = 'insights_promo_session_shown';

  final SpendingIntelligenceService _service = SpendingIntelligenceService();
  String? _message;
  bool _loading = true;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionShown = prefs.getBool(_prefSessionShown) ?? false;
    if (sessionShown) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final dismissedStr = prefs.getString(_prefDismissedAt);
    if (dismissedStr != null) {
      final dismissedAt = DateTime.tryParse(dismissedStr);
      if (dismissedAt != null &&
          DateTime.now().difference(dismissedAt) < const Duration(hours: 24)) {
        if (mounted) setState(() => _loading = false);
        return;
      }
    }

    try {
      final hook = await _service.getPromoHook();
      if (mounted) {
        setState(() {
          _message = hook['message'] as String?;
          _visible = _message != null && _message!.isNotEmpty;
          _loading = false;
        });
      }
      if (_visible) {
        await prefs.setBool(_prefSessionShown, true);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _prefDismissedAt, DateTime.now().toIso8601String());
    if (mounted) setState(() => _visible = false);
  }

  void _openInsights() {
    Get.to(() => const ExpenseInsightsScreen());
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || !_visible || _message == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: groupGapMd),
      child: GlassCard(
        margin: EdgeInsets.zero,
        opacity: 0.08,
        padding: const EdgeInsets.all(groupGapMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.auto_awesome, color: neopopYellow, size: 22),
            const SizedBox(width: groupGapSm),
            Expanded(
              child: GestureDetector(
                onTap: _openInsights,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expense Insights',
                      style: caption_text.copyWith(
                        color: groupOnSurfaceMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _message!,
                      style: body2_text.copyWith(
                        color: groupOnSurface,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'See insights →',
                      style: caption_text.copyWith(
                        color: neopopAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: groupOnSurfaceMuted),
              onPressed: _dismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }
}
