import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_motion.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';

/// Theme-inverted pill toast colors for [SplitrToastPill].
class SplitrToastColors {
  final Color background;
  final Color foreground;

  const SplitrToastColors({
    required this.background,
    required this.foreground,
  });

  static SplitrToastColors forBrightness(Brightness brightness) {
    if (brightness == Brightness.light) {
      return const SplitrToastColors(
        background: neopopBackground,
        foreground: neopopOnPrimary,
      );
    }
    return const SplitrToastColors(
      background: Colors.white,
      foreground: neopopBackground,
    );
  }
}

/// Pill-shaped toast body used by [SplitrToast.show].
class SplitrToastPill extends StatelessWidget {
  final String message;
  final Brightness brightness;

  const SplitrToastPill({
    super.key,
    required this.message,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    final colors = SplitrToastColors.forBrightness(brightness);
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: groupGutter,
          vertical: groupGapSm,
        ),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(AppDimensions.toastPillRadius),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: body2_text.copyWith(
            color: colors.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// App-wide theme-aware pill toast. Use instead of Fluttertoast / Get.snackbar / SnackBar.
abstract final class SplitrToast {
  static const Duration defaultDuration = AppMotion.toast;

  /// Merges a former snackbar title + body into one line.
  static String join(String title, String body) {
    final t = title.trim();
    final b = body.trim();
    if (t.isEmpty) return b;
    if (b.isEmpty) return t;
    return '$t: $b';
  }

  static Brightness _resolveBrightness([BuildContext? context]) {
    final ctx = context ?? Get.overlayContext ?? Get.context;
    if (ctx != null) {
      return Theme.of(ctx).brightness;
    }
    return Brightness.light;
  }

  /// Shows toast using Get overlay when available; falls back to Fluttertoast.
  static void show(
    String message, {
    Duration? duration,
    BuildContext? context,
  }) {
    final text = message.trim();
    if (text.isEmpty) return;

    final brightness = _resolveBrightness(context);
    final colors = SplitrToastColors.forBrightness(brightness);
    final showDuration = duration ?? defaultDuration;

    final overlayContext = context ?? Get.overlayContext ?? Get.context;
    if (overlayContext != null) {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.rawSnackbar(
        messageText: SplitrToastPill(
          message: text,
          brightness: brightness,
        ),
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.fromLTRB(
          groupGutter,
          0,
          groupGutter,
          groupGutter,
        ),
        snackPosition: SnackPosition.BOTTOM,
        duration: showDuration,
        isDismissible: true,
        barBlur: 0,
        overlayBlur: 0,
        borderRadius: 0,
      );
      return;
    }

    Fluttertoast.showToast(
      msg: text,
      toastLength: showDuration.inSeconds > 2
          ? Toast.LENGTH_LONG
          : Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: colors.background,
      textColor: colors.foreground,
      fontSize: splitrFontBodySm,
    );
  }

  /// Convenience when a [BuildContext] is already available.
  static void showFromContext(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    show(message, duration: duration, context: context);
  }
}
