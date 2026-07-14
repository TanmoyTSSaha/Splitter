import 'package:flutter/material.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/app_assets.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/shared.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Model/product_category_model.dart';
import 'package:splitr/Model/receipt_model.dart';
import 'package:splitr/Repository/personal_transaction_repository.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Screen/HomeScreen/widgets/personal_transaction_form_fields.dart';
import 'package:splitr/Services/budget_spend_service.dart';
import 'package:splitr/Services/currency_service.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Widgets/custom_big_text_form_field.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';
import 'package:uuid/uuid.dart';

class AddPersonalTransactionScreen extends StatefulWidget {
  final ReceiptData? receiptPrefill;

  const AddPersonalTransactionScreen({super.key, this.receiptPrefill});

  @override
  State<AddPersonalTransactionScreen> createState() =>
      _AddPersonalTransactionScreenState();
}

class _AddPersonalTransactionScreenState
    extends State<AddPersonalTransactionScreen> {
  final SupabaseDatabase _supabase = SupabaseDatabase();
  final PersonalTransactionRepository _personalRepo = Get.find();
  final String _userID = SupabaseAuth().supabaseGetUserID();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController otherCategoryController = TextEditingController();

  CategoryOnlyModel? selectedCategory;
  List<CategoryOnlyModel> categories = [];
  bool isLoading = true;
  String? _categoryError;
  DateTime selectedDate = DateTime.now();
  String selectedPaymentMethod = PaymentMethodDefaults.online;
  bool isOtherCategorySelected = false;
  bool _isIncome = false;
  bool _isSaving = false;

  final List<String> paymentMethods = kPersonalPaymentMethods;

  @override
  void initState() {
    super.initState();
    final prefill = widget.receiptPrefill;
    if (prefill != null) {
      if (prefill.total != null && prefill.total! > 0) {
        amountController.text = prefill.total!.toStringAsFixed(
          prefill.total! % 1 == 0 ? 0 : 2,
        );
      }
      if (prefill.merchantName != null && prefill.merchantName!.isNotEmpty) {
        descriptionController.text = prefill.merchantName!;
      }
      if (prefill.date != null) {
        selectedDate = prefill.date!;
      }
    }
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _categoryError = null;
      isLoading = true;
    });
    try {
      // Use TransactionService method but access via SupabaseDatabase (need to expose it or call directly)
      // SupabaseDatabase doesn't expose getPersonalCategories yet.
      // Assuming I'll update SupabaseDatabase too, or use TransactionService via SupabaseDatabase delegate.
      // For now, let's assume SupabaseDatabase has getPersonalCategoriesDelegate
      // Wait, I updated TransactionService but not SupabaseDatabase facade.
      // I should access TransactionService if possible, or update facade.
      // Let's assume I'll update the facade in next step.
      // For compilation safety, I can instantiate TransactionService directly here or update facade.
      // Let's use _supabase.getPersonalCategories if added, else TransactionService.

      // Update: I haven't added it to SupabaseDatabase facade yet.
      // I will do that in next step. For now I write this code assuming it exists.

      final fetched = await _supabase.getPersonalCategories(userID: _userID);
      var list = List<CategoryOnlyModel>.from(fetched);

      list.add(CategoryOnlyModel(
          category: CategoryDefaults.other,
          categoryLogo: AppUrls.dicebearInitials(CategoryDefaults.other)));
      list = ensurePersonalIncomeCategories(list);

      setState(() {
        categories = list;
        if (_isIncome) {
          selectedCategory = firstPersonalIncomeCategory(categories);
          isOtherCategorySelected = false;
        }
        isLoading = false;
      });
    } catch (e, stack) {
      AppErrorReporter.report(
        'Failed to fetch personal categories',
        error: e,
        stack: stack,
      );
      setState(() {
        _categoryError = AppStrings.errors.categoriesLoadFailed;
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
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
      if (DateUtils.isSameDay(picked, DateTime.now())) {
        // If today, keep current time
        setState(() {
          selectedDate = DateTime.now();
        });
      } else {
        // If other date, set to noon to avoid timezone shift issues or just keep midnight
        // Let's keep midnight as returned by picker
        setState(() {
          selectedDate = picked;
        });
      }
    }
  }

  void _saveTransaction() async {
    if (amountController.text.trim().isEmpty) {
      SplitrToast.show(AppStrings.home.enterAmount);
      return;
    }
    if (descriptionController.text.trim().isEmpty) {
      SplitrToast.show(AppStrings.home.enterDescription);
      return;
    }
    if (!_isIncome && selectedCategory == null) {
      SplitrToast.show(AppStrings.home.selectCategory);
      return;
    }

    String finalCategory = _resolveCategory();

    // Handle custom category (expense only).
    if (!_isIncome && isOtherCategorySelected) {
      final customName = otherCategoryController.text.trim();
      if (customName.isEmpty) {
        SplitrToast.show(AppStrings.home.enterCategoryName);
        return;
      }
      finalCategory = customName;

      await _supabase.addPersonalCustomCategory(
        categoryName: customName,
        iconSvgContent: AppUrls.dicebearInitials(customName),
        userID: _userID,
      );
    }

    try {
      setState(() => _isSaving = true);

      final currency = Get.find<CurrencyController>().code;
      double exchangeRate = CurrencyDefaults.exchangeRateToInr;
      try {
        exchangeRate = await CurrencyService().getExchangeRateToInr(currency);
      } catch (_) {
        // Offline or rate API unavailable — sync will use fallback rate.
      }
      final transactionId = const Uuid().v4();

      await _personalRepo.addTransaction(
        transactionId: transactionId,
        userId: _userID,
        amount: double.parse(amountController.text.trim()),
        description: descriptionController.text.trim(),
        category: finalCategory,
        date: selectedDate,
        paymentMethod: selectedPaymentMethod,
        currency: currency,
        exchangeRateToInr: exchangeRate,
        isCredit: _isIncome,
      );

      await reevaluateBudgetAlerts(_userID);

      Get.back(result: true);
      SplitrToast.show(AppStrings.home.transactionAdded);
    } catch (e, stack) {
      AppErrorReporter.reportActionFailure(
        AppStrings.home.transactionAddFailed,
        error: e,
        stack: stack,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _resolveCategory() {
    if (_isIncome) {
      final cat = selectedCategory?.category ?? CategoryDefaults.income;
      if (kPersonalIncomeCategories.contains(cat.toLowerCase())) return cat;
      return CategoryDefaults.income;
    }
    return selectedCategory?.category ?? CategoryDefaults.general;
  }

  void _onIncomeChanged(bool income) {
    setState(() {
      _isIncome = income;
      if (income) {
        categories = ensurePersonalIncomeCategories(categories);
        selectedCategory = firstPersonalIncomeCategory(categories);
        isOtherCategorySelected = false;
      } else if (selectedCategory != null &&
          kPersonalIncomeCategories
              .contains(selectedCategory!.category?.toLowerCase())) {
        selectedCategory = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: surface,
      appBar: SplitrDetailAppBar(
        title: _isIncome
            ? AppStrings.home.addPersonalIncome
            : AppStrings.home.addPersonalExpense,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(groupGutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomBigTextFormField(
              customBigTextFormFieldTextEditingController: amountController,
              autofocus: true,
              labelText: AppStrings.home.amount,
            ),
            const SizedBox(height: groupGapMd),
            CustomBigTextFormFieldWithPrefixIcon(
              customBigTextFormFieldTextEditingController:
                  descriptionController,
              hintText: AppStrings.home.whatFor,
              prefixIconString: AppAssets.iconNote,
              style: body1_text.copyWith(color: groupOnSurface),
            ),
            const SizedBox(height: groupGapMd),
            PersonalTransactionTypeToggle(
              isIncome: _isIncome,
              enabled: !_isSaving,
              onChanged: _onIncomeChanged,
            ),
            const SizedBox(height: groupGapMd),
            PersonalCategoryPicker(
              categories: categories,
              selected: selectedCategory,
              isIncome: _isIncome,
              loading: isLoading,
              errorMessage: _categoryError,
              enabled: !_isSaving,
              onRetry: _fetchCategories,
              onSelected: (cat) {
                setState(() {
                  selectedCategory = cat;
                  isOtherCategorySelected =
                      cat?.category == CategoryDefaults.other;
                });
              },
            ),
            if (isOtherCategorySelected) ...[
              const SizedBox(height: groupGapMd),
              CustomBigTextFormFieldWithPrefixIcon(
                customBigTextFormFieldTextEditingController:
                    otherCategoryController,
                hintText: AppStrings.home.categoryName,
                prefixIconString: AppAssets.iconTag,
                style: body1_text.copyWith(color: groupOnSurface),
              ),
            ],
            const SizedBox(height: groupGapLg),
            PersonalTransactionMetaRow(
              date: selectedDate,
              paymentMethod: selectedPaymentMethod,
              paymentMethods: paymentMethods,
              enabled: !_isSaving,
              onPickDate: () => _selectDate(context),
              onPaymentChanged: (v) =>
                  setState(() => selectedPaymentMethod = v),
            ),
            const SizedBox(height: groupGapLg),
            PersonalTransactionSaveButton(
              isIncome: _isIncome,
              loading: _isSaving,
              enabled: !_isSaving,
              onPressed: _saveTransaction,
            ),
            const SizedBox(height: groupGapXl),
          ],
        ),
      ),
    );
  }
}
