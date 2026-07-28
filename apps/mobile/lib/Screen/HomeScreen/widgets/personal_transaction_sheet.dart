import 'package:flutter/material.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/app_assets.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/shared.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Model/product_category_model.dart';
import 'package:splitr/Repository/personal_transaction_repository.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Screen/HomeScreen/widgets/personal_transaction_form_fields.dart';
import 'package:splitr/Services/budget_spend_service.dart';
import 'package:splitr/Services/currency_service.dart';
import 'package:splitr/Services/personal_category_cache.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Widgets/custom_big_text_form_field.dart';

class PersonalTransactionSheet extends StatefulWidget {
  final Map<String, dynamic> txn;
  final VoidCallback? onChanged;

  const PersonalTransactionSheet({
    super.key,
    required this.txn,
    this.onChanged,
  });

  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> txn,
    VoidCallback? onChanged,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: groupSheetTopBorderRadiusLg,
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: PersonalTransactionSheet(txn: txn, onChanged: onChanged),
      ),
    );
  }

  @override
  State<PersonalTransactionSheet> createState() =>
      _PersonalTransactionSheetState();
}

class _PersonalTransactionSheetState extends State<PersonalTransactionSheet> {
  final PersonalTransactionRepository _repo = Get.find();
  final SupabaseDatabase _supabase = SupabaseDatabase();
  final String _userId = SupabaseAuth().supabaseGetUserID();

  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;

  List<CategoryOnlyModel> _categories = [];
  CategoryOnlyModel? _selectedCategory;
  bool _loadingCategories = true;
  String? _categoryError;
  bool _isSaving = false;
  bool _isDeleting = false;
  late DateTime _selectedDate;
  late String _paymentMethod;
  late bool _isIncome;

  final List<String> _paymentMethods = kPersonalPaymentMethods;

  @override
  void initState() {
    super.initState();
    final rawAmount =
        widget.txn['raw_amount'] as num? ?? widget.txn['amount'] as num? ?? 0;
    _amountController =
        TextEditingController(text: rawAmount.toStringAsFixed(0));
    _descriptionController = TextEditingController(
      text: widget.txn['title']?.toString() ?? '',
    );
    _selectedDate = widget.txn['date'] as DateTime? ?? DateTime.now();
    _paymentMethod = widget.txn['payment_method']?.toString() ??
        PaymentMethodDefaults.online;
    _isIncome = widget.txn['is_credit'] as bool? ?? false;
    _fetchCategories();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _loadingCategories = true;
      _categoryError = null;
    });

    List<CategoryOnlyModel> cats;
    try {
      final fetched = await _supabase.getPersonalCategories(userID: _userId);
      cats = List<CategoryOnlyModel>.from(fetched);
    } catch (e, stack) {
      AppErrorReporter.report(
        'Failed to fetch personal categories',
        error: e,
        stack: stack,
      );
      final cached = await PersonalCategoryCache().load();
      if (cached == null || cached.isEmpty) {
        if (mounted) {
          setState(() {
            _loadingCategories = false;
            _categoryError = AppStrings.errors.categoriesLoadFailed;
          });
        }
        return;
      }
      cats = List<CategoryOnlyModel>.from(cached);
    }

    cats.add(CategoryOnlyModel(
      category: CategoryDefaults.other,
      categoryLogo: AppUrls.dicebearInitials(CategoryDefaults.other),
    ));
    cats = ensurePersonalIncomeCategories(cats);

    CategoryOnlyModel? match;
    final currentCat = widget.txn['category']?.toString() ?? '';
    for (final c in cats) {
      if (c.category?.toLowerCase() == currentCat.toLowerCase()) {
        match = c;
        break;
      }
    }

    if (mounted) {
      setState(() {
        _categories = cats;
        _selectedCategory = match;
        _loadingCategories = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(TransactionDateBounds.minYear),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: neopopBackground,
              onPrimary: neopopOnPrimary,
              onSurface: neopopBackground,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateUtils.isSameDay(picked, DateTime.now())
            ? DateTime.now()
            : picked;
      });
    }
  }

  String _resolveCategory() {
    if (_isIncome) {
      final cat = _selectedCategory?.category ?? CategoryDefaults.income;
      if (kPersonalIncomeCategories.contains(cat.toLowerCase())) return cat;
      return CategoryDefaults.income;
    }
    return _selectedCategory?.category ?? CategoryDefaults.general;
  }

  Future<void> _save() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      SplitrToast.show(AppStrings.home.enterAmount);
      return;
    }
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      SplitrToast.show(AppStrings.validation.validAmount);
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      SplitrToast.show(AppStrings.home.enterDescription);
      return;
    }
    if (!_isIncome && _selectedCategory == null) {
      SplitrToast.show(AppStrings.home.selectCategory);
      return;
    }

    final transactionId = widget.txn['id'] as String?;
    if (transactionId == null) {
      SplitrToast.show(AppStrings.home.cannotEditTransaction);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final currency = widget.txn['currency']?.toString() ??
          Get.find<CurrencyController>().code;
      double exchangeRate = CurrencyDefaults.exchangeRateToInr;
      try {
        exchangeRate = await CurrencyService().getExchangeRateToInr(currency);
      } catch (_) {}

      await _repo.updateTransaction(
        transactionId: transactionId,
        userId: _userId,
        amount: amount,
        description: _descriptionController.text.trim(),
        category: _resolveCategory(),
        date: _selectedDate,
        paymentMethod: _paymentMethod,
        currency: currency,
        exchangeRateToInr: exchangeRate,
        isCredit: _isIncome,
      );

      await reevaluateBudgetAlerts(_userId);

      if (mounted) {
        Navigator.of(context).pop();
        widget.onChanged?.call();
        SplitrToast.show(AppStrings.home.transactionUpdated);
      }
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        AppStrings.home.transactionUpdateFailed,
        error: e,
        stack: stack,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final transactionId = widget.txn['id'] as String?;
    if (transactionId == null) {
      SplitrToast.show(AppStrings.home.cannotDeleteTransaction);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: neopopYellow,
        title: Text(AppStrings.home.deleteTransactionTitle,
            style: sub_headline5_text.copyWith(color: neopopBackground)),
        content: Text(
          AppStrings.home.deleteTransactionConfirm,
          style: caption_text.copyWith(color: neopopBackground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.actions.cancel,
                style: button_text.copyWith(color: neopopBackground)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.actions.delete,
                style: button_text.copyWith(color: neopopError)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await _repo.deleteTransaction(transactionId: transactionId);
      if (mounted) {
        Navigator.of(context).pop();
        widget.onChanged?.call();
        SplitrToast.show(AppStrings.home.transactionDeleted);
      }
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        AppStrings.home.transactionDeleteFailed,
        error: e,
        stack: stack,
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  void _onIncomeChanged(bool income) {
    setState(() {
      _isIncome = income;
      if (income) {
        _categories = ensurePersonalIncomeCategories(_categories);
        _selectedCategory = firstPersonalIncomeCategory(_categories);
      } else if (_selectedCategory != null &&
          kPersonalIncomeCategories
              .contains(_selectedCategory!.category?.toLowerCase())) {
        _selectedCategory = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final busy = _isSaving || _isDeleting;

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
                width: AppDimensions.sheetDragHandleWidth,
                height: AppDimensions.sheetDragHandleHeight,
                decoration: BoxDecoration(
                  color: groupMutedBorderStrong,
                  borderRadius: BorderRadius.circular(groupRadiusHairline),
                ),
              ),
            ),
            const SizedBox(height: groupGapMd),
            Text(
              AppStrings.home.editTransaction,
              style: headline3_text.copyWith(
                fontFamily: kFontAlbra,
                color: groupOnSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: groupGapLg),
            CustomBigTextFormField(
              customBigTextFormFieldTextEditingController: _amountController,
              labelText: AppStrings.home.amount,
            ),
            const SizedBox(height: groupGapMd),
            CustomBigTextFormFieldWithPrefixIcon(
              customBigTextFormFieldTextEditingController:
                  _descriptionController,
              hintText: AppStrings.home.whatFor,
              prefixIconString: AppAssets.iconNote,
              style: body1_text.copyWith(color: groupOnSurface),
            ),
            const SizedBox(height: groupGapMd),
            PersonalTransactionTypeToggle(
              isIncome: _isIncome,
              enabled: !busy,
              onChanged: _onIncomeChanged,
            ),
            const SizedBox(height: groupGapMd),
            PersonalCategoryPicker(
              categories: _categories,
              selected: _selectedCategory,
              isIncome: _isIncome,
              loading: _loadingCategories,
              errorMessage: _categoryError,
              enabled: !busy,
              onRetry: _fetchCategories,
              onSelected: (cat) => setState(() => _selectedCategory = cat),
            ),
            const SizedBox(height: groupGapLg),
            PersonalTransactionMetaRow(
              date: _selectedDate,
              paymentMethod: _paymentMethod,
              paymentMethods: _paymentMethods,
              enabled: !busy,
              onPickDate: _pickDate,
              onPaymentChanged: (v) => setState(() => _paymentMethod = v),
            ),
            const SizedBox(height: groupGapLg),
            PersonalTransactionSaveButton(
              isIncome: _isIncome,
              loading: _isSaving,
              enabled: !busy,
              editLabel: AppStrings.actions.saveChanges,
              onPressed: _save,
            ),
            const SizedBox(height: groupGapMd),
            SizedBox(
              height: groupCtaHeightCompact,
              child: OutlinedButton.icon(
                onPressed: busy ? null : _confirmDelete,
                icon: _isDeleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: groupProgressStrokeWidth,
                          color: neopopError,
                        ),
                      )
                    : const Icon(Icons.delete_outline, color: neopopError),
                label: Text(
                  AppStrings.actions.deleteTransaction,
                  style: body1_text.copyWith(color: neopopError),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: neopopError),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(groupControlRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
