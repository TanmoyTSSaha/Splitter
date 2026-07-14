import 'package:flutter/material.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Model/user_upi_account_model.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Utils/upi_vpa_utils.dart';
import 'package:splitr/Widgets/app_bottom_sheet.dart';
import 'package:splitr/Constants/app_strings.dart';

/// Bottom sheet to pick a payee's saved UPI account (masked VPA display).
class PayeeUpiPickerSheet extends StatelessWidget {
  final List<UserUpiAccount> accounts;
  final String payeeName;

  const PayeeUpiPickerSheet({
    super.key,
    required this.accounts,
    required this.payeeName,
  });

  static Future<UserUpiAccount?> show(
    BuildContext context, {
    required List<UserUpiAccount> accounts,
    required String payeeName,
  }) {
    return showAppThemedBottomSheet<UserUpiAccount>(
      context: context,
      builder: (_) => PayeeUpiPickerSheet(
        accounts: accounts,
        payeeName: payeeName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sorted = List<UserUpiAccount>.from(accounts)
      ..sort((a, b) {
        if (a.isPrimary != b.isPrimary) {
          return a.isPrimary ? -1 : 1;
        }
        return a.bankAlias.compareTo(b.bankAlias);
      });

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          groupGutter,
          groupGapLg,
          groupGutter,
          groupGapLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.groups.selectPayeeBank,
              style: sub_headline5_text.copyWith(color: groupOnSurface),
            ),
            const SizedBox(height: groupGapSm),
            Text(
              payeeName,
              style: body2_text.copyWith(color: groupOnSurfaceMuted),
            ),
            const SizedBox(height: groupGapMd),
            ...sorted.map((account) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.account_balance_rounded,
                  color: account.isPrimary ? neopopAccent : groupOnSurfaceMuted,
                ),
                title: Text(
                  account.bankAlias,
                  style: body1_text.copyWith(
                    color: groupOnSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  UpiVpaUtils.maskVpa(account.vpa),
                  style: body2_text.copyWith(color: groupOnSurfaceMuted),
                ),
                trailing: account.isPrimary
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: groupGapSm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: neopopAccentFillMedium,
                          borderRadius:
                              BorderRadius.circular(groupRadiusHairline),
                        ),
                        child: Text(
                          AppStrings.profile.primaryBadge,
                          style: caption_text.copyWith(color: neopopAccent),
                        ),
                      )
                    : null,
                onTap: () => Navigator.pop(context, account),
              );
            }),
          ],
        ),
      ),
    );
  }
}
