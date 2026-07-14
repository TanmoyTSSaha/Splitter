import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:splitr/Constants/app_assets.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

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

Future<LottieComposition?> _decodeDotLottie(List<int> bytes) {
  return LottieComposition.decodeZip(
    bytes,
    filePicker: (files) {
      for (final file in files) {
        if (file.name.startsWith(AppAssets.lottieAnimationsDir) &&
            file.name.endsWith(AppAssets.lottieJsonSuffix)) {
          return file;
        }
      }
      return null;
    },
  );
}

class RupeeCoinAnimation extends StatelessWidget {
  final double size;

  const RupeeCoinAnimation(
      {super.key, this.size = AppDimensions.groupEmptyAnimationSizeLg});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: Lottie.asset(
          AppAssets.lottieRupeeCoin,
          decoder: _decodeDotLottie,
          repeat: true,
          animate: true,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Lottie.asset(
              AppAssets.lottieRupeeCoinFallback,
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

    final animationSize = widget.compact
        ? AppDimensions.groupEmptyAnimationSizeMd
        : AppDimensions.groupEmptyAnimationSizeLg;

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
                fontFamily: kFontAlbra,
                fontSize: widget.compact
                    ? AppDimensions.tabEmptyTitleCompact
                    : AppDimensions.tabEmptyTitle,
                fontWeight: FontWeight.w700,
                color: groupOnSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: groupGapSm),
              Text(
                widget.subtitle!,
                style: body2_text.copyWith(
                  color: groupOnSurfaceMuted,
                  height: groupLineHeightRelaxed,
                  fontSize: widget.compact
                      ? AppDimensions.tabEmptySubtitleCompact
                      : AppDimensions.tabEmptySubtitle,
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
