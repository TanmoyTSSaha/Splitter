import 'package:flutter/material.dart';
import 'package:splitr/Constants/constants.dart';

/// Semantic colors not covered by neopop*/group*/shareCard* tokens.
abstract final class AppPalette {
  static const labelMuted = Color(0xFF91919F);
  static const premiumDark = Color(0xFF0F0F0F);
  static const accentPurple = Color(0xFF8B5CF6);
  static const surfaceMuted = Color(0xFFEEEEEE);
  static const chipTrackBg = Color(0xFFE8E8E8);
  static const surfaceMutedFill = Color(0xFFF5F5F5);
  static const cardDarkFill = Color(0xFF1E1E1E);
  static const mintAccent = Color(0xFF1DE9B6);
  static const avatarGlowGreen = Color(0xFFB5F542);
  static const recapLightBg = Color(0xFFFAFAFA);
  static const recapLightBorder = Color(0xFFE0E0E0);
  static const recapMutedFill = Color(0xFFF5F5F7);
  /// NeoPOP dark story slides (Feature 14).
  static const recapOnSurface = Color(0xFFFFFFFF);
  static const recapOnSurfaceMuted = Color(0xFF8A8D8E);
  static const recapBorder = Color(0xFF323232);
  static const recapCardFill = cardDarkFill;
  static const shareCardGradientStart = Color(0xFF1A1A2E);
  static const shareCardGradientMid = Color(0xFF16213E);
  static const shareCardGradientEnd = Color(0xFF0F3460);
  static const shareCardSettledGreen = Color(0xFF00C853);
  static Color get shareCardSettledGreenFill =>
      shareCardSettledGreen.withValues(alpha: 0.15);
  static Color get shareCardSettledGreenBorder =>
      shareCardSettledGreen.withValues(alpha: 0.3);
  static Color get shareCardSettledGreenSubtle =>
      shareCardSettledGreen.withValues(alpha: 0.1);
  static const onboardingTeal = Color(0xFF00C9A7);
  static const onboardingPurpleStart = Color(0xFF667EEA);
  static const onboardingPurpleEnd = Color(0xFF764BA2);
  static const onboardingPinkStart = Color(0xFFF093FB);
  static const onboardingPinkEnd = Color(0xFFF5576C);
  static const tripPurpleStart = Color(0xFF5C54DB);
  static const tripPurpleEnd = Color(0xFF4A40BF);
  static const tripOrangeStart = Color(0xFFF25C30);
  static const tripOrangeEnd = Color(0xFFD94A1E);
  static const tripIndigoStart = Color(0xFF6C63FF);
  static const tripIndigoEnd = Color(0xFF483D8B);
  static const greyIcon = Color(0xFF9E9E9E);
  static const greyIconDark = Color(0xFF757575);
  static const categoryOrange = Color(0xFFFF9800);
  static const categoryPink = Color(0xFFE91E63);
  static const categoryBlue = Color(0xFF2196F3);
  static const categoryGreen = Color(0xFF4CAF50);
  static const categoryPurple = Color(0xFF9C27B0);
  static const razorpayTheme = Color(0xFF18C595);
}

/// Wishlist added-state greens (Material green 700 family).
abstract final class WishlistPalette {
  static const successGreen = Color(0xFF388E3C);
  static Color get border => successGreen.withValues(alpha: 0.35);
  static Color get iconFill => successGreen.withValues(alpha: 0.12);
  static Color get ctaFill => successGreen.withValues(alpha: 0.1);
}

abstract final class NotificationTypeColors {
  static const groupInvite = Color(0xFF8B5CF6);
  static const expenseAdded = Color(0xFF0EA5E9);
  static const settlementRequest = Color(0xFFB5F542);
  static const settlement = Color(0xFF22C55E);
  static const friendRequest = Color(0xFFF59E0B);
  static const loanRequest = Color(0xFF6366F1);
  static const settlementReminder = Color(0xFFEAB308);
  static const budgetAlert = Color(0xFFEF4444);
}

abstract final class InsightsChartPalette {
  static const purple = Colors.purpleAccent;
  static const blue = Colors.blueAccent;
  static const teal = Colors.tealAccent;
  static const orange = Colors.orangeAccent;
}

abstract final class CategoryMaterialColors {
  static const purple = Colors.purpleAccent;
  static const blue = Colors.blueAccent;
  static const orange = Colors.orangeAccent;
  static const green = Colors.greenAccent;
  static const yellow = Colors.yellowAccent;
  static const teal = Colors.tealAccent;
  static const grey = Colors.grey;
}

abstract final class DefaultReactionEmojis {
  static const list = ['👍', '❤️', '😂', '😮', '😢', '💸'];
}

/// Full-screen settle overlay scrim (~87% black).
abstract final class AppScrimColors {
  static const dark = Color(0xDE000000);
}

/// Confetti palette for swipe-to-settle celebration.
abstract final class SettleConfettiColors {
  static const list = [
    neopopAccent,
    neopopYellow,
    CategoryMaterialColors.teal,
    neopopPrimary,
    CategoryMaterialColors.purple,
    neopopSuccessBright,
  ];
}
