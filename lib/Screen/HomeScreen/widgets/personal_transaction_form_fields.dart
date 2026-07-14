import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splitr/Constants/app_assets.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Model/product_category_model.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

/// Ensures default personal income categories exist for the income picker.
List<CategoryOnlyModel> ensurePersonalIncomeCategories(
  List<CategoryOnlyModel> categories,
) {
  final result = List<CategoryOnlyModel>.from(categories);
  const defaults = <String, String>{
    'income': CategoryDefaults.income,
    'salary': 'Salary',
    'refund': 'Refund',
    'cashback': 'Cashback',
    'reimbursement': 'Reimbursement',
  };

  for (final entry in defaults.entries) {
    final exists = result.any(
      (c) => c.category?.toLowerCase() == entry.key,
    );
    if (!exists) {
      result.insert(
        0,
        CategoryOnlyModel(
          category: entry.value,
          categoryLogo: AppUrls.dicebearInitials(entry.value),
        ),
      );
    }
  }
  return result;
}

CategoryOnlyModel? firstPersonalIncomeCategory(
  List<CategoryOnlyModel> categories,
) {
  for (final cat in categories) {
    final key = cat.category?.toLowerCase() ?? '';
    if (kPersonalIncomeCategories.contains(key)) return cat;
  }
  return null;
}

class PersonalTransactionTypeToggle extends StatelessWidget {
  final bool isIncome;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  const PersonalTransactionTypeToggle({
    super.key,
    required this.isIncome,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _chip(
            label: AppStrings.home.personalExpense,
            selected: !isIncome,
            onTap: enabled ? () => onChanged(false) : null,
          ),
        ),
        const SizedBox(width: groupGapSm),
        Expanded(
          child: _chip(
            label: AppStrings.home.personalIncome,
            selected: isIncome,
            onTap: enabled ? () => onChanged(true) : null,
          ),
        ),
      ],
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(vertical: groupCarouselGap),
        decoration: BoxDecoration(
          color: selected ? neopopBackground : groupMutedFillFaint,
          borderRadius: BorderRadius.circular(groupControlRadius),
          border: Border.all(
            color: selected ? neopopBackground : groupMutedBorderHairline,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: body2_text.copyWith(
              color: selected ? neopopOnPrimary : groupOnSurface,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class PersonalCategoryPicker extends StatelessWidget {
  final List<CategoryOnlyModel> categories;
  final CategoryOnlyModel? selected;
  final bool isIncome;
  final bool loading;
  final String? errorMessage;
  final bool enabled;
  final VoidCallback? onRetry;
  final ValueChanged<CategoryOnlyModel?> onSelected;

  const PersonalCategoryPicker({
    super.key,
    required this.categories,
    required this.selected,
    required this.isIncome,
    required this.loading,
    this.errorMessage,
    this.enabled = true,
    this.onRetry,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.home.category,
          style: body1_text.copyWith(
            fontWeight: FontWeight.bold,
            color: groupOnSurface,
          ),
        ),
        const SizedBox(height: groupGapSm),
        if (loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(groupCarouselGap),
              child: CircularProgressIndicator(
                color: neopopAccent,
                strokeWidth: groupProgressStrokeWidth,
              ),
            ),
          )
        else if (errorMessage != null && categories.isEmpty)
          Column(
            children: [
              Text(
                errorMessage!,
                style: body2_text.copyWith(color: groupOnSurfaceMuted),
              ),
              if (onRetry != null)
                TextButton(
                  onPressed: enabled ? onRetry : null,
                  child: Text(
                    AppStrings.actions.tryAgain,
                    style: body2_text.copyWith(color: neopopAccent),
                  ),
                ),
            ],
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: categories.where((cat) {
              final key = cat.category?.toLowerCase() ?? '';
              if (isIncome) {
                return kPersonalIncomeCategories.contains(key);
              }
              return !kPersonalIncomeCategories.contains(key);
            }).map((cat) {
              final isSelected = selected == cat;
              return GestureDetector(
                onTap:
                    !enabled ? null : () => onSelected(isSelected ? null : cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? neopopBackground : groupMutedFillLight,
                    borderRadius: BorderRadius.circular(groupCardRadiusLg),
                    border: Border.all(
                      color: isSelected
                          ? neopopBackground
                          : groupMutedBorderHairline,
                    ),
                  ),
                  child: Text(
                    cat.category!,
                    style: body2_text.copyWith(
                      color: isSelected ? neopopOnPrimary : groupOnSurface,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class PersonalTransactionMetaRow extends StatelessWidget {
  final DateTime date;
  final String paymentMethod;
  final List<String> paymentMethods;
  final bool enabled;
  final VoidCallback onPickDate;
  final ValueChanged<String> onPaymentChanged;

  const PersonalTransactionMetaRow({
    super.key,
    required this.date,
    required this.paymentMethod,
    required this.paymentMethods,
    required this.onPickDate,
    required this.onPaymentChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final border = groupMutedBorderStrong;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: enabled ? onPickDate : null,
            child: Container(
              padding: const EdgeInsets.all(groupCarouselGap),
              decoration: BoxDecoration(
                border: Border.all(color: border),
                borderRadius: BorderRadius.circular(groupControlRadius),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: AppDimensions.groupIconMd, color: groupOnSurface),
                  const SizedBox(width: groupGapSm),
                  Text(
                    DateFormat(AppDateFormats.transactionPicker).format(date),
                    style: body1_text.copyWith(color: groupOnSurface),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: groupGapMd),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: groupCarouselGap),
            decoration: BoxDecoration(
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(groupControlRadius),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: paymentMethod,
                isExpanded: true,
                icon: Icon(Icons.payment,
                    size: AppDimensions.groupIconMd, color: groupOnSurface),
                items: paymentMethods
                    .map(
                      (v) => DropdownMenuItem(
                        value: v,
                        child: Text(
                          v,
                          style: body1_text.copyWith(color: groupOnSurface),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: enabled
                    ? (v) => onPaymentChanged(v ?? paymentMethod)
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PersonalTransactionSaveButton extends StatelessWidget {
  final bool isIncome;
  final bool loading;
  final bool enabled;
  final VoidCallback onPressed;
  final String? editLabel;

  const PersonalTransactionSaveButton({
    super.key,
    required this.isIncome,
    required this.loading,
    required this.onPressed,
    this.enabled = true,
    this.editLabel,
  });

  @override
  Widget build(BuildContext context) {
    final label = editLabel ??
        (isIncome ? AppStrings.home.saveIncome : AppStrings.home.saveExpense);
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.groupCtaHeight,
      child: ElevatedButton(
        onPressed: !enabled || loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: neopopAccent,
          disabledBackgroundColor: groupMutedBorder,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(groupControlRadius),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: AppDimensions.loadingIndicatorMd,
                height: AppDimensions.loadingIndicatorMd,
                child: CircularProgressIndicator(
                  strokeWidth: groupProgressStrokeWidth,
                  color: groupOnSurface,
                ),
              )
            : Text(
                label,
                style: button_text.copyWith(color: groupOnSurface),
              ),
      ),
    );
  }
}
