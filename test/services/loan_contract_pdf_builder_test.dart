import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Model/loan_model.dart';
import 'package:splitr/Model/repayment_schedule.dart';
import 'package:splitr/Services/loan_contract_pdf_builder.dart';

LoanModel _testLoan({
  String? id,
  double principal = 50000,
  int duration = 12,
  String status = 'pending',
  String? lenderName,
  String? borrowerName,
}) {
  final start = DateTime(2026, 1, 15);
  return LoanModel(
    id: id,
    lenderID: 'lender-id',
    borrowerID: 'borrower-id',
    principalAmount: principal,
    interestRate: 8,
    interestType: 'simple',
    interestPeriod: 'monthly',
    startDate: start,
    dueDate: DateTime(2027, 1, 15),
    status: status,
    duration: duration,
    durationUnit: 'months',
    repaymentStartDay: 1,
    repaymentEndDay: 5,
    lenderName: lenderName ?? 'Priya Sharma',
    borrowerName: borrowerName ?? 'Rahul Verma',
    currency: 'INR',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoanContractPdfBuilder font asset', () {
    test('bundled PDF font is TrueType, not CFF OpenType (OTTO)', () async {
      final bytes = await rootBundle.load(LoanContractPdfBuilder.fontAssetPath);
      final header = String.fromCharCodes(bytes.buffer.asUint8List(0, 4));
      expect(header, isNot('OTTO'));
      expect(header.codeUnits, [0, 1, 0, 0]);
    });
  });

  group('LoanContractPdfBuilder', () {
    test('produces non-empty PDF bytes', () async {
      final bytes = await LoanContractPdfBuilder.build(
        loan: _testLoan(id: 'abc123def456'),
      );

      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });

    test('includes full installment schedule for loan term', () async {
      final loan = _testLoan(duration: 12);
      final schedule = LoanScheduleCalculator.build(loan);
      final bytes = await LoanContractPdfBuilder.build(loan: loan);

      expect(schedule.installments.length, 12);
      expect(bytes.length, greaterThan(1000));
    });

    test('embeds Noto Sans font objects in PDF output', () async {
      const borrower = 'Tanu Saha';
      final bytes = await LoanContractPdfBuilder.build(
        loan: _testLoan(borrowerName: borrower),
      );

      final pdfText = String.fromCharCodes(bytes);
      expect(pdfText, contains('NotoSans-Regular'));
      expect(pdfText, contains('FontFile2'));
      expect(bytes.length, greaterThan(5000));
    });

    test('renders for pending and active statuses', () async {
      final pendingBytes = await LoanContractPdfBuilder.build(
        loan: _testLoan(status: 'pending'),
      );
      final activeBytes = await LoanContractPdfBuilder.build(
        loan: _testLoan(status: 'active'),
      );

      expect(pendingBytes, isNotEmpty);
      expect(activeBytes, isNotEmpty);
    });

    test('builds when loan id is missing', () async {
      final bytes = await LoanContractPdfBuilder.build(
        loan: _testLoan(id: null),
      );

      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });
  });
}
