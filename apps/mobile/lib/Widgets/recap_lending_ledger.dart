import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Model/loan_payment_recap_row.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Widgets/recap_stagger_reveal.dart';

/// Up to 3 staggered ledger rows for lending recap slide (F8).
class RecapLendingLedger extends StatelessWidget {
  const RecapLendingLedger({
    required this.rows,
    required this.currencySymbol,
    super.key,
  });

  final List<LoanPaymentRecapRow> rows;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();

    final visible = rows.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < visible.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i < visible.length - 1 ? 8 : 0),
            child: RecapStaggerReveal(
              index: i,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: groupGapMd,
                  vertical: groupGapSm,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppPalette.recapBorder),
                  color: AppPalette.recapCardFill.withValues(alpha: 0.35),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        visible[i].counterparty,
                        style: TextStyle(
                          fontFamily: kFontCourier,
                          fontSize: splitrFontCaption,
                          color: AppPalette.recapOnSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '$currencySymbol${NumberFormat(AppDateFormats.numberGrouped).format(visible[i].amount)}',
                      style: TextStyle(
                        fontFamily: kFontCourier,
                        fontWeight: FontWeight.bold,
                        fontSize: splitrFontCaption,
                        color: AppPalette.mintAccent,
                      ),
                    ),
                    const SizedBox(width: groupGapSm),
                    Text(
                      DateFormat(AppDateFormats.shortDay)
                          .format(visible[i].paidAt),
                      style: TextStyle(
                        fontFamily: kFontCourier,
                        fontSize: splitrFontMicro,
                        color: AppPalette.recapOnSurfaceMuted,
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
}
