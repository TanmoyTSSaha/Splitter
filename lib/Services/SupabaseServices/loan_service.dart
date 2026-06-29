import 'package:flutter/material.dart';
import 'package:splitter/Model/loan_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoanService {
  final supabase = Supabase.instance.client;

  Future<void> createLoan(LoanModel loan) async {
    try {
      await supabase.from('loans').insert(loan.toJson());
    } catch (e) {
      throw Exception('Failed to create loan: $e');
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
        .from('users')
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
          .from('loans')
          .select()
          .or('lender_id.eq.$userID,borrower_id.eq.$userID')
          .order('created_at', ascending: false);

      return _enrichLoansWithProfiles(response as List<dynamic>);
    } catch (e) {
      debugPrint("DEBUG: Error in getLoans: $e");
      throw Exception('Failed to fetch loans: $e');
    }
  }

  Future<LoanModel?> getLoanById(String loanID) async {
    try {
      final response =
          await supabase.from('loans').select().eq('id', loanID).single();

      final loans = await _enrichLoansWithProfiles([response]);
      return loans.isEmpty ? null : loans.first;
    } catch (e) {
      throw Exception('Failed to fetch loan: $e');
    }
  }

  Future<void> updateRepayment({
    required String loanID,
    required double newAmount,
  }) async {
    try {
      await supabase
          .from('loans')
          .update({'repayment_amount': newAmount}).eq('id', loanID);
    } catch (e) {
      throw Exception('Failed to update repayment: $e');
    }
  }

  Future<void> updateLoanStatus({
    required String loanID,
    required String status,
  }) async {
    try {
      await supabase.from('loans').update({'status': status}).eq('id', loanID);
    } catch (e) {
      throw Exception('Failed to update loan status: $e');
    }
  }

  Future<List<LoanModel>> getPendingLoansAwaitingAction({
    required String userID,
  }) async {
    try {
      final response = await supabase
          .from('loans')
          .select()
          .eq('status', 'pending')
          .neq('created_by', userID)
          .or('lender_id.eq.$userID,borrower_id.eq.$userID')
          .order('created_at', ascending: false);

      return _enrichLoansWithProfiles(response as List<dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch pending loans: $e');
    }
  }

  Future<void> recordLoanPayment({
    required String loanID,
    required double paymentAmount,
  }) async {
    final loan = await getLoanById(loanID);
    if (loan == null) {
      throw Exception('Loan not found');
    }
    if (loan.status != 'active') {
      throw Exception('Payments can only be recorded on active loans');
    }

    final remaining = loan.currentAmountOwed;
    if (paymentAmount <= 0) {
      throw Exception('Payment amount must be greater than zero');
    }
    if (paymentAmount > remaining) {
      throw Exception('Payment exceeds remaining balance');
    }

    final newRepayment = loan.repaymentAmount + paymentAmount;
    await updateRepayment(loanID: loanID, newAmount: newRepayment);

    final updatedLoan = await getLoanById(loanID);
    if (updatedLoan != null && updatedLoan.currentAmountOwed <= 0) {
      await updateLoanStatus(loanID: loanID, status: 'completed');
    }
  }
}
