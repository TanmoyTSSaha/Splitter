import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';

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
        color: neopopSecondaryGrey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(32),
      ),
      child: TabBar(
        controller: controller,
        dividerColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: neopopBackground,
          borderRadius: BorderRadius.circular(32),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: neopopBackground.withValues(alpha: 0.5),
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
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: neopopAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$badge',
              style: caption_text.copyWith(
                color: neopopOnBackground,
                fontWeight: FontWeight.w700,
                fontSize: 10,
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
    this.backgroundColor = Colors.white,
    this.rebuildToken,
  });

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

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
  Color backgroundColor = Colors.white,
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
