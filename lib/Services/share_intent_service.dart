import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:splitr/Model/receipt_model.dart';
import 'package:splitr/Screen/HomeScreen/add_personal_transaction_screen.dart';
import 'package:splitr/Services/receipt_parser_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

/// Handles images/PDFs shared into Splitr from other apps.
class ShareIntentService {
  StreamSubscription? _mediaSub;
  final ReceiptParserService _parser = ReceiptParserService();

  Future<void> initialize() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    try {
      final initial = await ReceiveSharingIntent.instance.getInitialMedia();
      if (initial.isNotEmpty) {
        await _handleShared(initial);
      }
    } catch (e, stack) {
      AppErrorReporter.report(
        'ShareIntentService.initialize failed',
        error: e,
        stack: stack,
        context: {'feature': 'share_intent', 'operation': 'getInitialMedia'},
      );
    }

    _mediaSub = ReceiveSharingIntent.instance.getMediaStream().listen(
          _handleShared,
          onError: (e) => AppErrorReporter.report(
            'ShareIntentService media stream error',
            error: e,
            context: {'feature': 'share_intent', 'operation': 'mediaStream'},
          ),
        );
  }

  Future<void> _handleShared(List<SharedMediaFile> files) async {
    if (files.isEmpty) return;
    final path = files.first.path;
    if (path.isEmpty) return;

    ReceiptData? parsed;
    try {
      parsed = await _parser.parseReceipt(File(path));
    } catch (e, stack) {
      AppErrorReporter.report(
        'ShareIntentService.parseReceipt failed',
        error: e,
        stack: stack,
        context: {'feature': 'share_intent', 'operation': 'parseReceipt'},
      );
    } finally {
      ReceiveSharingIntent.instance.reset();
      Get.to(() => AddPersonalTransactionScreen(receiptPrefill: parsed));
    }
  }

  void dispose() {
    _mediaSub?.cancel();
  }
}
