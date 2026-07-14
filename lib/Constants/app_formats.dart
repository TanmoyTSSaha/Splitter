/// Date/number format patterns, regexes, filename templates, and separators.
abstract final class AppDateFormats {
  static const exportDate = 'yyyy-MM-dd';
  static const exportDateTime = 'yyyy-MM-dd HH:mm';
  static const shortDay = 'MMM d';
  static const shortDayYear = 'MMM d, yyyy';
  static const longDayYear = 'MMMM d, yyyy';
  static const monthYear = 'MMMM yyyy';
  static const monthName = 'MMMM';
  static const monthAbbr = 'MMM';
  static const monthAbbrDay = 'MMM dd';
  static const weekdayShort = 'EEE';
  static const weekdayShortMonthDay = 'EEE, MMM d';
  static const time12h = 'h:mm a';
  static const time24hComment = 'HH:mm \t EEE d MMM';
  static const transactionPicker = 'dd MMM yyyy';
  static const tripRange = 'd MMM';
  static const dayOnly = 'd';
  static const activityTimestamp = 'MMM d, h:mm a';
  static const monthKey = 'yyyy-M';
  static const numberCompact = '#/##0';
  static const numberGrouped = '#,##0';
  static const slashDayMonthYear = 'd/M/yyyy';
}

abstract final class AppAmountHints {
  static const zero = '0';
  static const one = '1';
  static const decimal = '0.00';
  static const decimalShort = '0.0';
  static const decimalWithSymbol = '0.00';
}

abstract final class MonthAbbreviations {
  static const labels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
}

abstract final class SectionKeyPrefixes {
  static const daily = 'd_';
  static const weekly = 'w_';
  static const monthly = 'm_';
  static const yearly = 'y_';
}

abstract final class AppSeparators {
  static const monthJoiner = ' & ';
  static const monthYearJoiner = ' ';
  static const compositeKeyJoiner = '_';
  static const thousandsComma = ',';
  static const weekRange = ' – ';
  static const flowArrow = ' → ';
  static const bullet = ' • ';
  static const ellipsis = '…';
  static const recapDateRange = ' - ';
}

abstract final class StringDefaults {
  static const empty = '';
}

abstract final class ErrorFormatters {
  static const exceptionPrefix = 'Exception: ';

  static String stripExceptionPrefix(String message) =>
      message.replaceFirst(exceptionPrefix, StringDefaults.empty);
}

abstract final class DisplayFormatters {
  static String joinFirstLast(String? first, String? last) =>
      '${first ?? StringDefaults.empty}${AppSeparators.monthYearJoiner}${last ?? StringDefaults.empty}'
          .trim();

  static String? joinFirstLastOrNull(String? first, String? last) {
    final combined = joinFirstLast(first, last);
    return combined.isEmpty ? null : combined;
  }

  /// Removes viewer-relative "(you)" suffix from group member display names.
  static String stripMemberYouSuffix(String name) {
    final trimmed = name.trim();
    const bareSuffix = '(you)';
    if (trimmed.endsWith(bareSuffix)) {
      return trimmed.substring(0, trimmed.length - bareSuffix.length).trim();
    }
    return trimmed;
  }
}

abstract final class IdFormatters {
  static String transactionGroupId(String groupId) =>
      '$groupId${AppSeparators.compositeKeyJoiner}${DateTime.now().millisecondsSinceEpoch}';
}

abstract final class UpiSmsPatterns {
  static const amount = r'(?:Rs\.?|INR|₹)\s*([0-9,]+(?:\.[0-9]{1,2})?)';
  static const merchant =
      r'(?:at|to|from|paid to|debited at|spent at)\s+([A-Za-z0-9 .&\-_/]{2,40})';
}

abstract final class FilenamePatterns {
  static const safeChars = r'[^\w]+';
  static const shareCardSuffix = '.png';
  static const csvSuffix = '.csv';
  static const pdfSuffix = '.pdf';
  static const monthlyRecapPrefix = 'monthly_recap_';
}

abstract final class RecapCategoryKeywords {
  static const shop = 'shop';
  static const utility = 'utilit';
  static const bill = 'bill';
  static const flight = 'flight';
  static const grocery = 'grocery';
}

abstract final class ImportExtensions {
  static const csv = 'csv';
}

abstract final class InputPatterns {
  static const decimalInput = r'^\d*\.?\d*$';
  static const email = r'^[^@]+@[^@]+\.[^@]+';
  static const whitespace = r'\s+';
}

abstract final class DefaultDecimalPlaces {
  static const amount = 2;
  static const percentage = 1;
  static const hiddenErrorFontSize = 0.0;
}

abstract final class AppDisplaySymbols {
  static const percent = '%';
}

abstract final class ExportCsvHeaders {
  static const row = [
    'Date',
    'Description',
    'Category',
    'Amount',
    'Currency',
    'Paid By',
    'Split Type',
  ];
}

abstract final class ExportGroupCsvHeaders {
  static const row =
      'Date,Description,Category,Paid By,Shared With,Amount,Currency,Type';
}

abstract final class TransactionNotePatterns {
  static const stripNotes = r'\s*Notes:.*';
}

abstract final class DedupeKeyPrefixes {
  static const personal = 'personal_';
  static const group = 'group_';
  static const unknownGroup = 'unknown_';
}

abstract final class IsoFormats {
  static const datePartSplit = 'T';
  static const dateKeySeparator = '-';
  static const dateKeyDayPad = '0';
}
