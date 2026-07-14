import 'package:flutter/material.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/shared.dart';
import 'package:splitr/Controller/add_transaction_controller.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Screen/GroupScreen/receipt_scanner_screen.dart';
import 'package:splitr/Widgets/hero_amount_field.dart';
import 'package:splitr/Widgets/premium_gate.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Screen/GroupScreen/share_distribution_screen.dart';
import 'package:splitr/Repository/group_repository.dart';
import 'package:splitr/Repository/transaction_repository.dart';
import 'package:splitr/Services/reminder_trigger_helper.dart';
import 'package:splitr/Widgets/user_avatar.dart';

import '../../Constants/constants.dart';
import '../../Constants/category_style.dart';
import '../../Model/group_model.dart';
import 'package:splitr/Model/product_category_model.dart';
import 'package:splitr/Model/wishlist_prefill.dart';
import 'package:splitr/Services/wishlist_service.dart';
import 'package:splitr/Utils/expense_split_calculator.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/Widgets/splitr_inline_error.dart';
import 'package:splitr/Constants/app_assets.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Utils/transaction_date_formatter.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends StatefulWidget {
  final String userID;
  final Map<String, dynamic>? groupDetails;
  final List<GroupMembersWithNameModel> groupMembersDetails;
  const AddTransactionScreen({
    required this.userID,
    this.groupDetails,
    required this.groupMembersDetails,
    this.transactionToEdit,
    this.wishlistPrefill,
    super.key,
  });

  final ConsolidatedGroupTransactionModel? transactionToEdit;
  final WishlistPrefill? wishlistPrefill;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String? selectedGroupId;
  String? selectedPayerId;
  Map<String, dynamic>? selectedValue;
  final _formKey = GlobalKey<FormState>();
  TextEditingController notesTextEditingController = TextEditingController();
  TextEditingController expenseTextEditingController = TextEditingController();
  TextEditingController descriptionTextEditingController =
      TextEditingController();
  TextEditingController otherCategoryController = TextEditingController();

  String selectedCategory = CategoryDefaults.general;
  bool isOtherCategorySelected = false;
  DateTime selectedTransactionDate =
      TransactionDateFormatter.nowForTransaction();
  Future<List<CategoryOnlyModel>>? _categoriesFuture;
  Future<List<Map<String, dynamic>>>? _groupsFuture;

  @override
  void initState() {
    selectedGroupId = widget.groupDetails != null
        ? widget.groupDetails![UnifiedTxnKeys.groupId]
        : null;

    // Initialize controller — reset when opening from wishlist to avoid stale splits
    if (widget.wishlistPrefill != null &&
        Get.isRegistered<AddTransactionScreenController>()) {
      Get.delete<AddTransactionScreenController>();
    }
    final controller = Get.put(AddTransactionScreenController());

    if (widget.transactionToEdit != null) {
      // PRE-FILL DATA FOR EDITING
      expenseTextEditingController.text =
          widget.transactionToEdit!.totalTransactionAmount.toString();
      descriptionTextEditingController.text =
          widget.transactionToEdit!.description ?? "";
      selectedCategory =
          widget.transactionToEdit!.category ?? CategoryDefaults.general;
      selectedPayerId = widget.transactionToEdit!.paidByUUID ?? widget.userID;
      selectedTransactionDate = widget.transactionToEdit!.transactionDate ??
          TransactionDateFormatter.nowForTransaction();

      // Load split details into controller
      controller.loadTransaction(
          widget.transactionToEdit!, widget.groupMembersDetails);
    } else if (widget.wishlistPrefill != null) {
      final prefill = widget.wishlistPrefill!;
      descriptionTextEditingController.text = prefill.description;
      if (prefill.estimatedAmount != null) {
        expenseTextEditingController.text =
            prefill.estimatedAmount!.toStringAsFixed(2);
      }
      selectedPayerId = widget.userID;
      controller.applyEvenSplitForAllMembers(
        widget.groupMembersDetails,
        totalAmount: prefill.estimatedAmount,
        wishlistItemId: prefill.wishlistItemId,
      );
    } else {
      selectedPayerId = widget.userID;
    }

    _categoriesFuture = Get.find<TransactionRepository>()
        .getProductCategories(widget.groupDetails?[UnifiedTxnKeys.groupId]);

    _groupsFuture =
        Get.find<GroupRepository>().getDistinctGroups(widget.userID);

    super.initState();
  }

  Future<void> _selectTransactionDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedTransactionDate,
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
    if (picked == null || !mounted) return;

    setState(() {
      if (DateUtils.isSameDay(picked, DateTime.now())) {
        selectedTransactionDate = TransactionDateFormatter.nowForTransaction();
      } else {
        selectedTransactionDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          selectedTransactionDate.hour,
          selectedTransactionDate.minute,
        );
      }
    });
  }

  Future<void> _selectTransactionTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedTransactionDate),
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
    if (picked == null || !mounted) return;

    setState(() {
      selectedTransactionDate = DateTime(
        selectedTransactionDate.year,
        selectedTransactionDate.month,
        selectedTransactionDate.day,
        picked.hour,
        picked.minute,
      );
      if (selectedTransactionDate.isAfter(DateTime.now())) {
        selectedTransactionDate = TransactionDateFormatter.nowForTransaction();
      }
    });
  }

  Widget _buildTransactionDateTimeRow() {
    final border = groupMutedBorderStrong;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _selectTransactionDate(context),
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
                  Expanded(
                    child: Text(
                      DateFormat(AppDateFormats.transactionPicker)
                          .format(selectedTransactionDate),
                      style: body1_text.copyWith(color: groupOnSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: groupGapMd),
        Expanded(
          child: GestureDetector(
            onTap: () => _selectTransactionTime(context),
            child: Container(
              padding: const EdgeInsets.all(groupCarouselGap),
              decoration: BoxDecoration(
                border: Border.all(color: border),
                borderRadius: BorderRadius.circular(groupControlRadius),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time,
                      size: AppDimensions.groupIconMd, color: groupOnSurface),
                  const SizedBox(width: groupGapSm),
                  Expanded(
                    child: Text(
                      TransactionDateFormatter.formatTime(
                          selectedTransactionDate),
                      style: body1_text.copyWith(color: groupOnSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Form(
        key: _formKey,
        child: GestureDetector(
          onTap: () {
            setState(() {
              FocusManager.instance.primaryFocus!.unfocus();
            });
          },
          child: Scaffold(
            backgroundColor: surface,
            appBar: SplitrDetailAppBar(
              title: widget.transactionToEdit != null
                  ? AppStrings.groups.editTransaction
                  : AppStrings.groups.addTransaction,
              actions: [
                IconButton(
                  onPressed: () async {
                    if (selectedGroupId == null) {
                      SplitrToast.show(AppStrings.validation.selectGroupFirst);
                      return;
                    }
                    final allowed = await requirePremium(
                      featureLabel: AppStrings.groups.featureAiReceiptScanning);
                    if (!allowed) return;
                    Get.to(() => ReceiptScannerScreen(
                          groupID: selectedGroupId!,
                          members: widget.groupMembersDetails,
                          onTransactionCreated:
                              (category, amount, description, memberShares) {
                            setState(() {
                              selectedCategory = category;
                              expenseTextEditingController.text =
                                  amount.toStringAsFixed(2);
                              descriptionTextEditingController.text =
                                  description;
                            });
                            Get.find<AddTransactionScreenController>()
                                .applyReceiptScan(
                              category: category,
                              amount: amount,
                              description: description,
                              splits: memberShares,
                            );
                          },
                        ));
                  },
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                    color: groupOnSurface,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (selectedGroupId == null) {
                        SplitrToast.show(AppStrings.validation.selectGroup);
                        return;
                      }

                      // Logic to add expense
                      try {
                        Get.dialog(const LoadingWidget(),
                            barrierDismissible: false);

                        // Default to Even Split if no other mode logic is active/visible
                        // Use controller to get selected members
                        int totalMembers = widget.groupMembersDetails.length;
                        final controller =
                            Get.find<AddTransactionScreenController>();

                        String descriptionToCheck =
                            descriptionTextEditingController.text.trim();
                        // Notes are now passed separately
                        String notes = notesTextEditingController.text.trim();

                        double totalAmount =
                            double.parse(expenseTextEditingController.text);
                        Map<String, double> splits = {};
                        String sharingType = SharingTypeValues.evenly;

                        if (controller.receiptPrefilledSplits != null) {
                          splits = Map.from(controller.receiptPrefilledSplits!);
                          sharingType = SharingTypeValues.byItem;
                          controller.clearReceiptPrefill();
                        } else {
                          int currentTabIndex =
                              controller.currentTabIndex.value;
                          sharingType =
                              controller.sharingTypeForTab(currentTabIndex);

                          final validationError = controller.validateSplit(
                            tabIndex: currentTabIndex,
                            totalAmount: totalAmount,
                          );
                          if (validationError != null) {
                            Get.back();
                            SplitrToast.show(validationError);
                            return;
                          }

                          // SPLIT LOGIC BASED ON TAB
                          if (currentTabIndex == 0) {
                            // EVENLY
                            // Ensure controller has data (if not visited tabs)
                            if (controller.checkBoxBool.isEmpty ||
                                controller.checkBoxBool.length !=
                                    totalMembers) {
                              controller.addAllCheckBoxValue(totalMembers);
                              controller.involvedPersons.value = totalMembers;
                            }

                            List<String> involvedUserIDs = [];
                            for (int i = 0; i < totalMembers; i++) {
                              if (controller.checkBoxBool[i].value) {
                                involvedUserIDs
                                    .add(widget.groupMembersDetails[i].userID!);
                              }
                            }

                            if (involvedUserIDs.isEmpty) {
                              Get.back(); // Close loading
                              SplitrToast.show(AppStrings
                                      .validation.selectPersonToSplit);
                              return;
                            }

                            splits = ExpenseSplitCalculator.evenSplit(
                              totalAmount: totalAmount,
                              involvedUserIds: involvedUserIDs,
                            );
                          } else if (currentTabIndex == 1) {
                            splits = ExpenseSplitCalculator.unevenSplit(
                              controller.userAndSplitDetails,
                            );
                          } else if (currentTabIndex == 2) {
                            splits = ExpenseSplitCalculator.percentageSplit(
                              totalAmount: totalAmount,
                              percentageSplitDetails:
                                  controller.percentageSplitDetails,
                            );
                          } else if (currentTabIndex == 3) {
                            splits = ExpenseSplitCalculator.sharesSplit(
                              totalAmount: totalAmount,
                              totalShares: controller.totalShares.value,
                              sharesSplitDetails: controller.sharesSplitDetails,
                            );
                          } else if (currentTabIndex == 4) {
                            splits = ExpenseSplitCalculator.byItemSplit(
                              controller.itemSplitDetails,
                            );
                          }
                        }

                        if (splits.isEmpty &&
                            sharingType != SharingTypeValues.evenly) {
                          // If splits are empty (and not default even split where we already checked involvedUserIDs),
                          // it means user didn't assign anything in other tabs.
                          // OR calculation resulted in 0.
                          // We might want to warn?
                          // For now, let's proceed, maybe it's a "paid for self" scenario if splits is empty?
                          // But usually in split app, you want to split.
                        }

                        String finalCategory = selectedCategory;

                        // Handle CategoryDefaults.other category
                        if (isOtherCategorySelected) {
                          final customCategoryName =
                              otherCategoryController.text.trim();
                          if (customCategoryName.isNotEmpty) {
                            finalCategory = customCategoryName;
                            // Add custom category to DB
                            // Note: In a real app, you might want to check if it already exists to avoid dupes
                            // or simple handle it in the backend.
                            // For now, we add it. The FutureBuilder won't refresh immediately without setState logic or re-fetching
                            // but the transaction will be saved with the new category.
                            await Get.find<TransactionRepository>()
                                .addCustomCategory(
                              groupId: selectedGroupId!,
                              categoryName: customCategoryName,
                              iconSvgContent:
                                  AppUrls.dicebearInitials(customCategoryName),
                              userId: widget.userID,
                            );
                          } else {
                            // If user selected CategoryDefaults.other but typed nothing, default to CategoryDefaults.general or warn?
                            // Let's warn.
                            Get.back(); // Close loading
                            SplitrToast.show(AppStrings.home.enterCategoryName);
                            return;
                          }
                        }

                        if (widget.transactionToEdit != null) {
                          // If editing, delete old transaction first
                          // We use the same flow: Delete -> Add New
                          // Ideally, we should wrap this in a transaction or use an 'update' RPC,
                          // but for now we follow the "Delete & Re-Add" pattern.
                          await Get.find<TransactionRepository>()
                              .deleteGroupTransaction(
                            transactionGroupID:
                                widget.transactionToEdit!.transactionGroupID!,
                            groupID: selectedGroupId!,
                          );
                        }

                        await Get.find<TransactionRepository>().addGroupExpense(
                          groupID: selectedGroupId!,
                          paidByUserID: selectedPayerId ?? widget.userID,
                          totalAmount: totalAmount,
                          description: descriptionToCheck,
                          category: finalCategory,
                          splits: splits,
                          currency: Get.find<CurrencyController>().code,
                          note: notes.isNotEmpty ? notes : null,
                          sharingType: sharingType,
                          transactionDate: selectedTransactionDate,
                        );

                        final memberNames = {
                          for (final m in widget.groupMembersDetails)
                            m.userID!: m.userName ?? DisplayFallbacks.member,
                        };
                        await ReminderTriggerHelper.onExpenseAdded(
                          groupId: selectedGroupId!,
                          groupName:
                              widget.groupDetails?[SupabaseColumns.groupName] ??
                                  DisplayFallbacks.group,
                          splits: splits,
                          memberNames: memberNames,
                          payerUserId: selectedPayerId ?? widget.userID,
                        );

                        final wishlistItemId =
                            widget.wishlistPrefill?.wishlistItemId ??
                                controller.pendingWishlistItemId;
                        if (wishlistItemId != null) {
                          await WishlistService()
                              .markAsAdded(itemId: wishlistItemId);
                          controller.clearPendingWishlistItem();
                        }

                        Get.back(); // Close loading
                        Get.back(); // Close screen
                        SplitrToast.show(widget.transactionToEdit != null
                              ? AppStrings.groups.transactionUpdated
                              : AppStrings.groups.splitAdded);
                      } catch (e, stack) {
                        Get.back(); // Close loading
                        AppErrorReporter.reportActionFailure(
                          AppStrings.home.transactionAddFailed,
                          error: e,
                          stack: stack,
                        );
                      }
                    }
                  },
                  icon: const Icon(
                    Icons.check_rounded,
                    color: groupOnSurface,
                  ),
                ),
              ],
            ),
            body: FutureBuilder<List<Map<String, dynamic>>>(
              future: _groupsFuture,
              builder: (context, distinctGroupSnapshot) {
                if (distinctGroupSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  // Show a loading indicator while fetching data
                  return const LoadingWidget();
                } else if (distinctGroupSnapshot.hasError) {
                  return SplitrInlineError(
                    message: AppErrorReporter.inlineMessage(
                      distinctGroupSnapshot.error,
                      fallback: AppStrings.errors.loadHumorous,
                    ),
                  );
                } else if (!distinctGroupSnapshot.hasData ||
                    distinctGroupSnapshot.data!.isEmpty) {
                  // Show a message if no data is returned
                  return Text(AppStrings.groups.noDataAvailable);
                } else {
                  // Build the dropdown menu with the fetched data
                  final dropdownItems = distinctGroupSnapshot.data!;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(groupGutter),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButton<String>(
                          hint: Text(
                            AppStrings.groups.selectAGroup,
                            style:
                                body1_text.copyWith(color: groupOnSurfaceMuted),
                          ),
                          value: selectedGroupId,
                          dropdownColor: groupCardFill,
                          icon: const Icon(Icons.arrow_drop_down,
                              color: groupOnSurface),
                          style: body1_text.copyWith(color: groupOnSurface),
                          items: dropdownItems.map((item) {
                            return DropdownMenuItem<String>(
                              value: item[UnifiedTxnKeys
                                  .groupId], // Use `group_id` as the unique value
                              child: Text(
                                item[SupabaseColumns.groupName] ??
                                    DisplayFallbacks.unknownUser,
                                style:
                                    body1_text.copyWith(color: groupOnSurface),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              selectedGroupId =
                                  value; // Update only the `group_id`
                            });
                          },
                        ),
                        const SizedBox(height: groupGapMd),

                        // Paid By Dropdown
                        Text(AppStrings.groups.paidBy,
                            style:
                                body2_text.copyWith(color: neopopBackground)),
                        SizedBox(height: groupGap10),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: groupGap10),
                          decoration: BoxDecoration(
                            border: Border.all(color: neopopGrey),
                            borderRadius: BorderRadius.circular(groupRadiusMd),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedPayerId,
                              isExpanded: true,
                              dropdownColor: groupCardFill,
                              style: body1_text.copyWith(color: groupOnSurface),
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: groupOnSurface),
                              items: widget.groupMembersDetails.map((member) {
                                return DropdownMenuItem<String>(
                                  value: member.userID,
                                  child: Row(
                                    children: [
                                      UserAvatar(
                                        userID: member.userID ?? "",
                                        userName: member.userName ??
                                            DisplayFallbacks.user,
                                        imageUrl: member.userPic,
                                        radius: groupGap10 * 1.5,
                                      ),
                                      SizedBox(width: groupGap10),
                                      Text(
                                        member.userID == widget.userID
                                            ? GroupCopy.self
                                            : member.userName ??
                                                DisplayFallbacks.unknownUser,
                                        style: body1_text.copyWith(
                                            color: groupOnSurface),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedPayerId = newValue;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: groupGapMd),

                        // NEED TO ADD VALIDATOR IN EACH TEXT FORM FIELD
                        CustomTextFormFieldWithPrefixIcon(
                          customTextFormFieldTextEditingController:
                              descriptionTextEditingController,
                          keyboardType: TextInputType.text,
                          hintText: AppStrings.groups.writeDescription,
                          prefixIconString: AppAssets.iconBill,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              SplitrToast.show(AppStrings.validation.descriptionRequired);
                              return AppStrings.validation.descriptionRequired;
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: groupGapMd),
                        HeroAmountField(
                          controller: expenseTextEditingController,
                          hintText: AppAmountHints.decimal,
                          validator: (value) {
                            if (value != null && GetUtils.isNum(value)) {
                              return null;
                            } else if (value == null || value.isEmpty) {
                              SplitrToast.show(AppStrings.validation.needAmount);
                              return AppStrings.validation.needAmount;
                            } else if (!GetUtils.isNum(value)) {
                              SplitrToast.show(AppStrings.validation.numbersOnly);
                              return AppStrings.validation.numbersOnly;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: groupGapMd),

                        // Category Selector
                        Text(
                          AppStrings.groups.category,
                          style: body2_text.copyWith(color: neopopBackground),
                        ),
                        SizedBox(height: groupGap10),
                        FutureBuilder<List<CategoryOnlyModel>>(
                          future: _categoriesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Text(
                                  AppStrings.groups.errorLoadingCategories);
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Text(AppStrings.groups.noCategoriesFound);
                            }

                            final categories = snapshot.data!;
                            final hasOther = categories.any(
                              (c) =>
                                  c.category?.toLowerCase().trim() ==
                                  CategoryDefaults.other.toLowerCase(),
                            );
                            final allCategories = [
                              ...categories,
                              if (!hasOther)
                                CategoryOnlyModel(
                                  category: CategoryDefaults.other,
                                  categoryLogo: AppUrls.iconifyMoreHoriz,
                                ),
                            ];

                            return SizedBox(
                              height: groupGap10 * 10,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: allCategories.length,
                                itemBuilder: (context, index) {
                                  final cat = allCategories[index];
                                  final isOther =
                                      cat.category?.toLowerCase().trim() ==
                                          CategoryDefaults.other.toLowerCase();
                                  final isSelected = isOtherCategorySelected
                                      ? isOther
                                      : cat.category == selectedCategory;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (cat.category
                                                ?.toLowerCase()
                                                .trim() ==
                                            CategoryDefaults.other
                                                .toLowerCase()) {
                                          isOtherCategorySelected = true;
                                          selectedCategory =
                                              ''; // Clear for custom input
                                        } else {
                                          isOtherCategorySelected = false;
                                          selectedCategory = cat.category!;
                                        }
                                      });
                                    },
                                    child: Container(
                                      margin:
                                          EdgeInsets.only(right: groupGutter),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: groupGap10 * 5,
                                            width: groupGap10 * 5,
                                            padding: EdgeInsets.all(groupGap10),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? neopopAccent
                                                  : groupChipTrackBg,
                                              shape: BoxShape.circle,
                                              border: isSelected
                                                  ? Border.all(
                                                      color: neopopBackground,
                                                      width: 2)
                                                  : null,
                                            ),
                                            child: buildCategoryLogo(
                                              categoryLogo: cat.categoryLogo,
                                              category: cat.category ?? '',
                                              color: isSelected
                                                  ? neopopBackground
                                                  : neopopAccent,
                                              size: groupGap10 * 2.5,
                                            ),
                                          ),
                                          const SizedBox(height: groupGapSm),
                                          Text(
                                            cat.category ?? "",
                                            style: caption_text.copyWith(
                                              color: isSelected
                                                  ? neopopAccent
                                                  : neopopGrey,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        if (isOtherCategorySelected) ...[
                          const SizedBox(height: groupGapMd),
                          CustomTextFormFieldWithPrefixIcon(
                            customTextFormFieldTextEditingController:
                                otherCategoryController,
                            keyboardType: TextInputType.text,
                            hintText: AppStrings.groups.customCategoryNameHint,
                            prefixIconString:
                                AppAssets.iconEdit, // Use an existing edit icon
                            validator: (value) {
                              if (isOtherCategorySelected &&
                                  (value == null || value.isEmpty)) {
                                return AppStrings
                                    .validation.categoryNameRequired;
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: groupGapMd),
                        _buildTransactionDateTimeRow(),
                        const SizedBox(height: groupGapMd),

                        CustomBigTextFormFieldWithPrefixIcon(
                          customBigTextFormFieldTextEditingController:
                              notesTextEditingController,
                          hintText: AppStrings.groups.writeNotes,
                          prefixIconString: AppAssets.iconNote,
                        ),
                        const SizedBox(height: groupGapMd),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: groupGap10 * 5,
                              width: groupGap10 * 5,
                              padding: const EdgeInsets.all(groupGapSm),
                              decoration: BoxDecoration(
                                color: groupTransparent,
                                border: Border.all(
                                  color: neopopGrey,
                                  width: 2,
                                ),
                                borderRadius:
                                    BorderRadius.circular(groupGapSm / 2),
                              ),
                              child: SvgPicture.asset(
                                AppAssets.iconEqual,
                                height: AppDimensions.loadingIndicatorSm,
                                width: AppDimensions.loadingIndicatorSm,
                                color: neopopGrey,
                              ),
                            ),
                            SizedBox(
                              width: devSysWidth * 0.79,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppStrings.groups.sharingMode,
                                        style: body2_text.copyWith(
                                          color: neopopBackground,
                                        ),
                                      ),
                                      SizedBox(width: groupGap10),
                                      Obx(() {
                                        final controller = Get.find<
                                            AddTransactionScreenController>();
                                        controller
                                            .isTheStateNeedToBeRefreshed.value;
                                        String mode =
                                            SharingMode.byEvenly.label;
                                        switch (
                                            controller.currentTabIndex.value) {
                                          case 0:
                                            mode = SharingMode.byEvenly.label;
                                            break;
                                          case 1:
                                            mode = SharingMode.byUnevenly.label;
                                            break;
                                          case 2:
                                            mode =
                                                SharingMode.byPercentage.label;
                                            break;
                                          case 3:
                                            mode = SharingMode.byShares.label;
                                            break;
                                          case 4:
                                            mode = SharingMode.byItem.label;
                                            break;
                                        }
                                        return NeoPopCustomTextButton(
                                          buttonName:
                                              AppStringFormat.bySharingMode(
                                                  mode),
                                          buttonTextColor: neopopBackground,
                                          buttonForegroundColor: neopopAccent,
                                          onPressed: () async {
                                            await Get.to(
                                              () => ShareDistributionScreen(
                                                groupMembersWithNameModel:
                                                    widget.groupMembersDetails,
                                                totalAmount: isNumeric(
                                                        expenseTextEditingController
                                                            .text)
                                                    ? double.parse(
                                                        expenseTextEditingController
                                                            .text)
                                                    : 0.0,
                                              ),
                                            );
                                          },
                                          isBorder: true,
                                          borderColor: neopopBackground,
                                        );
                                      }),
                                    ],
                                  ),
                                  SizedBox(height: groupGap10),
                                  Text(
                                    AppStrings.groups.sharingAmong,
                                    style: body2_text.copyWith(
                                      color: neopopBackground,
                                    ),
                                  ),
                                  SizedBox(height: groupGap10),
                                  Obx(() {
                                    final controller = Get.find<
                                        AddTransactionScreenController>();
                                    controller.isTheStateNeedToBeRefreshed.value;
                                    final involvedIndices = controller
                                        .involvedMemberIndicesFor(
                                      widget.groupMembersDetails,
                                    );
                                    final showOverflow =
                                        involvedIndices.length > 11;
                                    final displayIndices = showOverflow
                                        ? involvedIndices.take(11).toList()
                                        : involvedIndices;
                                    final itemCount = showOverflow
                                        ? displayIndices.length + 1
                                        : displayIndices.length;

                                    if (itemCount == 0) {
                                      return Text(
                                        AppStrings.validation.selectPersonToSplit,
                                        style: body2_text.copyWith(
                                          color: neopopGrey,
                                        ),
                                      );
                                    }

                                    return GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 6,
                                        childAspectRatio: 1,
                                        crossAxisSpacing: groupGap10,
                                        mainAxisSpacing: groupGap10,
                                      ),
                                      itemCount: itemCount,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        if (showOverflow &&
                                            index == displayIndices.length) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: neopopBackground,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                groupGutter * 2.5,
                                              ),
                                            ),
                                            child: SvgPicture.asset(
                                              AppAssets.iconThreeDots,
                                              color: neopopBackground,
                                              height: groupGapLg,
                                              width: groupGapLg,
                                            ),
                                          );
                                        }

                                        final memberIndex =
                                            displayIndices[index];
                                        final member = widget
                                            .groupMembersDetails[memberIndex];
                                        return UserAvatar(
                                          userID: member.userID ?? '',
                                          userName:
                                              member.userName ?? ' User',
                                          imageUrl: member.userPic,
                                          radius: groupGap10 * 2.5,
                                        );
                                      },
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: groupGapMd),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ),
    );
  }
}
