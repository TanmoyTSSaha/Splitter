import 'package:flutter/material.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Services/shareable_card_service.dart';
import 'package:splitr/Widgets/recap_share_card.dart';

/// Renders [RecapShareCard] offscreen and captures story / square PNGs.
class RecapShareExporter {
  static Future<String?> captureStoryPng({
    required BuildContext context,
    required RecapShareCardData data,
    required int filenameMillis,
  }) {
    return _capture(
      context: context,
      data: data,
      filename: AppStringFormat.recapFilename(filenameMillis),
    );
  }

  /// Story center crop → 1080×1080 feed image (3× from 360×640 story).
  static Future<String?> captureSquarePng({
    required BuildContext context,
    required RecapShareCardData data,
    required int filenameMillis,
  }) async {
    final storyPath = await _capture(
      context: context,
      data: data,
      filename: AppStringFormat.recapFilename(filenameMillis),
    );
    if (storyPath == null) return null;
    return ShareableCardService.cropFileToCenterSquare(
      storyPath,
      outputFilename: AppStringFormat.recapSquareFilename(filenameMillis),
    );
  }

  static Future<String?> _capture({
    required BuildContext context,
    required RecapShareCardData data,
    required String filename,
  }) async {
    final key = GlobalKey();
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => Positioned(
        left: -RecapShareCard.storyWidth * 2,
        top: 0,
        child: Material(
          type: MaterialType.transparency,
          child: RepaintBoundary(
            key: key,
            child: RecapShareCard(data: data),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 60));
      await WidgetsBinding.instance.endOfFrame;
      return ShareableCardService.captureToFile(
        key,
        filename: filename,
      );
    } finally {
      entry.remove();
    }
  }
}
