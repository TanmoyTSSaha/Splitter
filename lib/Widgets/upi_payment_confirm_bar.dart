import 'package:flutter/material.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Constants/app_strings.dart';

/// Floating bar asking payer to confirm UPI payment after returning from UPI app.
class UpiPaymentConfirmBar extends StatelessWidget {
  final VoidCallback onYes;
  final VoidCallback onNo;
  final bool enabled;

  const UpiPaymentConfirmBar({
    super.key,
    required this.onYes,
    required this.onNo,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;

    return Material(
      elevation: 8,
      color: surface,
      shadowColor: groupSurfaceFillMedium,
      borderRadius: BorderRadius.circular(groupCardRadius),
      child: Container(
        padding: const EdgeInsets.all(groupGapMd),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(groupCardRadius),
          border: Border.all(color: neopopAccent),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.groups.upiPaymentConfirmQuestion,
              style: body1_text.copyWith(
                color: groupOnSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: groupGapMd),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: enabled ? onNo : null,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: groupMutedBorderHairline),
                      padding: const EdgeInsets.symmetric(vertical: groupGapSm),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(groupControlRadius),
                      ),
                    ),
                    child: Text(
                      AppStrings.actions.no,
                      style: button_text.copyWith(color: groupOnSurface),
                    ),
                  ),
                ),
                const SizedBox(width: groupGapSm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: enabled ? onYes : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: neopopAccent,
                      disabledBackgroundColor: neopopAccentIconMuted,
                      padding: const EdgeInsets.symmetric(vertical: groupGapSm),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(groupControlRadius),
                      ),
                    ),
                    child: Text(
                      AppStrings.actions.yes,
                      style: button_text.copyWith(
                        color: neopopOnAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
