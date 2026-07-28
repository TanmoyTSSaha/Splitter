import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/glass_card.dart';
import 'package:splitr/Constants/gradient_mesh_background.dart';
import 'package:splitr/Constants/shared.dart';
import 'package:splitr/Controller/lending_refresh_controller.dart';
import 'package:splitr/Controller/profile_controller.dart';
import 'package:splitr/Controller/notification_badge_controller.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Model/loan_model.dart';
import 'package:splitr/Model/user_details_model.dart';
import 'package:splitr/Repository/loan_repository.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Screen/LendingScreen/create_loan_screen.dart';
import 'package:splitr/Screen/LendingScreen/loan_detail_screen.dart';
import 'package:splitr/Screen/LendingScreen/request_loan_screen.dart';
import 'package:splitr/Screen/LendingScreen/widgets/loan_repayment_progress_bar.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Widgets/notification_bell_button.dart';
import 'package:splitr/Widgets/pill_tab_bar.dart';
import 'package:splitr/Widgets/tab_empty_state.dart';
import 'package:splitr/Widgets/user_avatar.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/app_keys.dart';

class LendingDashboard extends StatefulWidget {
  const LendingDashboard({super.key});

  @override
  State<LendingDashboard> createState() => _LendingDashboardState();
}

class _LendingDashboardState extends State<LendingDashboard>
    with SingleTickerProviderStateMixin {
  final String _userID = SupabaseAuth().supabaseGetUserID();
  LoanRepository get _loanRepo => Get.find<LoanRepository>();

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
      final profile = Get.find<ProfileController>();
      final results = await Future.wait([
        _loanRepo.getLoans(_userID),
        profile.user.value != null
            ? Future.value(profile.user.value)
            : profile.fetchProfileData().then((_) => profile.user.value),
      ]);

      final loans = results[0] as List<LoanModel>;
      final user = results[1] as UserDetails?;

      final pending = <LoanModel>[];
      final active = <LoanModel>[];
      final completed = <LoanModel>[];
      double owedToMe = 0;
      double iOwe = 0;

      for (final loan in loans) {
        switch (loan.status) {
          case GroupInviteStatusValues.pending:
            pending.add(loan);
            break;
          case LoanStatusValues.active:
            active.add(loan);
            if (loan.lenderID == _userID) {
              owedToMe += loan.currentAmountOwed;
            } else {
              iOwe += loan.currentAmountOwed;
            }
            break;
          case LoanStatusValues.completed:
          case LoanStatusValues.rejected:
          case LoanStatusValues.defaulted:
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
    } catch (e, stack) {
      AppErrorReporter.report(
        AppStrings.errors.loadLending,
        error: e,
        stack: stack,
      );
      setState(() {
        _isLoading = false;
        _fetchError = AppStrings.errors.loadLending;
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
    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: surface,
      appBar: _buildAppBar(_user, surface),
      body: _isLoading
          ? const Center(child: LoadingWidget())
          : _fetchError != null
              ? _buildErrorState()
              : NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(child: _buildHeaderContent()),
                    sliverPillTabBar(
                      controller: _tabController,
                      tabs: [
                        AppStrings.lending.active,
                        AppStrings.lending.pending,
                        AppStrings.lending.completed
                      ],
                    ),
                  ],
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLoansTab(
                        loans: _activeLoans,
                        emptyTitle: AppStrings.lending.noActiveContracts,
                        emptySubtitle: AppStrings.lending.activeEmptySubtitle,
                      ),
                      _buildLoansTab(
                        loans: _pendingLoans,
                        emptyTitle: AppStrings.lending.noPendingOffers,
                        emptySubtitle: AppStrings.lending.pendingEmptySubtitle,
                      ),
                      _buildLoansTab(
                        loans: _completedLoans,
                        emptyTitle: AppStrings.lending.noCompletedContracts,
                        emptySubtitle:
                            AppStrings.lending.completedEmptySubtitle,
                      ),
                    ],
                  ),
                ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: groupFabClearance + 10),
        child: SizedBox(
          width: 160,
          height: groupCtaHeight,
          child: FloatingActionButton.extended(
            heroTag: HeroTags.lendingFab,
            onPressed: () async {
              await Get.to(() => const CreateLoanScreen());
              _fetchData();
            },
            backgroundColor: neopopBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(groupCardRadius),
            ),
            label: Text(
              AppStrings.lending.newContract,
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
              child: Text(AppStrings.groups.retry,
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(UserDetails? user, Color surface) {
    return AppBar(
      backgroundColor: groupTransparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: const Text(
        AppBranding.brandLogo,
        style: TextStyle(
          fontFamily: kFontAlbra,
          fontSize: splitrFontHeadline2,
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
            padding: const EdgeInsets.all(groupGap2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: groupSurfaceBorder, width: 2),
            ),
            child: CircleAvatar(
              backgroundColor: groupChipTrackBg,
              radius: 18,
              child: const Icon(Icons.person_rounded,
                  color: groupOnSurfaceMuted, size: 20),
            ),
          ),
        const SizedBox(width: groupGutter),
      ],
    );
  }

  Widget _buildTagline() {
    return Text(
      AppStrings.lending.tagline,
      style: TextStyle(
        fontFamily: kFontAlbra,
        fontSize: splitrFontHeadline1,
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
          AppStrings.lending.totalNetPosition,
          style: body2_text.copyWith(color: groupOnSurfaceMuted),
        ),
        const SizedBox(height: 4),
        Text(
          AppStrings.lending.activeContractsOnly,
          style: caption_text.copyWith(color: neopopGrey),
        ),
        const SizedBox(height: groupGapSm),
        Obx(() {
          final sym = Get.find<CurrencyController>().symbol;
          return Text(
            '$sym ${netPos.abs().toStringAsFixed(0)}',
            style: TextStyle(
              fontFamily: kFontAlbra,
              fontSize: splitrFontRecapLg,
              color: groupOnSurface,
              fontWeight: FontWeight.bold,
            ),
          );
        }),
        const SizedBox(height: groupGapSm),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: groupCarouselGap, vertical: groupGapXs),
          decoration: BoxDecoration(
            color: isPositive
                ? Colors.green.withValues(alpha: 0.12)
                : Colors.red.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(groupControlRadiusSm),
            border: Border.all(
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
          child: Text(
            isPositive
                ? AppStrings.lending.inTheGreen
                : AppStrings.lending.oweMoreThanOwed,
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
            AppStrings.lending.lendMoney,
            Icons.arrow_outward_rounded,
            () => Get.to(() => const CreateLoanScreen())
                ?.then((_) => _fetchData()),
          ),
        ),
        const SizedBox(width: groupGapMd),
        Expanded(
          child: _buildActionCard(
            AppStrings.lending.borrowMoney,
            Icons.call_received_rounded,
            () => Get.to(() => const RequestLoanScreen())
                ?.then((_) => _fetchData()),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(String label, IconData icon, VoidCallback onTap) {
    final surface = Theme.of(context).colorScheme.surface;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(groupGapMd),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(groupCardRadius),
          boxShadow: [
            BoxShadow(
              color: groupSurfaceFillSubtle,
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
    if (loan.status == GroupInviteStatusValues.pending) {
      final initiatedByMe = loan.createdBy == _userID;
      if (initiatedByMe) {
        return AppStrings.lending.awaitingTheirResponse;
      }
      return AppStrings.lending.awaitingYourResponse;
    }

    if (loan.status == LoanStatusValues.completed) {
      return isLender
          ? AppStrings.lending.fullyRepaidToYou
          : AppStrings.lending.fullyRepaid;
    }
    if (loan.status == LoanStatusValues.rejected) {
      return AppStrings.notifications.inviteDeclined;
    }
    if (loan.status == LoanStatusValues.defaulted) {
      return AppStrings.lending.defaulted;
    }

    return isLender ? AppStrings.friends.owesYou : AppStrings.friends.youOwe;
  }

  Widget _buildLoanCard(LoanModel loan) {
    final isLender = loan.lenderID == _userID;
    final otherUserName = isLender
        ? (loan.borrowerName ?? LoanRoleFallbacks.borrower)
        : (loan.lenderName ?? LoanRoleFallbacks.lender);
    final otherUserAvatar =
        isLender ? (loan.borrowerAvatar ?? '') : (loan.lenderAvatar ?? '');
    final otherUserId = isLender ? loan.borrowerID : loan.lenderID;

    final badgeColor = loan.status == LoanStatusValues.active
        ? neopopAccent
        : (loan.status == GroupInviteStatusValues.pending
            ? Colors.orangeAccent
            : groupOnSurfaceMuted);

    return GestureDetector(
      onTap: () => _openLoanDetail(loan),
      child: GlassCard(
        margin: const EdgeInsets.only(bottom: groupGapMd),
        padding: const EdgeInsets.all(groupGapMd),
        opacity: 0.08,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          style:
                              caption_text.copyWith(color: groupOnSurfaceMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: groupGap10, vertical: groupGapXxs),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(groupControlRadiusSm),
                    border: Border.all(color: badgeColor),
                  ),
                  child: Text(
                    loan.status.toUpperCase(),
                    style: const TextStyle(
                      fontSize: splitrFontMicro,
                      fontWeight: FontWeight.bold,
                      color: groupOnSurface,
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
                      loan.status == LoanStatusValues.active
                          ? AppStrings.lending.totalPayable
                          : AppStrings.lending.principal,
                      style: caption_text.copyWith(color: groupOnSurfaceMuted),
                    ),
                    const SizedBox(height: 4),
                    Obx(() {
                      final sym = Get.find<CurrencyController>().symbol;
                      final amount = loan.status == LoanStatusValues.active
                          ? loan.totalContractPayable
                          : loan.principalAmount;
                      return Text(
                        '$sym${amount.toStringAsFixed(0)}',
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
                      loan.status == LoanStatusValues.active
                          ? AppStrings.lending.remaining
                          : AppStrings.home.amount,
                      style: caption_text.copyWith(color: groupOnSurfaceMuted),
                    ),
                    Obx(() {
                      final sym = Get.find<CurrencyController>().symbol;
                      final amount = loan.status == LoanStatusValues.active
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
            if (loan.status == LoanStatusValues.active) ...[
              const SizedBox(height: groupGapMd),
              LoanRepaymentProgressBar.fromLoan(loan),
            ],
            if (loan.dueDate != null) ...[
              const SizedBox(height: groupGapSm),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 14, color: groupOnSurfaceMuted),
                  const SizedBox(width: groupGapXxs),
                  Text(
                    AppStringFormat.dueOn(
                      DateFormat(AppDateFormats.shortDayYear)
                          .format(loan.dueDate!),
                    ),
                    style: caption_text.copyWith(
                      color: groupOnSurfaceMuted,
                      fontSize: splitrFontCaptionSm,
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
