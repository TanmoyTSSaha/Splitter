import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Controllers/currency_controller.dart';

class TransactionTile extends StatelessWidget {
  final Map<String, dynamic> txn;

  const TransactionTile({super.key, required this.txn});

  @override
  Widget build(BuildContext context) {
    bool isCredit = txn['is_credit'] ?? false;
    bool isGroup = txn['type'] == 'group';
    String amountPrefix = isCredit ? '+' : '-';
    Color amountColor = isCredit ? neopopAccent : neopopPrimary;

    return Container(
      margin: EdgeInsets.only(bottom: height_16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: neopopSecondaryGrey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getCategoryIcon(
                  txn['category'] ?? (isGroup ? 'group' : 'receipt')),
              color: neopopBackground,
              size: 20,
            ),
          ),
          SizedBox(width: width_16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        txn['title']?.toString() ?? "Untitled",
                        style: body1_text.copyWith(
                          fontWeight: FontWeight.bold,
                          color: neopopBackground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isGroup) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: neopopAccent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "Group",
                          style: caption_text.copyWith(
                            color: neopopAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  txn['subtitle']?.toString() ?? "",
                  style: caption_text.copyWith(
                    color: neopopGrey,
                    fontStyle: FontStyle.normal,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            final sym = Get.find<CurrencyController>().symbol;
            return Text(
              "$amountPrefix $sym${txn['amount'].toStringAsFixed(0)}",
              style: body1_text.copyWith(
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    String cat = category.toLowerCase();
    if (cat.contains('food') ||
        cat.contains('dining') ||
        cat.contains('restaurant')) return Icons.restaurant_rounded;
    if (cat.contains('home') ||
        cat.contains('rent') ||
        cat.contains('apartment')) return Icons.home_rounded;
    if (cat.contains('travel') || cat.contains('trip'))
      return Icons.flight_takeoff_rounded;
    if (cat.contains('settlement')) return Icons.swap_horiz_rounded;
    if (cat.contains('group')) return Icons.group_rounded;
    if (cat.contains('income') || cat.contains('salary'))
      return Icons.account_balance_wallet_rounded;
    if (cat.contains('refund') || cat.contains('cashback'))
      return Icons.replay_rounded;
    return Icons.receipt_long_rounded;
  }
}
