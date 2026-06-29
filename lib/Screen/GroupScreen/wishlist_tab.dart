import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:neopop/neopop.dart';
import 'package:splitter/Constants/shared.dart';
import 'package:splitter/Controller/group_screen_controller.dart';
import 'package:splitter/Widgets/tab_empty_state.dart';
import 'package:splitter/Screen/GroupScreen/add_transaction_screen.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitter/Model/wishlist_model.dart';
import 'package:splitter/Model/wishlist_prefill.dart';
import 'package:splitter/Services/realtime_service.dart';
import 'package:splitter/Services/supabase_service.dart';
import 'package:splitter/Services/wishlist_service.dart';
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
        title: 'No planned expenses yet',
        subtitle: 'Propose expenses the group should plan for.',
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
                const Icon(Icons.add_rounded, color: neopopBackground, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Add First Item',
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
      backgroundColor: Colors.white,
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
    );  }

  Widget _buildWishlistCard(WishlistItem item, int index) {
    final isAdded = item.isAddedToExpenses;

    return Opacity(
      opacity: isAdded ? 0.55 : 1.0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(groupGapMd),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAdded
                ? Colors.green.withValues(alpha: 0.35)
                : neopopGrey.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: neopopBackground.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isAdded
                        ? Colors.green.withValues(alpha: 0.12)
                        : neopopAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isAdded
                        ? Icons.check_circle_rounded
                        : Icons.lightbulb_rounded,
                    color: isAdded ? Colors.green.shade700 : neopopAccent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: body1_text.copyWith(
                          color: neopopBackground,
                          fontWeight: FontWeight.w600,
                          decoration:
                              isAdded ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'by ${item.addedByName}',
                        style: caption_text.copyWith(
                          color: neopopGrey,
                          fontSize: 12,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.estimatedAmount != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: neopopAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '₹${item.estimatedAmount!.toStringAsFixed(0)}',
                      style: body2_text.copyWith(
                        color: neopopBackground,
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
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_task_rounded,
                            color: Colors.green.shade700,
                            size: 15,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Add as Expense',
                            style: caption_text.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Text(
                    'Added ✓',
                    style: caption_text.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                if (item.addedByUserId == widget.userId && !isAdded) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _deleteItem(item),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: neopopGrey,
                      size: 20,
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
            'group_id': widget.groupId,
            'group_name': widget.groupName,
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
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Could not open add expense: $e',
          textColor: neopopBackground,
          backgroundColor: neopopYellow,
        );
      }
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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).padding.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: neopopGrey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Plan an Expense',
                  style: sub_headline5_text.copyWith(color: neopopBackground),
                ),
                const SizedBox(height: 20),

                // Title
                TextField(
                  controller: titleController,
                  style: body1_text.copyWith(color: neopopBackground),
                  decoration: InputDecoration(
                    hintText: 'e.g. Birthday cake for Alex',
                    hintStyle: body1_text.copyWith(
                      color: neopopGrey,
                    ),
                    labelText: 'What do you need?',
                    labelStyle: caption_text.copyWith(
                      color: neopopAccent,
                    ),
                    filled: true,
                    fillColor: neopopBackground.withOpacity(0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: neopopBackground.withOpacity(0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: neopopAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Amount (optional)
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: body1_text.copyWith(color: neopopBackground),
                  decoration: InputDecoration(
                    hintText: 'Optional',
                    hintStyle: body1_text.copyWith(
                      color: neopopGrey,
                    ),
                    labelText: 'Estimated Amount (₹)',
                    labelStyle: caption_text.copyWith(
                      color: neopopAccent,
                    ),
                    filled: true,
                    fillColor: neopopBackground.withOpacity(0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: neopopBackground.withOpacity(0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: neopopAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

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
                        Fluttertoast.showToast(
                          msg: 'Item added! 🎯',
                          textColor: neopopBackground,
                          backgroundColor: neopopAccent,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: neopopAccent,
                      foregroundColor: neopopBackground,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Add to Wishlist',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isUpvoted
              ? neopopAccent.withValues(alpha: 0.15)
              : neopopSecondaryGrey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUpvoted
                ? neopopAccent.withValues(alpha: 0.4)
                : neopopGrey.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isUpvoted ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
              size: 14,
              color: isUpvoted ? neopopAccent : neopopGrey,
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                color: isUpvoted ? neopopAccent : neopopBackground,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}