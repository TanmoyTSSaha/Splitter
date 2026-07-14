import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Model/group_model.dart';
import 'package:splitr/Model/loan_model.dart';
import 'package:splitr/Services/loan_contract_pdf_builder.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Utils/transaction_date_formatter.dart';

/// Exports group transaction data to CSV or PDF and shares via system sheet.
class ExportService {
  final _dateFormat = DateFormat(AppDateFormats.exportDate);

  Future<void> exportGroupCsv({
    required String groupId,
    required String groupName,
    required String userId,
  }) async {
    final rows = await _loadTransactions(groupId, userId);
    if (rows.isEmpty) throw ServiceErrors.noTransactionsToExport;

    final buffer = StringBuffer();
    buffer.writeln(ExportGroupCsvHeaders.row);

    for (final t in rows) {
      buffer.writeln([
        _quote(TransactionDateFormatter.formatDateTime(
            t.transactionDate ?? DateTime.now())),
        _quote(t.description ?? ''),
        _quote(t.category ?? ''),
        _quote(t.paidByName ?? ''),
        _quote(t.sharedWithName ?? ''),
        (t.sharedTransactionAmount ?? t.totalTransactionAmount ?? 0)
            .toStringAsFixed(2),
        CurrencyDefaults.code,
        _quote(t.sharingType ?? ExpenseTypeLabels.expense),
      ].join(','));
    }

    final file = await _writeTemp(
      '${AppBranding.exportFilePrefix}_${_safeName(groupName)}_${_dateFormat.format(DateTime.now())}.csv',
      buffer.toString(),
    );

    await Share.shareXFiles(
      [XFile(file.path)],
      subject:
          '$groupName${AppStrings.services.export_.transactionExportSubject}',
      text:
          '${AppBranding.brandName}${AppStrings.services.export_.transactionExportText}$groupName',
    );
  }

  Future<void> exportGroupPdf({
    required String groupId,
    required String groupName,
    required String userId,
  }) async {
    final rows = await _loadTransactions(groupId, userId);
    if (rows.isEmpty) throw ServiceErrors.noTransactionsToExport;

    double total = 0;
    for (final t in rows) {
      total += t.sharedTransactionAmount ?? t.totalTransactionAmount ?? 0;
    }

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              groupName,
              style: pw.TextStyle(
                fontSize: splitrFontSubheadLg,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Text(
              '${AppStrings.services.export_.exportedPrefix}${DateFormat(AppDateFormats.shortDayYear).format(DateTime.now())}'),
          pw.SizedBox(height: 8),
          pw.Text('${AppStrings.services.export_.totalRows}${rows.length}'),
          pw.Text(
              '${AppStrings.services.export_.combinedAmount}${total.toStringAsFixed(2)}'),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: [
              AppStrings.services.export_.date,
              AppStrings.services.export_.description,
              AppStrings.services.export_.paidBy,
              AppStrings.services.export_.amount,
              AppStrings.services.export_.type,
            ],
            data: rows.map((t) {
              final amount =
                  t.sharedTransactionAmount ?? t.totalTransactionAmount ?? 0;
              return [
                TransactionDateFormatter.formatDateTime(
                    t.transactionDate ?? DateTime.now()),
                t.description ?? '',
                t.paidByName ?? '',
                amount.toStringAsFixed(2),
                t.sharingType ?? ExpenseTypeLabels.expense,
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            '${AppStrings.services.export_.generatedBy}${AppBranding.brandName}',
            style: const pw.TextStyle(
              fontSize: splitrFontMicro,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );

    final bytes = await doc.save();
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/${AppBranding.exportFilePrefix}_${_safeName(groupName)}_${_dateFormat.format(DateTime.now())}.pdf',
    );
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: '$groupName${AppStrings.services.export_.pdfExportSubject}',
      text:
          '${AppBranding.brandName}${AppStrings.services.export_.pdfExportText}$groupName',
    );
  }

  /// Generates a minimal loan contract PDF (Pro feature).
  Future<void> exportLoanContractPdf({required LoanModel loan}) async {
    final borrower = loan.borrowerName ?? LoanRoleFallbacks.borrower;
    final exportCopy = AppStrings.services.export_;

    final bytes = await LoanContractPdfBuilder.build(loan: loan);
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/${AppBranding.exportFilePrefix}_contract_${_safeName(borrower)}_${_dateFormat.format(DateTime.now())}${FilenamePatterns.pdfSuffix}',
    );
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: '${exportCopy.contractSubject}$borrower',
      text: '${AppBranding.brandName}${exportCopy.contractShareText}',
    );
  }

  Future<List<GroupTransactionModel>> _loadTransactions(
      String groupId, String userId) async {
    return SupabaseDatabase().getGroupTransactionsData(
      userID: userId,
      groupID: groupId,
    );
  }

  String _quote(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  String _safeName(String name) =>
      name.replaceAll(RegExp(FilenamePatterns.safeChars), '_').toLowerCase();

  Future<File> _writeTemp(String filename, String content) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(content);
    return file;
  }
}
