import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:splitr/Constants/app_dimensions.dart';

import 'package:splitr/Constants/constants.dart';

import 'package:splitr/Constants/domain_values.dart';

import 'package:splitr/Controllers/currency_controller.dart';

import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

import 'package:splitr/Utils/transaction_date_formatter.dart';

class TransactionTile extends StatelessWidget {
  final Map<String, dynamic> txn;

  final bool showDate;

  final bool showFlowArrow;

  final VoidCallback? onLongPress;

  const TransactionTile({
    super.key,
    required this.txn,
    this.showDate = true,
    this.showFlowArrow = true,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCredit = txn[UnifiedTxnKeys.isCredit] ?? false;

    final bool isGroup = txn[UnifiedTxnKeys.type] == TransactionTypes.group;

    final Color amountColor = isCredit ? neopopAccent : neopopPrimary;

    final DateTime? date = txn[UnifiedTxnKeys.date] as DateTime?;

    return GestureDetector(
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: groupGutter),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(groupCarouselGap),
              decoration: const BoxDecoration(
                color: groupChipTrackBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(
                  txn[UnifiedTxnKeys.category] ??
                      (isGroup
                          ? CategorySlugValues.group
                          : CategorySlugValues.receipt),
                ),
                color: neopopBackground,
                size: AppDimensions.groupIconMd,
              ),
            ),
            const SizedBox(width: groupGutter),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          txn[UnifiedTxnKeys.title]?.toString() ??
                              DisplayFallbacks.untitled,
                          style: body1_text.copyWith(
                            fontWeight: FontWeight.bold,
                            color: neopopBackground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isGroup) ...[
                        const SizedBox(width: groupGapXs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: groupGapXs,
                            vertical: groupGap2,
                          ),
                          decoration: BoxDecoration(
                            color: neopopAccentFillLight,
                            borderRadius: BorderRadius.circular(groupRadiusSm),
                          ),
                          child: Text(
                            DisplayFallbacks.group,
                            style: caption_text.copyWith(
                              color: neopopAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: splitrFontNanoSm,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: groupGap2),
                  Row(
                    children: [
                      if (showDate && date != null) ...[
                        Flexible(
                          child: Text(
                            TransactionDateFormatter.formatRelative(date),
                            style: caption_text.copyWith(
                              color: neopopGrey,
                              fontStyle: FontStyle.normal,
                              fontSize: splitrFontMicro,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if ((txn['subtitle']?.toString() ?? '').isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: groupGapXs,
                            ),
                            child: Text(
                              DisplaySeparators.pipe,
                              style: caption_text.copyWith(
                                color: neopopGreyIconMuted,
                                fontSize: splitrFontMicro,
                              ),
                            ),
                          ),
                        ],
                      ],
                      if ((txn['subtitle']?.toString() ?? '').isNotEmpty)
                        Flexible(
                          child: Text(
                            txn['subtitle']?.toString() ?? '',
                            style: caption_text.copyWith(
                              color: neopopGrey,
                              fontStyle: FontStyle.normal,
                              fontSize: splitrFontMicro,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (showFlowArrow) ...[
              const SizedBox(width: groupGapXxs),
              Icon(
                isCredit ? Icons.south_west : Icons.north_east,
                color: isCredit ? neopopAccent : neopopPrimary,
                size: groupIconMd,
              ),
            ],
            const SizedBox(width: groupGapSm),
            Obx(() {
              final sym = Get.find<CurrencyController>().symbol;

              return Text(
                "$sym${(txn[UnifiedTxnKeys.amount] as num).toStringAsFixed(0)}",
                style: body1_text.copyWith(
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    String cat = category.toLowerCase();

    if (cat.contains(CategorySlugValues.food) ||
        cat.contains(CategorySlugValues.dining) ||
        cat.contains(CategorySlugValues.restaurant)) {
      return Icons.restaurant_rounded;
    }

    if (cat.contains(CategorySlugValues.home) ||
        cat.contains(CategorySlugValues.rent) ||
        cat.contains(CategorySlugValues.apartment)) {
      return Icons.home_rounded;
    }

    if (cat.contains(CategorySlugValues.travel) ||
        cat.contains(CategorySlugValues.trip)) {
      return Icons.flight_takeoff_rounded;
    }

    if (cat.contains(CategorySlugValues.settlement)) {
      return Icons.swap_horiz_rounded;
    }

    if (cat.contains(CategorySlugValues.group)) return Icons.group_rounded;

    if (cat.contains(CategorySlugValues.income) ||
        cat.contains(CategorySlugValues.salary)) {
      return Icons.account_balance_wallet_rounded;
    }

    if (cat.contains(CategorySlugValues.refund) ||
        cat.contains(CategorySlugValues.cashback)) {
      return Icons.replay_rounded;
    }

    return Icons.receipt_long_rounded;
  }
}
