import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Model/badge_model.dart';

/// Shows a celebratory snackbar when a badge is newly unlocked.
void showBadgeUnlockToast(BadgeModel badge) {
  Get.snackbar(
    '🏆 Badge Unlocked',
    badge.name,
    messageText: Text(
      badge.description,
      style: body2_text.copyWith(color: neopopBackground.withOpacity(0.9)),
    ),
    backgroundColor: neopopAccent.withOpacity(0.95),
    colorText: neopopBackground,
    duration: const Duration(seconds: 4),
    margin: EdgeInsets.all(height_16),
    borderRadius: 12,
    icon: const Icon(Icons.emoji_events_rounded, color: neopopBackground),
  );
}
