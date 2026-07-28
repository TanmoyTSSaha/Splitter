import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitr/Constants/app_themes.dart';
import 'package:splitr/Controllers/currency_controller.dart';

import 'mock_http_overrides.dart' as mock_http;

/// Wraps a widget for component tests with Splitr theme + optional GetX.
class ComponentTestHarness {
  static Future<void> mockSharedPreferences([
    Map<String, Object> values = const {},
  ]) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(values);
    await SharedPreferences.getInstance();
  }

  static Future<T> runWithMockHttp<T>(Future<T> Function() body) {
    return mock_http.runWithMockHttp(body);
  }

  static void registerCurrency({String code = 'INR'}) {
    if (Get.isRegistered<CurrencyController>()) {
      Get.delete<CurrencyController>();
    }
    final controller = CurrencyController(forTest: true);
    controller.seedCodeForTest(code);
    Get.put(controller);
  }

  static Future<void> pump(
    WidgetTester tester,
    Widget child, {
    bool withGetX = false,
    String currencyCode = 'INR',
    Size surfaceSize = const Size(390, 844),
  }) async {
    await tester.binding.setSurfaceSize(surfaceSize);

    if (withGetX) {
      registerCurrency(code: currencyCode);
    }

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppThemes.light,
        home: Scaffold(body: child),
      ),
    );
    await tester.pump();
  }

  static void tearDownGetX() {
    Get.reset();
  }
}
