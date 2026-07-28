import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';

/// Persists light / dark / system theme preference.
class ThemeController extends GetxController {
  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(PrefKeys.themeMode);
    themeMode.value = switch (raw) {
      ThemeModeValues.dark => ThemeMode.dark,
      ThemeModeValues.system => ThemeMode.system,
      _ => ThemeMode.light,
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    themeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    final stored = switch (mode) {
      ThemeMode.dark => ThemeModeValues.dark,
      ThemeMode.system => ThemeModeValues.system,
      ThemeMode.light => ThemeModeValues.light,
    };
    await prefs.setString(PrefKeys.themeMode, stored);
  }

  bool get isDark => themeMode.value == ThemeMode.dark;
}
