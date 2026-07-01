import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/glass_card.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';

class InsightsCoachCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accent;

  const InsightsCoachCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accent,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: groupGapSm),
      opacity: 0.06,
      padding: const EdgeInsets.all(groupGapMd),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: groupGapMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: caption_text.copyWith(color: groupOnSurfaceMuted)),
                const SizedBox(height: 4),
                Text(value,
                    style: body1_text.copyWith(
                      color: groupOnSurface,
                      fontWeight: FontWeight.w600,
                    )),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: caption_text.copyWith(color: groupOnSurfaceMuted)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
