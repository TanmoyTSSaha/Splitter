import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Controllers/currency_controller.dart';

class SummaryStatCard extends StatelessWidget {
  final String title;
  final String amount;
  final String subtitle;
  final bool isPositive;

  const SummaryStatCard({
    super.key,
    required this.title,
    required this.amount,
    required this.subtitle,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Colored circle — fills the top-right corner of the card
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: (isPositive ? neopopAccent : neopopPrimary)
                      .withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: caption_text.copyWith(
                    color: neopopGrey,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final sym = Get.find<CurrencyController>().symbol;
                  return Text(
                    "$sym$amount",
                    style: headline2_text.copyWith(
                      color: isPositive ? neopopAccent : neopopPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      size: 14,
                      color: neopopGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      subtitle,
                      style: caption_text.copyWith(
                        color: neopopGrey,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
