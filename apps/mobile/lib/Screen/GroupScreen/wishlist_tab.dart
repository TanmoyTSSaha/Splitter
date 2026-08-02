import 'dart:async';
import 'package:splitr/Widgets/splitr_toast.dart';

import 'package:flutter/material.dart';
import 'package:splitr/Utils/currency_utils.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:neopop/neopop.dart';
import 'package:splitr/Constants/shared.dart';
import 'package:splitr/Controller/group_screen_controller.dart';
import 'package:splitr/Widgets/tab_empty_state.dart';
import 'package:splitr/Screen/GroupScreen/add_transaction_screen.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Model/wishlist_model.dart';
import 'package:splitr/Model/wishlist_prefill.dart';
import 'package:splitr/Services/realtime_service.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Services/wishlist_service.dart';
import 'package:splitr/Widgets/bordered_input_field.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';

/// Tab that displays a group's shared wishlist / planned expenses.
/// Members can propose items, upvote, and convert them to group expenses.
class WishlistTab extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userId;

  const WishlistTab({
    required this.groupId,
    required this.groupName,
    required this.userId,
    super.key,
  });

  @override
  State<WishlistTab> createState() => WishlistTabState();
}

class WishlistTabState extends State<WishlistTab> {
  final WishlistService _service = WishlistService();
  final RealtimeService _realtimeService = Get.find<RealtimeService>();
  List<WishlistItem> _items = [];
  bool _isLoading = true;
  String? _openingExpenseItemId;
  Worker? _refreshWorker;
  StreamSubscription<String>? _wishlistRealtimeSub;

  @override
  void initState() {
    super.initState();
    _loadItems();
    if (Get.isRegistered<GroupScreenController>()) {
      final groupController = Get.find<GroupScreenController>();
      _refreshWorker = ever(groupController.refreshTrigger, (_) {
        _loadItems(showLoading: false);
      });
    }
    _wishlistRealtimeSub = _realtimeService.onWishlistChange.listen((groupId) {
      if (groupId == widget.groupId && mounted) {
        _loadItems(showLoading: false);
      }
    });
  }

  @override
  void dispose() {
    _refreshWorker?.dispose();
    _wishlistRealtimeSub?.cancel();
    super.dispose();
  }

  Future<void> _loadItems({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() => _isLoading = true);
    }
    final items = await _service.getWishlistItems(
      groupId: widget.groupId,
      currentUserId: widget.userId,
    );
    // Sort: not-added first (by upvotes desc), then added items
    items.sort((a, b) {
      if (a.isAddedToExpenses != b.isAddedToExpenses) {
        return a.isAddedToExpenses ? 1 : -1;
      }
      return b.upvoteCount.compareTo(a.upvoteCount);
    });
    if (mounted) {
      setState(() {
        _items = items;
        _isLoading = false;
      });
      if (Get.isRegistered<GroupScreenController>()) {
        Get.find<GroupScreenController>().wishlistHasItems.value =
            items.isNotEmpty;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: neopopAccent),
      );
    }

    if (_items.isEmpty) {
      return TabEmptyState(
        variant: TabEmptyVariant.wishlist,
        title: AppStrings.groups.noPlannedExpensesYet,
        subtitle: AppStrings.groups.noPlannedExpensesSubtitle,
        action: NeoPopButton(
          color: neopopAccent,
          buttonPosition: Position.fullBottom,
          onTapUp: _showAddItemSheet,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: groupGapLg,
              vertical: groupGapMd,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded,
                    color: neopopBackground, size: groupCarouselIconSm),
                const SizedBox(width: groupGapSm),
                Text(
                  AppStrings.groups.addFirstItem,
                  style: button_text.copyWith(
                    color: neopopBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: neopopAccent,
      backgroundColor: Theme.of(context).colorScheme.surface,
      onRefresh: _loadItems,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          bottom: groupFabClearance,
          top: groupGapSm,
        ),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: groupGapMd),
        itemBuilder: (context, index) {
          return _buildWishlistCard(_items[index], index);
        },
      ),
    );
  }

  Widget _buildWishlistCard(WishlistItem item, int index) {
    final isAdded = item.isAddedToExpenses;

    return Opacity(
      opacity: isAdded ? AppDimensions.wishlistAddedOpacity : 1.0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(groupGapMd),
        decoration: BoxDecoration(
          color: groupCardFill,
          borderRadius: BorderRadius.circular(groupCardRadius),
          border: Border.all(
            color: isAdded ? WishlistPalette.border : groupMutedBorderStrong,
          ),
          boxShadow: [
            BoxShadow(
              color: groupSurfaceFillFaint,
              blurRadius: AppDimensions.groupCardShadowBlur,
              offset: AppAnimationOffsets.cardShadow,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppDimensions.groupWishlistIconBox,
                  height: AppDimensions.groupWishlistIconBox,
                  decoration: BoxDecoration(
                    color: isAdded
                        ? WishlistPalette.iconFill
                        : neopopAccentFillLight,
                    borderRadius: BorderRadius.circular(groupControlRadius),
                  ),
                  child: Icon(
                    isAdded
                        ? Icons.check_circle_rounded
                        : Icons.lightbulb_rounded,
                    color:
                        isAdded ? WishlistPalette.successGreen : neopopAccent,
                    size: AppDimensions.groupIconLg,
                  ),
                ),
                const SizedBox(width: groupGapSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: body1_text.copyWith(
                          color: groupOnSurface,
                          fontWeight: FontWeight.w600,
                          decoration:
                              isAdded ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: groupGapXxs),
                      Text(
                        AppStringFormat.addedBy(item.addedByName),
                        style: caption_text.copyWith(
                          color: groupOnSurfaceMuted,
                          fontSize: splitrFontCaption,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.estimatedAmount != null) ...[
                  const SizedBox(width: groupGapSm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: groupGap10,
                      vertical: groupGapXs,
                    ),
                    decoration: BoxDecoration(
                      color: neopopAccentFillLight,
                      borderRadius: BorderRadius.circular(groupRadiusMd),
                    ),
                    child: Text(
                      '${userCurrencySymbol()}${item.estimatedAmount!.toStringAsFixed(0)}',
                      style: body2_text.copyWith(
                        color: groupOnSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: groupGapMd),
            Row(
              children: [
                _UpvotePill(
                  count: item.upvoteCount,
                  isUpvoted: item.currentUserUpvoted,
                  isDisabled: isAdded,
                  onTap: () => _toggleUpvote(index),
                ),
                const Spacer(),
                if (!isAdded)
                  GestureDetector(
                    onTap: _openingExpenseItemId == item.id
                        ? null
                        : () => _openAddExpenseFromWishlist(item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: groupCarouselGap,
                        vertical: groupGapXs,
                      ),
                      decoration: BoxDecoration(
                        color: WishlistPalette.ctaFill,
                        borderRadius: BorderRadius.circular(groupRadiusMd),
                        border: Border.all(
                          color: WishlistPalette.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_task_rounded,
                            color: WishlistPalette.successGreen,
                            size: groupIconSm,
                          ),
                          const SizedBox(width: groupGapXxs),
                          Text(
                            AppStrings.groups.addAsExpense,
                            style: caption_text.copyWith(
                              color: WishlistPalette.successGreen,
                              fontWeight: FontWeight.w600,
                              fontSize: splitrFontCaption,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Text(
                    AppStrings.groups.addedCheck,
                    style: caption_text.copyWith(
                      color: WishlistPalette.successGreen,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                if (item.addedByUserId == widget.userId && !isAdded) ...[
                  const SizedBox(width: groupGapSm),
                  GestureDetector(
                    onTap: () => _deleteItem(item),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: groupOnSurfaceMuted,
                      size: AppDimensions.groupIconMd,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleUpvote(int index) async {
    if (index < 0 || index >= _items.length) return;
    final item = _items[index];
    final previous = item;

    setState(() {
      _items[index] = item.copyWith(
        currentUserUpvoted: !item.currentUserUpvoted,
        upvoteCount: item.currentUserUpvoted
            ? item.upvoteCount - 1
            : item.upvoteCount + 1,
      );
    });

    final result = await _service.toggleUpvote(
      itemId: item.id,
      userId: widget.userId,
    );

    if (!mounted) return;

    if (result == null) {
      setState(() => _items[index] = previous);
      return;
    }

    await _loadItems(showLoading: false);
  }

  Future<void> _openAddExpenseFromWishlist(WishlistItem item) async {
    if (_openingExpenseItemId != null) return;

    setState(() => _openingExpenseItemId = item.id);

    Get.dialog(
      const Center(child: LoadingWidget()),
      barrierDismissible: false,
    );

    try {
      final members = await SupabaseDatabase().getGroupMembers(
        groupID: widget.groupId,
        currentUserID: widget.userId,
      );

      if (Get.isDialogOpen ?? false) Get.back();

      await Get.to(
        () => AddTransactionScreen(
          userID: widget.userId,
          groupDetails: <String, dynamic>{
            UnifiedTxnKeys.groupId: widget.groupId,
            SupabaseColumns.groupName: widget.groupName,
          },
          groupMembersDetails: members,
          wishlistPrefill: WishlistPrefill(
            wishlistItemId: item.id,
            description: item.title,
            estimatedAmount: item.estimatedAmount,
          ),
        ),
      );

      await _loadItems(showLoading: false);
      if (Get.isRegistered<GroupScreenController>()) {
        Get.find<GroupScreenController>().triggerRefresh();
      }
    } catch (e, stack) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppErrorReporter.report(
        AppStrings.errors.couldNotOpenAddExpensePrefix,
        error: e,
        stack: stack,
      );
    } finally {
      if (mounted) {
        setState(() => _openingExpenseItemId = null);
      }
    }
  }

  Future<void> _deleteItem(WishlistItem item) async {
    final success = await _service.deleteItem(itemId: item.id);
    if (success) {
      await _loadItems();
    }
  }

  void showAddItemSheet() => _showAddItemSheet();

  void _showAddItemSheet() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: groupTransparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.only(
              top: groupGapLg,
              left: groupGutter,
              right: groupGutter,
              bottom: MediaQuery.of(context).padding.bottom + groupGutter,
            ),
            decoration: const BoxDecoration(
              color: groupCardFill,
              borderRadius: groupSheetTopBorderRadiusXl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: AppDimensions.sheetDragHandleWidth,
                    height: AppDimensions.sheetDragHandleHeight,
                    decoration: BoxDecoration(
                      color: groupMutedBorderSoft,
                      borderRadius: BorderRadius.circular(groupRadiusHairline),
                    ),
                  ),
                ),
                const SizedBox(height: groupGapLg),
                Text(
                  AppStrings.groups.planExpense,
                  style: sub_headline5_text.copyWith(color: groupOnSurface),
                ),
                const SizedBox(height: groupGapLg),

                BorderedInputField(
                  controller: titleController,
                  labelText: AppStrings.groups.whatDoYouNeed,
                  hintText: AppStrings.groups.wishlistTitleHint,
                ),
                const SizedBox(height: groupGapMd),

                BorderedInputField(
                  controller: amountController,
                  labelText: AppStringFormat.estimatedAmountLabel(
                      userCurrencySymbol()),
                  hintText: AppStrings.groups.optional,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: groupGapLg),

                // Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final title = titleController.text.trim();
                      if (title.isEmpty) return;

                      final amount =
                          double.tryParse(amountController.text.trim());

                      Navigator.of(context).pop();

                      final success = await _service.addWishlistItem(
                        groupId: widget.groupId,
                        userId: widget.userId,
                        title: title,
                        estimatedAmount: amount,
                      );

                      if (success) {
                        await _loadItems();
                        SplitrToast.show(AppStrings.groups.itemAdded);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: neopopAccent,
                      foregroundColor: neopopBackground,
                      padding: const EdgeInsets.symmetric(vertical: groupGap14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(groupRadiusLgSm),
                      ),
                    ),
                    child: Text(
                      AppStrings.groups.addToWishlist,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: splitrFontBodyMd),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Upvote pill widget — shows count with thumb icon and accent highlight when upvoted.
class _UpvotePill extends StatelessWidget {
  final int count;
  final bool isUpvoted;
  final bool isDisabled;
  final VoidCallback onTap;

  const _UpvotePill({
    required this.count,
    required this.isUpvoted,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: AppMotion.standard,
        padding: const EdgeInsets.symmetric(
            horizontal: groupGap10, vertical: groupGapXs),
        decoration: BoxDecoration(
          color: isUpvoted ? neopopAccentFillMedium : groupMutedFillFaint,
          borderRadius: BorderRadius.circular(groupCardRadiusLg),
          border: Border.all(
            color:
                isUpvoted ? neopopAccentBorderStrong : groupMutedBorderHairline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isUpvoted ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
              size: groupIconSm,
              color: isUpvoted ? neopopAccent : groupOnSurfaceMuted,
            ),
            const SizedBox(width: groupGapXxs),
            Text(
              '$count',
              style: TextStyle(
                color: isUpvoted ? neopopAccent : groupOnSurface,
                fontWeight: FontWeight.w600,
                fontSize: splitrFontCaption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
