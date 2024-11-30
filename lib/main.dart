import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Screen/AuthScreens/login_screen.dart';
import 'package:splitter/Screen/BottomNavigationController/bottom_navigation_controller.dart';
import 'package:splitter/Services/supabase_service.dart';
import 'package:splitter/git_ignore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


// RENAME THIS APP TO SplitO.

Future<void> main() async {
  await Supabase.initialize(
    url: supabaseURL,
    anonKey: supabaseAnonPublicKey,
  );
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
      home: SupabaseAuth().supabaseRetrieveSession()
          ? const BottomNavigationController()
          : const LoginScreen(),
    );
  }
}

