import 'package:flutter/material.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

/// Pill-style tab bar matching the Groups screen aesthetic.
class PillTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;
  final List<int?>? badgeCounts;

  const PillTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.badgeCounts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: groupGutter,
        vertical: groupGapSm,
      ),
      decoration: BoxDecoration(
        color: groupMutedFillFaint,
        borderRadius: BorderRadius.circular(groupPillRadius),
      ),
      child: TabBar(
        controller: controller,
        dividerColor: groupTransparent,
        indicatorColor: groupTransparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: neopopBackground,
          borderRadius: BorderRadius.circular(groupPillRadius),
        ),
        labelColor: groupChipSelectedFg,
        unselectedLabelColor: groupOnSurfaceMuted,
        labelStyle: body2_text.copyWith(fontWeight: FontWeight.bold),
        tabs: List.generate(tabs.length, (i) {
          final count = badgeCounts != null && i < badgeCounts!.length
              ? badgeCounts![i]
              : null;
          return _buildTab(tabs[i], count);
        }),
      ),
    );
  }

  Widget _buildTab(String label, int? badge) {
    if (badge == null || badge <= 0) {
      return Tab(text: label);
    }

    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: AppDimensions.groupBadgeGap),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: groupGapXs, vertical: groupGap2),
            decoration: BoxDecoration(
              color: neopopAccent,
              borderRadius: BorderRadius.circular(groupRadiusMd),
            ),
            child: Text(
              '$badge',
              style: caption_text.copyWith(
                color: neopopOnBackground,
                fontWeight: FontWeight.w700,
                fontSize: splitrFontMicro,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pinned sliver header wrapper for [PillTabBar].
class SliverPillTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final Color backgroundColor;
  final Object? rebuildToken;

  SliverPillTabBarDelegate(
    this.child, {
    this.backgroundColor = groupCardFill,
    this.rebuildToken,
  });

  @override
  double get minExtent => AppDimensions.groupTabBarHeight;

  @override
  double get maxExtent => AppDimensions.groupTabBarHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: backgroundColor,
      child: child,
    );
  }

  @override
  bool shouldRebuild(SliverPillTabBarDelegate oldDelegate) =>
      rebuildToken != oldDelegate.rebuildToken ||
      backgroundColor != oldDelegate.backgroundColor;
}

/// Convenience sliver for a pinned pill tab bar.
SliverPersistentHeader sliverPillTabBar({
  required TabController controller,
  required List<String> tabs,
  List<int?>? badgeCounts,
  Color backgroundColor = groupCardFill,
}) {
  final rebuildToken = badgeCounts?.join(',');
  return SliverPersistentHeader(
    pinned: true,
    delegate: SliverPillTabBarDelegate(
      PillTabBar(
        controller: controller,
        tabs: tabs,
        badgeCounts: badgeCounts,
      ),
      backgroundColor: backgroundColor,
      rebuildToken: rebuildToken,
    ),
  );
}
