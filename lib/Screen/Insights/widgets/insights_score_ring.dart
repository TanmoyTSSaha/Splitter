import 'package:flutter/material.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/glass_card.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Services/spending_intelligence_service.dart';

class InsightsScoreRing extends StatelessWidget {
  final String label;
  final int score;
  final Color accent;
  final String explanation;

  const InsightsScoreRing({
    required this.label,
    required this.score,
    required this.accent,
    required this.explanation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scoreLabel = SpendingIntelligenceService.scoreLabel(score);
    final progress = score / 100;

    return GlassCard(
      margin: EdgeInsets.zero,
      opacity: 0.06,
      padding: const EdgeInsets.all(groupGapSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(groupControlRadius),
        onTap: () => _showBreakdown(context),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: caption_text.copyWith(color: groupOnSurfaceMuted)),
                const SizedBox(width: groupGapXxs),
                Icon(Icons.help_outline,
                    size: 12, color: groupMutedTextSecondary),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: AppDimensions.insightsScoreRingSize,
              height: AppDimensions.insightsScoreRingSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: AppDimensions.insightsScoreRingStroke,
                    backgroundColor: accent.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(accent),
                  ),
                  Text(
                    '$score',
                    style: caption_text.copyWith(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      fontSize: splitrFontBodySm,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              scoreLabel,
              style: caption_text.copyWith(
                color: groupOnSurface,
                fontWeight: FontWeight.w600,
                fontSize: splitrFontCaptionSm,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBreakdown(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: groupSheetTopBorderRadius,
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(groupGapLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStringFormat.insightsScoreBreakdown(label, score),
              style: sub_headline4_text.copyWith(color: groupOnSurface),
            ),
            const SizedBox(height: groupGapSm),
            Text(
              explanation,
              style: body2_text.copyWith(
                color: groupOnSurfaceMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: groupGapMd),
          ],
        ),
      ),
    );
  }
}
