import 'package:flutter/material.dart';

import 'package:splitter/Controller/group_screen_controller.dart';
import 'package:splitter/Controller/lending_refresh_controller.dart';
import 'package:splitter/Screen/GroupScreen/group_screen.dart';
import 'package:splitter/Screen/HomeScreen/home_screen.dart';
import 'package:splitter/Screen/ProfileScreen/profile_screen.dart';
import 'package:splitter/Screen/LendingScreen/lending_dashboard.dart';
import 'package:splitter/Widgets/animated_glass_bottom_nav_bar.dart';

class BottomNavigationController extends StatefulWidget {
  const BottomNavigationController({super.key});

  @override
  State<BottomNavigationController> createState() =>
      _BottomNavigationControllerState();
}

class _BottomNavigationControllerState
    extends State<BottomNavigationController> {
  int currIndex = 0;

  static const _navItems = [
    BottomNavItemData(
      outlineIcon: Icons.home_outlined,
      filledIcon: Icons.home_rounded,
      label: 'Home',
    ),
    BottomNavItemData(
      outlineIcon: Icons.groups_2_outlined,
      filledIcon: Icons.groups_2_rounded,
      label: 'Groups',
    ),
    BottomNavItemData(
      outlineIcon: Icons.account_balance_wallet_outlined,
      filledIcon: Icons.account_balance_wallet,
      label: 'Lending',
    ),
    BottomNavItemData(
      outlineIcon: Icons.person_outline,
      filledIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  final List<Widget> screens = [
    HomeScreen(),
    GroupScreen(),
    LendingDashboard(),
    ProfileScreen(),
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
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
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
    );
  }
}
