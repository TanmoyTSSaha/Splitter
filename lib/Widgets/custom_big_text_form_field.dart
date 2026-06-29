import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';

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
            Text("₹",
                style: headline1_text.copyWith(fontSize: 48, color: onSurface)),
            SizedBox(width: width_10),
            Expanded(
              child: TextField(
                controller: customBigTextFormFieldTextEditingController,
                autofocus: autofocus,
                keyboardType: keyboardType,
                style: headline1_text.copyWith(fontSize: 48, color: onSurface),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "0.00",
                  hintStyle:
                      headline1_text.copyWith(fontSize: 48, color: neopopGrey),
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
