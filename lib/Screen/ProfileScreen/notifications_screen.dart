import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Model/user_details_model.dart';
import 'package:splitter/Services/SupabaseServices/notification_service.dart';
import 'package:splitter/Services/reminder_settings_service.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const Color _bg = Color(0xFFF0F0F5);
const Color _cardBg = Colors.white;
const Color _sectionLabel = Color(0xFF9E9E9E);
const Color _titleColor = Color(0xFF1A1A1A);
const Color _borderColor = Color(0xFFEEEEEE);
const Color _accentGreen = Color(0xFFB5F542);
const Color _red = Color(0xFFE53935);

// Notification type → icon + color
const Map<String, IconData> _typeIcons = {
  'group_invite': Icons.group_add_outlined,
  'expense_added': Icons.receipt_long_outlined,
  'settlement_request': Icons.currency_rupee_rounded,
  'friend_request': Icons.person_add_outlined,
  'general': Icons.notifications_outlined,
};
const Map<String, Color> _typeColors = {
  'group_invite': Color(0xFF8B5CF6),
  'expense_added': Color(0xFF0EA5E9),
  'settlement_request': Color(0xFFB5F542),
  'friend_request': Color(0xFFF59E0B),
  'general': Color(0xFF9E9E9E),
};

class NotificationsScreen extends StatefulWidget {
  final UserDetails user;
  const NotificationsScreen({super.key, required this.user});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService();
  final _reminderSettings = Get.find<ReminderSettingsService>();
  List<NotificationModel> _notifications = [];
  bool _loading = true;
  bool _silentReminders = false;

  @override
  void initState() {
    super.initState();
    _load();
    _loadSilentMode();
  }

  Future<void> _loadSilentMode() async {
    final silent = await _reminderSettings.isSilentMode();
    if (mounted) setState(() => _silentReminders = silent);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _service.getNotifications(
      userID: widget.user.userID ?? '',
    );
    if (mounted)
      setState(() {
        _notifications = data;
        _loading = false;
      });
  }

  Future<void> _markAllRead() async {
    await _service.markAllRead(userID: widget.user.userID ?? '');
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
  }

  Future<void> _delete(NotificationModel n) async {
    await _service.deleteNotification(notificationID: n.id);
    if (mounted) setState(() => _notifications.remove(n));
  }

  // Group notifications into Today / Earlier
  Map<String, List<NotificationModel>> _grouped() {
    final today = DateTime.now();
    final result = <String, List<NotificationModel>>{
      'Today': [],
      'Earlier': [],
    };
    for (final n in _notifications) {
      final isSameDay = n.createdAt.year == today.year &&
          n.createdAt.month == today.month &&
          n.createdAt.day == today.day;
      (isSameDay ? result['Today']! : result['Earlier']!).add(n);
    }
    result.removeWhere((_, v) => v.isEmpty);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _grouped();
    final hasUnread = _notifications.any((n) => !n.isRead);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: _titleColor),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _titleColor,
          ),
        ),
        centerTitle: false,
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: _markAllRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _sectionLabel,
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                  color: _accentGreen, strokeWidth: 2))
          : _notifications.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: _accentGreen,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      _buildSilentModeCard(),
                      const SizedBox(height: 16),
                      ...groups.entries.expand((group) {
                      return [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            group.key.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.6,
                              color: _sectionLabel,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: _cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _borderColor),
                          ),
                          child: Column(
                            children: group.value.asMap().entries.map((e) {
                              final isLast = e.key == group.value.length - 1;
                              return _buildNotifTile(e.value, isLast: isLast);
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ];
                    }).toList(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSilentModeCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text(
          'Silent settlement reminders',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _titleColor,
          ),
        ),
        subtitle: const Text(
          'Pause friendly local nudges about open balances',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: _sectionLabel,
          ),
        ),
        value: _silentReminders,
        activeThumbColor: _accentGreen,
        onChanged: (v) async {
          setState(() => _silentReminders = v);
          await _reminderSettings.setSilentMode(v);
        },
      ),
    );
  }

  Widget _buildNotifTile(NotificationModel n, {bool isLast = false}) {
    final icon = _typeIcons[n.type] ?? Icons.notifications_outlined;
    final color = _typeColors[n.type] ?? _sectionLabel;

    return Dismissible(
      key: Key(n.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: _red.withOpacity(0.1),
          borderRadius: isLast
              ? const BorderRadius.vertical(bottom: Radius.circular(16))
              : BorderRadius.zero,
        ),
        child: const Icon(Icons.delete_outline_rounded, color: _red, size: 22),
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
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon circle
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
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
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: n.isRead
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                  color: _titleColor,
                                ),
                              ),
                            ),
                            if (!n.isRead)
                              Container(
                                width: 8,
                                height: 8,
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
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: _sectionLabel,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          _timeAgo(n.createdAt),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            color: _sectionLabel.withOpacity(0.7),
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
            const Divider(
                height: 1, color: _borderColor, indent: 68, endIndent: 16),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _cardBg,
              shape: BoxShape.circle,
              border: Border.all(color: _borderColor),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 32,
              color: _sectionLabel,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "You're all caught up ✓",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _titleColor,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'No new notifications right now.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: _sectionLabel,
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
