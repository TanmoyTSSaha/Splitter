import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_palette.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Controller/group_screen_controller.dart';
import 'package:splitr/Controller/lending_refresh_controller.dart';
import 'package:splitr/Controller/notification_badge_controller.dart';
import 'package:splitr/Model/group_invite_model.dart';
import 'package:splitr/Model/loan_model.dart';
import 'package:splitr/Repository/loan_repository.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Screen/LendingScreen/loan_detail_screen.dart';
import 'package:splitr/Services/SupabaseServices/group_service.dart';
import 'package:splitr/Services/SupabaseServices/notification_service.dart';
import 'package:splitr/Services/reminder_settings_service.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/Widgets/notification_action_cards.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';
import 'package:splitr/Widgets/splitr_toast.dart';

// Notification type → icon + color
const Map<String, IconData> _typeIcons = {
  NotificationTypes.groupInvite: Icons.group_add_outlined,
  NotificationTypes.expenseAdded: Icons.receipt_long_outlined,
  NotificationTypes.settlementRequest: Icons.currency_rupee_rounded,
  NotificationTypes.settlement: Icons.payments_outlined,
  NotificationTypes.friendRequest: Icons.person_add_outlined,
  NotificationTypes.general: Icons.notifications_outlined,
};
const Map<String, Color> _typeColors = {
  NotificationTypes.groupInvite: NotificationTypeColors.groupInvite,
  NotificationTypes.expenseAdded: NotificationTypeColors.expenseAdded,
  NotificationTypes.settlementRequest: NotificationTypeColors.settlementRequest,
  NotificationTypes.settlement: NotificationTypeColors.settlement,
  NotificationTypes.friendRequest: NotificationTypeColors.friendRequest,
  NotificationTypes.general: neopopDisabledFg,
};

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService();
  final _groupService = GroupService();
  final _reminderSettings = Get.find<ReminderSettingsService>();
  final String _userId = SupabaseAuth().supabaseGetUserID();

  List<NotificationModel> _notifications = [];
  List<GroupInviteModel> _pendingInvites = [];
  List<LoanModel> _pendingLoans = [];
  bool _loading = true;
  bool _silentReminders = false;

  bool get _hasPendingActions =>
      _pendingInvites.isNotEmpty || _pendingLoans.isNotEmpty;

  bool get _isEmpty => !_hasPendingActions && _notifications.isEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Get.isRegistered<NotificationBadgeController>()) {
        await Get.find<NotificationBadgeController>().markViewed();
      }
    });
    _load();
    _loadSilentMode();
  }

  Future<void> _loadSilentMode() async {
    final silent = await _reminderSettings.isSilentMode();
    if (mounted) setState(() => _silentReminders = silent);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _service.getNotifications(userID: _userId),
      _groupService.getPendingInvites(userID: _userId),
      Get.find<LoanRepository>().getPendingLoansAwaitingAction(_userId),
    ]);
    if (mounted) {
      setState(() {
        _notifications = results[0] as List<NotificationModel>;
        _pendingInvites = results[1] as List<GroupInviteModel>;
        _pendingLoans = results[2] as List<LoanModel>;
        _loading = false;
      });
    }
  }

  Future<void> _refreshBadge() async {
    if (Get.isRegistered<NotificationBadgeController>()) {
      await Get.find<NotificationBadgeController>().updateBadge();
    }
  }

  Future<void> _handleInvite(String inviteID, bool accept) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: neopopAccent)),
        barrierDismissible: false,
      );

      await _groupService.respondToInvite(inviteID: inviteID, accept: accept);
      Get.back();

      if (accept) {
        GroupScreenController.refreshFromAnywhere();
      }

      SplitrToast.show(SplitrToast.join(
        accept
            ? AppStrings.notifications.inviteSuccess
            : AppStrings.notifications.inviteDeclined,
        accept
            ? AppStrings.notifications.inviteAccepted
            : AppStrings.notifications.inviteRejected,
      ));

      await _load();
      await _refreshBadge();
    } catch (e, stack) {
      Get.back();
      AppErrorReporter.reportActionFailure(
        AppStrings.notifications.processInviteError,
        error: e,
        stack: stack,
      );
    }
  }

  Future<void> _handleLoanAction(String loanID, bool accept) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: neopopAccent)),
        barrierDismissible: false,
      );

      await Get.find<LoanRepository>().updateLoanStatus(
        loanId: loanID,
        status: accept ? LoanStatusValues.active : LoanStatusValues.rejected,
      );

      Get.back();
      SplitrToast.show(SplitrToast.join(
        accept
            ? AppStrings.notifications.loanAcceptedTitle
            : AppStrings.notifications.loanRejectedTitle,
        accept
            ? AppStrings.notifications.loanNowActive
            : AppStrings.notifications.loanOfferRejected,
      ));
      LendingRefreshController.refreshFromAnywhere();
      await _load();
      await _refreshBadge();
    } catch (e, stack) {
      Get.back();
      AppErrorReporter.reportActionFailure(
        AppStrings.notifications.actionFailed,
        error: e,
        stack: stack,
      );
    }
  }

  Future<void> _markAllRead() async {
    await _service.markAllRead(userID: _userId);
    setState(() {
      _notifications = _notifications
          .map((n) => NotificationModel(
                id: n.id,
                type: n.type,
                title: n.title,
                body: n.body,
                isRead: true,
                metadata: n.metadata,
                createdAt: n.createdAt,
              ))
          .toList();
    });
    await _refreshBadge();
  }

  Future<void> _delete(NotificationModel n) async {
    await _service.deleteNotification(notificationID: n.id);
    if (mounted) setState(() => _notifications.remove(n));
    await _refreshBadge();
  }

  Map<String, List<NotificationModel>> _grouped() {
    final today = DateTime.now();
    final result = <String, List<NotificationModel>>{
      AppStrings.profile.today: [],
      AppStrings.profile.earlier: [],
    };
    for (final n in _notifications) {
      final isSameDay = n.createdAt.year == today.year &&
          n.createdAt.month == today.month &&
          n.createdAt.day == today.day;
      (isSameDay
              ? result[AppStrings.profile.today]!
              : result[AppStrings.profile.earlier]!)
          .add(n);
    }
    result.removeWhere((_, v) => v.isEmpty);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _grouped();
    final hasUnread = _notifications.any((n) => !n.isRead);
    final surface = Theme.of(context).colorScheme.surface;
    final borderColor = groupMutedBorderHairline;

    return Scaffold(
      backgroundColor: surface,
      appBar: SplitrDetailAppBar(
        title: AppStrings.notifications.title,
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                AppStrings.notifications.markAllRead,
                style: TextStyle(
                  fontFamily: kFontPoppins,
                  fontSize: splitrFontCaption,
                  fontWeight: FontWeight.w600,
                  color: groupOnSurfaceMuted,
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: neopopAccent,
                strokeWidth: groupProgressStrokeWidth,
              ),
            )
          : _isEmpty
              ? _buildEmpty(context)
              : RefreshIndicator(
                  onRefresh: _load,
                  color: neopopAccent,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      groupGap20,
                      groupGapSm,
                      groupGap20,
                      groupGapXl,
                    ),
                    children: [
                      _buildSilentModeCard(context),
                      const SizedBox(height: 16),
                      if (_hasPendingActions) ...[
                        _buildSectionHeader(
                          AppStrings.notifications.needsYourAction,
                        ),
                        const SizedBox(height: groupGapSm),
                        ..._pendingInvites.map(
                          (invite) => Padding(
                            padding: const EdgeInsets.only(bottom: groupGap10),
                            child: GroupInviteActionCard(
                              invite: invite,
                              onDecline: () => _handleInvite(invite.id, false),
                              onAccept: () => _handleInvite(invite.id, true),
                            ),
                          ),
                        ),
                        ..._pendingLoans.map(
                          (loan) => Padding(
                            padding: const EdgeInsets.only(bottom: groupGap10),
                            child: LoanRequestActionCard(
                              loan: loan,
                              onReject: () =>
                                  _handleLoanAction(loan.id!, false),
                              onView: () async {
                                final result = await Get.to<bool>(
                                  () => LoanDetailScreen(loan: loan),
                                );
                                if (result == true) {
                                  await _load();
                                  await _refreshBadge();
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      ...groups.entries.expand((group) {
                        return [
                          _buildSectionHeader(group.key.toUpperCase()),
                          const SizedBox(height: groupGapSm),
                          Container(
                            decoration: BoxDecoration(
                              color: surface,
                              borderRadius:
                                  BorderRadius.circular(groupCardRadius),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              children: group.value.asMap().entries.map((e) {
                                final isLast = e.key == group.value.length - 1;
                                return _buildNotifTile(
                                  context,
                                  e.value,
                                  isLast: isLast,
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ];
                      }),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionHeader(String label) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: kFontPoppins,
        fontSize: splitrFontCaptionSm,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.6,
        color: groupOnSurfaceMuted,
      ),
    );
  }

  Widget _buildSilentModeCard(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final borderColor = groupMutedBorderHairline;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: groupGutter,
        vertical: groupGapSm,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(groupCardRadius),
        border: Border.all(color: borderColor),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          AppStrings.notifications.silentRemindersTitle,
          style: TextStyle(
            fontFamily: kFontPoppins,
            fontSize: splitrFontBody,
            fontWeight: FontWeight.w600,
            color: groupOnSurface,
          ),
        ),
        subtitle: Text(
          AppStrings.notifications.silentRemindersSubtitle,
          style: TextStyle(
            fontFamily: kFontPoppins,
            fontSize: splitrFontCaption,
            color: groupOnSurfaceMuted,
          ),
        ),
        value: _silentReminders,
        activeThumbColor: neopopAccent,
        onChanged: (v) async {
          setState(() => _silentReminders = v);
          await _reminderSettings.setSilentMode(v);
        },
      ),
    );
  }

  Widget _buildNotifTile(
    BuildContext context,
    NotificationModel n, {
    bool isLast = false,
  }) {
    final borderColor = groupMutedBorderHairline;
    final icon = _typeIcons[n.type] ?? Icons.notifications_outlined;
    final color = _typeColors[n.type] ?? groupOnSurfaceMuted;

    return Dismissible(
      key: Key(n.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: groupGapLg),
        decoration: BoxDecoration(
          color: neopopErrorFillSoft,
          borderRadius:
              isLast ? groupSheetBottomBorderRadius : BorderRadius.zero,
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: neopopError,
          size: 22,
        ),
      ),
      onDismissed: (_) => _delete(n),
      child: Column(
        children: [
          InkWell(
            onTap: () async {
              if (!n.isRead) {
                await _service.markRead(notificationID: n.id);
                if (mounted) {
                  setState(() {
                    final idx = _notifications.indexOf(n);
                    if (idx != -1) {
                      _notifications[idx] = NotificationModel(
                        id: n.id,
                        type: n.type,
                        title: n.title,
                        body: n.body,
                        isRead: true,
                        metadata: n.metadata,
                        createdAt: n.createdAt,
                      );
                    }
                  });
                  await _refreshBadge();
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: groupGutter,
                vertical: groupGap14,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: AppDimensions.notificationIconBox,
                    height: AppDimensions.notificationIconBox,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(groupControlRadius),
                    ),
                    child: Icon(icon, size: 20, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                n.title,
                                style: TextStyle(
                                  fontFamily: kFontPoppins,
                                  fontSize: splitrFontBodySm,
                                  fontWeight: n.isRead
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                  color: groupOnSurface,
                                ),
                              ),
                            ),
                            if (!n.isRead)
                              Container(
                                width: AppDimensions.notificationDotSize,
                                height: AppDimensions.notificationDotSize,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        if (n.body != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            n.body!,
                            style: TextStyle(
                              fontFamily: kFontPoppins,
                              fontSize: splitrFontCaption,
                              color: groupOnSurfaceMuted,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          _timeAgo(n.createdAt),
                          style: TextStyle(
                            fontFamily: kFontPoppins,
                            fontSize: splitrFontMicro,
                            color: groupMutedTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isLast)
            Divider(height: 1, color: borderColor, indent: 68, endIndent: 16),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final borderColor = groupMutedBorderHairline;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: surface,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 32,
              color: groupOnSurfaceMuted,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.notifications.caughtUp,
            style: const TextStyle(
              fontFamily: kFontPoppins,
              fontSize: splitrFontBodyLg,
              fontWeight: FontWeight.w600,
              color: groupOnSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.notifications.noNewSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: kFontPoppins,
              fontSize: splitrFontBodySm,
              color: groupOnSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return AppStrings.dates.justNow;
    if (diff.inMinutes < 60) {
      return AppStringFormat.timeAgoMinutes(diff.inMinutes);
    }
    if (diff.inHours < 24) {
      return AppStringFormat.timeAgoHours(diff.inHours);
    }
    if (diff.inDays < 7) {
      return AppStringFormat.timeAgoDays(diff.inDays);
    }
    return DateFormat(AppDateFormats.slashDayMonthYear).format(dt);
  }
}
