import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/theme_accent_colors.dart';
import 'package:splitr/Constants/glass_card.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Screen/Insights/expense_insights_screen.dart';
import 'package:splitr/Services/spending_intelligence_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

/// Contextual home-screen card promoting Expense Insights (Cursor-style).
class InsightsPromoCard extends StatefulWidget {
  const InsightsPromoCard({super.key});

  @override
  State<InsightsPromoCard> createState() => _InsightsPromoCardState();
}

class _InsightsPromoCardState extends State<InsightsPromoCard> {
  SpendingIntelligenceService? _service;
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
    final sessionShown =
        prefs.getBool(PrefKeys.insightsPromoSessionShown) ?? false;
    if (sessionShown) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final dismissedStr = prefs.getString(PrefKeys.insightsPromoDismissedAt);
    if (dismissedStr != null) {
      final dismissedAt = DateTime.tryParse(dismissedStr);
      if (dismissedAt != null &&
          DateTime.now().difference(dismissedAt) <
              AppMotion.insightsPromoDismiss) {
        if (mounted) setState(() => _loading = false);
        return;
      }
    }

    try {
      final hook =
          await (_service ??= SpendingIntelligenceService()).getPromoHook();
      if (mounted) {
        setState(() {
          _message = hook['message'] as String?;
          _visible = _message != null && _message!.isNotEmpty;
          _loading = false;
        });
      }
      if (_visible) {
        await prefs.setBool(PrefKeys.insightsPromoSessionShown, true);
      }
    } catch (e, stack) {
      AppErrorReporter.report(
        'Insights promo card load failed',
        error: e,
        stack: stack,
      );
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        PrefKeys.insightsPromoDismissedAt, DateTime.now().toIso8601String());
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
        opacity: AppDimensions.glassCardOpacityDefault,
        padding: const EdgeInsets.all(groupGapMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.auto_awesome,
              color: ThemeAccentColors.highlight(context),
              size: AppDimensions.insightsPromoIcon,
            ),
            const SizedBox(width: groupGapSm),
            Expanded(
              child: GestureDetector(
                onTap: _openInsights,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.insights.title,
                      style: caption_text.copyWith(
                        color: groupOnSurfaceMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: groupGapXxs),
                    Text(
                      _message!,
                      style: body2_text.copyWith(
                        color: groupOnSurface,
                        height: groupLineHeightRelaxed,
                      ),
                    ),
                    const SizedBox(height: groupGapXs),
                    Text(
                      AppStrings.insights.seeInsights,
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
              icon: const Icon(
                Icons.close,
                size: AppDimensions.insightsPromoDismissIcon,
                color: groupOnSurfaceMuted,
              ),
              onPressed: _dismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: AppDimensions.insightsPromoDismissTap,
                minHeight: AppDimensions.insightsPromoDismissTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
