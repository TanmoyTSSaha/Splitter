import 'package:flutter/material.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';

/// Pill-style tab bar matching the Groups screen aesthetic.
class PillTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;

  const PillTabBar({
    super.key,
    required this.controller,
    required this.tabs,
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
        tabs: tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }
}

/// Pinned sliver header wrapper for [PillTabBar].
class SliverPillTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  SliverPillTabBarDelegate(this.child);

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
      color: Colors.white,
      child: child,
    );
  }

  @override
  bool shouldRebuild(SliverPillTabBarDelegate oldDelegate) => false;
}

/// Convenience sliver for a pinned pill tab bar.
SliverPersistentHeader sliverPillTabBar({
  required TabController controller,
  required List<String> tabs,
}) {
  return SliverPersistentHeader(
    pinned: true,
    delegate: SliverPillTabBarDelegate(
      PillTabBar(controller: controller, tabs: tabs),
    ),
  );
}
