import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Controller/all_transactions_controller.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Utils/transaction_date_formatter.dart';
import 'package:splitr/Widgets/bordered_input_field.dart';

class TransactionFilterSheet extends StatefulWidget {
  final AllTransactionsController controller;

  const TransactionFilterSheet({super.key, required this.controller});

  static void show(BuildContext context, AllTransactionsController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: groupSheetTopBorderRadius,
      ),
      builder: (_) => TransactionFilterSheet(controller: controller),
    );
  }

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  late Set<String> _categories;
  late Set<String> _groupIds;
  late Set<String> _paymentMethods;
  late TextEditingController _minController;
  late TextEditingController _maxController;
  DateTime? _since;
  DateTime? _until;
  String? _dateError;
  String? _priceError;

  @override
  void initState() {
    super.initState();
    final c = widget.controller;
    _categories = Set<String>.from(c.selectedCategories);
    _groupIds = Set<String>.from(c.selectedGroupIds);
    _paymentMethods = Set<String>.from(c.selectedPaymentMethods);
    _minController = TextEditingController(
      text: c.minAmount.value?.toStringAsFixed(0) ?? '',
    );
    _maxController = TextEditingController(
      text: c.maxAmount.value?.toStringAsFixed(0) ?? '',
    );
    _since = c.customSince.value;
    _until = c.customUntil.value;
    _minController.addListener(_validate);
    _maxController.addListener(_validate);
    _validate();
  }

  @override
  void dispose() {
    _minController.removeListener(_validate);
    _maxController.removeListener(_validate);
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  DateTime get _today => TransactionDateFormatter.today;

  void _validate() {
    String? dateError;
    String? priceError;

    final hasFrom = _since != null;
    final hasTo = _until != null;

    if (hasFrom != hasTo) {
      dateError = AppStrings.home.filterDateBothRequired;
    } else if (hasFrom && hasTo) {
      final from = TransactionDateFormatter.startOfDay(_since!);
      final to = TransactionDateFormatter.startOfDay(_until!);

      if (from.isAfter(_today) || to.isAfter(_today)) {
        dateError = AppStrings.home.filterDateFuture;
      } else if (to.isBefore(from)) {
        dateError = AppStrings.home.filterDateOrder;
      }
    }

    final minText = _minController.text.trim();
    final maxText = _maxController.text.trim();
    final min = double.tryParse(minText);
    final max = double.tryParse(maxText);

    if (minText.isNotEmpty && min == null) {
      priceError = AppStrings.home.filterMinInvalid;
    } else if (maxText.isNotEmpty && max == null) {
      priceError = AppStrings.home.filterMaxInvalid;
    } else if (min != null && max != null && min > max) {
      priceError = AppStrings.home.filterMinMaxOrder;
    }

    setState(() {
      _dateError = dateError;
      _priceError = priceError;
    });
  }

  bool get _canApply => _dateError == null && _priceError == null;

  Future<void> _pickDate({required bool isFrom}) async {
    final today = _today;
    final initial = isFrom
        ? (_since ?? today.subtract(AppMotion.filterDefaultLookback))
        : (_until ?? _since ?? today);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(today) ? today : initial,
      firstDate: isFrom
          ? DateTime(TransactionDateBounds.filterMinYear)
          : (_since != null
              ? TransactionDateFormatter.startOfDay(_since!)
              : DateTime(TransactionDateBounds.filterMinYear)),
      lastDate: isFrom
          ? (_until != null && _until!.isBefore(today) ? _until! : today)
          : today,
    );
    if (picked == null) return;

    setState(() {
      if (isFrom) {
        _since = TransactionDateFormatter.startOfDay(picked);
      } else {
        _until = TransactionDateFormatter.startOfDay(picked);
      }
    });
    _validate();
  }

  void _applyPreset(Duration lookback) {
    final today = _today;
    setState(() {
      _since = today.subtract(lookback);
      _until = today;
    });
    _validate();
  }

  void _apply() {
    if (!_canApply) return;

    final minText = _minController.text.trim();
    final maxText = _maxController.text.trim();
    final min = minText.isEmpty ? null : double.tryParse(minText);
    final max = maxText.isEmpty ? null : double.tryParse(maxText);

    final hasCustomRange = _since != null && _until != null;

    widget.controller.applyFilters(
      categories: _categories,
      groupIds: _groupIds,
      paymentMethods: _paymentMethods,
      min: min,
      max: max,
      since: hasCustomRange ? _since : null,
      until: hasCustomRange ? _until : null,
      clearDateRange: !hasCustomRange &&
          (widget.controller.customSince.value != null ||
              widget.controller.customUntil.value != null),
    );
    Navigator.pop(context);
  }

  void _clearAll() {
    widget.controller.clearAllFilters();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final sym = Get.find<CurrencyController>().symbol;
    final categories = widget.controller.availableCategories;
    final groups = widget.controller.availableGroups;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: AppDimensions.filterSheetInitial,
      minChildSize: AppDimensions.filterSheetMin,
      maxChildSize: AppDimensions.filterSheetMax,
      builder: (context, scrollController) {
        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(groupGutter),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.home.filters,
                      style: headline3_text.copyWith(
                        fontFamily: kFontAlbra,
                        color: groupOnSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: _clearAll,
                      child: Text(
                        AppStrings.home.clearAll,
                        style: body2_text.copyWith(color: neopopAccent),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    groupGutter,
                    0,
                    groupGutter,
                    bottomInset + groupGutter,
                  ),
                  children: [
                    _sectionTitle(AppStrings.home.quickRange),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _presetChip(AppStrings.home.filterPresets7,
                            AppMotion.filterSevenDays),
                        _presetChip(AppStrings.home.filterPresets30,
                            AppMotion.filterThirtyDays),
                        _presetChip(AppStrings.home.filterPresets3Months,
                            AppMotion.filterNinetyDays),
                        _presetChip(AppStrings.home.filterPresets6Months,
                            AppMotion.filterOneEightyDays),
                        _presetChip(AppStrings.home.filterPresets12Months,
                            AppMotion.filterThreeSixtyFiveDays),
                      ],
                    ),
                    const SizedBox(height: groupGapMd),
                    _sectionTitle('${AppStrings.home.priceRange} ($sym)'),
                    Row(
                      children: [
                        Expanded(
                          child: BorderedInputField(
                            controller: _minController,
                            hintText: AppStrings.home.min,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: groupGapSm),
                        Expanded(
                          child: BorderedInputField(
                            controller: _maxController,
                            hintText: AppStrings.home.max,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    if (_priceError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: groupGapSm),
                        child: Text(
                          _priceError!,
                          style: caption_text.copyWith(
                            color: neopopError,
                            fontSize: splitrFontCaptionSm,
                          ),
                        ),
                      ),
                    const SizedBox(height: groupGapMd),
                    _sectionTitle(AppStrings.home.customDateRange),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _pickDate(isFrom: true),
                            child: Text(
                              _since != null
                                  ? '${_since!.day}/${_since!.month}/${_since!.year}'
                                  : AppStrings.home.from,
                              style: body2_text.copyWith(
                                color: groupOnSurface,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: groupGapSm),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _pickDate(isFrom: false),
                            child: Text(
                              _until != null
                                  ? '${_until!.day}/${_until!.month}/${_until!.year}'
                                  : AppStrings.home.to,
                              style: body2_text.copyWith(
                                color: groupOnSurface,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_dateError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: groupGapSm),
                        child: Text(
                          _dateError!,
                          style: caption_text.copyWith(
                            color: neopopError,
                            fontSize: splitrFontCaptionSm,
                          ),
                        ),
                      ),
                    const SizedBox(height: groupGapMd),
                    _sectionTitle(AppStrings.home.paymentMethod),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kPersonalPaymentMethods.map((method) {
                        final selected = _paymentMethods.contains(method);
                        return FilterChip(
                          label: Text(method),
                          selected: selected,
                          onSelected: (v) {
                            setState(() {
                              if (v) {
                                _paymentMethods.add(method);
                              } else {
                                _paymentMethods.remove(method);
                              }
                            });
                          },
                          selectedColor: neopopAccentFillStrong,
                          checkmarkColor: neopopAccent,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: groupGapMd),
                    _sectionTitle(AppStrings.home.category),
                    if (categories.isEmpty)
                      Text(
                        AppStrings.home.noCategoriesLoaded,
                        style:
                            caption_text.copyWith(color: groupOnSurfaceMuted),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categories.map((cat) {
                          final selected = _categories.contains(cat);
                          return FilterChip(
                            label: Text(cat),
                            selected: selected,
                            onSelected: (v) {
                              setState(() {
                                if (v) {
                                  _categories.add(cat);
                                } else {
                                  _categories.remove(cat);
                                }
                              });
                            },
                            selectedColor: neopopAccentFillStrong,
                            checkmarkColor: neopopAccent,
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: groupGapMd),
                    _sectionTitle(DisplayFallbacks.group),
                    if (groups.isEmpty)
                      Text(
                        AppStrings.home.noGroupsAvailable,
                        style:
                            caption_text.copyWith(color: groupOnSurfaceMuted),
                      )
                    else
                      ...groups.map((g) {
                        final id = g.groupID ?? '';
                        if (id.isEmpty) return const SizedBox.shrink();
                        return CheckboxListTile(
                          value: _groupIds.contains(id),
                          activeColor: neopopAccent,
                          title: Text(
                            g.groupName ?? DisplayFallbacks.unnamedGroup,
                            style: body2_text.copyWith(
                              color: groupOnSurface,
                            ),
                          ),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _groupIds.add(id);
                              } else {
                                _groupIds.remove(id);
                              }
                            });
                          },
                        );
                      }),
                    const SizedBox(height: groupGapMd),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  groupGutter,
                  0,
                  groupGutter,
                  groupGutter + bottomInset,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: neopopAccent,
                      foregroundColor: groupOnSurface,
                      disabledBackgroundColor: groupMutedBorder,
                      padding: const EdgeInsets.symmetric(vertical: groupGapMd),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(groupControlRadius),
                      ),
                    ),
                    onPressed: _canApply ? _apply : null,
                    child: Text(
                      AppStrings.actions.apply,
                      style: button_text.copyWith(color: groupOnSurface),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: groupGapSm),
      child: Text(
        text,
        style: body1_text.copyWith(
          color: groupOnSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _presetChip(String label, Duration lookback) {
    return ActionChip(
      label: Text(label),
      onPressed: () => _applyPreset(lookback),
      backgroundColor: groupMutedFillFaint,
      labelStyle: body2_text.copyWith(color: groupOnSurface),
    );
  }
}
