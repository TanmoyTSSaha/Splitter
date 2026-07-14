import 'package:flutter/animation.dart';

/// Shared animation durations, delays, and curves.
abstract final class AppMotion {
  static const micro = Duration(milliseconds: 50);
  static const fast = Duration(milliseconds: 160);
  static const chip = Duration(milliseconds: 180);
  static const standard = Duration(milliseconds: 200);
  static const medium = Duration(milliseconds: 250);
  static const nav = Duration(milliseconds: 300);
  static const slide = Duration(milliseconds: 400);
  static const splash = Duration(milliseconds: 900);
  static const syncPulse = Duration(milliseconds: 800);
  static const emptyStateFadeIn = Duration(milliseconds: 800);
  static const emptyStateFloat = Duration(seconds: 4);
  static const badgeToast = Duration(seconds: 4);
  static const achievementCelebration = Duration(milliseconds: 1500);
  static const meshBackground = Duration(seconds: 8);
  static const aiTooltip = Duration(seconds: 10);
  static const settleSwipePrimary = Duration(milliseconds: 1500);
  static const settleSwipeSecondary = Duration(milliseconds: 1200);
  static const settleSwipeReset = Duration(milliseconds: 500);
  static const settleSwipeDelay = Duration(milliseconds: 800);
  static const staggerItemDelay = Duration(milliseconds: 50);
  static const staggerItemDuration = Duration(milliseconds: 400);
  static const biometricDelay = Duration(milliseconds: 300);
  static const toast = Duration(seconds: 2);
  static const insightsPromoDismiss = Duration(hours: 24);
  static const insightsBriefingMaxAge = Duration(days: 7);
  static const reminderSettlementDelay = Duration(hours: 12);
  static const goalEstimateDebounce = Duration(seconds: 4);
  static const fxRequestTimeout = Duration(seconds: 8);
  static const shareLinkTtl = Duration(days: 30);
  static const premiumMonthly = Duration(days: 30);
  static const premiumYearly = Duration(days: 365);
  static const filterDefaultLookback = Duration(days: 30);
  static const filterSevenDays = Duration(days: 7);
  static const filterThirtyDays = Duration(days: 30);
  static const filterNinetyDays = Duration(days: 90);
  static const filterOneEightyDays = Duration(days: 180);
  static const filterThreeSixtyFiveDays = Duration(days: 365);
  static const tripPastBound = Duration(days: 30);
  static const tripFutureBound = Duration(days: 365);
  static const goalDefaultTarget = Duration(days: 90);
  static const insightsStaleCutoff = Duration(days: 30);
  static const insightsLookback = Duration(days: 90);
  static const goalDeadlineWindow = Duration(days: 60);
  static const allTransactionsLoadedSince = Duration(days: 365);
  static const analyticsWeek = Duration(days: 7);
  static const analyticsMonth = Duration(days: 30);
  static const analyticsYear = Duration(days: 365);
  static const reminderDaily = Duration(days: 1);
  static const reminderWeekly = Duration(days: 7);
  static const reminderBiweekly = Duration(days: 14);
  static const reminderMonthly = Duration(days: 30);
  static const transactionDayBoundary = Duration(seconds: 1);
  static const fxCacheMaxAge = Duration(milliseconds: 86400000);
}

abstract final class AppCurves {
  static const standard = Curves.easeInOut;
  static const emptyStateFloat = Curves.easeInOutSine;
  static const settleSheet = Curves.easeOutCubic;
  static const staggerFade = Curves.easeOut;
  static const staggerSlide = Curves.easeOutCubic;
  static const navExpand = Curves.easeOutCubic;
  static const navAccent = Curves.easeOutBack;
  static const settleSpring = Curves.elasticOut;
}

abstract final class AppAnimationOffsets {
  static const emptyStateFloatEnd = -15.0;
  static const emptyStateTranslateY = 20.0;
  static const settleSheetBegin = Offset(0, 0.1);
  static const staggerSlideBegin = Offset(0, 0.15);
  static const bottomNavLabelSlideBegin = Offset(-0.5, 0);
  static const cardShadow = Offset(0, 4);
  static const meshShadow = Offset(0, 10);
}
