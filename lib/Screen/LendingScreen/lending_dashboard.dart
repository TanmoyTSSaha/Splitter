import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/glass_card.dart';
import 'package:splitter/Constants/gradient_mesh_background.dart';
import 'package:splitter/Constants/shared.dart';
import 'package:splitter/Controller/lending_refresh_controller.dart';
import 'package:splitter/Controller/notification_badge_controller.dart';
import 'package:splitter/Controllers/currency_controller.dart';
import 'package:splitter/Model/loan_model.dart';
import 'package:splitter/Model/user_details_model.dart';
import 'package:splitter/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitter/Screen/LendingScreen/create_loan_screen.dart';
import 'package:splitter/Screen/LendingScreen/loan_detail_screen.dart';
import 'package:splitter/Screen/LendingScreen/request_loan_screen.dart';
import 'package:splitter/Services/supabase_service.dart';
import 'package:splitter/Widgets/notification_bell_button.dart';
import 'package:splitter/Widgets/pill_tab_bar.dart';
import 'package:splitter/Widgets/tab_empty_state.dart';
import 'package:splitter/Widgets/user_avatar.dart';

class LendingDashboard extends StatefulWidget {
  const LendingDashboard({super.key});

  @override
  State<LendingDashboard> createState() => _LendingDashboardState();
}

class _LendingDashboardState extends State<LendingDashboard>
    with SingleTickerProviderStateMixin {
  final SupabaseDatabase _supabase = SupabaseDatabase();
  final String _userID = SupabaseAuth().supabaseGetUserID();

  late TabController _tabController;

  bool _isLoading = true;
  String? _fetchError;
  List<LoanModel> _pendingLoans = [];
  List<LoanModel> _activeLoans = [];
  List<LoanModel> _completedLoans = [];
  double _totalOwedToMe = 0;
  double _totalIOwe = 0;
  UserDetails? _user;
  Worker? _refreshWorker;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    if (!Get.isRegistered<LendingRefreshController>()) {
      Get.put(LendingRefreshController());
    }
    _refreshWorker = ever(
      Get.find<LendingRefreshController>().refreshTrigger,
      (_) => _fetchData(),
    );

    if (Get.isRegistered<NotificationBadgeController>()) {
      Get.find<NotificationBadgeController>().updateBadge();
    }
    _fetchData();
  }

  @override
  void dispose() {
    _refreshWorker?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _fetchError = null;
    });

    try {
      final results = await Future.wait([
        _supabase.getLoans(userID: _userID),
        _supabase.getCurrentUserProfile(userID: _userID),
      ]);

      final loans = results[0] as List<LoanModel>;
      final user = results[1] as UserDetails;

      final pending = <LoanModel>[];
      final active = <LoanModel>[];
      final completed = <LoanModel>[];
      double owedToMe = 0;
      double iOwe = 0;

      for (final loan in loans) {
        switch (loan.status) {
          case 'pending':
            pending.add(loan);
            break;
          case 'active':
            active.add(loan);
            if (loan.lenderID == _userID) {
              owedToMe += loan.currentAmountOwed;
            } else {
              iOwe += loan.currentAmountOwed;
            }
            break;
          case 'completed':
          case 'rejected':
          case 'defaulted':
            completed.add(loan);
            break;
        }
      }

      setState(() {
        _pendingLoans = pending;
        _activeLoans = active;
        _completedLoans = completed;
        _user = user;
        _totalOwedToMe = owedToMe;
        _totalIOwe = iOwe;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching lending data: $e');
      setState(() {
        _isLoading = false;
        _fetchError = 'Could not load lending data. Pull to retry.';
      });
    }
  }

  Future<void> _openLoanDetail(LoanModel loan) async {
    final refreshed = await Get.to<bool>(() => LoanDetailScreen(loan: loan));
    if (refreshed == true) {
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _buildAppBar(_user),
      body: _isLoading
          ? const Center(child: LoadingWidget())
          : _fetchError != null
              ? _buildErrorState()
              : NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(child: _buildHeaderContent()),
                    sliverPillTabBar(
                      controller: _tabController,
                      tabs: const ['Active', 'Pending', 'Completed'],
                    ),
                  ],
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLoansTab(
                        loans: _activeLoans,
                        emptyTitle: 'No active contracts',
                        emptySubtitle:
                            'Lend or borrow to start a contract.',
                      ),
                      _buildLoansTab(
                        loans: _pendingLoans,
                        emptyTitle: 'No pending offers',
                        emptySubtitle:
                            'Offers awaiting acceptance appear here.',
                      ),
                      _buildLoansTab(
                        loans: _completedLoans,
                        emptyTitle: 'No completed contracts',
                        emptySubtitle:
                            'Closed, declined, and defaulted loans appear here.',
                      ),
                    ],
                  ),
                ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: groupFabClearance + 10),
        child: SizedBox(
          width: 160,
          height: 56,
          child: FloatingActionButton.extended(
            heroTag: 'lending_fab',
            onPressed: () async {
              await Get.to(() => const CreateLoanScreen());
              _fetchData();
            },
            backgroundColor: neopopBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            label: Text(
              '+ New Contract',
              style: body1_text.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeaderContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        groupGutter,
        groupGapSm,
        groupGutter,
        groupGapMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientMeshBackground(
            child: GlassCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(groupGapLg),
              opacity: 0.12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTagline(),
                  const SizedBox(height: groupGapLg),
                  _buildHeroSection(),
                ],
              ),
            ),
          ),
          const SizedBox(height: groupGapLg),
          _buildActionGrid(),
        ],
      ),
    );
  }

  Widget _buildLoansTab({
    required List<LoanModel> loans,
    required String emptyTitle,
    required String emptySubtitle,
  }) {
    if (loans.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchData,
        color: neopopAccent,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            TabEmptyState(
              title: emptyTitle,
              subtitle: emptySubtitle,
              compact: true,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      color: neopopAccent,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          groupGutter,
          groupGapMd,
          groupGutter,
          groupFabClearance + 40,
        ),
        itemCount: loans.length,
        itemBuilder: (context, index) => _buildLoanCard(loans[index]),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(groupGapLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _fetchError!,
              textAlign: TextAlign.center,
              style: body2_text.copyWith(color: groupOnSurfaceMuted),
            ),
            const SizedBox(height: groupGapMd),
            ElevatedButton(
              onPressed: _fetchData,
              style: ElevatedButton.styleFrom(
                backgroundColor: neopopBackground,
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(UserDetails? user) {
    return AppBar(
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: const Text(
        'Splitr.',
        style: TextStyle(
          fontFamily: 'Albra',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: neopopBackground,
        ),
      ),
      actions: [
        const NotificationBellButton(),
        const SizedBox(width: 10),
        if (user != null)
          UserAvatar(
            userID: user.userID ?? _userID,
            userName: '${user.firstName} ${user.lastName}',
            imageUrl: user.profilePictureURL,
            radius: 20,
          )
        else
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              radius: 18,
              child: const Icon(Icons.person_rounded,
                  color: Colors.grey, size: 20),
            ),
          ),
        const SizedBox(width: groupGutter),
      ],
    );
  }

  Widget _buildTagline() {
    return const Text(
      'lending,\nsimplified.',
      style: TextStyle(
        fontFamily: 'Albra',
        fontSize: 32,
        height: 1.2,
        color: groupOnSurface,
      ),
    );
  }

  Widget _buildHeroSection() {
    final netPos = _totalOwedToMe - _totalIOwe;
    final isPositive = netPos >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Net Position',
          style: body2_text.copyWith(color: groupOnSurfaceMuted),
        ),
        const SizedBox(height: 4),
        Text(
          'Active contracts only',
          style: caption_text.copyWith(color: neopopGrey),
        ),
        const SizedBox(height: groupGapSm),
        Obx(() {
          final sym = Get.find<CurrencyController>().symbol;
          return Text(
            '$sym ${netPos.abs().toStringAsFixed(0)}',
            style: const TextStyle(
              fontFamily: 'Albra',
              fontSize: 40,
              color: groupOnSurface,
              fontWeight: FontWeight.bold,
            ),
          );
        }),
        const SizedBox(height: groupGapSm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isPositive
                ? Colors.green.withValues(alpha: 0.12)
                : Colors.red.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
          child: Text(
            isPositive
                ? 'You are in the green'
                : 'You owe more than you\'re owed',
            style: caption_text.copyWith(
              color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            'Lend Money',
            Icons.arrow_outward_rounded,
            () => Get.to(() => const CreateLoanScreen())?.then((_) => _fetchData()),
          ),
        ),
        const SizedBox(width: groupGapMd),
        Expanded(
          child: _buildActionCard(
            'Borrow Money',
            Icons.call_received_rounded,
            () =>
                Get.to(() => const RequestLoanScreen())?.then((_) => _fetchData()),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(groupGapMd),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: groupOnSurface, size: 28),
            Text(
              label,
              style: body2_text.copyWith(
                color: groupOnSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _subtitleForLoan(LoanModel loan, bool isLender) {
    if (loan.status == 'pending') {
      final initiatedByMe = loan.createdBy == _userID;
      if (initiatedByMe) {
        return 'Awaiting their response';
      }
      return 'Awaiting your response — check Notifications';
    }

    if (loan.status == 'completed') {
      return isLender ? 'Fully repaid to you' : 'Fully repaid';
    }
    if (loan.status == 'rejected') {
      return 'Declined';
    }
    if (loan.status == 'defaulted') {
      return 'Defaulted';
    }

    return isLender ? 'owes you' : 'you owe';
  }

  Widget _buildLoanCard(LoanModel loan) {
    final isLender = loan.lenderID == _userID;
    final otherUserName = isLender
        ? (loan.borrowerName ?? 'Borrower')
        : (loan.lenderName ?? 'Lender');
    final otherUserAvatar =
        isLender ? (loan.borrowerAvatar ?? '') : (loan.lenderAvatar ?? '');
    final otherUserId = isLender ? loan.borrowerID : loan.lenderID;

    final badgeColor = loan.status == 'active'
        ? neopopAccent
        : (loan.status == 'pending' ? Colors.orangeAccent : Colors.grey);

    return GestureDetector(
      onTap: () => _openLoanDetail(loan),
      child: GlassCard(
        margin: const EdgeInsets.only(bottom: groupGapMd),
        padding: const EdgeInsets.all(groupGapMd),
        opacity: 0.08,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    UserAvatar(
                      userID: otherUserId,
                      userName: otherUserName,
                      imageUrl: otherUserAvatar,
                      radius: 20,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          otherUserName,
                          style: body1_text.copyWith(
                            fontWeight: FontWeight.bold,
                            color: groupOnSurface,
                          ),
                        ),
                        Text(
                          _subtitleForLoan(loan, isLender),
                          style: caption_text.copyWith(color: groupOnSurfaceMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: badgeColor),
                  ),
                  child: Text(
                    loan.status.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: groupGapMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Principal',
                      style: caption_text.copyWith(color: groupOnSurfaceMuted),
                    ),
                    const SizedBox(height: 4),
                    Obx(() {
                      final sym = Get.find<CurrencyController>().symbol;
                      return Text(
                        '$sym${loan.principalAmount.toStringAsFixed(0)}',
                        style: body2_text.copyWith(
                          fontWeight: FontWeight.w600,
                          color: groupOnSurface,
                        ),
                      );
                    }),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      loan.status == 'active' ? 'Current Due' : 'Amount',
                      style: caption_text.copyWith(color: groupOnSurfaceMuted),
                    ),
                    Obx(() {
                      final sym = Get.find<CurrencyController>().symbol;
                      final amount = loan.status == 'active'
                          ? loan.currentAmountOwed
                          : loan.principalAmount;
                      return Text(
                        '$sym${amount.toStringAsFixed(0)}',
                        style: headline3_text.copyWith(
                          fontWeight: FontWeight.bold,
                          color: groupOnSurface,
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
            if (loan.status == 'active') ...[
              const SizedBox(height: groupGapMd),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: loan.repaymentProgress,
                  backgroundColor: neopopSecondaryGrey.withValues(alpha: 0.15),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(neopopAccent),
                  minHeight: 8,
                ),
              ),
            ],
            if (loan.dueDate != null) ...[
              const SizedBox(height: groupGapSm),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 14, color: neopopGrey),
                  const SizedBox(width: 4),
                  Text(
                    'Due ${DateFormat('MMM d, yyyy').format(loan.dueDate!)}',
                    style: caption_text.copyWith(
                      color: groupOnSurfaceMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
