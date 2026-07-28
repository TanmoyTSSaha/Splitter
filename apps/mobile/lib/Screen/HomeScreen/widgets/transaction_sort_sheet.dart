import 'package:flutter/material.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Controller/all_transactions_controller.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Services/transaction_list_helper.dart';

class TransactionSortSheet extends StatelessWidget {
  final AllTransactionsController controller;

  const TransactionSortSheet({super.key, required this.controller});

  static void show(BuildContext context, AllTransactionsController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: groupSheetTopBorderRadius,
      ),
      builder: (_) => TransactionSortSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = controller.sortOption.value;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(groupGutter),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.home.sortBy,
              style: headline3_text.copyWith(
                fontFamily: kFontAlbra,
                color: groupOnSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: groupGapMd),
            ...TransactionSortOption.values.map((option) {
              return RadioListTile<TransactionSortOption>(
                value: option,
                groupValue: current,
                activeColor: neopopAccent,
                title: Text(
                  TransactionListHelper.sortLabel(option),
                  style: body1_text.copyWith(color: groupOnSurface),
                ),
                onChanged: (value) {
                  if (value == null) return;
                  controller.setSort(value);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
