import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Screen/FriendScreen/friends_screen.dart';
import 'package:splitter/Screen/GroupScreen/group_screen.dart';
import 'package:splitter/Screen/HomeScreen/home_screen.dart';
import 'package:splitter/Screen/ProfileScreen/profile_screen.dart';

class BottomNavigationController extends StatefulWidget {
  const BottomNavigationController({super.key});

  @override
  State<BottomNavigationController> createState() =>
      _BottomNavigationControllerState();
}

class _BottomNavigationControllerState
    extends State<BottomNavigationController> {
  int currIndex = 0;
  List<Widget> screens = const [
    HomeScreen(),
    GroupScreen(),
    FriendScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: neopopBackground,
      body: screens[currIndex],
      bottomNavigationBar: SalomonBottomBar(
        itemShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(height_10 * 0.8),
            topRight: Radius.circular(height_10 * 0.8),
            bottomLeft: currIndex == 0
                ? Radius.circular(height_10 * 2.8)
                : Radius.circular(height_10 * 0.8),
            bottomRight: currIndex == 3
                ? Radius.circular(height_10 * 2.8)
                : Radius.circular(height_10 * 0.8),
          ),
        ),
        // margin: const EdgeInsets.symmetric(
        //   horizontal: 32,
        //   vertical: 24,
        // ),
        itemPadding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
        currentIndex: currIndex,
        onTap: (i) => setState(() => currIndex = i),
        items: [
          SalomonBottomBarItem(
              icon: Icon(
                Icons.home,
                size: height_10 * 2.4,
              ),
              title: Text(
                "Home",
                style: body2_text.copyWith(fontWeight: FontWeight.w500),
              ),
              selectedColor: neopopAccent),
          SalomonBottomBarItem(
              icon: Icon(
                Icons.groups,
                size: height_10 * 2.4,
              ),
              title: Text(
                "Groups",
                style: body2_text.copyWith(fontWeight: FontWeight.w500),
              ),
              selectedColor: neopopAccent),
          SalomonBottomBarItem(
              icon: Icon(
                Icons.person,
                size: height_10 * 2.4,
              ),
              title: Text(
                "Friends",
                style: body2_text.copyWith(fontWeight: FontWeight.w500),
              ),
              selectedColor: neopopAccent),
          SalomonBottomBarItem(
            icon: Icon(
              Icons.account_box,
              size: height_10 * 2.4,
            ),
            title: Text(
              "Profile",
              style: body2_text.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            selectedColor: neopopAccent,
          ),
        ],
      ),
    );
  }
}
