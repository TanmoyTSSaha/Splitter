import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Controller/group_screen_controller.dart';
import 'package:splitter/Controller/lending_refresh_controller.dart';
import 'package:splitter/Controller/notification_badge_controller.dart';
import 'package:splitter/Controllers/currency_controller.dart';
import 'package:splitter/Model/group_invite_model.dart';
import 'package:splitter/Services/supabase_service.dart';
import 'package:splitter/Model/loan_model.dart';
import 'package:splitter/Services/SupabaseServices/group_service.dart';

const Color _screenBg = Color(0xFFF5F5F7);
const Color _cardBg = Colors.white;
const Color _titleColor = Color(0xFF1A1A1A);
const Color _borderColor = Color(0xFFEEEEEE);

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final GroupService _groupService = GroupService();
  final String userID = SupabaseAuth().supabaseGetUserID();
  late Future<List<dynamic>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Get.isRegistered<NotificationBadgeController>()) {
        await Get.find<NotificationBadgeController>().markViewed();
      }
    });
    _refreshInvites();
  }

  void _refreshInvites() {
    setState(() {
      _notificationsFuture = _fetchNotifications();
    });
  }

  Future<void> _refreshBadge() async {
    if (Get.isRegistered<NotificationBadgeController>()) {
      await Get.find<NotificationBadgeController>().updateBadge();
    }
  }

  Future<List<dynamic>> _fetchNotifications() async {
    final results = await Future.wait([
      _groupService.getPendingInvites(userID: userID),
      SupabaseDatabase().getPendingLoansAwaitingAction(userID: userID),
    ]);

    final invites = results[0] as List<GroupInviteModel>;
    final loans = results[1] as List<LoanModel>;

    return [...invites, ...loans];
  }

  Future<void> _handleInvite(String inviteID, bool accept) async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: neopopAccent),
        ),
        barrierDismissible: false,
      );

      await _groupService.respondToInvite(inviteID: inviteID, accept: accept);

      Get.back();

      if (accept) {
        GroupScreenController.refreshFromAnywhere();
      }

      Get.snackbar(
        accept ? "Success" : "Declined",
        accept ? "You have joined the group!" : "Invite declined.",
        backgroundColor: neopopBackground,
        colorText: neopopOnBackground,
      );

      _refreshInvites();
      await _refreshBadge();
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "Could not process invite: $e");
    }
  }

  Future<void> _handleLoanAction(String loanID, bool accept) async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: neopopAccent),
        ),
        barrierDismissible: false,
      );

      await SupabaseDatabase().updateLoanStatus(
        loanID: loanID,
        status: accept ? 'active' : 'rejected',
      );

      Get.back();
      Get.snackbar(
        accept ? 'Loan Accepted' : 'Loan Rejected',
        accept
            ? 'The loan is now active.'
            : 'You have rejected the loan offer.',
        backgroundColor: neopopBackground,
        colorText: neopopOnBackground,
      );
      LendingRefreshController.refreshFromAnywhere();
      _refreshInvites();
      await _refreshBadge();
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "Action failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _titleColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Notifications",
          style: sub_headline4_text.copyWith(
            color: _titleColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: neopopAccent,
                size: 40,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading notifications",
                style: body2_text.copyWith(color: neopopGrey),
              ),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded,
                      size: 60, color: neopopGrey.withValues(alpha: 0.6)),
                  const SizedBox(height: 16),
                  Text(
                    "No new notifications",
                    style: sub_headline5_text.copyWith(color: neopopGrey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Group invites and loan requests will appear here.",
                    style: body2_text.copyWith(color: neopopGrey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(width_16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => SizedBox(height: height_10),
            itemBuilder: (context, index) {
              final item = notifications[index];
              if (item is GroupInviteModel) {
                return _buildInviteCard(item);
              } else if (item is LoanModel) {
                return _buildLoanRequestCard(item);
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildInviteCard(GroupInviteModel invite) {
    return Container(
      padding: EdgeInsets.all(width_16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: neopopBackground.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: neopopAccent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.group_add_rounded, color: neopopAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: invite.inviterName ?? "Someone",
                        style: sub_headline5_text.copyWith(
                          color: _titleColor,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(
                            text: " invited you to join ",
                            style: body2_text.copyWith(color: neopopGrey),
                          ),
                          TextSpan(
                            text: invite.groupName ?? "a group",
                            style: sub_headline5_text.copyWith(
                              color: neopopAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Pending invite",
                      style: caption_text.copyWith(
                        color: neopopGrey,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: height_16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleInvite(invite.id, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Decline"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleInvite(invite.id, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neopopAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Accept"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoanRequestCard(LoanModel loan) {
    final isLendOffer = loan.isLendOffer();
    final initiatorName = isLendOffer
        ? (loan.lenderName ?? 'Someone')
        : (loan.borrowerName ?? 'Someone');

    return Container(
      padding: EdgeInsets.all(width_16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: neopopBackground.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: neopopAccent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.monetization_on_rounded,
                    color: neopopAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      final sym = Get.find<CurrencyController>().symbol;
                      final amount =
                          '$sym${loan.principalAmount.toStringAsFixed(0)}';
                      return RichText(
                        text: TextSpan(
                          text: initiatorName,
                          style: sub_headline5_text.copyWith(
                            color: _titleColor,
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            TextSpan(
                              text: isLendOffer
                                  ? ' offered you a loan of '
                                  : ' requested to borrow ',
                              style: body2_text.copyWith(color: neopopGrey),
                            ),
                            TextSpan(
                              text: isLendOffer ? amount : '$amount from you',
                              style: sub_headline5_text.copyWith(
                                color: neopopAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 4),
                    Text(
                      isLendOffer ? 'Loan offer' : 'Borrow request',
                      style: caption_text.copyWith(
                        color: neopopGrey,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: height_16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleLoanAction(loan.id!, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Refuse"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleLoanAction(loan.id!, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neopopAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Accept"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
