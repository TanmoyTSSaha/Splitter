import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:splitr/Model/loan_model.dart';
import 'package:splitr/Model/repayment_schedule.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

/// Stacked bar: green = principal paid, amber = interest paid, gray = remaining.
class LoanRepaymentProgressBar extends StatelessWidget {
  final LoanRepaymentAllocation allocation;
  final double height;

  const LoanRepaymentProgressBar({
    super.key,
    required this.allocation,
    this.height = 12,
  });

  factory LoanRepaymentProgressBar.fromLoan(
    LoanModel loan, {
    double height = 12,
  }) {
    return LoanRepaymentProgressBar(
      allocation: loan.repaymentAllocation,
      height: height,
    );
  }

  static const Color principalPaidColor = Color(0xFF2E7D32);
  static const Color interestPaidColor = Color(0xFFFFC107);
  static const Color remainingTrackColor = Color(0xFFD0D5DD);

  static int _flexWeight(double amount, double total) {
    if (amount <= 0 || total <= 0) return 0;
    return math.max(1, (amount / total * 10000).round());
  }

  @override
  Widget build(BuildContext context) {
    final total = allocation.totalPayable;
    if (total <= 0) {
      return SizedBox(height: height);
    }

    final principalFlex = _flexWeight(allocation.principalPaid, total);
    final interestFlex = _flexWeight(allocation.interestPaid, total);
    final remainingFlex = _flexWeight(allocation.totalRemaining, total);

    final segments = <_ProgressSegment>[];
    if (principalFlex > 0) {
      segments.add(
        _ProgressSegment(flex: principalFlex, color: principalPaidColor),
      );
    }
    if (interestFlex > 0) {
      segments.add(
        _ProgressSegment(flex: interestFlex, color: interestPaidColor),
      );
    }
    if (remainingFlex > 0) {
      segments.add(
        _ProgressSegment(flex: remainingFlex, color: remainingTrackColor),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(groupRadiusSm),
        border: Border.all(color: groupMutedBorderStrong),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(groupRadiusSm - 1),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: segments.isEmpty
              ? const ColoredBox(color: remainingTrackColor)
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final segment in segments)
                      Expanded(
                        flex: segment.flex,
                        child: ColoredBox(color: segment.color),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ProgressSegment {
  final int flex;
  final Color color;

  const _ProgressSegment({required this.flex, required this.color});
}
