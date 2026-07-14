import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:splitr/Model/receipt_model.dart';

/// On-device receipt parser using Google ML Kit text recognition.
/// No API calls, no privacy concerns — all processing runs locally.
class ReceiptParserService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Processes a receipt image and returns structured data.
  Future<ReceiptData> parseReceipt(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognizedText = await _textRecognizer.processImage(inputImage);

    final lines = recognizedText.blocks
        .expand((block) => block.lines)
        .map((line) => line.text)
        .toList();

    return _extractReceiptData(lines);
  }

  /// Extracts structured receipt data from raw text lines.
  ReceiptData _extractReceiptData(List<String> lines) {
    final receiptData = ReceiptData(lineItems: []);

    // Price pattern: matches ₹, $, or plain numbers like 123.45
    final priceRegex = RegExp(r'[\₹\$]?\s*(\d+[,.]?\d{0,2})$');
    final taxRegex =
        RegExp(r'(tax|gst|vat|cgst|sgst|igst)', caseSensitive: false);
    final tipRegex = RegExp(r'(tip|gratuity|service)', caseSensitive: false);
    final totalRegex = RegExp(r'(total|grand total|amount due|net amount)',
        caseSensitive: false);
    final subtotalRegex =
        RegExp(r'(subtotal|sub total|sub-total)', caseSensitive: false);
    final dateRegex = RegExp(r'(\d{1,2}[/\-\.]\d{1,2}[/\-\.]\d{2,4})');

    // Try to extract merchant name from first non-empty line
    for (var line in lines.take(3)) {
      if (line.trim().isNotEmpty && !priceRegex.hasMatch(line)) {
        receiptData.merchantName = line.trim();
        break;
      }
    }

    // Try to extract date
    for (var line in lines) {
      final dateMatch = dateRegex.firstMatch(line);
      if (dateMatch != null) {
        try {
          receiptData.date = _parseDate(dateMatch.group(1)!);
        } catch (_) {}
        break;
      }
    }

    // Parse line items, tax, tip, total
    for (var line in lines) {
      final priceMatch = priceRegex.firstMatch(line.trim());
      if (priceMatch == null) continue;

      final priceStr = priceMatch.group(1)!.replaceAll(',', '');
      final price = double.tryParse(priceStr);
      if (price == null || price <= 0) continue;

      final itemName = line.trim().substring(0, priceMatch.start).trim();

      // Categorize the line
      if (totalRegex.hasMatch(line) && !subtotalRegex.hasMatch(line)) {
        receiptData.total = price;
      } else if (subtotalRegex.hasMatch(line)) {
        receiptData.subtotal = price;
      } else if (taxRegex.hasMatch(line)) {
        receiptData.tax = (receiptData.tax ?? 0) + price;
      } else if (tipRegex.hasMatch(line)) {
        receiptData.tip = price;
      } else if (itemName.isNotEmpty) {
        // It's a line item
        receiptData.lineItems.add(ReceiptLineItem(
          name: itemName,
          price: price,
        ));
      }
    }

    // If total wasn't found, calculate it
    receiptData.total ??= _calculateTotal(receiptData);

    return receiptData;
  }

  DateTime? _parseDate(String dateStr) {
    // Try common formats: DD/MM/YYYY, MM/DD/YYYY, DD-MM-YYYY
    final parts = dateStr.split(RegExp(r'[/\-\.]'));
    if (parts.length != 3) return null;

    int? day, month, year;
    if (parts[2].length == 4) {
      // DD/MM/YYYY or MM/DD/YYYY
      year = int.tryParse(parts[2]);
      final a = int.tryParse(parts[0])!;
      final b = int.tryParse(parts[1])!;
      if (a > 12) {
        day = a;
        month = b;
      } else {
        month = a;
        day = b;
      }
    } else {
      // Assume DD/MM/YY
      day = int.tryParse(parts[0]);
      month = int.tryParse(parts[1]);
      year = int.tryParse(parts[2]);
      if (year != null && year < 100) year += 2000;
    }

    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  double _calculateTotal(ReceiptData data) {
    double sum = 0;
    for (var item in data.lineItems) {
      sum += item.totalPrice;
    }
    sum += data.tax ?? 0;
    sum += data.tip ?? 0;
    return sum;
  }

  /// Dispose the recognizer when done.
  void dispose() {
    _textRecognizer.close();
  }
}
