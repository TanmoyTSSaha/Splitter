import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Services/currency_service.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

/// Large Albra amount entry — borderless hero field (loan, group expense, etc.).
class HeroAmountField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final String hintText;

  const HeroAmountField({
    required this.controller,
    this.label,
    this.validator,
    this.onChanged,
    this.autofocus = false,
    this.hintText = AppAmountHints.zero,
    super.key,
  });

  static TextStyle amountStyle(Color color) => TextStyle(
        fontFamily: kFontAlbra,
        fontSize: splitrFontRecapXl,
        fontWeight: FontWeight.w700,
        color: color,
      );

  String _currencySymbol() {
    if (Get.isRegistered<CurrencyController>()) {
      return Get.find<CurrencyController>().symbol;
    }
    return CurrencyService.symbolFor(CurrencyDefaults.code);
  }

  InputDecoration _decoration() => InputDecoration(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        filled: false,
        hintText: hintText,
        hintStyle: amountStyle(groupMutedIconMuted),
        contentPadding: EdgeInsets.zero,
        isDense: true,
        isCollapsed: true,
      );

  @override
  Widget build(BuildContext context) {
    final sym = _currencySymbol();

    final amountRow = Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(sym, style: amountStyle(groupOnSurface)),
        const SizedBox(width: groupGapSm),
        Expanded(
          child: validator != null
              ? TextFormField(
                  controller: controller,
                  autofocus: autofocus,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: validator,
                  onChanged: onChanged,
                  style: amountStyle(groupOnSurface),
                  decoration: _decoration(),
                )
              : TextField(
                  controller: controller,
                  autofocus: autofocus,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: onChanged,
                  style: amountStyle(groupOnSurface),
                  decoration: _decoration(),
                ),
        ),
      ],
    );

    if (label == null) return amountRow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label!, style: caption_text.copyWith(color: groupOnSurfaceMuted)),
        const SizedBox(height: groupGapSm),
        amountRow,
      ],
    );
  }
}
