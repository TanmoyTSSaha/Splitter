import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';

/// Builds and opens UPI deep links for peer settlements.
abstract final class UpiSettleService {
  static const int maxNoteLength = 50;

  static String sanitizeNote(String? note) {
    if (note == null || note.trim().isEmpty) return '';
    final cleaned = note
        .replaceAll(RegExp(r'[^\w\s@.\-&,]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (cleaned.length <= maxNoteLength) return cleaned;
    return cleaned.substring(0, maxNoteLength);
  }

  static Uri buildLink({
    required String payeeVpa,
    required String payeeName,
    required double amountInr,
    String? note,
  }) {
    final params = <String, String>{
      UpiQueryParams.payeeAddress: payeeVpa.trim(),
      UpiQueryParams.payeeName: payeeName.trim(),
      UpiQueryParams.amount: amountInr.toStringAsFixed(2),
      UpiQueryParams.currency: CurrencyDefaults.code,
    };

    final sanitized = sanitizeNote(note);
    if (sanitized.isNotEmpty) {
      params[UpiQueryParams.note] = sanitized;
    }

    final uri = Uri(
      scheme: UpiDefaults.scheme,
      host: UpiDefaults.host,
      queryParameters: params,
    );

    if (kDebugMode) {
      debugPrint('UpiSettleService link: $uri');
    }

    return uri;
  }

  static Future<bool> openUpiApp({
    required String payeeVpa,
    required String payeeName,
    required double amountInr,
    String? note,
  }) async {
    final uri = buildLink(
      payeeVpa: payeeVpa,
      payeeName: payeeName,
      amountInr: amountInr,
      note: note,
    );

    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
