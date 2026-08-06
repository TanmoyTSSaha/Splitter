import 'package:splitr/Constants/domain_values.dart';
import 'dart:io';

import 'package:splitr/Model/friend_model.dart';
import 'package:splitr/Model/group_model.dart';
import 'package:splitr/Model/personal_transaction_model.dart';
import 'package:splitr/Model/product_category_model.dart';
import 'package:splitr/Model/user_details_model.dart';
import 'package:splitr/Model/master_upi_bank_model.dart';
import 'package:splitr/Model/user_upi_account_model.dart';
import 'package:splitr/Services/SupabaseServices/auth_service.dart';
import 'package:splitr/Services/google_auth_result.dart';
import 'package:splitr/Services/SupabaseServices/friend_service.dart';
import 'package:splitr/Services/SupabaseServices/group_service.dart';
import 'package:splitr/Services/SupabaseServices/transaction_service.dart';
import 'package:splitr/Services/SupabaseServices/user_service.dart';
import 'package:splitr/Services/SupabaseServices/goal_service.dart';
import 'package:splitr/Model/financial_goal_model.dart';
import 'package:splitr/Model/loan_model.dart';
import 'package:splitr/Services/SupabaseServices/loan_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Facade for Authentication Service
class SupabaseAuth {
  final supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();

  String? supabaseGetUserIDOrNull() {
    return _authService.supabaseGetUserIDOrNull();
  }

  String supabaseGetUserID() {
    return _authService.supabaseGetUserID();
  }

  Future<bool> supabaseEmailPassSignIn({
    required String userEmail,
    required String userPassword,
  }) {
    return _authService.supabaseEmailPassSignIn(
      userEmail: userEmail,
      userPassword: userPassword,
    );
  }

  void supabaseSignOut() {
    _authService.supabaseSignOut();
  }

  Future<bool> supabaseSignUp({
    required String userEmail,
    required String userPassword,
    required String userName,
    required String firstName,
    required String lastName,
  }) {
    return _authService.supabaseSignUp(
      userEmail: userEmail,
      userPassword: userPassword,
      userName: userName,
      firstName: firstName,
      lastName: lastName,
    );
  }

  Future<bool> googleSignIn() {
    return _authService.googleSignIn();
  }

  Future<GoogleAuthResult> signInWithGoogle() {
    return _authService.signInWithGoogle();
  }

  Future<String?> getLastUsedLoginMethod() {
    return _authService.getLastUsedLoginMethod();
  }

  Future<void> recordLastUsedLoginMethod(String method) {
    return _authService.recordLastUsedLoginMethod(method);
  }

  Future<bool> resetPassword({required String email}) {
    return _authService.resetPassword(email: email);
  }

  bool supabaseRetrieveSession() {
    return _authService.supabaseRetrieveSession();
  }
}

/// Facade for Database Service
class SupabaseDatabase {
  final supabase = Supabase.instance.client;

  final UserService _userService = UserService();
  final GroupService _groupService = GroupService();
  final FriendService _friendService = FriendService();
  final TransactionService _transactionService = TransactionService();

  // ===================== USER SERVICE DELEGATES =====================

  Future<UserDetails> getCurrentUserProfile({required String userID}) {
    return _userService.getCurrentUserProfile(userID: userID);
  }

  Future<List<Map<String, dynamic>>> searchUsersByEmail({
    required String email,
  }) {
    return _userService.searchUsersByEmail(email: email);
  }

  Future<List<Map<String, dynamic>>> searchUsersByEmails({
    required List<String> emails,
  }) {
    return _userService.searchUsersByEmails(emails: emails);
  }

  Future<UserDetails?> getUserByEmail(String email) {
    return _userService.getUserByEmail(email);
  }

  Future<void> updateUserProfile({
    required String userID,
    required String userName,
    required String firstName,
    required String lastName,
    required String phone,
  }) {
    return _userService.updateUserProfile(
      userID: userID,
      userName: userName,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
    );
  }

  Future<String> uploadProfilePhoto({
    required String userID,
    required File imageFile,
  }) {
    return _userService.uploadProfilePhoto(
      userID: userID,
      imageFile: imageFile,
    );
  }

  Future<List<UserUpiAccount>> listUpiAccounts(String userId) {
    return _userService.listUpiAccounts(userId);
  }

  Future<List<UserUpiAccount>> listUpiAccountsForUsers(
    List<String> userIds,
  ) {
    return _userService.listUpiAccountsForUsers(userIds);
  }

  Future<List<MasterUpiBank>> listMasterUpiBanks() {
    return _userService.listMasterUpiBanks();
  }

  Future<UserUpiAccount> upsertUpiAccount({
    required String userId,
    required String vpa,
    required String bankAlias,
    String? existingId,
    bool? isPrimary,
  }) {
    return _userService.upsertUpiAccount(
      userId: userId,
      vpa: vpa,
      bankAlias: bankAlias,
      existingId: existingId,
      isPrimary: isPrimary,
    );
  }

  Future<void> deleteUpiAccount({
    required String userId,
    required String accountId,
  }) {
    return _userService.deleteUpiAccount(
      userId: userId,
      accountId: accountId,
    );
  }

  Future<void> setPrimaryUpiAccount({
    required String userId,
    required String accountId,
  }) {
    return _userService.setPrimaryUpiAccount(
      userId: userId,
      accountId: accountId,
    );
  }

  // ===================== GROUP SERVICE DELEGATES =====================

  Future<void> addMembersToGroup({
    required String groupID,
    required List<String> memberIDs,
  }) {
    return _groupService.addMembersToGroup(
      groupID: groupID,
      memberIDs: memberIDs,
    );
  }

  Future<List<GroupMembers>> getGroupMembersData({required String userID}) {
    return _groupService.getGroupMembersData(userID: userID);
  }

  Future<List<GroupModel>> getGroupData({required String userID}) {
    return _groupService.getGroupData(userID: userID);
  }

  Future<List<GroupMembersWithNameModel>> getGroupMembers({
    required String groupID,
    required String currentUserID,
  }) {
    return _groupService.getGroupMembers(
      groupID: groupID,
      currentUserID: currentUserID,
    );
  }

  Future<List<Map<String, dynamic>>> getDistinctGroups({
    required String userID,
  }) {
    return _groupService.getDistinctGroups(userID: userID);
  }

  Future<List<GroupBalanceModel>> getGroupBalancesForSettleUp({
    required String groupID,
  }) {
    return _groupService.getGroupBalancesForSettleUp(groupID: groupID);
  }

  Future<void> recordSettlement({
    required String groupID,
    required String fromUserID,
    required String toUserID,
    required double amount,
    required String currency,
  }) {
    return _groupService.recordSettlement(
      groupID: groupID,
      fromUserID: fromUserID,
      toUserID: toUserID,
      amount: amount,
      currency: currency,
    );
  }

  Future<void> sendGroupInvite({
    required String groupID,
    required String invitedUserID,
  }) {
    return _groupService.sendGroupInvite(
      groupID: groupID,
      invitedUserID: invitedUserID,
    );
  }

  Future<GroupModel> getOrCreateDirectSplitGroup({
    required String userID,
    required String friendUserId,
    required String friendName,
  }) {
    return _groupService.getOrCreateDirectSplitGroup(
      userID: userID,
      friendUserId: friendUserId,
      friendName: friendName,
    );
  }

  Future<void> addGroupExpense({
    required String groupID,
    required String paidByUserID,
    required double totalAmount,
    required String description,
    required String category,
    required Map<String, double> splits,
    required String currency,
    String? note,
    String sharingType = 'evenly',
    DateTime? transactionDate,
  }) {
    return _groupService.addGroupExpense(
      groupID: groupID,
      paidByUserID: paidByUserID,
      totalAmount: totalAmount,
      description: description,
      category: category,
      splits: splits,
      currency: currency,
      note: note,
      sharingType: sharingType,
      transactionDate: transactionDate,
    );
  }

  Future<GroupModel?> getGroupModel(String groupID) {
    return _groupService.getGroupModel(groupID);
  }

  // ===================== FRIEND SERVICE DELEGATES =====================

  Future<List<FriendModel>> getFriends({required String userID}) {
    return _friendService.getFriends(userID: userID);
  }

  Future<bool> sendFriendRequest({
    required String fromUserID,
    required String toUserID,
  }) {
    return _friendService.sendFriendRequest(
      fromUserID: fromUserID,
      toUserID: toUserID,
    );
  }

  Future<void> acceptFriendRequest({required String requestID}) {
    return _friendService.acceptFriendRequest(requestID: requestID);
  }

  Future<void> cancelFriendRequest({
    required String requestID,
    required String fromUserID,
  }) {
    return _friendService.cancelFriendRequest(
      requestID: requestID,
      fromUserID: fromUserID,
    );
  }

  Future<List<FriendBalanceModel>> getFriendBalances({
    required String userID,
    required List<FriendModel> friends,
  }) {
    return _friendService.getFriendBalances(userID: userID, friends: friends);
  }

  // ===================== TRANSACTION SERVICE DELEGATES =====================

  Future<List<PersonalTransactionModel>> getPersonalTransaction({
    required String userID,
    int? limit,
  }) {
    return _transactionService.getPersonalTransaction(
      userID: userID,
      limit: limit,
    );
  }

  Future<List<PersonalTransactionWithProductCategoryModel>>
      getHomePhaseExpenseHistory({required String userID}) {
    return _transactionService.getHomePhaseExpenseHistory(userID: userID);
  }

  List<ConsolidatedGroupTransactionModel> getConsolidatedGroupTransactionData({
    required List<GroupTransactionModel> groupTransactionList,
  }) {
    return _transactionService.getConsolidatedGroupTransactionData(
      groupTransactionList: groupTransactionList,
    );
  }

  Future<List<GroupTransactionModel>> getGroupTransactionsData({
    required String userID,
    required String groupID,
  }) {
    return _transactionService.getGroupTransactionsData(
      userID: userID,
      groupID: groupID,
    );
  }

  Future<List<CategoryOnlyModel>> getProductCategories(
      {String? groupID}) async {
    return _transactionService.getProductCategories(groupID: groupID);
  }

  Future<void> deleteGroupTransaction({required String transactionGroupID}) {
    return _transactionService.deleteGroupTransaction(
        transactionGroupID: transactionGroupID);
  }

  Future<void> addCustomCategory({
    required String groupID,
    required String categoryName,
    required String iconSvgContent,
    required String userID,
  }) {
    return _transactionService.addCustomCategory(
      groupID: groupID,
      categoryName: categoryName,
      iconSvgContent: iconSvgContent,
      userID: userID,
    );
  }

  Future<List<Map<String, dynamic>>> getUnifiedTransactions({
    required String userID,
    int? limit = 10,
    String selectedCurrency = CurrencyDefaults.code,
    DateTime? since,
    DateTime? until,
  }) {
    return _transactionService.getUnifiedTransactions(
      userID: userID,
      limit: limit,
      selectedCurrency: selectedCurrency,
      since: since,
      until: until,
    );
  }

  Future<Map<String, double>> getMonthlySpendAnalytics(
      {required String userID,
      String selectedCurrency = CurrencyDefaults.code}) {
    return _transactionService.getMonthlySpendAnalytics(
        userID: userID, selectedCurrency: selectedCurrency);
  }

  Future<double> getMonthlyCashFlow(
      {required String userID,
      String selectedCurrency = CurrencyDefaults.code}) {
    return _transactionService.getMonthlyCashFlow(
        userID: userID, selectedCurrency: selectedCurrency);
  }

  Future<List<Map<String, dynamic>>> getMonthlyPulseData(
      {required String userID,
      String selectedCurrency = CurrencyDefaults.code}) {
    return _transactionService.getMonthlyPulseData(
        userID: userID, selectedCurrency: selectedCurrency);
  }

  Future<void> addPersonalTransaction({
    required String userID,
    required double amount,
    required String description,
    required String category,
    required DateTime date,
    required String paymentMethod,
    required String currency,
  }) {
    return _transactionService.addPersonalTransaction(
      userID: userID,
      amount: amount,
      description: description,
      category: category,
      date: date,
      paymentMethod: paymentMethod,
      currency: currency,
    );
  }

  Future<List<CategoryOnlyModel>> getPersonalCategories(
      {required String userID}) {
    return _transactionService.getPersonalCategories(userID: userID);
  }

  Future<void> addPersonalCustomCategory({
    required String categoryName,
    required String iconSvgContent,
    required String userID,
  }) {
    return _transactionService.addPersonalCustomCategory(
      categoryName: categoryName,
      iconSvgContent: iconSvgContent,
      userID: userID,
    );
  }

  // ===================== GOAL SERVICE DELEGATES =====================
  // Making GoalService accessible via getter or delegates
  // For now, exposing the service directly or via delegates.
  // Let's add delegates for consistency with other services.

  // Actually, to fix the lint `SupabaseService.goalService`, I should probably
  // just expose the static instance if that was the intent, OR update the usage
  // in HomeScreen to use `_supabase.getGoals(...)`.
  //
  // Looking at `HomeScreen.dart` usage: `SupabaseService.goalService.getGoals(...)`
  // `SupabaseService` is likely a typo for `SupabaseDatabase` or a different class?
  // The file `supabase_service.dart` contains `SupabaseDatabase` class.
  //
  // I will add the delegates here and update HomeScreen to use `_supabase.getGoals`.

  final GoalService _goalService = GoalService();

  Future<List<FinancialGoalModel>> getGoals({required String userID}) {
    return _goalService.getGoals(userID: userID);
  }

  Future<void> addGoal(FinancialGoalModel goal) {
    return _goalService.addGoal(goal);
  }

  Future<void> updateGoalAmount(String goalId, double newAmount) {
    return _goalService.updateGoalAmount(goalId, newAmount);
  }

  Future<void> deleteGoal(String goalId) {
    return _goalService.deleteGoal(goalId);
  }

  // ===================== LOAN SERVICE DELEGATES =====================

  final LoanService _loanService = LoanService();

  Future<LoanModel> createLoan(LoanModel loan) {
    return _loanService.createLoan(loan);
  }

  Future<List<LoanModel>> getLoans({required String userID}) {
    return _loanService.getLoans(userID: userID);
  }

  Future<LoanModel?> getLoanById(String loanID) {
    return _loanService.getLoanById(loanID);
  }

  Future<void> updateLoanRepayment({
    required String loanID,
    required double newAmount,
  }) {
    return _loanService.updateRepayment(
      loanID: loanID,
      newAmount: newAmount,
    );
  }

  Future<void> updateLoanStatus({
    required String loanID,
    required String status,
  }) {
    return _loanService.updateLoanStatus(
      loanID: loanID,
      status: status,
    );
  }

  Future<List<LoanModel>> getPendingLoansAwaitingAction({
    required String userID,
  }) {
    return _loanService.getPendingLoansAwaitingAction(userID: userID);
  }

  Future<void> recordLoanPayment({
    required String loanID,
    required double paymentAmount,
  }) {
    return _loanService.recordLoanPayment(
      loanID: loanID,
      paymentAmount: paymentAmount,
    );
  }
}
