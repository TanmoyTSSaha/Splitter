// Run: dart run scripts/migrate_currency_symbols.dart
import 'dart:io';

const skip = {
  'donate_screen.dart',
  'premium_plan_screen.dart',
  'upi_sms_parser.dart',
  'receipt_parser_service.dart',
  'currency_service.dart',
  'currency_controller.dart',
  'currency_utils.dart',
  'migrate_currency_symbols.dart',
};

const tripFiles = {
  'trip_timeline_screen.dart',
  'shareable_trip_summary_card.dart',
};

const rupee = '\u20B9';
const importLine = "import 'package:splitr/Utils/currency_utils.dart';";
const currencyServiceImport =
    "import 'package:splitr/Services/currency_service.dart';";

String addImport(String content, String line) {
  if (content.contains(line)) return content;
  final match = RegExp(r"import 'package:[^']+';").firstMatch(content);
  if (match == null) return '$line\n$content';
  final end = match.end;
  return '${content.substring(0, end)}\n$line${content.substring(end)}';
}

String migrate(String content) {
  var c = content;

  final simple = <List<String>>[
    ["prefixText: '${rupee} '", 'prefixText: currencyPrefixText()'],
    ['prefixText: "${rupee} "', 'prefixText: currencyPrefixText()'],
    ['hintText: "${rupee}0.00"', r'hintText: "${userCurrencySymbol()}0.00"'],
    ['Text("${rupee}"', 'Text(userCurrencySymbol()'],
    [
      "labelText: 'Estimated Amount (${rupee})'",
      r"labelText: 'Estimated Amount (${userCurrencySymbol()})'",
    ],
    [': \'${rupee}\';', ": CurrencyService.symbolFor('INR');"],
    ["return '${rupee}';", "return CurrencyService.symbolFor('INR');"],
  ];
  for (final pair in simple) {
    c = c.replaceAll(pair[0], pair[1]);
  }

  // Generic: ₹${ -> ${userCurrencySymbol()}${
  c = c.replaceAll('${rupee}\${', r'${userCurrencySymbol()}${');

  return c;
}

void main() {
  final lib = Directory('lib');
  for (final entity in lib.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final name = entity.uri.pathSegments.last;
    if (skip.contains(name) || tripFiles.contains(name)) continue;

    var content = entity.readAsStringSync();
    if (!content.contains(rupee)) continue;

    final original = content;
    content = migrate(content);
    if (content == original) continue;

    if (content.contains('userCurrencySymbol') ||
        content.contains('currencyPrefixText')) {
      content = addImport(content, importLine);
    }
    if (content.contains('CurrencyService.symbolFor')) {
      content = addImport(content, currencyServiceImport);
    }

    entity.writeAsStringSync(content);
    stdout.writeln(entity.path);
  }
}
