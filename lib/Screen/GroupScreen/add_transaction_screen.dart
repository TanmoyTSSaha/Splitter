import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/shared.dart';
import 'package:splitter/Controller/add_transaction_controller.dart';
import 'package:splitter/Controllers/currency_controller.dart';
import 'package:splitter/Screen/GroupScreen/receipt_scanner_screen.dart';
import 'package:splitter/Widgets/premium_gate.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitter/Screen/GroupScreen/share_distribution_screen.dart';
import 'package:splitter/Services/reminder_trigger_helper.dart';
import 'package:splitter/Services/supabase_service.dart';
import 'package:splitter/Widgets/user_avatar.dart';

import '../../Constants/constants.dart';
import '../../Constants/category_style.dart';
import '../../Model/group_model.dart';
import 'package:splitter/Model/product_category_model.dart';
import 'package:splitter/Model/wishlist_prefill.dart';
import 'package:splitter/Services/wishlist_service.dart';

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

  String selectedCategory = "General";
  bool isOtherCategorySelected = false;
  Future<List<CategoryOnlyModel>>? _categoriesFuture;
  Future<List<Map<String, dynamic>>>? _groupsFuture;

  @override
  void initState() {
    selectedGroupId =
        widget.groupDetails != null ? widget.groupDetails!["group_id"] : null;

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
      selectedCategory = widget.transactionToEdit!.category ?? "General";
      selectedPayerId = widget.transactionToEdit!.paidByUUID ?? widget.userID;

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

    _categoriesFuture = SupabaseDatabase()
        .getProductCategories(groupID: widget.groupDetails?["group_id"]);

    _groupsFuture = SupabaseDatabase().getDistinctGroups(userID: widget.userID);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: GestureDetector(
          onTap: () {
            setState(() {
              FocusManager.instance.primaryFocus!.unfocus();
            });
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              automaticallyImplyLeading: true,
              iconTheme: const IconThemeData(color: neopopBackground),
              primary: true,
              backgroundColor: Colors.white,
              scrolledUnderElevation: 0,
              centerTitle: false,
              title: Text(
                widget.transactionToEdit != null
                    ? "Edit Transaction"
                    : "Add Transaction",
                style: sub_headline4_text.copyWith(color: neopopBackground),
              ),
              elevation: 0,
              actions: [
                IconButton(
                  onPressed: () async {
                    if (selectedGroupId == null) {
                      Fluttertoast.showToast(msg: "Please select a group first");
                      return;
                    }
                    final allowed = await requirePremium(
                      featureLabel: 'AI Receipt Scanning',
                    );
                    if (!allowed) return;
                    Get.to(() => ReceiptScannerScreen(
                          groupID: selectedGroupId!,
                          members: widget.groupMembersDetails,
                          onTransactionCreated: (category, amount, description,
                              memberShares) {
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
                    color: neopopBackground,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (selectedGroupId == null) {
                        Fluttertoast.showToast(msg: "Please select a group");
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
                        String sharingType = 'evenly';

                        if (controller.receiptPrefilledSplits != null) {
                          splits = Map.from(controller.receiptPrefilledSplits!);
                          sharingType = 'by_item';
                          controller.clearReceiptPrefill();
                        } else {
                        int currentTabIndex = controller.currentTabIndex.value;
                        sharingType =
                            controller.sharingTypeForTab(currentTabIndex);

                        final validationError = controller.validateSplit(
                          tabIndex: currentTabIndex,
                          totalAmount: totalAmount,
                        );
                        if (validationError != null) {
                          Get.back();
                          Fluttertoast.showToast(msg: validationError);
                          return;
                        }

                        // SPLIT LOGIC BASED ON TAB
                        if (currentTabIndex == 0) {
                          // EVENLY
                          // Ensure controller has data (if not visited tabs)
                          if (controller.checkBoxBool.isEmpty ||
                              controller.checkBoxBool.length != totalMembers) {
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
                            Fluttertoast.showToast(
                                msg:
                                    "Select at least one person to split with");
                            return;
                          }

                          double splitAmount =
                              totalAmount / involvedUserIDs.length;
                          for (var userId in involvedUserIDs) {
                            splits[userId] = splitAmount;
                          }
                        } else if (currentTabIndex == 1) {
                          // UNEVENLY
                          for (var item in controller.userAndSplitDetails) {
                            if (item["user_id"] != null &&
                                item["user_id"].toString().isNotEmpty) {
                              splits[item["user_id"]] =
                                  double.tryParse(item["amount"].toString()) ??
                                      0.0;
                            }
                          }
                        } else if (currentTabIndex == 2) {
                          // PERCENTAGE
                          for (var item in controller.percentageSplitDetails) {
                            if (item["user_id"] != null &&
                                item["user_id"].toString().isNotEmpty) {
                              double percent = double.tryParse(
                                      item["percentage"].toString()) ??
                                  0.0;
                              splits[item["user_id"]] =
                                  (totalAmount * percent) / 100;
                            }
                          }
                        } else if (currentTabIndex == 3) {
                          // SHARES
                          int totalShares = controller.totalShares.value;
                          if (totalShares > 0) {
                            for (var item in controller.sharesSplitDetails) {
                              if (item["user_id"] != null &&
                                  item["user_id"].toString().isNotEmpty) {
                                int userShares =
                                    int.tryParse(item["shares"].toString()) ??
                                        0;
                                splits[item["user_id"]] =
                                    (totalAmount * userShares) / totalShares;
                              }
                            }
                          }
                        } else if (currentTabIndex == 4) {
                          // BY ITEM
                          for (var item in controller.itemSplitDetails) {
                            double price =
                                double.tryParse(item["price"].toString()) ??
                                    0.0;
                            List<String> assignees =
                                List<String>.from(item["assignees"] ?? []);
                            if (assignees.isNotEmpty) {
                              double split = price / assignees.length;
                              for (var uid in assignees) {
                                splits[uid] = (splits[uid] ?? 0.0) + split;
                              }
                            }
                          }
                        }
                        }

                        if (splits.isEmpty && sharingType != 'evenly') {
                          // If splits are empty (and not default even split where we already checked involvedUserIDs),
                          // it means user didn't assign anything in other tabs.
                          // OR calculation resulted in 0.
                          // We might want to warn?
                          // For now, let's proceed, maybe it's a "paid for self" scenario if splits is empty?
                          // But usually in split app, you want to split.
                        }

                        String finalCategory = selectedCategory;

                        // Handle "Other" category
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
                            await SupabaseDatabase().addCustomCategory(
                              groupID: selectedGroupId!,
                              categoryName: customCategoryName,
                              iconSvgContent:
                                  "https://api.dicebear.com/9.x/initials/svg?seed=$customCategoryName", // Fallback/Default for custom
                              userID: widget.userID,
                            );
                          } else {
                            // If user selected "Other" but typed nothing, default to "General" or warn?
                            // Let's warn.
                            Get.back(); // Close loading
                            Fluttertoast.showToast(
                                msg: "Please enter a category name");
                            return;
                          }
                        }

                        if (widget.transactionToEdit != null) {
                          // If editing, delete old transaction first
                          // We use the same flow: Delete -> Add New
                          // Ideally, we should wrap this in a transaction or use an 'update' RPC,
                          // but for now we follow the "Delete & Re-Add" pattern.
                          await SupabaseDatabase().deleteGroupTransaction(
                              transactionGroupID: widget
                                  .transactionToEdit!.transactionGroupID!);
                        }

                        await SupabaseDatabase().addGroupExpense(
                          groupID: selectedGroupId!,
                          paidByUserID: selectedPayerId ?? widget.userID,
                          totalAmount: totalAmount,
                          description: descriptionToCheck,
                          category: finalCategory,
                          splits: splits,
                          currency: Get.find<CurrencyController>().code,
                          note: notes.isNotEmpty ? notes : null,
                          sharingType: sharingType,
                        );

                        final memberNames = {
                          for (final m in widget.groupMembersDetails)
                            m.userID!: m.userName ?? 'Member',
                        };
                        await ReminderTriggerHelper.onExpenseAdded(
                          groupId: selectedGroupId!,
                          groupName:
                              widget.groupDetails?['group_name'] ?? 'Group',
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
                        Fluttertoast.showToast(
                          msg: widget.transactionToEdit != null
                              ? "Transaction updated successfully!"
                              : "Split added successfully!",
                          textColor: neopopBackground,
                          backgroundColor: neopopYellow,
                        );
                      } catch (e) {
                        Get.back(); // Close loading
                        debugPrint("Error adding transaction: $e");
                        Fluttertoast.showToast(
                            msg: "Failed to add transaction: $e");
                      }
                    }
                  },
                  icon: const Icon(
                    Icons.check_rounded,
                    color: neopopBackground,
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
                  // Show an error message if the API call fails
                  return Text("Error: ${distinctGroupSnapshot.error}");
                } else if (!distinctGroupSnapshot.hasData ||
                    distinctGroupSnapshot.data!.isEmpty) {
                  // Show a message if no data is returned
                  return const Text("No data available");
                } else {
                  // Build the dropdown menu with the fetched data
                  final dropdownItems = distinctGroupSnapshot.data!;
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(height_16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButton<String>(
                          hint: Text(
                            "Select a group",
                            style: body1_text.copyWith(color: groupOnSurfaceMuted),
                          ),
                          value: selectedGroupId,
                          dropdownColor: Colors.white,
                          icon: const Icon(Icons.arrow_drop_down,
                              color: groupOnSurface),
                          style: body1_text.copyWith(color: groupOnSurface),
                          items: dropdownItems.map((item) {
                            return DropdownMenuItem<String>(
                              value: item[
                                  'group_id'], // Use `group_id` as the unique value
                              child: Text(
                                item['group_name'] ?? 'Unknown',
                                style: body1_text.copyWith(color: groupOnSurface),
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
                        SizedBox(height: height_16),

                        // Paid By Dropdown
                        Text("Paid By",
                            style:
                                body2_text.copyWith(color: neopopBackground)),
                        SizedBox(height: height_10),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: width_10),
                          decoration: BoxDecoration(
                            border: Border.all(color: neopopGrey),
                            borderRadius: BorderRadius.circular(height_10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedPayerId,
                              isExpanded: true,
                              dropdownColor: Colors.white,
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
                                        userName: member.userName ?? "User",
                                        imageUrl: member.userPic,
                                        radius: height_10 * 1.5,
                                      ),
                                      SizedBox(width: width_10),
                                      Text(
                                        member.userID == widget.userID
                                            ? "You"
                                            : member.userName ?? "Unknown",
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
                        SizedBox(height: height_16),

                        // NEED TO ADD VALIDATOR IN EACH TEXT FORM FIELD
                        CustomTextFormFieldWithPrefixIcon(
                          customTextFormFieldTextEditingController:
                              descriptionTextEditingController,
                          keyboardType: TextInputType.text,
                          hintText: "Write a description",
                          prefixIconString:
                              "assets/icons/svg/mingcute--bill-line.svg",
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              Fluttertoast.showToast(
                                msg: "Description is required!",
                                textColor: neopopBackground,
                                backgroundColor: neopopYellow,
                              );
                              return "Description is required!";
                            }

                            return null;
                          },
                        ),
                        SizedBox(height: height_16),
                        CustomTextFormFieldWithPrefixIcon(
                          customTextFormFieldTextEditingController:
                              expenseTextEditingController,
                          keyboardType: TextInputType.number,
                          hintText: "0.0",
                          prefixIconString:
                              "assets/icons/svg/material-symbols--currency-rupee-circle-rounded.svg",
                          validator: (value) {
                            if (value != null && GetUtils.isNum(value)) {
                              return null;
                            } else if (value == null) {
                              Fluttertoast.showToast(
                                msg: "Need amount here!",
                                textColor: neopopBackground,
                                backgroundColor: neopopYellow,
                              );
                              return "Need amount here!";
                            } else if (!GetUtils.isNum(value)) {
                              Fluttertoast.showToast(
                                msg: "Only numbers are allowed here!",
                                textColor: neopopBackground,
                                backgroundColor: neopopYellow,
                              );
                              return "Only numbers are allowed here!";
                            }

                            return null;
                          },
                        ),
                        SizedBox(height: height_16),

                        // Category Selector
                        Text(
                          "Category",
                          style: body2_text.copyWith(color: neopopBackground),
                        ),
                        SizedBox(height: height_10),
                        FutureBuilder<List<CategoryOnlyModel>>(
                          future: _categoriesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Text("Error loading categories");
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Text("No categories found");
                            }

                            final categories = snapshot.data!;
                            final hasOther = categories.any(
                              (c) =>
                                  c.category?.toLowerCase().trim() == 'other',
                            );
                            final allCategories = [
                              ...categories,
                              if (!hasOther)
                                CategoryOnlyModel(
                                  category: 'Other',
                                  categoryLogo:
                                      'https://api.iconify.design/material-symbols-light/more-horiz.svg',
                                ),
                            ];

                            return SizedBox(
                              height: height_10 * 10,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: allCategories.length,
                                itemBuilder: (context, index) {
                                  final cat = allCategories[index];
                                  final isOther =
                                      cat.category?.toLowerCase().trim() ==
                                          'other';
                                  final isSelected = isOtherCategorySelected
                                      ? isOther
                                      : cat.category == selectedCategory;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (cat.category?.toLowerCase().trim() ==
                                            'other') {
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
                                      margin: EdgeInsets.only(right: width_16),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: height_10 * 5,
                                            width: height_10 * 5,
                                            padding: EdgeInsets.all(height_10),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? neopopAccent
                                                  : neopopSecondaryGrey,
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
                                              size: height_10 * 2.5,
                                            ),
                                          ),
                                          SizedBox(height: height_10 / 2),
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
                          SizedBox(height: height_16),
                          CustomTextFormFieldWithPrefixIcon(
                            customTextFormFieldTextEditingController:
                                otherCategoryController,
                            keyboardType: TextInputType.text,
                            hintText: "Enter custom category name",
                            prefixIconString:
                                "assets/icons/svg/ic--baseline-edit.svg", // Use an existing edit icon
                            validator: (value) {
                              if (isOtherCategorySelected &&
                                  (value == null || value.isEmpty)) {
                                return "Category name is required";
                              }
                              return null;
                            },
                          ),
                        ],
                        SizedBox(height: height_16),

                        CustomBigTextFormFieldWithPrefixIcon(
                          customBigTextFormFieldTextEditingController:
                              notesTextEditingController,
                          hintText: "Write some notes...",
                          prefixIconString:
                              "assets/icons/svg/hugeicons--note.svg",
                        ),
                        SizedBox(height: height_16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: height_10 * 5,
                              width: height_10 * 5,
                              padding: EdgeInsets.all(height_10 / 2),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                  color: neopopGrey,
                                  width: 2,
                                ),
                                borderRadius:
                                    BorderRadius.circular(height_16 / 4),
                              ),
                              child: SvgPicture.asset(
                                "assets/icons/svg/material-symbols--equal.svg",
                                height: 20,
                                width: 20,
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
                                        "Sharing mode: ",
                                        style: body2_text.copyWith(
                                          color: neopopBackground,
                                        ),
                                      ),
                                      SizedBox(width: width_10),
                                      Obx(() {
                                        final controller = Get.find<
                                            AddTransactionScreenController>();
                                        String mode = "Evenly";
                                        switch (
                                            controller.currentTabIndex.value) {
                                          case 0:
                                            mode = "Evenly";
                                            break;
                                          case 1:
                                            mode = "Unevenly";
                                            break;
                                          case 2:
                                            mode = "Percentage";
                                            break;
                                          case 3:
                                            mode = "Shares";
                                            break;
                                          case 4:
                                            mode = "By Item";
                                            break;
                                        }
                                        return NeoPopCustomTextButton(
                                          buttonName: "By $mode",
                                          buttonTextColor: neopopBackground,
                                          buttonForegroundColor: neopopAccent,
                                          onPressed: () {
                                            // ignore: prefer_interpolation_to_compose_strings
                                            Get.to(
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
                                  SizedBox(height: height_10),
                                  Text(
                                    "Sharing among: ",
                                    style: body2_text.copyWith(
                                      color: neopopBackground,
                                    ),
                                  ),
                                  SizedBox(height: height_10),
                                  GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 6,
                                      childAspectRatio: 1,
                                      crossAxisSpacing: height_10,
                                      mainAxisSpacing: height_10,
                                    ),
                                    itemCount:
                                        widget.groupMembersDetails.length <= 12
                                            ? widget.groupMembersDetails.length
                                            : 12,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return widget.groupMembersDetails.length >
                                              11
                                          ? index == 11
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                    color: neopopBackground,
                                                    borderRadius: BorderRadius
                                                        .circular(height_16 *
                                                            2.5), // Corrected radius logic
                                                  ),
                                                  child: SvgPicture.asset(
                                                    "assets/icons/svg/bi--three-dots.svg",
                                                    color: neopopBackground,
                                                    height: height_10 * 2.4,
                                                    width: height_10 * 2.4,
                                                  ),
                                                )
                                              : UserAvatar(
                                                  userID: widget
                                                          .groupMembersDetails[
                                                              index]
                                                          .userID ??
                                                      "",
                                                  userName: widget
                                                          .groupMembersDetails[
                                                              index]
                                                          .userName ??
                                                      " User",
                                                  imageUrl: widget
                                                      .groupMembersDetails[
                                                          index]
                                                      .userPic,
                                                  radius: height_10 *
                                                      2.5, // Approx 25
                                                )
                                          : UserAvatar(
                                              userID: widget
                                                      .groupMembersDetails[
                                                          index]
                                                      .userID ??
                                                  "",
                                              userName: widget
                                                      .groupMembersDetails[
                                                          index]
                                                      .userName ??
                                                  " User",
                                              imageUrl: widget
                                                  .groupMembersDetails[index]
                                                  .userPic,
                                              radius: height_10 * 2.5,
                                            );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height_16),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
