import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neopop/neopop.dart';
import 'package:splitr/Constants/app_assets.dart';
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GoalScreen/create_goal_screen.dart';
import 'package:splitr/Screen/GroupScreen/create_group_screen.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Screen/HomeScreen/add_personal_transaction_screen.dart';

class HomeEmptyState extends StatefulWidget {
  final String? userName;
  final Future<void> Function() onActionComplete;

  const HomeEmptyState({
    super.key,
    this.userName,
    required this.onActionComplete,
  });

  @override
  State<HomeEmptyState> createState() => _HomeEmptyStateState();
}

class _HomeEmptyStateState extends State<HomeEmptyState>
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
      CurvedAnimation(
        parent: _controller,
        curve: AppCurves.emptyStateFloat,
      ),
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
    final greetingName = widget.userName?.trim();
    final title = (greetingName != null && greetingName.isNotEmpty)
        ? '${AppStrings.home.welcomeNamed}$greetingName'
        : '${AppStrings.home.welcomeBrand}${AppBranding.brandName}';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: groupGutter,
        vertical: groupGutter,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: Get.height * 0.02),
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
                  image: AssetImage(AppAssets.emptyStateSplittingBills),
                  fit: BoxFit.contain,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: neopopAccentFillLight,
                    blurRadius: AppDimensions.homeHeroShadowBlur,
                    spreadRadius: AppDimensions.homeHeroShadowSpread,
                    offset: Offset(0, AppAnimationOffsets.emptyStateTranslateY),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: groupGapLg),
          TweenAnimationBuilder<double>(
            duration: AppMotion.emptyStateFadeIn,
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
                  title,
                  style: const TextStyle(
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
                  AppStrings.home.emptyPickFirstStep,
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
          _buildPrimaryCta(
            label: AppStrings.home.createGroup,
            icon: Icons.groups_2_rounded,
            onTap: () => _navigateAndRefresh(
              Get.to(() => const CreateGroupScreen()),
            ),
          ),
          const SizedBox(height: groupGapSm),
          _buildSecondaryCta(
            label: AppStrings.home.addTransaction,
            icon: Icons.receipt_long_rounded,
            onTap: () => _navigateAndRefresh(
              Get.to(() => const AddPersonalTransactionScreen()),
            ),
          ),
          const SizedBox(height: groupGapSm),
          _buildSecondaryCta(
            label: AppStrings.home.setGoal,
            icon: Icons.flag_rounded,
            onTap: () => _navigateAndRefresh(
              Get.to(() => const CreateGoalScreen()),
            ),
          ),
          const SizedBox(height: groupFabClearance),
        ],
      ),
    );
  }

  Widget _buildPrimaryCta({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: NeoPopButton(
        color: neopopAccent,
        buttonPosition: Position.fullBottom,
        onTapUp: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: groupGutter,
            vertical: groupGapMd,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: neopopBackground, size: AppDimensions.groupIconMd),
              const SizedBox(width: groupGapSm),
              Text(
                label,
                style: button_text.copyWith(
                  color: neopopBackground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryCta({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: neopopBackground,
          side: BorderSide(color: neopopBackground.withValues(alpha: 0.2)),
          padding: const EdgeInsets.symmetric(vertical: groupGap14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(groupControlRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppDimensions.groupIconMd),
            const SizedBox(width: groupGapSm),
            Text(
              label,
              style: button_text.copyWith(
                color: neopopBackground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
