import 'package:flutter/material.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Utils/currency_utils.dart';
import 'package:get/get.dart';
import 'package:splitr/Model/group_model.dart';

class AddTransactionScreenController extends GetxController {
  RxBool isTheStateNeedToBeRefreshed = false.obs;

  void updateStateRefresh() {
    isTheStateNeedToBeRefreshed.value = !isTheStateNeedToBeRefreshed.value;
    update();
  }

  // TAB CONTROLLER
  RxInt currentTabIndex = 0.obs;

  void updateCurrentTabIndex(int index) {
    currentTabIndex.value = index;
  }

  // EVEN SHARES CONTROLLERS
  RxInt involvedPersons = 0.obs;

  void increaseInvolvedPersons() {
    involvedPersons.value = involvedPersons.value + 1;
  }

  void decreaseInvolvedPersons() {
    involvedPersons.value = involvedPersons.value - 1;
  }

  List<RxBool> checkBoxBool = [];

  void addAllCheckBoxValue(int length) {
    if (checkBoxBool.length == length) return;
    checkBoxBool.clear(); // Clear the list to avoid mismatches
    for (var i = 0; i < length; i++) {
      checkBoxBool.add(true.obs);
    }
  }

  void selectOrDeselectOneCheckBox(int index) {
    if (index < checkBoxBool.length) {
      checkBoxBool[index].value = !checkBoxBool[index].value;
    }
  }

  void selectOrDeselectAllCheckBox(int length) {
    if (checkBoxBool.length == length) {
      for (var i = 0; i < length; i++) {
        checkBoxBool[i].value = !checkBoxBool[i].value;
      }
    }
  }

  RxBool allCheckBoxSelector = true.obs;
  void changeAllCheckBoxSelectorState({int isChanged = 0}) {
    if (isChanged == 0) {
      allCheckBoxSelector.value = !allCheckBoxSelector.value;
    } else if (isChanged == 1) {
      allCheckBoxSelector.value = true;
    } else if (isChanged == 2) {
      allCheckBoxSelector.value = false;
    } else {
      allCheckBoxSelector.value = !allCheckBoxSelector.value;
    }
  }

  void selectOrDeselectAllCheckBoxAtOnce() {
    if (allCheckBoxSelector.value) {
      involvedPersons.value = checkBoxBool.length;
    } else {
      involvedPersons.value = 0;
    }

    for (var i = 0; i < checkBoxBool.length; i++) {
      checkBoxBool[i].value = allCheckBoxSelector.value;
    }
  }

  // UNEVEN SHARE CONTROLLER LOGICS
  RxList<RxMap<String, dynamic>> userAndSplitDetails =
      <RxMap<String, dynamic>>[].obs;

  RxDouble totalAddedAmount = 0.0.obs;

  final List<TextEditingController> textControllers = [];

  void initializeList(int count) {
    if (userAndSplitDetails.isEmpty) {
      // Initialize user and split details only once
      userAndSplitDetails.value = List.generate(count, (_) {
        RxMap<String, dynamic> details = <String, dynamic>{}.obs;
        details[SplitDetailKeys.userId] = "";
        details[SplitDetailKeys.amount] = AppAmountHints.decimalShort;
        return details;
      });

      // Initialize TextEditingControllers only once
      for (int i = 0; i < count; i++) {
        textControllers.add(
          TextEditingController(
            text: userAndSplitDetails[i]
                [SplitDetailKeys.amount], // Default to "0.0"
          ),
        );
      }
    }
  }

  void updateValue(int index, String value, String userID) {
    if (index < userAndSplitDetails.length) {
      // Parse the previous and new values
      double oldValue =
          double.tryParse(userAndSplitDetails[index][SplitDetailKeys.amount]) ??
              0.0;
      double newValue = double.tryParse(value) ?? 0.0;

      // Update the total added amount
      totalAddedAmount.value += (newValue - oldValue);

      // Update the specific user's details
      userAndSplitDetails[index][SplitDetailKeys.amount] = value;
      userAndSplitDetails[index][SplitDetailKeys.userId] = userID;
    }
  }

  // PERCENTAGE SHARE CONTROLLER LOGICS
  RxList<RxMap<String, dynamic>> percentageSplitDetails =
      <RxMap<String, dynamic>>[].obs;

  RxDouble totalPercentage = 0.0.obs;

  final List<TextEditingController> percentageTextControllers = [];

  void initializePercentageList(int count) {
    if (percentageSplitDetails.isEmpty) {
      percentageSplitDetails.value = List.generate(count, (_) {
        RxMap<String, dynamic> details = <String, dynamic>{}.obs;
        details[SplitDetailKeys.userId] = "";
        details[SplitDetailKeys.percentage] = AppAmountHints.decimalShort;
        return details;
      });

      for (int i = 0; i < count; i++) {
        percentageTextControllers.add(
          TextEditingController(
            text: percentageSplitDetails[i][SplitDetailKeys.percentage],
          ),
        );
      }
    }
  }

  void updatePercentageValue(int index, String value, String userID) {
    if (index < percentageSplitDetails.length) {
      double oldValue = double.tryParse(
              percentageSplitDetails[index][SplitDetailKeys.percentage]) ??
          0.0;
      double newValue = double.tryParse(value) ?? 0.0;

      totalPercentage.value += (newValue - oldValue);

      percentageSplitDetails[index][SplitDetailKeys.percentage] = value;
      percentageSplitDetails[index][SplitDetailKeys.userId] = userID;
    }
  }

  // SHARES CONTROLLER LOGICS
  RxList<RxMap<String, dynamic>> sharesSplitDetails =
      <RxMap<String, dynamic>>[].obs;

  RxInt totalShares = 0.obs;

  final List<TextEditingController> sharesTextControllers = [];

  void initializeSharesList(int count) {
    if (sharesSplitDetails.isEmpty) {
      sharesSplitDetails.value = List.generate(count, (_) {
        RxMap<String, dynamic> details = <String, dynamic>{}.obs;
        details[SplitDetailKeys.userId] = "";
        details[SplitDetailKeys.shares] = AppAmountHints.zero;
        return details;
      });

      for (int i = 0; i < count; i++) {
        sharesTextControllers.add(
          TextEditingController(
            text: sharesSplitDetails[i][SplitDetailKeys.shares],
          ),
        );
      }
    }
  }

  void updateSharesValue(int index, String value, String userID) {
    if (index < sharesSplitDetails.length) {
      int oldValue =
          int.tryParse(sharesSplitDetails[index][SplitDetailKeys.shares]) ?? 0;
      int newValue = int.tryParse(value) ?? 0;

      totalShares.value += (newValue - oldValue);

      sharesSplitDetails[index][SplitDetailKeys.shares] = value;
      sharesSplitDetails[index][SplitDetailKeys.userId] = userID;
    }
  }

  // BY-ITEM SPLIT CONTROLLER LOGICS
  RxList<RxMap<String, dynamic>> itemSplitDetails =
      <RxMap<String, dynamic>>[].obs;

  RxDouble totalItemPrice = 0.0.obs;

  final List<TextEditingController> itemNameControllers = [];
  final List<TextEditingController> itemPriceControllers = [];

  void initializeItemList() {
    if (itemSplitDetails.isEmpty) {
      addItem();
    }
  }

  void addItem() {
    RxMap<String, dynamic> item = <String, dynamic>{}.obs;
    item[SplitDetailKeys.name] = "";
    item[SplitDetailKeys.price] = AppAmountHints.decimalShort;
    item[SplitDetailKeys.assignees] = <String>[];
    itemSplitDetails.add(item);

    itemNameControllers.add(TextEditingController());
    itemPriceControllers.add(TextEditingController());
  }

  void removeItem(int index) {
    if (index < itemSplitDetails.length) {
      double price =
          double.tryParse(itemSplitDetails[index][SplitDetailKeys.price]) ??
              0.0;
      totalItemPrice.value -= price;

      itemSplitDetails.removeAt(index);
      itemNameControllers[index].dispose();
      itemPriceControllers[index].dispose();
      itemNameControllers.removeAt(index);
      itemPriceControllers.removeAt(index);
    }
  }

  void updateItemName(int index, String name) {
    if (index < itemSplitDetails.length) {
      itemSplitDetails[index][SplitDetailKeys.name] = name;
    }
  }

  void updateItemPrice(int index, String price) {
    if (index < itemSplitDetails.length) {
      double oldPrice =
          double.tryParse(itemSplitDetails[index][SplitDetailKeys.price]) ??
              0.0;
      double newPrice = double.tryParse(price) ?? 0.0;

      totalItemPrice.value += (newPrice - oldPrice);
      itemSplitDetails[index][SplitDetailKeys.price] = price;
    }
  }

  void toggleItemAssignee(int itemIndex, String userId) {
    if (itemIndex < itemSplitDetails.length) {
      List<String> assignees = List<String>.from(
          itemSplitDetails[itemIndex][SplitDetailKeys.assignees]);
      if (assignees.contains(userId)) {
        assignees.remove(userId);
      } else {
        assignees.add(userId);
      }
      itemSplitDetails[itemIndex][SplitDetailKeys.assignees] = assignees;
      itemSplitDetails.refresh();
    }
  }

  // LOAD TRANSACTION FOR EDITING
  void loadTransaction(ConsolidatedGroupTransactionModel transaction,
      List<GroupMembersWithNameModel> groupMembers) {
    // 1. Basic Details
    // totalAddedAmount.value = transaction.totalTransactionAmount ?? 0.0;
    // We will calculate totalAddedAmount based on the populated splits to ensure consistency
    totalAddedAmount.value = 0.0;
    // Note: The UI uses textControllers[index] for splits, but for the main amount
    // it's usually handled in the UI's TextEditingController.
    // The UI needs to bind its main amount controller to this value or vice versa.
    // Checking AddTransactionScreen, it likely has its own 'amountController'.
    // We'll return the values or let the UI pull them.
    // Actually, looking at the UI code is safer.
    // But assuming the UI will call this and then update its own controllers:

    // 2. Decode Split Type
    // 'evenly', 'unevenly', SplitDetailKeys.percentage, SplitDetailKeys.shares
    String type =
        transaction.sharingType?.toLowerCase() ?? SharingTypeValues.evenly;
    setTabIndexFromSharingType(type);

    // 3. Populate Splits
    if (type == SharingTypeValues.evenly) {
      // Logic: Iterate existing group members. If memberID is in transaction.sharedWith, set checkbox = true
      // We need the full list of group members to know which index corresponds to which user

      List<String> sharedWithIDs = [];
      if (transaction.sharedWith != null) {
        sharedWithIDs = transaction.sharedWith!
            .map((e) => e.sharedWithUUID!.toLowerCase())
            .toList(); // Normalize to lower case
      }

      // Initialize checkboxes if not already done
      if (checkBoxBool.length != groupMembers.length) {
        addAllCheckBoxValue(groupMembers.length);
      }

      // Reset all to false first
      for (var i = 0; i < checkBoxBool.length; i++) {
        checkBoxBool[i].value = false;
      }

      int selectedCount = 0;
      for (var i = 0; i < groupMembers.length; i++) {
        // Normalize group member ID to lower case for comparison
        if (sharedWithIDs
            .contains(groupMembers[i].userID?.toLowerCase() ?? "")) {
          checkBoxBool[i].value = true;
          selectedCount++;
        }
      }
      involvedPersons.value = selectedCount;

      // FILL DATA FOR OTHER TABS TO AVOID 0.0 Issues
      initializeList(groupMembers.length);
      initializePercentageList(groupMembers.length);
      initializeSharesList(groupMembers.length);

      double totalDetailsAmount = transaction.totalTransactionAmount ?? 0.0;
      double evenAmount =
          selectedCount > 0 ? (totalDetailsAmount / selectedCount) : 0.0;
      double evenPercent = selectedCount > 0
          ? (GroupBusinessRules.percentageTotal / selectedCount)
          : 0.0;

      for (var i = 0; i < groupMembers.length; i++) {
        String userId = groupMembers[i].userID ?? "";

        if (checkBoxBool[i].value) {
          // Unevenly
          userAndSplitDetails[i][SplitDetailKeys.amount] =
              evenAmount.toStringAsFixed(DefaultDecimalPlaces.amount);
          userAndSplitDetails[i][SplitDetailKeys.userId] = userId;
          textControllers[i].text =
              evenAmount.toStringAsFixed(DefaultDecimalPlaces.amount);

          // Percentage
          percentageSplitDetails[i][SplitDetailKeys.percentage] =
              evenPercent.toStringAsFixed(DefaultDecimalPlaces.amount);
          percentageSplitDetails[i][SplitDetailKeys.userId] = userId;
          percentageTextControllers[i].text =
              evenPercent.toStringAsFixed(DefaultDecimalPlaces.amount);

          // Shares
          sharesSplitDetails[i][SplitDetailKeys.shares] = AppAmountHints.one;
          sharesSplitDetails[i][SplitDetailKeys.userId] = userId;
          sharesTextControllers[i].text = AppAmountHints.one;
        } else {
          // Unevenly
          userAndSplitDetails[i][SplitDetailKeys.amount] =
              AppAmountHints.decimalShort;
          userAndSplitDetails[i][SplitDetailKeys.userId] = userId;
          textControllers[i].text = AppAmountHints.decimalShort;

          // Percentage
          percentageSplitDetails[i][SplitDetailKeys.percentage] =
              AppAmountHints.decimalShort;
          percentageSplitDetails[i][SplitDetailKeys.userId] = userId;
          percentageTextControllers[i].text = AppAmountHints.decimalShort;

          // Shares
          sharesSplitDetails[i][SplitDetailKeys.shares] = AppAmountHints.zero;
          sharesSplitDetails[i][SplitDetailKeys.userId] = userId;
          sharesTextControllers[i].text = AppAmountHints.zero;
        }
      }

      // Update totals
      totalAddedAmount.value = transaction.totalTransactionAmount ?? 0.0;
      totalPercentage.value = selectedCount * evenPercent;
      totalShares.value = selectedCount;
    } else if (type == SharingTypeValues.unevenly) {
      // Populate userAndSplitDetails
      // We need to match sharedWith data to the correct index in userAndSplitDetails
      // userAndSplitDetails is initialized with 'count' (group members length)

      initializeList(groupMembers.length); // Ensure initialized

      for (var i = 0; i < groupMembers.length; i++) {
        final memberID = groupMembers[i].userID;
        final sharedData = transaction.sharedWith?.firstWhere(
            (e) =>
                (e.sharedWithUUID?.toLowerCase() ?? "") ==
                (memberID?.toLowerCase() ?? ""),
            orElse: () => ConsolidatedGroupTransactionSharedTransactionModel());

        if (sharedData?.sharedWithUUID != null) {
          String amount = sharedData!.sharedTransactionAmount.toString();
          userAndSplitDetails[i][SplitDetailKeys.amount] = amount;
          userAndSplitDetails[i][SplitDetailKeys.userId] = memberID;
          textControllers[i].text = amount; // Sync text controller
        } else {
          userAndSplitDetails[i][SplitDetailKeys.amount] =
              AppAmountHints.decimalShort;
          userAndSplitDetails[i][SplitDetailKeys.userId] = memberID;
          textControllers[i].text = AppAmountHints.decimalShort;
        }
      }
      // Recalculate total
      double total = 0;
      for (var item in userAndSplitDetails) {
        total += double.tryParse(item[SplitDetailKeys.amount]) ?? 0;
      }
      totalAddedAmount.value = total;
    } else if (type == SharingTypeValues.percentage) {
      initializePercentageList(groupMembers.length);

      for (var i = 0; i < groupMembers.length; i++) {
        final memberID = groupMembers[i].userID;
        final sharedData = transaction.sharedWith?.firstWhere(
            (e) =>
                (e.sharedWithUUID?.toLowerCase() ?? "") ==
                (memberID?.toLowerCase() ?? ""),
            orElse: () => ConsolidatedGroupTransactionSharedTransactionModel());

        if (sharedData?.sharedWithUUID != null) {
          String percent = sharedData!.sharedPercentage.toString();
          percentageSplitDetails[i][SplitDetailKeys.percentage] = percent;
          percentageSplitDetails[i][SplitDetailKeys.userId] = memberID;
          percentageTextControllers[i].text = percent;
        } else {
          percentageSplitDetails[i][SplitDetailKeys.percentage] =
              AppAmountHints.decimalShort;
          percentageSplitDetails[i][SplitDetailKeys.userId] = memberID;
          percentageTextControllers[i].text = AppAmountHints.decimalShort;
        }
      }
      // Recalc total percentage
      double total = 0;
      for (var item in percentageSplitDetails) {
        total += double.tryParse(item[SplitDetailKeys.percentage]) ?? 0;
      }
      totalPercentage.value = total;
    }
    // Note: SplitDetailKeys.shares logic omitted as discussed (fallback or complex)

    update();
  }

  /// Pre-filled splits from receipt scanner (bypasses tab calculation).
  Map<String, double>? receiptPrefilledSplits;

  void applyReceiptScan({
    required String category,
    required double amount,
    required String description,
    required Map<String, double> splits,
  }) {
    receiptPrefilledSplits = Map.from(splits);
    currentTabIndex.value = 1;
    totalAddedAmount.value = amount;
  }

  void clearReceiptPrefill() => receiptPrefilledSplits = null;

  /// Wishlist item to mark as added after a successful save.
  String? pendingWishlistItemId;

  void clearPendingWishlistItem() => pendingWishlistItemId = null;

  /// Clears split state so a new add-transaction session starts fresh.
  void resetForNewTransaction() {
    currentTabIndex.value = 0;
    involvedPersons.value = 0;
    checkBoxBool.clear();
    allCheckBoxSelector.value = true;
    totalAddedAmount.value = 0.0;
    totalPercentage.value = 0.0;
    totalShares.value = 0;
    totalItemPrice.value = 0.0;
    receiptPrefilledSplits = null;
    pendingWishlistItemId = null;

    for (final c in textControllers) {
      c.dispose();
    }
    textControllers.clear();
    userAndSplitDetails.clear();

    for (final c in percentageTextControllers) {
      c.dispose();
    }
    percentageTextControllers.clear();
    percentageSplitDetails.clear();

    for (final c in sharesTextControllers) {
      c.dispose();
    }
    sharesTextControllers.clear();
    sharesSplitDetails.clear();

    for (final c in itemNameControllers) {
      c.dispose();
    }
    itemNameControllers.clear();
    for (final c in itemPriceControllers) {
      c.dispose();
    }
    itemPriceControllers.clear();
    itemSplitDetails.clear();

    update();
  }

  /// Pre-fills even split among all group members (wishlist → expense flow).
  void applyEvenSplitForAllMembers(
    List<GroupMembersWithNameModel> groupMembers, {
    double? totalAmount,
    String? wishlistItemId,
  }) {
    resetForNewTransaction();
    pendingWishlistItemId = wishlistItemId;

    final count = groupMembers.length;
    if (count == 0) return;

    addAllCheckBoxValue(count);
    involvedPersons.value = count;
    allCheckBoxSelector.value = true;

    initializeList(count);
    initializePercentageList(count);
    initializeSharesList(count);

    final evenAmount =
        totalAmount != null && count > 0 ? totalAmount / count : 0.0;
    final evenPercent =
        count > 0 ? GroupBusinessRules.percentageTotal / count : 0.0;

    for (var i = 0; i < count; i++) {
      final userId = groupMembers[i].userID ?? '';

      userAndSplitDetails[i][SplitDetailKeys.amount] =
          evenAmount.toStringAsFixed(DefaultDecimalPlaces.amount);
      userAndSplitDetails[i][SplitDetailKeys.userId] = userId;
      textControllers[i].text =
          evenAmount.toStringAsFixed(DefaultDecimalPlaces.amount);

      percentageSplitDetails[i][SplitDetailKeys.percentage] =
          evenPercent.toStringAsFixed(DefaultDecimalPlaces.amount);
      percentageSplitDetails[i][SplitDetailKeys.userId] = userId;
      percentageTextControllers[i].text =
          evenPercent.toStringAsFixed(DefaultDecimalPlaces.amount);

      sharesSplitDetails[i][SplitDetailKeys.shares] = AppAmountHints.one;
      sharesSplitDetails[i][SplitDetailKeys.userId] = userId;
      sharesTextControllers[i].text = AppAmountHints.one;
    }

    if (totalAmount != null) {
      totalAddedAmount.value = totalAmount;
    }
    totalPercentage.value = count * evenPercent;
    totalShares.value = count;

    update();
  }

  /// Returns null when valid, otherwise a user-facing error message.
  String? validateSplit({
    required int tabIndex,
    required double totalAmount,
  }) {
    const tolerance = SplitValidationTolerance.amount;
    switch (tabIndex) {
      case 1:
        if ((totalAddedAmount.value - totalAmount).abs() > tolerance) {
          return AppStringFormat.splitAmountsMustEqual(
            userCurrencySymbol(),
            totalAmount.toStringAsFixed(DefaultDecimalPlaces.amount),
          );
        }
        if (totalAddedAmount.value <= 0) {
          return AppStrings.validation.enterSplitAmounts;
        }
        return null;
      case 2:
        if ((totalPercentage.value - GroupBusinessRules.percentageTotal).abs() >
            tolerance) {
          return AppStringFormat.percentagesMustAddUp(
            totalPercentage.value
                .toStringAsFixed(DefaultDecimalPlaces.percentage),
          );
        }
        return null;
      case 3:
        if (totalShares.value <= 0) {
          return AppStrings.validation.totalSharesGreaterThanZero;
        }
        return null;
      case 4:
        if ((totalItemPrice.value - totalAmount).abs() > tolerance) {
          return AppStringFormat.itemTotalsMustEqual(
            userCurrencySymbol(),
            totalAmount.toStringAsFixed(DefaultDecimalPlaces.amount),
          );
        }
        for (final item in itemSplitDetails) {
          final assignees =
              List<String>.from(item[SplitDetailKeys.assignees] ?? []);
          final price =
              double.tryParse(item[SplitDetailKeys.price].toString()) ?? 0;
          if (price > 0 && assignees.isEmpty) {
            return AppStrings.validation.assignEachItem;
          }
        }
        return null;
      default:
        return null;
    }
  }

  String sharingTypeForTab(int tabIndex) {
    switch (tabIndex) {
      case 1:
        return SharingTypeValues.unevenly;
      case 2:
        return SharingTypeValues.percentage;
      case 3:
        return SharingTypeValues.shares;
      case 4:
        return SharingTypeValues.byItem;
      default:
        return SharingTypeValues.evenly;
    }
  }

  void setTabIndexFromSharingType(String? sharingType) {
    final type = sharingType?.toLowerCase() ?? SharingTypeValues.evenly;
    currentTabIndex.value = switch (type) {
      SharingTypeValues.unevenly => 1,
      SharingTypeValues.percentage => 2,
      SharingTypeValues.shares => 3,
      SharingTypeValues.byItem => 4,
      _ => 0,
    };
  }

  /// Member indices included in the current split configuration.
  List<int> involvedMemberIndices(int memberCount) {
    switch (currentTabIndex.value) {
      case 1:
        return [
          for (var i = 0; i < memberCount; i++)
            if (i < userAndSplitDetails.length &&
                (double.tryParse(
                        userAndSplitDetails[i][SplitDetailKeys.amount]
                            .toString()) ??
                    0) >
                    0)
              i,
        ];
      case 2:
        return [
          for (var i = 0; i < memberCount; i++)
            if (i < percentageSplitDetails.length &&
                (double.tryParse(
                        percentageSplitDetails[i][SplitDetailKeys.percentage]
                            .toString()) ??
                    0) >
                    0)
              i,
        ];
      case 3:
        return [
          for (var i = 0; i < memberCount; i++)
            if (i < sharesSplitDetails.length &&
                (int.tryParse(
                        sharesSplitDetails[i][SplitDetailKeys.shares]
                            .toString()) ??
                    0) >
                    0)
              i,
        ];
      default:
        if (checkBoxBool.length != memberCount) {
          return List.generate(memberCount, (i) => i);
        }
        return [
          for (var i = 0; i < memberCount; i++)
            if (checkBoxBool[i].value) i,
        ];
    }
  }

  List<int> involvedMemberIndicesFor(
    List<GroupMembersWithNameModel> members,
  ) {
    if (currentTabIndex.value == 4) {
      final assignees = <String>{};
      for (final item in itemSplitDetails) {
        assignees.addAll(
          List<String>.from(item[SplitDetailKeys.assignees] ?? const []),
        );
      }
      return [
        for (var i = 0; i < members.length; i++)
          if (assignees.contains(members[i].userID)) i,
      ];
    }
    return involvedMemberIndices(members.length);
  }
}
