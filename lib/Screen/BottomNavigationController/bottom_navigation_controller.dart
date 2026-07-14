import 'package:flutter/material.dart';

import 'package:splitr/Controller/group_screen_controller.dart';
import 'package:splitr/Controller/lending_refresh_controller.dart';
import 'package:splitr/Screen/GroupScreen/group_screen.dart';
import 'package:splitr/Screen/HomeScreen/home_screen.dart';
import 'package:splitr/Screen/ProfileScreen/profile_screen.dart';
import 'package:splitr/Screen/LendingScreen/lending_dashboard.dart';
import 'package:splitr/Widgets/animated_glass_bottom_nav_bar.dart';
import 'package:splitr/Constants/app_strings.dart';

class BottomNavigationController extends StatefulWidget {
  const BottomNavigationController({super.key});

  @override
  State<BottomNavigationController> createState() =>
      _BottomNavigationControllerState();
}

class _BottomNavigationControllerState
    extends State<BottomNavigationController> {
  int currIndex = 0;

  static final _navItems = [
    BottomNavItemData(
      outlineIcon: Icons.home_outlined,
      filledIcon: Icons.home_rounded,
      label: AppStrings.bottomNav.home,
    ),
    BottomNavItemData(
      outlineIcon: Icons.groups_2_outlined,
      filledIcon: Icons.groups_2_rounded,
      label: AppStrings.bottomNav.groups,
    ),
    BottomNavItemData(
      outlineIcon: Icons.account_balance_wallet_outlined,
      filledIcon: Icons.account_balance_wallet,
      label: AppStrings.bottomNav.lending,
    ),
    BottomNavItemData(
      outlineIcon: Icons.person_outline,
      filledIcon: Icons.person_rounded,
      label: AppStrings.bottomNav.profile,
    ),
  ];

  final List<Widget> screens = [
    const HomeScreen(),
    const GroupScreen(),
    const LendingDashboard(),
    const ProfileScreen(),
  ];

  void _onTabTap(int index) {
    if (currIndex == index) return;
    setState(() => currIndex = index);
    if (index == 1) {
      GroupScreenController.refreshFromAnywhere();
    } else if (index == 2) {
      LendingRefreshController.refreshFromAnywhere();
    }
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: surface,
        extendBody: true,
        body: Stack(
          children: [
            IndexedStack(
              index: currIndex,
              children: screens,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedGlassBottomNavBar(
                currentIndex: currIndex,
                onTap: _onTabTap,
                items: _navItems,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
