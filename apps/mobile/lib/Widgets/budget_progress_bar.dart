import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

/// Green = spend within limit; red = amount over limit.
class BudgetProgressBar extends StatelessWidget {
  final double spent;
  final double limit;
  final double height;

  const BudgetProgressBar({
    super.key,
    required this.spent,
    required this.limit,
    this.height = 8,
  });

  static const Color withinColor = Color(0xFF18C595);
  static const Color overColor = Color(0xFFE53935);
  static const Color trackColor = Color(0xFFE0E0E0);

  static int _flexWeight(double amount, double total) {
    if (amount <= 0 || total <= 0) return 0;
    return math.max(1, (amount / total * 10000).round());
  }

  @override
  Widget build(BuildContext context) {
    if (limit <= 0) {
      return SizedBox(height: height);
    }

    final segments = <_ProgressSegment>[];

    if (spent <= limit) {
      final usedFlex = _flexWeight(spent, limit);
      final remainFlex = _flexWeight(limit - spent, limit);
      if (usedFlex > 0) {
        segments.add(_ProgressSegment(flex: usedFlex, color: withinColor));
      }
      if (remainFlex > 0) {
        segments.add(_ProgressSegment(flex: remainFlex, color: trackColor));
      }
    } else {
      final total = spent;
      final withinFlex = _flexWeight(limit, total);
      final overFlex = _flexWeight(spent - limit, total);
      if (withinFlex > 0) {
        segments.add(_ProgressSegment(flex: withinFlex, color: withinColor));
      }
      if (overFlex > 0) {
        segments.add(_ProgressSegment(flex: overFlex, color: overColor));
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(groupRadiusSm),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: segments.isEmpty
            ? const ColoredBox(color: trackColor)
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
    );
  }
}

class _ProgressSegment {
  final int flex;
  final Color color;

  const _ProgressSegment({required this.flex, required this.color});
}
