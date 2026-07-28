import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/app_assets.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Model/personal_budget_model.dart';
import 'package:splitr/Model/product_category_model.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Screen/HomeScreen/widgets/personal_transaction_form_fields.dart';
import 'package:splitr/Services/personal_budget_service.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/Constants/shared.dart';
import 'package:splitr/Widgets/bordered_input_field.dart';
import 'package:splitr/Widgets/splitr_toast.dart';

class BudgetEditorSheet extends StatefulWidget {
  final String userId;
  final List<PersonalBudget> existingBudgets;
  final PersonalBudget? existing;

  const BudgetEditorSheet({
    super.key,
    required this.userId,
    required this.existingBudgets,
    this.existing,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String userId,
    required List<PersonalBudget> existingBudgets,
    PersonalBudget? existing,
  }) {
    final surface = Theme.of(context).colorScheme.surface;
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: groupSheetTopBorderRadiusLg,
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: BudgetEditorSheet(
          userId: userId,
          existingBudgets: existingBudgets,
          existing: existing,
        ),
      ),
    );
  }

  @override
  State<BudgetEditorSheet> createState() => _BudgetEditorSheetState();
}

class _BudgetEditorSheetState extends State<BudgetEditorSheet> {
  final _supabase = SupabaseDatabase();
  final _service = PersonalBudgetService();
  final _limitCtrl = TextEditingController();
  final _otherCategoryCtrl = TextEditingController();

  List<CategoryOnlyModel> _categories = [];
  CategoryOnlyModel? _selectedCategory;
  bool _isOverall = false;
  bool _loadingCategories = true;
  String? _categoryError;
  String _period = BudgetDefaults.defaultPeriod;
  bool _includeGroupExpenses = true;
  bool _isOtherSelected = false;
  bool _saving = false;

  String get _sym => Get.find<CurrencyController>().symbol;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _isOverall = e.isOverall;
      _period = e.period;
      _includeGroupExpenses = e.includeGroupExpenses;
      _limitCtrl.text = e.limitAmount.toStringAsFixed(0);
    }
    _fetchCategories();
  }

  @override
  void dispose() {
    _limitCtrl.dispose();
    _otherCategoryCtrl.dispose();
    super.dispose();
  }

  Set<String> get _blockedCategoryKeys {
    final blocked = <String>{};
    for (final b in widget.existingBudgets) {
      if (widget.existing?.id == b.id) continue;
      if (b.period != _period) continue;
      if (b.isOverall) {
        blocked.add('__overall__');
      } else if (b.category != null) {
        blocked.add(b.category!.toLowerCase());
      }
    }
    return blocked;
  }

  List<CategoryOnlyModel> get _visibleCategories {
    final blocked = _blockedCategoryKeys;
    return _categories.where((cat) {
      final key = cat.category?.toLowerCase() ?? '';
      if (kPersonalIncomeCategories.contains(key)) return false;
      if (blocked.contains(key)) return false;
      return true;
    }).toList();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _categoryError = null;
      _loadingCategories = true;
    });
    try {
      final fetched =
          await _supabase.getPersonalCategories(userID: widget.userId);
      var list = List<CategoryOnlyModel>.from(fetched);
      list.add(CategoryOnlyModel(
        category: CategoryDefaults.other,
        categoryLogo: AppUrls.dicebearInitials(CategoryDefaults.other),
      ));

      CategoryOnlyModel? match;
      final e = widget.existing;
      if (e != null && !e.isOverall && e.category != null) {
        for (final c in list) {
          if (c.category?.toLowerCase() == e.category!.toLowerCase()) {
            match = c;
            break;
          }
        }
        if (match == null) {
          match = CategoryOnlyModel(
            category: e.category,
            categoryLogo: AppUrls.dicebearInitials(e.category!),
          );
          list.add(match);
        }
      }

      if (mounted) {
        setState(() {
          _categories = list;
          _loadingCategories = false;
          if (e != null) {
            _isOverall = e.isOverall;
            if (!e.isOverall) {
              _selectedCategory = match;
              _isOtherSelected =
                  match?.category == CategoryDefaults.other;
            }
          }
        });
      }
    } catch (e, stack) {
      AppErrorReporter.report(
        'BudgetEditorSheet: failed to load categories',
        error: e,
        stack: stack,
      );
      if (mounted) {
        setState(() {
          _categoryError = AppStrings.errors.categoriesLoadFailed;
          _loadingCategories = false;
        });
      }
    }
  }

  String _periodLabel(String period) {
    switch (period) {
      case BudgetPeriodValues.daily:
        return AppStrings.budget.periodDaily;
      case BudgetPeriodValues.weekly:
        return AppStrings.budget.periodWeekly;
      case BudgetPeriodValues.monthly:
        return AppStrings.budget.periodMonthly;
      case BudgetPeriodValues.quarterly:
        return AppStrings.budget.periodQuarterly;
      case BudgetPeriodValues.halfYearly:
        return AppStrings.budget.periodHalfYearly;
      case BudgetPeriodValues.yearly:
        return AppStrings.budget.periodYearly;
      default:
        return period;
    }
  }

  Future<void> _save() async {
    final limit = double.tryParse(_limitCtrl.text.trim());
    if (limit == null || limit <= 0) {
      SplitrToast.show(AppStrings.validation.validAmount);
      return;
    }

    if (!_isOverall && _selectedCategory == null) {
      SplitrToast.show(AppStrings.budget.selectCategory);
      return;
    }

    if (_isOverall && _blockedCategoryKeys.contains('__overall__')) {
      SplitrToast.show(AppStrings.budget.duplicateBudget);
      return;
    }

    String? category;
    if (!_isOverall) {
      if (_isOtherSelected) {
        final customName = _otherCategoryCtrl.text.trim();
        if (customName.isEmpty) {
          SplitrToast.show(AppStrings.home.enterCategoryName);
          return;
        }
        category = customName;
        await _supabase.addPersonalCustomCategory(
          categoryName: customName,
          iconSvgContent: AppUrls.dicebearInitials(customName),
          userID: widget.userId,
        );
      } else {
        category = _selectedCategory?.category;
      }
    }

    setState(() => _saving = true);
    try {
      await _service.upsertBudget(
        userId: widget.userId,
        id: widget.existing?.id,
        category: category,
        period: _period,
        limitAmount: limit,
        alertThreshold: widget.existing?.alertThreshold ?? 0.9,
        includeGroupExpenses: _includeGroupExpenses,
      );
      if (mounted) Navigator.pop(context, true);
    } on BudgetDuplicateException {
      SplitrToast.show(AppStrings.budget.duplicateBudget);
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        AppStrings.errors.loadBudgets,
        error: e,
        stack: stack,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _saving;
    final overallTaken = _blockedCategoryKeys.contains('__overall__') &&
        !(widget.existing?.isOverall ?? false);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          groupGutter,
          groupGapMd,
          groupGutter,
          groupGapLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: groupMutedBorderStrong,
                  borderRadius: BorderRadius.circular(groupRadiusHairline),
                ),
              ),
            ),
            const SizedBox(height: groupGapMd),
            Text(
              widget.existing == null
                  ? AppStrings.budget.addBudget
                  : AppStrings.budget.editBudget,
              style: headline3_text.copyWith(
                fontFamily: kFontAlbra,
                color: groupOnSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: groupGapLg),
            Text(
              AppStrings.budget.categoryLabel,
              style: body1_text.copyWith(
                fontWeight: FontWeight.bold,
                color: groupOnSurface,
              ),
            ),
            const SizedBox(height: groupGapSm),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (!overallTaken)
                  GestureDetector(
                    onTap: busy
                        ? null
                        : () => setState(() {
                              _isOverall = true;
                              _selectedCategory = null;
                              _isOtherSelected = false;
                            }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _isOverall
                            ? neopopBackground
                            : groupMutedFillLight,
                        borderRadius: BorderRadius.circular(groupCardRadiusLg),
                        border: Border.all(
                          color: _isOverall
                              ? neopopBackground
                              : groupMutedBorderHairline,
                        ),
                      ),
                      child: Text(
                        AppStrings.budget.overallChip,
                        style: body2_text.copyWith(
                          color:
                              _isOverall ? neopopOnPrimary : groupOnSurface,
                          fontWeight:
                              _isOverall ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (!_isOverall) ...[
              const SizedBox(height: groupGapSm),
              PersonalCategoryPicker(
                categories: _visibleCategories,
                selected: _selectedCategory,
                isIncome: false,
                loading: _loadingCategories,
                errorMessage: _categoryError,
                enabled: !busy,
                onRetry: _fetchCategories,
                onSelected: (cat) {
                  setState(() {
                    _isOverall = false;
                    _selectedCategory = cat;
                    _isOtherSelected = cat?.category == CategoryDefaults.other;
                  });
                },
              ),
              if (_isOtherSelected) ...[
                const SizedBox(height: groupGapMd),
                CustomBigTextFormFieldWithPrefixIcon(
                  customBigTextFormFieldTextEditingController: _otherCategoryCtrl,
                  hintText: AppStrings.home.categoryName,
                  prefixIconString: AppAssets.iconTag,
                  style: body1_text.copyWith(color: groupOnSurface),
                ),
              ],
            ],
            const SizedBox(height: groupGapLg),
            BorderedInputField(
              controller: _limitCtrl,
              labelText: AppStringFormat.budgetLimit(_sym),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: groupGapLg),
            Text(
              AppStrings.budget.periodLabel,
              style: body1_text.copyWith(
                fontWeight: FontWeight.bold,
                color: groupOnSurface,
              ),
            ),
            const SizedBox(height: groupGapSm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: BudgetPeriodValues.all.map((p) {
                final selected = _period == p;
                return ChoiceChip(
                  label: Text(_periodLabel(p)),
                  selected: selected,
                  onSelected: busy
                      ? null
                      : (_) {
                          setState(() {
                            _period = p;
                            if (_blockedCategoryKeys.contains('__overall__')) {
                              _isOverall = false;
                            }
                            final key =
                                _selectedCategory?.category?.toLowerCase();
                            if (key != null &&
                                _blockedCategoryKeys.contains(key)) {
                              _selectedCategory = null;
                              _isOtherSelected = false;
                            }
                          });
                        },
                );
              }).toList(),
            ),
            const SizedBox(height: groupGapMd),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                AppStrings.budget.includeGroupExpenses,
                style: body2_text.copyWith(color: groupOnSurface),
              ),
              value: _includeGroupExpenses,
              activeThumbColor: neopopAccent,
              onChanged: busy
                  ? null
                  : (v) => setState(() => _includeGroupExpenses = v),
            ),
            const SizedBox(height: groupGapLg),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: busy ? null : () => Navigator.pop(context, false),
                    child: Text(AppStrings.actions.cancel),
                  ),
                ),
                Expanded(
                  child: FilledButton(
                    onPressed: busy ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: neopopAccent,
                      foregroundColor: neopopBackground,
                    ),
                    child: busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: neopopBackground,
                            ),
                          )
                        : Text(AppStrings.actions.save),
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
