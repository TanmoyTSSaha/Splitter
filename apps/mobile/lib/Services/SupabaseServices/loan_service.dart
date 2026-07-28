import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/business_rules.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Model/loan_model.dart';
import 'package:splitr/Model/loan_payment_recap_row.dart';
import 'package:splitr/Model/repayment_schedule.dart';
import 'package:splitr/Services/app_logger.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoanService {
  final supabase = Supabase.instance.client;

  Future<LoanModel> createLoan(LoanModel loan) async {
    try {
      final response = await supabase
          .from(SupabaseTables.loans)
          .insert(loan.toJson())
          .select()
          .single();
      final enriched = await _enrichLoansWithProfiles([response]);
      return enriched.first;
    } catch (e, stack) {
      AppErrorReporter.unexpected(
        'LoanService.createLoan failed',
        error: e,
        stack: stack,
        context: {'feature': 'lending', 'operation': 'createLoan'},
      );
      throw Exception(AppStrings.errors.actionHumorous);
    }
  }

  Future<List<LoanModel>> _enrichLoansWithProfiles(List<dynamic> data) async {
    if (data.isEmpty) return [];

    final Set<String> userIds = {};
    for (final loan in data) {
      if (loan['lender_id'] != null) userIds.add(loan['lender_id']);
      if (loan['borrower_id'] != null) userIds.add(loan['borrower_id']);
    }

    final profilesResponse = await supabase
        .from(SupabaseTables.users)
        .select('user_id, firstname, lastname, profile_picture_url')
        .inFilter('user_id', userIds.toList());

    final List<dynamic> profilesData = profilesResponse as List<dynamic>;
    final Map<String, Map<String, dynamic>> profilesMap = {
      for (final p in profilesData) p['user_id'].toString(): p
    };

    return data.map((loanData) {
      final lender = profilesMap[loanData['lender_id']];
      final borrower = profilesMap[loanData['borrower_id']];
      final Map<String, dynamic> enrichedData = Map.from(loanData);
      if (lender != null) enrichedData['lender'] = lender;
      if (borrower != null) enrichedData['borrower'] = borrower;
      return LoanModel.fromJson(enrichedData);
    }).toList();
  }

  Future<List<LoanModel>> getLoans({required String userID}) async {
    try {
      final response = await supabase
          .from(SupabaseTables.loans)
          .select()
          .or('lender_id.eq.$userID,borrower_id.eq.$userID')
          .order('created_at', ascending: false);

      return _enrichLoansWithProfiles(response as List<dynamic>);
    } catch (e, stack) {
      AppErrorReporter.unexpected(
        'LoanService.getLoans failed',
        error: e,
        stack: stack,
        context: {'feature': 'lending', 'operation': 'getLoans'},
      );
      throw Exception(AppStrings.errors.loadHumorous);
    }
  }

  Future<LoanModel?> getLoanById(String loanID) async {
    try {
      final response = await supabase
          .from(SupabaseTables.loans)
          .select()
          .eq('id', loanID)
          .single();

      final loans = await _enrichLoansWithProfiles([response]);
      return loans.isEmpty ? null : loans.first;
    } catch (e, stack) {
      AppErrorReporter.unexpected(
        'LoanService.getLoanById failed',
        error: e,
        stack: stack,
        context: {'feature': 'lending', 'operation': 'getLoanById'},
      );
      throw Exception(AppStrings.errors.loadHumorous);
    }
  }

  Future<void> updateRepayment({
    required String loanID,
    required double newAmount,
  }) async {
    try {
      await supabase
          .from(SupabaseTables.loans)
          .update({'repayment_amount': newAmount}).eq('id', loanID);
    } catch (e, stack) {
      AppErrorReporter.unexpected(
        'LoanService.updateRepayment failed',
        error: e,
        stack: stack,
        context: {'feature': 'lending', 'operation': 'updateRepayment'},
      );
      throw Exception(AppStrings.errors.actionHumorous);
    }
  }

  Future<void> updateLoanStatus({
    required String loanID,
    required String status,
  }) async {
    try {
      await supabase
          .from(SupabaseTables.loans)
          .update({'status': status}).eq('id', loanID);
    } catch (e, stack) {
      AppErrorReporter.unexpected(
        'LoanService.updateLoanStatus failed',
        error: e,
        stack: stack,
        context: {'feature': 'lending', 'operation': 'updateLoanStatus'},
      );
      throw Exception(AppStrings.errors.actionHumorous);
    }
  }

  Future<List<LoanModel>> getPendingLoansAwaitingAction({
    required String userID,
  }) async {
    try {
      final response = await supabase
          .from(SupabaseTables.loans)
          .select()
          .eq(SupabaseColumns.status, FriendStatusValues.pending)
          .neq('created_by', userID)
          .or('lender_id.eq.$userID,borrower_id.eq.$userID')
          .order('created_at', ascending: false);

      return _enrichLoansWithProfiles(response as List<dynamic>);
    } catch (e, stack) {
      AppErrorReporter.unexpected(
        'LoanService.getPendingLoansAwaitingAction failed',
        error: e,
        stack: stack,
        context: {'feature': 'lending', 'operation': 'getPendingLoans'},
      );
      throw Exception(AppStrings.errors.loadHumorous);
    }
  }

  Future<List<LoanPaymentRecapRow>> getPaymentsInMonth({
    required String userID,
    required DateTime month,
  }) async {
    try {
      final loans = await getLoans(userID: userID);
      final loanIds = loans.where((l) => l.id != null).map((l) => l.id!).toList();
      if (loanIds.isEmpty) return const [];

      final monthStart = DateTime(month.year, month.month, 1);
      final monthEnd = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
      final rows = await supabase
          .from(SupabaseTables.loanPayments)
          .select(
            '${SupabaseColumns.loanId}, ${SupabaseColumns.amount}, '
            '${SupabaseColumns.paymentDate}',
          )
          .inFilter(SupabaseColumns.loanId, loanIds)
          .gte(SupabaseColumns.paymentDate, monthStart.toIso8601String())
          .lte(SupabaseColumns.paymentDate, monthEnd.toIso8601String())
          .order(SupabaseColumns.paymentDate, ascending: false);

      final loansById = {for (final loan in loans) loan.id!: loan};
      final payments = <LoanPaymentRecapRow>[];
      for (final row in rows as List) {
        final loanId = row[SupabaseColumns.loanId] as String?;
        if (loanId == null) continue;
        final loan = loansById[loanId];
        if (loan == null) continue;
        payments.add(
          LoanPaymentRecapRow(
            loanId: loanId,
            counterparty: _counterpartyLabel(loan, userID),
            amount: double.tryParse(
                  row[SupabaseColumns.amount]?.toString() ?? '0',
                ) ??
                0,
            paidAt: DateTime.tryParse(
                  row[SupabaseColumns.paymentDate]?.toString() ?? '',
                ) ??
                monthStart,
          ),
        );
      }
      return payments;
    } catch (e, stack) {
      if (!AppErrorReporter.shouldSkipSentry(e)) {
        AppErrorReporter.unexpected(
          'LoanService.getPaymentsInMonth failed',
          error: e,
          stack: stack,
          context: {'feature': 'lending', 'operation': 'getPaymentsInMonth'},
        );
      } else {
        AppLogger.warning(
          'LoanService.getPaymentsInMonth skipped — schema not ready',
          data: {'error': e.toString()},
        );
      }
      return const [];
    }
  }

  static String _counterpartyLabel(LoanModel loan, String userId) {
    if (loan.lenderID == userId) {
      return loan.borrowerName ?? DisplayFallbacks.aFriend;
    }
    return loan.lenderName ?? DisplayFallbacks.aFriend;
  }

  Future<void> recordLoanPayment({
    required String loanID,
    required double paymentAmount,
  }) async {
    final loan = await getLoanById(loanID);
    if (loan == null) {
      throw Exception(LoanServiceErrors.notFound);
    }
    if (loan.status != LoanStatusValues.active) {
      throw Exception(LoanServiceErrors.paymentsActiveOnly);
    }

    final remaining = loan.currentAmountOwed;
    if (paymentAmount <= 0) {
      throw Exception(LoanServiceErrors.paymentMustBePositive);
    }
    if (paymentAmount > remaining) {
      throw Exception(AppStrings.validation.paymentExceedsBalance);
    }

    final newRepayment = LoanScheduleCalculator.roundMoney(
      loan.repaymentAmount + paymentAmount,
    );
    await updateRepayment(loanID: loanID, newAmount: newRepayment);

    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      try {
        await supabase.from(SupabaseTables.loanPayments).insert({
          SupabaseColumns.loanId: loanID,
          SupabaseColumns.amount: paymentAmount,
          SupabaseColumns.paidBy: userId,
          SupabaseColumns.paymentDate: DateTime.now().toUtc().toIso8601String(),
        });
      } catch (e, stack) {
        AppErrorReporter.unexpected(
          'LoanService.recordLoanPayment payment history insert failed',
          error: e,
          stack: stack,
          context: {'feature': 'lending', 'operation': 'recordLoanPayment'},
        );
      }
    }

    final updatedLoan = await getLoanById(loanID);
    if (updatedLoan != null) {
      final schedule = LoanScheduleCalculator.build(updatedLoan);
      const tolerance = SplitValidationTolerance.amount;
      final fullyRepaid = updatedLoan.currentAmountOwed <= tolerance ||
          updatedLoan.repaymentAmount >=
              schedule.totalPayable - tolerance ||
          LoanScheduleCalculator.isScheduleFullySettled(schedule);
      if (fullyRepaid) {
        await updateLoanStatus(
            loanID: loanID, status: LoanStatusValues.completed);
      }
    }
  }
}
