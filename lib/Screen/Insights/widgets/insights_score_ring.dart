import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/glass_card.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitter/Services/spending_intelligence_service.dart';

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
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showBreakdown(context),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: caption_text.copyWith(color: groupOnSurfaceMuted)),
                const SizedBox(width: 4),
                Icon(Icons.help_outline,
                    size: 12, color: groupOnSurfaceMuted.withValues(alpha: 0.7)),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 52,
              height: 52,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 5,
                    backgroundColor: accent.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(accent),
                  ),
                  Text(
                    '$score',
                    style: caption_text.copyWith(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
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
                fontSize: 11,
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(groupGapLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label score: $score',
                style: sub_headline4_text.copyWith(color: groupOnSurface)),
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
