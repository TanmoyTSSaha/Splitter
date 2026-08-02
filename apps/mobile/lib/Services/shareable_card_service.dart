import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'dart:io';

/// Utility to capture a widget wrapped in [RepaintBoundary] as a PNG image
/// and share it via the OS share sheet.
class ShareableCardService {
  /// Captures the widget behind [repaintKey] at 3× resolution and returns
  /// the temp PNG path, or null when capture fails.
  static Future<String?> captureToFile(
    GlobalKey repaintKey, {
    required String filename,
  }) async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('ShareableCardService: boundary not found');
        return null;
      }

      final ui.Image image =
          await boundary.toImage(pixelRatio: ShareCardConfig.pixelRatio);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        debugPrint('ShareableCardService: failed to capture image');
        return null;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$filename.png');
      await file.writeAsBytes(pngBytes);
      return file.path;
    } catch (e, stack) {
      AppErrorReporter.report(
        'ShareableCardService.captureToFile failed',
        error: e,
        stack: stack,
        context: {'feature': 'sharing', 'operation': 'captureToFile'},
      );
      return null;
    }
  }

  /// Center-crops a PNG file to a square (1080×1080 at 3× from story export).
  static Future<String?> cropFileToCenterSquare(
    String inputPath, {
    required String outputFilename,
  }) async {
    try {
      final bytes = await File(inputPath).readAsBytes();
      final cropped = await cropPngToCenterSquare(bytes);
      if (cropped == null) return null;

      final tempDir = await getTemporaryDirectory();
      final out = File('${tempDir.path}/$outputFilename.png');
      await out.writeAsBytes(cropped);
      return out.path;
    } catch (e, stack) {
      AppErrorReporter.report(
        'ShareableCardService.cropFileToCenterSquare failed',
        error: e,
        stack: stack,
        context: {'feature': 'sharing', 'operation': 'cropSquare'},
      );
      return null;
    }
  }

  /// Crops PNG bytes to the largest centered square region.
  static Future<Uint8List?> cropPngToCenterSquare(Uint8List pngBytes) async {
    final codec = await ui.instantiateImageCodec(pngBytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final side = math.min(image.width, image.height);
    final left = (image.width - side) ~/ 2;
    final top = (image.height - side) ~/ 2;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(left.toDouble(), top.toDouble(), side.toDouble(), side.toDouble()),
      Rect.fromLTWH(0, 0, side.toDouble(), side.toDouble()),
      Paint(),
    );
    final picture = recorder.endRecording();
    final cropped = await picture.toImage(side, side);
    final byteData =
        await cropped.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  /// Captures the widget behind [repaintKey] at 3× resolution, writes to
  /// a temp PNG file, and opens the native share dialog.
  ///
  /// [filename] controls the temp file name (without extension).
  /// [shareText] is the optional text that accompanies the image.
  static Future<void> captureAndShare(
    GlobalKey repaintKey, {
    String filename = '${AppBranding.exportFilePrefix}_card',
    String? shareText,
  }) async {
    try {
      final path = await captureToFile(repaintKey, filename: filename);
      if (path == null) return;

      await Share.shareXFiles(
        [XFile(path)],
        text: shareText ?? AppBranding.shareAttribution,
      );
    } catch (e, stack) {
      AppErrorReporter.report(
        'ShareableCardService.captureAndShare failed',
        error: e,
        stack: stack,
        context: {'feature': 'sharing', 'operation': 'captureAndShare'},
      );
    }
  }
}
