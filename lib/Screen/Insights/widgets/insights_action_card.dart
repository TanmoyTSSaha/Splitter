import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/glass_card.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitter/Services/insights_navigation.dart';

class InsightsActionCard extends StatelessWidget {
  final Map<String, dynamic> action;
  final int index;

  const InsightsActionCard({
    required this.action,
    required this.index,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: groupGapSm),
      child: GlassCard(
        margin: EdgeInsets.zero,
        opacity: 0.06,
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: CircleAvatar(
            radius: 14,
            backgroundColor: neopopAccent.withValues(alpha: 0.15),
            child: Text(
              '$index',
              style: caption_text.copyWith(
                color: neopopAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            action['title'] as String? ?? 'Action',
            style: body2_text.copyWith(color: groupOnSurface),
          ),
          subtitle: Text(
            action['reason'] as String? ?? '',
            style: caption_text.copyWith(color: groupOnSurfaceMuted),
          ),
          trailing: const Icon(Icons.chevron_right_rounded,
              color: groupOnSurfaceMuted),
          onTap: () => InsightsNavigation.handleAction(action),
        ),
      ),
    );
  }
}
