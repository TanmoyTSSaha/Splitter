import 'package:flutter/services.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

/// Global status bar + gesture navigation bar style — matches HomeScreen.
const kSplitrSystemUiOverlay = SystemUiOverlayStyle(
  statusBarColor: groupTransparent,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
  systemNavigationBarColor: groupCardFill,
  systemNavigationBarIconBrightness: Brightness.dark,
);
