import 'package:flutter/material.dart';
import 'package:splitr/Utils/currency_utils.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

class CustomBigTextFormField extends StatelessWidget {
  final TextEditingController customBigTextFormFieldTextEditingController;
  final bool autofocus;
  final String labelText;
  final TextInputType keyboardType;

  const CustomBigTextFormField({
    super.key,
    required this.customBigTextFormFieldTextEditingController,
    this.autofocus = false,
    required this.labelText,
    this.keyboardType = const TextInputType.numberWithOptions(decimal: true),
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText.isNotEmpty)
          Text(labelText, style: body2_text.copyWith(color: neopopGrey)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(userCurrencySymbol(),
                style: headline1_text.copyWith(
                    fontSize: splitrFontRecapXl, color: onSurface)),
            const SizedBox(width: groupGap10),
            Expanded(
              child: TextField(
                controller: customBigTextFormFieldTextEditingController,
                autofocus: autofocus,
                keyboardType: keyboardType,
                style: headline1_text.copyWith(
                    fontSize: splitrFontRecapXl, color: onSurface),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  hintText: AppAmountHints.decimal,
                  hintStyle: headline1_text.copyWith(
                      fontSize: splitrFontRecapXl, color: neopopGrey),
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
