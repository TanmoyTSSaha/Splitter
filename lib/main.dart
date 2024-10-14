import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Screen/BottomNavigationController/bottom_navigation_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Spliter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: neopopColorScheme,
        highlightColor: neopopAccent,
        splashColor: neopopAccent,
        useMaterial3: true,
        textTheme: splitter_custom_text_theme,
      ),
      home: BottomNavigationController(),
    );
  }
}
