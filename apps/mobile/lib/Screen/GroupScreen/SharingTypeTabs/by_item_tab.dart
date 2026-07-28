import 'package:flutter/material.dart';
import 'package:splitr/Utils/currency_utils.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/theme_accent_colors.dart';
import 'package:splitr/Controller/add_transaction_controller.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Widgets/user_avatar.dart';

import '../../../Model/group_model.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/business_rules.dart';

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
      final isValid = remaining.abs() < MoneyEpsilon.itemSplitRemaining;

      return Column(
        children: [
          // ── Header ──
          Text(
            SharingMode.byItem.tabTitle,
            style: sub_headline4_text.copyWith(color: groupOnSurface),
          ),
          const SizedBox(height: groupGapSm),
          Text(
            SharingMode.byItem.tabSubtitle,
            style: body1_text.copyWith(color: groupOnSurface),
          ),
          const SizedBox(height: groupGapMd),

          // ── Running total bar ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: groupGutter,
              vertical: groupGap10,
            ),
            decoration: BoxDecoration(
              color: isValid
                  ? AppPalette.shareCardSettledGreenSubtle
                  : neopopYellowFillSoft,
              borderRadius: BorderRadius.circular(groupRadiusMd),
              border: Border.all(
                color: isValid
                    ? AppPalette.shareCardSettledGreenBorder
                    : neopopYellow.withValues(
                        alpha: AppDimensions.cardShadowColorOpacity),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.groups.itemsTotal,
                  style: body2_text.copyWith(
                    color: groupOnSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "${userCurrencySymbol()}${_controller.totalItemPrice.value.toStringAsFixed(DefaultDecimalPlaces.amount)}",
                      style: sub_headline5_text.copyWith(
                        color: isValid
                            ? AppPalette.shareCardSettledGreen
                            : ThemeAccentColors.oweWarning(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      " / ${userCurrencySymbol()}${widget.totalAmount.toStringAsFixed(DefaultDecimalPlaces.amount)}",
                      style: body2_text.copyWith(
                        color: groupOnSurfaceMuted,
                      ),
                    ),
                    const SizedBox(width: groupGapSm),
                    Icon(
                      isValid
                          ? Icons.check_circle_rounded
                          : Icons.info_outline_rounded,
                      color: isValid
                          ? AppPalette.shareCardSettledGreen
                          : ThemeAccentColors.oweWarning(context),
                      size: groupCarouselIconSm,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: groupGapMd),

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
    final List<String> assignees =
        List<String>.from(item[SplitDetailKeys.assignees] ?? []);

    return Container(
      margin: const EdgeInsets.only(bottom: groupCarouselGap),
      padding: const EdgeInsets.all(groupGap14),
      decoration: BoxDecoration(
        color: shareCardFillWhisper,
        borderRadius: BorderRadius.circular(groupRadiusLgSm),
        border: Border.all(color: shareCardFillSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item number + delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: groupGap10, vertical: groupGap3),
                decoration: BoxDecoration(
                  color: neopopAccentFillLight,
                  borderRadius: BorderRadius.circular(groupRadiusMdSm),
                ),
                child: Text(
                  AppStringFormat.itemLabel(index + 1),
                  style: caption_text.copyWith(
                    color: neopopAccent,
                    fontWeight: FontWeight.w700,
                    fontSize: splitrFontCaptionSm,
                  ),
                ),
              ),
              if (_controller.itemSplitDetails.length > 1)
                GestureDetector(
                  onTap: () => _controller.removeItem(index),
                  child: Icon(
                    Icons.close_rounded,
                    color: shareCardBorderSoft,
                    size: groupCarouselIconSm,
                  ),
                ),
            ],
          ),
          const SizedBox(height: groupGapSm),

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
                    hintText: AppStrings.groups.itemNameHint,
                    hintStyle: body1_text.copyWith(
                      color: shareCardBorderSoft,
                    ),
                    filled: true,
                    fillColor: shareCardFillWhisper,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: groupCarouselGap, vertical: groupGap10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(groupRadiusMd),
                      borderSide: BorderSide(
                        color: shareCardFillMedium,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(groupRadiusMd),
                      borderSide: const BorderSide(color: neopopAccent),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: groupGapSm),

              // Price
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _controller.itemPriceControllers[index],
                  keyboardType: TextInputType.number,
                  style: body1_text.copyWith(
                    color: ThemeAccentColors.amount(context),
                    fontWeight: FontWeight.w600,
                  ),
                  onChanged: (value) =>
                      _controller.updateItemPrice(index, value),
                  decoration: InputDecoration(
                    isDense: true,
                    prefixText: currencyPrefixText(),
                    prefixStyle: body1_text.copyWith(
                      color: ThemeAccentColors.amount(context)
                          .withValues(alpha: 0.6),
                    ),
                    hintText: AppAmountHints.decimalWithSymbol,
                    hintStyle: body1_text.copyWith(
                      color: shareCardFillMedium,
                    ),
                    filled: true,
                    fillColor: shareCardFillWhisper,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: groupCarouselGap, vertical: groupGap10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(groupRadiusMd),
                      borderSide: BorderSide(
                        color: shareCardFillMedium,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(groupRadiusMd),
                      borderSide: const BorderSide(color: neopopYellow),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: groupGapSm),

          // Assignee label
          Text(
            AppStrings.groups.whoSharesThisItem,
            style: caption_text.copyWith(
              color: shareCardBorderStrong,
              fontSize: splitrFontCaptionSm,
            ),
          ),
          const SizedBox(height: groupGapSm),

          // Assignee chips
          Wrap(
            spacing: groupGapSm,
            runSpacing: groupGapSm,
            children: widget.groupMembersWithNameModel.map((member) {
              final isAssigned = assignees.contains(member.userID);

              return GestureDetector(
                onTap: () =>
                    _controller.toggleItemAssignee(index, member.userID!),
                child: AnimatedContainer(
                  duration: AppMotion.standard,
                  padding: const EdgeInsets.symmetric(
                      horizontal: groupGap10, vertical: groupGapXs),
                  decoration: BoxDecoration(
                    color: isAssigned
                        ? neopopAccentFillMedium
                        : shareCardFillWhisper,
                    borderRadius: BorderRadius.circular(groupCardRadiusLg),
                    border: Border.all(
                      color: isAssigned ? neopopAccent : shareCardFillMedium,
                      width: isAssigned
                          ? groupAccentBorderWidth
                          : AppDimensions.borderWidthHairline,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Avatar
                      UserAvatar(
                        userID: member.userID ?? "",
                        userName: member.userName ?? DisplayFallbacks.user,
                        imageUrl: member.userPic,
                        radius: AppDimensions.tripAvatarRadius,
                      ),
                      const SizedBox(width: groupGapXs),
                      Text(
                        member.userName!,
                        style: caption_text.copyWith(
                          color: isAssigned ? neopopAccent : shareCardIconDim,
                          fontWeight:
                              isAssigned ? FontWeight.w600 : FontWeight.w400,
                          fontSize: splitrFontCaption,
                        ),
                      ),
                      if (isAssigned) ...[
                        const SizedBox(width: groupGapXxs),
                        const Icon(Icons.check_rounded,
                            size: groupIconSm, color: neopopAccent),
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
        margin: const EdgeInsets.only(bottom: groupGap80),
        padding: const EdgeInsets.symmetric(vertical: groupGap14),
        decoration: BoxDecoration(
          color: neopopAccentFillFaint,
          borderRadius: BorderRadius.circular(groupControlRadius),
          border: Border.all(
            color: neopopAccentFillStrong,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_rounded,
              color: neopopAccentIconMedium,
              size: groupCarouselIconSm,
            ),
            const SizedBox(width: groupGapSm),
            Text(
              AppStrings.groups.addAnotherItem,
              style: body2_text.copyWith(
                color: neopopAccentScrim,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
