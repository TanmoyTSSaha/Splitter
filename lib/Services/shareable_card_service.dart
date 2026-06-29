import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

/// Utility to capture a widget wrapped in [RepaintBoundary] as a PNG image
/// and share it via the OS share sheet.
class ShareableCardService {
  /// Captures the widget behind [repaintKey] at 3× resolution, writes to
  /// a temp PNG file, and opens the native share dialog.
  ///
  /// [filename] controls the temp file name (without extension).
  /// [shareText] is the optional text that accompanies the image.
  static Future<void> captureAndShare(
    GlobalKey repaintKey, {
    String filename = 'splito_card',
    String? shareText,
  }) async {
    try {
      // 1. Find the render object
      final boundary = repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('ShareableCardService: boundary not found');
        return;
      }

      // 2. Capture at 3× for crisp images
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        debugPrint('ShareableCardService: failed to capture image');
        return;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // 3. Write to temp directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$filename.png');
      await file.writeAsBytes(pngBytes);

      // 4. Share via platform share sheet
      await Share.shareXFiles(
        [XFile(file.path)],
        text: shareText ?? 'Shared from SplitO ✨',
      );
    } catch (e) {
      debugPrint('ShareableCardService: error — $e');
    }
  }
}
