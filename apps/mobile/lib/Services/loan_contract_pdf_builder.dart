import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Model/loan_model.dart';
import 'package:splitr/Model/repayment_schedule.dart';
import 'package:splitr/Services/currency_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

/// Minimal Splitr-branded loan contract PDF layout.
class LoanContractPdfBuilder {
  LoanContractPdfBuilder._();

  static const fontAssetPath = 'assets/fonts/pdf/NotoSans-Variable.ttf';

  static pw.Font? _noto;

  static const _pdfRangeSeparator = ' - ';

  static final _accent = PdfColor.fromHex('#18C595');
  static final _textPrimary = PdfColor.fromHex('#1A1A1A');
  static final _textBody = PdfColor.fromHex('#374151');
  static final _textMuted = PdfColor.fromHex('#6B7280');
  static final _cardBg = PdfColor.fromHex('#F9FAFB');
  static final _tableHeader = PdfColor.fromHex('#F3F4F6');
  static final _footerMuted = PdfColor.fromHex('#9CA3AF');

  static final _scheduleTableBorder = pw.TableBorder(
    left: pw.BorderSide.none,
    right: pw.BorderSide.none,
    top: pw.BorderSide.none,
    bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.25),
    horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.25),
    verticalInside: pw.BorderSide.none,
  );

  static Future<pw.Font> _loadFont() async {
    if (_noto != null) return _noto!;
    try {
      final data = await rootBundle.load(fontAssetPath);
      _noto = pw.Font.ttf(data);
      return _noto!;
    } catch (e, stack) {
      AppErrorReporter.unexpected(
        'LoanContractPdfBuilder font load failed',
        error: e,
        stack: stack,
        context: {'feature': 'export', 'asset': fontAssetPath},
      );
      throw StateError('Contract PDF fonts failed to load');
    }
  }

  static Future<Uint8List> build({required LoanModel loan}) async {
    final noto = await _loadFont();

    final schedule = LoanScheduleCalculator.build(loan);
    final sym = CurrencyService.symbolFor(loan.currency);
    final longDate = DateFormat(AppDateFormats.longDayYear);
    final shortDate = DateFormat(AppDateFormats.shortDayYear);
    final periodDate = DateFormat(AppDateFormats.shortDay);
    final exportCopy = AppStrings.services.export_;
    final lender = loan.lenderName ?? LoanRoleFallbacks.lender;
    final borrower = loan.borrowerName ?? LoanRoleFallbacks.borrower;
    final contractRef = _contractRef(loan);

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(base: noto, bold: noto),
        build: (context) => [
          _header(exportCopy, contractRef),
          pw.SizedBox(height: 20),
          pw.Text(
            exportCopy.loanAgreementSummary,
            style: _sectionStyle(),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '${exportCopy.generatedVia}${longDate.format(DateTime.now())}',
            style: _mutedStyle(fontSize: splitrFontMicro),
          ),
          pw.SizedBox(height: 20),
          _heroCard(
            exportCopy: exportCopy,
            sym: sym,
            schedule: schedule,
          ),
          pw.SizedBox(height: 24),
          _sectionTitle(exportCopy.parties),
          pw.SizedBox(height: 8),
          _termsTable([
            (exportCopy.lender.trim(), lender),
            (exportCopy.borrower.trim(), borrower),
          ]),
          pw.SizedBox(height: 20),
          _sectionTitle(exportCopy.termsSection),
          pw.SizedBox(height: 8),
          _termsTable([
            (exportCopy.startDate, longDate.format(loan.startDate)),
            if (loan.dueDate != null)
              (exportCopy.maturity, longDate.format(loan.dueDate!)),
            (
              exportCopy.interestRateLabel,
              _interestLabel(loan, exportCopy),
            ),
            if (loan.duration != null && loan.durationUnit != null)
              (
                exportCopy.durationLabel,
                '${loan.duration} ${loan.durationUnit}',
              ),
            if (loan.repaymentStartDay != null && loan.repaymentEndDay != null)
              (
                exportCopy.repaymentWindowLabel,
                'Day ${loan.repaymentStartDay}$_pdfRangeSeparator'
                '${loan.repaymentEndDay} each month',
              ),
            (exportCopy.currencyLabel, loan.currency),
            (exportCopy.contractStatus, _loanStatusLabel(loan.status)),
          ]),
          if (schedule.installments.isNotEmpty) ...[
            pw.SizedBox(height: 24),
            _sectionTitle(exportCopy.installmentSchedule),
            pw.SizedBox(height: 12),
            _scheduleTable(
              exportCopy: exportCopy,
              sym: sym,
              installments: schedule.installments,
              periodDate: periodDate,
              shortDate: shortDate,
            ),
          ],
          pw.SizedBox(height: 32),
          pw.Divider(color: _footerMuted, thickness: 0.5),
          pw.SizedBox(height: 8),
          pw.Text(
            exportCopy.contractDisclaimer,
            style: _mutedStyle(fontSize: splitrFontNano),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '${exportCopy.generatedBy}${AppBranding.brandName}${exportCopy.via}${AppBranding.webBaseUrl.replaceFirst('https://', '')}',
            style: _mutedStyle(fontSize: splitrFontNano),
          ),
        ],
      ),
    );

    return doc.save();
  }

  static String _formatMoney(String prefix, double amount) =>
      '$prefix${amount.toStringAsFixed(2)}';

  static String _contractRef(LoanModel loan) {
    final date = DateFormat('yyyyMMdd').format(DateTime.now());
    final id = loan.id;
    if (id != null && id.length >= 6) {
      return '${AppStrings.services.export_.contractRefPrefix}LC-$date-${id.substring(id.length - 6).toUpperCase()}';
    }
    return '${AppStrings.services.export_.contractRefPrefix}LC-$date-DRAFT';
  }

  static String _interestLabel(LoanModel loan, dynamic exportCopy) {
    final period = loan.interestPeriod == LoanFrequencyValues.yearly
        ? exportCopy.year
        : exportCopy.month;
    return '${loan.interestRate.toStringAsFixed(1)}${exportCopy.percentPer}$period (${loan.interestType})';
  }

  static String _loanStatusLabel(String status) {
    final copy = AppStrings.services.export_;
    switch (status) {
      case LoanStatusValues.pending:
        return copy.statusPendingAcceptance;
      case LoanStatusValues.active:
        return copy.statusActive;
      case LoanStatusValues.rejected:
        return copy.statusRejected;
      case LoanStatusValues.completed:
        return copy.statusCompleted;
      case LoanStatusValues.defaulted:
        return copy.statusDefaulted;
      default:
        return status;
    }
  }

  static String _installmentStatusLabel(InstallmentStatus status) {
    final lending = AppStrings.lending;
    switch (status) {
      case InstallmentStatus.upcoming:
        return lending.upcoming;
      case InstallmentStatus.paid:
        return lending.paid;
      case InstallmentStatus.partial:
        return lending.partial;
      case InstallmentStatus.missed:
        return lending.missed;
      case InstallmentStatus.prepaid:
        return lending.prepaid;
    }
  }

  static pw.Widget _header(dynamic exportCopy, String contractRef) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              AppBranding.brandLogo,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: splitrFontSubhead,
                color: _textPrimary,
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  exportCopy.loanContract,
                  style: _bodyStyle(
                    fontSize: splitrFontMicro,
                    color: _textMuted,
                  ),
                ),
                pw.Text(
                  contractRef,
                  style: _mutedStyle(fontSize: splitrFontNanoSm),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Container(height: 1, color: _accent),
      ],
    );
  }

  static pw.Widget _heroCard({
    required dynamic exportCopy,
    required String sym,
    required RepaymentSchedule schedule,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _cardBg,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          _heroRow(
            exportCopy.principalLabel.toUpperCase(),
            _formatMoney(sym, schedule.principal),
          ),
          pw.SizedBox(height: 10),
          _heroRow(
            exportCopy.totalPayable.trim(),
            _formatMoney(sym, schedule.totalPayable),
          ),
          pw.SizedBox(height: 10),
          _heroRow(
            exportCopy.interestAccrued.toUpperCase(),
            _formatMoney(sym, schedule.totalInterest),
          ),
          if (schedule.monthCount > 0) ...[
            pw.SizedBox(height: 10),
            _heroRow(
              '${exportCopy.emiLabel.toUpperCase()} - ${schedule.monthCount}${exportCopy.installments}',
              '${_formatMoney(sym, schedule.monthlyEmi)}${exportCopy.perMonth}',
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _heroRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: _mutedStyle(fontSize: splitrFontNanoSm)),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: splitrFontBody,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Text(title, style: _sectionStyle());
  }

  static pw.Widget _termsTable(List<(String label, String value)> rows) {
    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(0.35),
        1: const pw.FlexColumnWidth(0.65),
      },
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.top,
      children: rows
          .map(
            (row) => pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8, right: 12),
                  child: pw.Text(
                    row.$1,
                    style: _mutedStyle(fontSize: splitrFontMicro),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Text(
                    row.$2,
                    style: _bodyStyle(fontSize: splitrFontMicro),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  static pw.Widget _scheduleTable({
    required dynamic exportCopy,
    required String sym,
    required List<RepaymentInstallment> installments,
    required DateFormat periodDate,
    required DateFormat shortDate,
  }) {
    return pw.TableHelper.fromTextArray(
      headers: [
        exportCopy.hashSymbol,
        exportCopy.dueWindow,
        exportCopy.amount,
        exportCopy.status,
      ],
      data: installments.map((i) {
        final period =
            '${periodDate.format(i.windowStart)}$_pdfRangeSeparator${shortDate.format(i.windowEnd)}';
        return [
          '${i.index}',
          period,
          _formatMoney(sym, i.amount),
          _installmentStatusLabel(i.status),
        ];
      }).toList(),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: splitrFontMicro,
        color: _textPrimary,
      ),
      cellStyle: _bodyStyle(fontSize: splitrFontMicro),
      headerDecoration: pw.BoxDecoration(color: _tableHeader),
      cellAlignment: pw.Alignment.centerLeft,
      border: _scheduleTableBorder,
      columnWidths: {
        0: const pw.FixedColumnWidth(28),
        1: const pw.FlexColumnWidth(2.5),
        2: const pw.FlexColumnWidth(1.2),
        3: const pw.FlexColumnWidth(1),
      },
    );
  }

  static pw.TextStyle _sectionStyle() {
    return pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: splitrFontCaptionSm,
      letterSpacing: 1.2,
      color: _textPrimary,
    );
  }

  static pw.TextStyle _bodyStyle({
    double fontSize = splitrFontMicro,
    PdfColor? color,
  }) {
    return pw.TextStyle(
      fontSize: fontSize,
      color: color ?? _textBody,
    );
  }

  static pw.TextStyle _mutedStyle({double fontSize = splitrFontNanoSm}) {
    return pw.TextStyle(
      fontSize: fontSize,
      color: _textMuted,
    );
  }
}
