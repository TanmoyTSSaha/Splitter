import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Utils/currency_utils.dart';

/// Single outer border; inner field uses [InputBorder.none].
class BorderedInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final String? prefixText;
  final Widget? prefixIcon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final TextStyle? style;

  const BorderedInputField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixText,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.style,
  });

  /// Prefix SVG icon inside the same bordered container.
  factory BorderedInputField.withSvgIcon({
    Key? key,
    required TextEditingController controller,
    required String svgAssetPath,
    required String hintText,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    bool enabled = true,
    ValueChanged<String>? onChanged,
    TextStyle? style,
  }) {
    return BorderedInputField(
      key: key,
      controller: controller,
      hintText: hintText,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      enabled: enabled,
      onChanged: onChanged,
      style: style,
      prefixIcon: SvgPicture.asset(
        svgAssetPath,
        height: AppDimensions.groupIconMd,
        width: AppDimensions.groupIconMd,
        colorFilter: ColorFilter.mode(
          groupOnSurfaceMuted,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  /// Amount entry with the user's currency symbol as prefix.
  factory BorderedInputField.amount({
    Key? key,
    required TextEditingController controller,
    String? labelText,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    bool enabled = true,
  }) {
    return BorderedInputField(
      key: key,
      controller: controller,
      labelText: labelText,
      prefixText: currencyPrefixText(),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = groupMutedBorderHairline;
    final mutedFill = groupMutedFillFaint;
    final fieldStyle = style ??
        body1_text.copyWith(
            color: enabled ? groupOnSurface : groupOnSurfaceMuted);

    final field = TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      onChanged: onChanged,
      style: fieldStyle,
      decoration: InputDecoration(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        hintText: hintText,
        hintStyle: body2_text.copyWith(
          color: groupMutedIconDim,
        ),
        labelText: labelText,
        labelStyle: caption_text.copyWith(color: groupOnSurfaceMuted),
        prefixText: prefixText,
        prefixStyle: fieldStyle,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: mutedFill,
        borderRadius: BorderRadius.circular(groupControlRadius),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: groupGap14, vertical: groupCarouselGap),
      child: prefixIcon != null
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: groupGap2, right: groupCarouselGap),
                  child: prefixIcon,
                ),
                Expanded(child: field),
              ],
            )
          : field,
    );
  }
}
