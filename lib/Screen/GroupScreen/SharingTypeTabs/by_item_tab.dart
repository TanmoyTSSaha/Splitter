import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Controller/add_transaction_controller.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitter/Widgets/user_avatar.dart';

import '../../../Model/group_model.dart';

/// Tab that lets users split an expense by individual items.
/// Each item has a name, price, and a set of assigned group members.
class ByItemTab extends StatefulWidget {
  final double totalAmount;
  final List<GroupMembersWithNameModel> groupMembersWithNameModel;

  const ByItemTab({
    super.key,
    required this.groupMembersWithNameModel,
    required this.totalAmount,
  });

  @override
  State<ByItemTab> createState() => _ByItemTabState();
}

class _ByItemTabState extends State<ByItemTab> {
  final AddTransactionScreenController _controller =
      Get.put(AddTransactionScreenController());

  @override
  void initState() {
    super.initState();
    _controller.initializeItemList();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final remaining = widget.totalAmount - _controller.totalItemPrice.value;
      final isValid = remaining.abs() < 0.01;

      return Column(
        children: [
          // ── Header ──
          Text(
            "Split by items",
            style: sub_headline4_text.copyWith(color: groupOnSurface),
          ),
          SizedBox(height: height_16 / 2),
          Text(
            "Add items and assign who shares each",
            style: body1_text.copyWith(color: groupOnSurface),
          ),
          SizedBox(height: height_16),

          // ── Running total bar ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isValid
                  ? Colors.green.withOpacity(0.1)
                  : neopopYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isValid
                    ? Colors.green.withOpacity(0.3)
                    : neopopYellow.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Items total",
                  style: body2_text.copyWith(
                    color: groupOnSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "₹${_controller.totalItemPrice.value.toStringAsFixed(2)}",
                      style: sub_headline5_text.copyWith(
                        color: isValid ? Colors.green : neopopYellow,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      " / ₹${widget.totalAmount.toStringAsFixed(2)}",
                      style: body2_text.copyWith(
                        color: groupOnSurfaceMuted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isValid
                          ? Icons.check_circle_rounded
                          : Icons.info_outline_rounded,
                      color: isValid ? Colors.green : neopopYellow,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: height_16),

          // ── Item list ──
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _controller.itemSplitDetails.length + 1,
              itemBuilder: (context, index) {
                if (index == _controller.itemSplitDetails.length) {
                  return _buildAddItemButton();
                }
                return _buildItemCard(index);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildItemCard(int index) {
    final item = _controller.itemSplitDetails[index];
    final List<String> assignees = List<String>.from(item["assignees"] ?? []);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: neopopOnPrimary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: neopopOnPrimary.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item number + delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: neopopAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "Item ${index + 1}",
                  style: caption_text.copyWith(
                    color: neopopAccent,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              if (_controller.itemSplitDetails.length > 1)
                GestureDetector(
                  onTap: () => _controller.removeItem(index),
                  child: Icon(
                    Icons.close_rounded,
                    color: neopopOnPrimary.withOpacity(0.3),
                    size: 18,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Name + Price row
          Row(
            children: [
              // Item name
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _controller.itemNameControllers[index],
                  style: body1_text.copyWith(color: neopopOnPrimary),
                  onChanged: (value) =>
                      _controller.updateItemName(index, value),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: "Item name",
                    hintStyle: body1_text.copyWith(
                      color: neopopOnPrimary.withOpacity(0.25),
                    ),
                    filled: true,
                    fillColor: neopopOnPrimary.withOpacity(0.04),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: neopopOnPrimary.withOpacity(0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: neopopAccent),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Price
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _controller.itemPriceControllers[index],
                  keyboardType: TextInputType.number,
                  style: body1_text.copyWith(
                    color: neopopYellow,
                    fontWeight: FontWeight.w600,
                  ),
                  onChanged: (value) =>
                      _controller.updateItemPrice(index, value),
                  decoration: InputDecoration(
                    isDense: true,
                    prefixText: "₹ ",
                    prefixStyle: body1_text.copyWith(
                      color: neopopYellow.withOpacity(0.6),
                    ),
                    hintText: "0.00",
                    hintStyle: body1_text.copyWith(
                      color: neopopOnPrimary.withOpacity(0.2),
                    ),
                    filled: true,
                    fillColor: neopopOnPrimary.withOpacity(0.04),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: neopopOnPrimary.withOpacity(0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: neopopYellow),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Assignee label
          Text(
            "Who shares this item?",
            style: caption_text.copyWith(
              color: neopopOnPrimary.withOpacity(0.4),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),

          // Assignee chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.groupMembersWithNameModel.map((member) {
              final isAssigned = assignees.contains(member.userID);

              return GestureDetector(
                onTap: () =>
                    _controller.toggleItemAssignee(index, member.userID!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isAssigned
                        ? neopopAccent.withOpacity(0.15)
                        : neopopOnPrimary.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isAssigned
                          ? neopopAccent
                          : neopopOnPrimary.withOpacity(0.1),
                      width: isAssigned ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Avatar
                      UserAvatar(
                        userID: member.userID ?? "",
                        userName: member.userName ?? "User",
                        imageUrl: member.userPic,
                        radius: 10,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        member.userName!,
                        style: caption_text.copyWith(
                          color: isAssigned
                              ? neopopAccent
                              : neopopOnPrimary.withOpacity(0.5),
                          fontWeight:
                              isAssigned ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                      if (isAssigned) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.check_rounded,
                            size: 12, color: neopopAccent),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddItemButton() {
    return GestureDetector(
      onTap: () => _controller.addItem(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 80),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: neopopAccent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: neopopAccent.withOpacity(0.2),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_rounded,
              color: neopopAccent.withOpacity(0.7),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              "Add another item",
              style: body2_text.copyWith(
                color: neopopAccent.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
