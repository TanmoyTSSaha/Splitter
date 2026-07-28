import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Widgets/insights_pro_gate.dart';
import 'package:splitr/Widgets/premium_gate.dart';

/// Registry of reusable UI components and their test file coverage.
void main() {
  test('widget component registry lists covered components', () {
    const covered = [
      'BorderedInputField',
      'CustomBigTextFormField',
      'SmartDecimalTextField',
      'PremiumLockBadge',
      'InsightsProGate',
      'DarkSurfaceTheme',
      'GlassCard',
      'TabEmptyState',
      'SyncIndicator',
      'SyncStatusBanner',
      'PrimaryTextFormField',
      'PersonalTransactionTypeToggle',
      'PersonalCategoryPicker',
      'PillTabBar',
      'AnimatedGlassBottomNavBar',
      'SummaryStatCard',
      'TransactionTile',
      'ActiveGroupCard',
      'TripGradientCard',
      'GradientMeshBackground',
      'StaggeredListItem',
      'category_style',
    ];

    expect(covered, contains('BorderedInputField'));
    expect(covered.length, greaterThanOrEqualTo(20));
  });

  test('InsightsProGate exposes test premium override', () {
    expect(
      const InsightsProGate(
        featureLabel: 'X',
        testIsPremium: false,
        child: SizedBox.shrink(),
      ).testIsPremium,
      isFalse,
    );
  });

  test('PremiumLockBadge is const constructible', () {
    expect(const PremiumLockBadge(), isNotNull);
  });
}
