import 'package:flutter/material.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

/// Dropdown styled like profile / settle-up form controls (light surface).
class ThemedDropdownField<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hint;

  const ThemedDropdownField({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: groupGapMd),
      decoration: BoxDecoration(
        color: groupMutedFillFaint,
        borderRadius: BorderRadius.circular(groupControlRadius),
        border: Border.all(color: groupMutedBorderHairline),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: hint == null
              ? null
              : Text(
                  hint!,
                  style: body1_text.copyWith(color: groupOnSurfaceMuted),
                ),
          style: body1_text.copyWith(color: groupOnSurface),
          dropdownColor: surface,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: neopopAccent,
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Bottom sheet using [Theme.of(context).colorScheme.surface] (not neopop dark).
Future<T?> showAppThemedBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: groupSheetTopBorderRadiusXl,
    ),
    builder: builder,
  );
}
