import 'package:flutter/material.dart';

import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/business_rules.dart';

/// Animated check when settle-up health is strong (F7).
class RecapSettlementTick extends StatefulWidget {
  const RecapSettlementTick({
    super.key,
    required this.settleUpHealthScore,
    this.size = 28,
  });

  final int settleUpHealthScore;
  final double size;

  static bool shouldShow(int settleUpHealthScore) =>
      settleUpHealthScore >= RecapThresholds.settlementTickMinScore;

  @override
  State<RecapSettlementTick> createState() => _RecapSettlementTickState();
}

class _RecapSettlementTickState extends State<RecapSettlementTick>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    if (RecapSettlementTick.shouldShow(widget.settleUpHealthScore)) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant RecapSettlementTick oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (RecapSettlementTick.shouldShow(widget.settleUpHealthScore) &&
        !RecapSettlementTick.shouldShow(oldWidget.settleUpHealthScore)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!RecapSettlementTick.shouldShow(widget.settleUpHealthScore)) {
      return const SizedBox.shrink();
    }

    return ScaleTransition(
      scale: _scale,
      child: Icon(
        Icons.check_circle_rounded,
        color: AppPalette.shareCardSettledGreen,
        size: widget.size,
      ),
    );
  }
}
