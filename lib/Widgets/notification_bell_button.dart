import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Controller/notification_badge_controller.dart';
import 'package:splitter/Screen/NotificationScreen/notification_screen.dart';

/// Bell icon with an optional unseen-notification dot.
class NotificationBellButton extends StatelessWidget {
  final Color iconColor;
  final double iconSize;

  const NotificationBellButton({
    super.key,
    this.iconColor = neopopBackground,
    this.iconSize = 28,
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
              await Get.to(() => const NotificationScreen());
              await badgeController.markViewed();
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
              right: 10,
              top: 10,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: neopopAccent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: iconColor == neopopOnPrimary
                        ? neopopBackground
                        : Colors.white,
                    width: 1.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
