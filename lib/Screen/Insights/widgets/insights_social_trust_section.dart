import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitter/Services/insights_navigation.dart';

class InsightsSocialTrustSection extends StatelessWidget {
  final Map<String, dynamic> social;
  final String currencySymbol;

  const InsightsSocialTrustSection({
    required this.social,
    required this.currencySymbol,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final openExposure = (social['openExposure'] as num?)?.toDouble() ?? 0;
    final groupCount = social['groupCount'] as int? ?? 0;
    final payerRatio = (social['payerRatio'] as num?)?.toDouble() ?? 0;
    final avgDays = social['settlementAvgDays'] as int? ?? 0;
    final staleAmt = (social['staleBalanceAmount'] as num?)?.toDouble() ?? 0;
    final staleCount = social['staleBalanceCount'] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _row(
          Icons.account_balance_wallet_outlined,
          'Open exposure',
          openExposure > 0
              ? '$currencySymbol${openExposure.toStringAsFixed(0)} across $groupCount group${groupCount == 1 ? '' : 's'}'
              : 'All clear — no open balances',
          neopopAccent,
          openExposure >= 500
              ? () => InsightsNavigation.handleAction({
                    'action_type': 'settle_up',
                    'group_id': social['topGroupId'],
                    'group_name': social['topGroupName'],
                  })
              : null,
        ),
        if (payerRatio > 0)
          _row(
            Icons.payments_outlined,
            'You front group spends',
            '${payerRatio.toStringAsFixed(0)}% of group expenses this month',
            neopopYellow,
            null,
          ),
        if (avgDays > 0)
          _row(
            Icons.schedule_outlined,
            'Settlement speed',
            'Avg $avgDays days from expense to settle-up',
            const Color(0xFF2E7D32),
            null,
          ),
        if (staleAmt > 0 && staleCount > 0)
          _row(
            Icons.warning_amber_rounded,
            'Stale balances',
            '$currencySymbol${staleAmt.toStringAsFixed(0)} unsettled 30+ days',
            Colors.orangeAccent,
            () => InsightsNavigation.handleAction({
                  'action_type': 'settle_up',
                  'group_id': social['topGroupId'],
                  'group_name': social['topGroupName'],
                }),
          ),
      ],
    );
  }

  Widget _row(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback? onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: groupGapSm),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: color),
        title: Text(title, style: body2_text.copyWith(color: groupOnSurface)),
        subtitle: Text(subtitle,
            style: caption_text.copyWith(color: groupOnSurfaceMuted)),
        trailing: onTap != null
            ? TextButton(
                onPressed: onTap,
                child: Text('Settle',
                    style: caption_text.copyWith(color: neopopAccent)),
              )
            : null,
      ),
    );
  }
}
