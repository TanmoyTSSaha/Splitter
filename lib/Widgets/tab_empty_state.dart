import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';

enum TabEmptyVariant {
  activity,
  transactions,
  settleUpNoSplits,
  settleUpAllSettled,
  wishlist,
  analytics,
  members,
  generic,
}

const _kRupeeCoinDotLottie = 'assets/lottie/Rupee Coin.lottie';
const _kRupeeCoinJson = 'assets/lottie/rupee_coin.json';

Future<LottieComposition?> _decodeDotLottie(List<int> bytes) {
  return LottieComposition.decodeZip(
    bytes,
    filePicker: (files) {
      for (final file in files) {
        if (file.name.startsWith('animations/') &&
            file.name.endsWith('.json')) {
          return file;
        }
      }
      return null;
    },
  );
}

class RupeeCoinAnimation extends StatelessWidget {
  final double size;

  const RupeeCoinAnimation({super.key, this.size = 180});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: Lottie.asset(
          _kRupeeCoinDotLottie,
          decoder: _decodeDotLottie,
          repeat: true,
          animate: true,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Lottie.asset(
              _kRupeeCoinJson,
              repeat: true,
              animate: true,
              fit: BoxFit.contain,
            );
          },
        ),
      ),
    );
  }
}

class TabEmptyState extends StatefulWidget {
  final String title;
  final String? subtitle;
  final TabEmptyVariant variant;
  final Widget? action;
  final bool compact;

  const TabEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.variant = TabEmptyVariant.generic,
    this.action,
    this.compact = false,
  });

  @override
  State<TabEmptyState> createState() => _TabEmptyStateState();
}

class _TabEmptyStateState extends State<TabEmptyState>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final animationSize = widget.compact ? 120.0 : 180.0;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: groupGapMd,
          vertical: widget.compact ? groupGapMd : groupGapLg,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            RupeeCoinAnimation(size: animationSize),
            SizedBox(height: widget.compact ? groupGapMd : groupGapLg),
            Text(
              widget.title,
              style: TextStyle(
                fontFamily: 'Albra',
                fontSize: widget.compact ? 20 : 24,
                fontWeight: FontWeight.w700,
                color: neopopBackground,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: groupGapSm),
              Text(
                widget.subtitle!,
                style: body2_text.copyWith(
                  color: neopopGrey,
                  height: 1.4,
                  fontSize: widget.compact ? 13 : 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (widget.action != null) ...[
              const SizedBox(height: groupGapLg),
              widget.action!,
            ],
          ],
        ),
      ),
    );
  }
}
