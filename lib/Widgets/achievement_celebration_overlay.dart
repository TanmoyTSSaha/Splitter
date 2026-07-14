import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:splitr/Constants/achievement_icon_map.dart';
import 'package:splitr/Constants/app_assets.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Controller/achievement_controller.dart';
import 'package:splitr/Model/achievement_model.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

/// Global host — stacks celebration overlay above all routes.
class AchievementCelebrationHost extends StatelessWidget {
  const AchievementCelebrationHost({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AchievementController>()) {
      return child;
    }
    final controller = Get.find<AchievementController>();
    return Obx(() {
      final active = controller.activeCelebration.value;
      return Stack(
        fit: StackFit.expand,
        children: [
          child,
          if (active != null)
            AchievementCelebrationOverlay(
              achievement: active,
              onComplete: controller.onCelebrationComplete,
            ),
        ],
      );
    });
  }
}

class AchievementCelebrationOverlay extends StatefulWidget {
  const AchievementCelebrationOverlay({
    required this.achievement,
    required this.onComplete,
    super.key,
  });

  final AchievementModel achievement;
  final Future<void> Function() onComplete;

  @override
  State<AchievementCelebrationOverlay> createState() =>
      _AchievementCelebrationOverlayState();
}

class _AchievementCelebrationOverlayState extends State<AchievementCelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: AppMotion.medium,
    );
    _scale = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _scaleController.forward();
    Future.delayed(AppMotion.achievementCelebration, _finish);
  }

  Future<void> _finish() async {
    if (!mounted) return;
    await widget.onComplete();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assetPath = AchievementIconMap.assetFor(widget.achievement.iconKey);
    return IgnorePointer(
      child: Material(
        color: Colors.black.withValues(alpha: 0.82),
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: Lottie.asset(
                    AppAssets.lottieRupeeCoinFallback,
                    repeat: false,
                  ),
                ),
                const SizedBox(height: groupGapMd),
                _buildIcon(assetPath),
                const SizedBox(height: groupGapMd),
                Text(
                  AppStrings.insights.badgeUnlocked,
                  style: headline3_text.copyWith(
                    color: neopopBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: groupGapSm),
                Text(
                  widget.achievement.name,
                  textAlign: TextAlign.center,
                  style: headline2_text.copyWith(color: neopopAccent),
                ),
                const SizedBox(height: groupGapSm),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: groupGutter),
                  child: Text(
                    widget.achievement.description,
                    textAlign: TextAlign.center,
                    style: body2_text.copyWith(color: neopopBackgroundOverlay),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(String? assetPath) {
    final border = BoxDecoration(
      color: neopopAccentFillSoft,
      borderRadius: BorderRadius.circular(groupRadiusBadge),
      border: Border.all(color: neopopAccent, width: 2),
    );
    if (assetPath != null) {
      return Container(
        height: 88,
        width: 88,
        decoration: border,
        padding: const EdgeInsets.all(groupCarouselGap),
        child: Image.asset(
          assetPath,
          errorBuilder: (_, __, ___) => Icon(
            AchievementIconMap.iconFor(widget.achievement.iconKey),
            size: 40,
            color: neopopAccent,
          ),
        ),
      );
    }
    return Container(
      height: 88,
      width: 88,
      decoration: border,
      child: Icon(
        AchievementIconMap.iconFor(widget.achievement.iconKey),
        size: 40,
        color: neopopAccent,
      ),
    );
  }
}
