import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Controller/notification_badge_controller.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Screen/ProfileScreen/notifications_screen.dart';

/// Bell icon with an optional unseen-notification dot.
class NotificationBellButton extends StatelessWidget {
  final Color iconColor;
  final double iconSize;

  const NotificationBellButton({
    super.key,
    this.iconColor = neopopBackground,
    this.iconSize = AppDimensions.notificationBellIcon,
  });

  @override
  Widget build(BuildContext context) {
    final badgeController = Get.find<NotificationBadgeController>();

    return Obx(
      () => Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            onPressed: () async {
              await Get.to(() => const NotificationsScreen());
              await badgeController.updateBadge();
            },
            icon: Icon(
              Icons.notifications_outlined,
              color: iconColor,
              size: iconSize,
            ),
          ),
          if (badgeController.hasUnseen.value)
            Positioned(
              right: AppDimensions.notificationBellBadgePos,
              top: AppDimensions.notificationBellBadgePos,
              child: Container(
                width: AppDimensions.notificationBellBadge,
                height: AppDimensions.notificationBellBadge,
                decoration: BoxDecoration(
                  color: neopopAccent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: iconColor == neopopOnPrimary
                        ? neopopBackground
                        : groupCardFill,
                    width: AppDimensions.borderWidthStandard,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
