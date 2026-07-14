import 'package:flutter/material.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/theme_accent_colors.dart';
import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Services/insights_navigation.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/app_keys.dart';

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
    final openExposure =
        (social[SocialTrustKeys.openExposure] as num?)?.toDouble() ?? 0;
    final groupCount = social[SocialTrustKeys.groupCount] as int? ?? 0;
    final payerRatio =
        (social[SocialTrustKeys.payerRatio] as num?)?.toDouble() ?? 0;
    final avgDays = social[SocialTrustKeys.settlementAvgDays] as int? ?? 0;
    final staleAmt =
        (social[SocialTrustKeys.staleBalanceAmount] as num?)?.toDouble() ?? 0;
    final staleCount = social[SocialTrustKeys.staleBalanceCount] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _row(
          Icons.account_balance_wallet_outlined,
          AppStrings.insights.openExposure,
          openExposure > 0
              ? AppStringFormat.insightsOpenExposure(
                  currencySymbol,
                  openExposure.toStringAsFixed(0),
                  groupCount,
                )
              : AppStrings.insights.allClearNoBalances,
          neopopAccent,
          openExposure >= 500
              ? () => InsightsNavigation.handleAction({
                    'action_type': InsightActionTypes.settleUp,
                    UnifiedTxnKeys.groupId: social[SocialTrustKeys.topGroupId],
                    SupabaseColumns.groupName:
                        social[SocialTrustKeys.topGroupName],
                  })
              : null,
        ),
        if (payerRatio > 0)
          _row(
            Icons.payments_outlined,
            AppStrings.insights.youFrontGroupSpends,
            AppStringFormat.insightsPayerRatio(
              payerRatio.toStringAsFixed(0),
            ),
            ThemeAccentColors.oweWarning(context),
            null,
          ),
        if (avgDays > 0)
          _row(
            Icons.schedule_outlined,
            AppStrings.insights.settlementSpeed,
            AppStringFormat.insightsSettlementSpeed(avgDays),
            neopopSuccess,
            null,
          ),
        if (staleAmt > 0 && staleCount > 0)
          _row(
            Icons.warning_amber_rounded,
            AppStrings.insights.staleBalances,
            AppStringFormat.insightsStaleBalances(
              currencySymbol,
              staleAmt.toStringAsFixed(0),
            ),
            InsightsChartPalette.orange,
            () => InsightsNavigation.handleAction({
              'action_type': InsightActionTypes.settleUp,
              UnifiedTxnKeys.groupId: social[SocialTrustKeys.topGroupId],
              SupabaseColumns.groupName: social[SocialTrustKeys.topGroupName],
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
                child: Text(
                  AppStrings.insights.settle,
                  style: caption_text.copyWith(color: neopopAccent),
                ),
              )
            : null,
      ),
    );
  }
}
