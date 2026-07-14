import 'package:flutter/material.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/glass_card.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Services/insights_navigation.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/app_keys.dart';

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
            backgroundColor: neopopAccentFillMedium,
            child: Text(
              '$index',
              style: caption_text.copyWith(
                color: neopopAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            action[UnifiedTxnKeys.title] as String? ??
                AppStrings.insights.actionFallback,
            style: body2_text.copyWith(color: groupOnSurface),
          ),
          subtitle: Text(
            action[BriefingActionKeys.reason] as String? ?? '',
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
