import 'package:flutter/material.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Utils/upi_vpa_utils.dart';
import 'package:splitr/Widgets/bordered_input_field.dart';
import 'package:splitr/Widgets/app_bottom_sheet.dart';
import 'package:splitr/Constants/app_strings.dart';

/// Bottom sheet for entering payee VPA when they have no saved UPI accounts.
class ManualPayeeVpaSheet extends StatefulWidget {
  final String payeeName;

  const ManualPayeeVpaSheet({super.key, required this.payeeName});

  static Future<String?> show(
    BuildContext context, {
    required String payeeName,
  }) {
    return showAppThemedBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ManualPayeeVpaSheet(payeeName: payeeName),
    );
  }

  @override
  State<ManualPayeeVpaSheet> createState() => _ManualPayeeVpaSheetState();
}

class _ManualPayeeVpaSheetState extends State<ManualPayeeVpaSheet> {
  final _vpaController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _vpaController.dispose();
    super.dispose();
  }

  void _submit() {
    final vpa = UpiVpaUtils.validateAndNormalize(_vpaController.text);
    if (vpa == null) {
      setState(() => _errorText = AppStrings.profile.invalidVpa);
      return;
    }
    Navigator.pop(context, vpa);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: groupGutter,
          right: groupGutter,
          top: groupGapLg,
          bottom: MediaQuery.of(context).viewInsets.bottom + groupGapLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.groups.receiverUpiId,
              style: sub_headline5_text.copyWith(color: groupOnSurface),
            ),
            const SizedBox(height: groupGapSm),
            Text(
              AppStringFormat.payeeNoUpiManualEntry(widget.payeeName),
              style: body2_text.copyWith(color: groupOnSurfaceMuted),
            ),
            const SizedBox(height: groupGapMd),
            BorderedInputField(
              controller: _vpaController,
              hintText: AppStrings.groups.nameUpiHint,
              labelText: AppStrings.groups.payeeVpa,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }
              },
            ),
            if (_errorText != null) ...[
              const SizedBox(height: groupGapSm),
              Text(
                _errorText!,
                style: caption_text.copyWith(color: neopopAlert),
              ),
            ],
            const SizedBox(height: groupGapLg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: groupGapMd),
                      side: const BorderSide(color: groupOnSurfaceMuted),
                    ),
                    child: Text(
                      AppStrings.actions.cancel,
                      style: button_text.copyWith(color: groupOnSurface),
                    ),
                  ),
                ),
                const SizedBox(width: groupGapSm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: neopopAccent,
                      padding:
                          const EdgeInsets.symmetric(vertical: groupGapMd),
                    ),
                    child: Text(
                      AppStrings.groups.openUpi,
                      style: button_text.copyWith(color: neopopBackground),
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
