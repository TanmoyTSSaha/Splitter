import 'package:splitr/Model/loan_model.dart';
import 'package:splitr/Services/SupabaseServices/loan_service.dart';

/// Repository facade for lending — delegates to [LoanService] for now.
class LoanRepository {
  final LoanService _loanService = LoanService();

  Future<LoanModel> createLoan(LoanModel loan) => _loanService.createLoan(loan);

  Future<List<LoanModel>> getLoans(String userId) =>
      _loanService.getLoans(userID: userId);

  Future<LoanModel?> getLoanById(String loanId) =>
      _loanService.getLoanById(loanId);

  Future<void> updateRepayment({
    required String loanId,
    required double newAmount,
  }) =>
      _loanService.updateRepayment(loanID: loanId, newAmount: newAmount);

  Future<void> updateLoanStatus({
    required String loanId,
    required String status,
  }) =>
      _loanService.updateLoanStatus(loanID: loanId, status: status);

  Future<List<LoanModel>> getPendingLoansAwaitingAction(String userId) =>
      _loanService.getPendingLoansAwaitingAction(userID: userId);

  Future<void> recordLoanPayment({
    required String loanId,
    required double paymentAmount,
  }) =>
      _loanService.recordLoanPayment(
        loanID: loanId,
        paymentAmount: paymentAmount,
      );
}
