import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neopop/neopop.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/create_group_screen.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/app_assets.dart';
import 'package:splitr/Constants/app_strings.dart';

class GroupEmptyState extends StatefulWidget {
  final Future<void> Function() onActionComplete;

  const GroupEmptyState({
    super.key,
    required this.onActionComplete,
  });

  @override
  State<GroupEmptyState> createState() => _GroupEmptyStateState();
}

class _GroupEmptyStateState extends State<GroupEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppMotion.emptyStateFloat,
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: 0,
      end: AppAnimationOffsets.emptyStateFloatEnd,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.emptyStateFloat),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigateAndRefresh(Future<dynamic>? navigation) async {
    final result = await navigation;
    if (result == true) {
      await widget.onActionComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: groupGutter,
        vertical: groupGapMd,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: Get.height * 0.04),
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: child,
              );
            },
            child: Container(
              height: AppDimensions.homeHeroImageSize,
              width: AppDimensions.homeHeroImageSize,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage(
                    AppAssets.emptyStateSplittingBills,
                  ),
                  fit: BoxFit.contain,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: neopopAccentFillLight,
                    blurRadius: AppDimensions.homeHeroShadowBlur,
                    spreadRadius: AppDimensions.homeHeroShadowSpread,
                    offset: const Offset(0, groupGap20),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: groupGapLg),
          TweenAnimationBuilder<double>(
            duration: AppMotion.syncPulse,
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0,
                      AppAnimationOffsets.emptyStateTranslateY * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                Text(
                  AppStrings.groups.noGroupsYet,
                  style: TextStyle(
                    fontFamily: kFontAlbra,
                    fontSize: splitrFontHeadline2,
                    fontWeight: FontWeight.w700,
                    color: neopopBackground,
                    letterSpacing: AppDimensions.letterSpacingWide,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: groupGapSm),
                Text(
                  AppStrings.groups.emptyStateExtendedSubtitle,
                  style: body1_text.copyWith(
                    color: groupOnSurfaceMuted,
                    height: 1.5,
                    fontSize: splitrFontBody,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: groupGapLg),
          SizedBox(
            width: double.infinity,
            child: NeoPopButton(
              color: neopopAccent,
              buttonPosition: Position.fullBottom,
              onTapUp: () => _navigateAndRefresh(
                Get.to(() => const CreateGroupScreen()),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: groupGutter,
                  vertical: groupGapMd,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.groups_2_rounded,
                      color: neopopBackground,
                      size: AppDimensions.groupIconMd,
                    ),
                    const SizedBox(width: groupGapSm),
                    Text(
                      AppStrings.groups.createGroup,
                      style: button_text.copyWith(
                        color: neopopBackground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: groupFabClearance),
        ],
      ),
    );
  }
}
