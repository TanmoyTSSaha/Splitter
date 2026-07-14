import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/app_dimensions.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/shared.dart';
import 'package:splitr/Model/group_model.dart';
import 'package:splitr/Model/reminder_settings_model.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Widgets/premium_gate.dart';
import 'package:splitr/Controllers/premium_subscription_controller.dart';
import 'package:splitr/Services/reminder_settings_service.dart';

/// Bottom sheet for per-group reminder cadence, tone, and muted members.
class GroupReminderSettingsSheet extends StatefulWidget {
  final String groupId;
  final List<GroupMembersWithNameModel> members;

  const GroupReminderSettingsSheet({
    required this.groupId,
    required this.members,
    super.key,
  });

  static Future<void> show(
    BuildContext context, {
    required String groupId,
    required List<GroupMembersWithNameModel> members,
  }) {
    final surface = Theme.of(context).colorScheme.surface;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: groupSheetTopBorderRadiusLg,
      ),
      builder: (_) => GroupReminderSettingsSheet(
        groupId: groupId,
        members: members,
      ),
    );
  }

  @override
  State<GroupReminderSettingsSheet> createState() =>
      _GroupReminderSettingsSheetState();
}

class _GroupReminderSettingsSheetState
    extends State<GroupReminderSettingsSheet> {
  final _service = Get.find<ReminderSettingsService>();
  late ReminderSettings _settings;
  bool _loading = true;
  bool _saving = false;

  ThemeData get _lightSheetTheme => ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: neopopAccent,
          onPrimary: neopopOnPrimary,
          surface: groupCardFill,
          onSurface: neopopBackground,
        ),
      );

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _settings = await _service.getSettings(widget.groupId);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await _service.saveSettings(_settings);
    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        height: devSysHeight * AppDimensions.reminderSheetHeightRatio,
        child: const Center(child: LoadingWidget()),
      );
    }

    return Theme(
      data: _lightSheetTheme,
      child: Padding(
        padding: EdgeInsets.only(
          left: groupGutter,
          right: groupGutter,
          top: groupGutter,
          bottom: MediaQuery.of(context).viewInsets.bottom + groupGutter,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.reminders.settlementTitle,
              style: sub_headline4_text.copyWith(color: neopopBackground),
            ),
            SizedBox(height: groupGap10),
            Text(
              AppStrings.reminders.settlementSubtitle,
              style: caption_text.copyWith(
                color: neopopGrey,
                fontStyle: FontStyle.normal,
              ),
            ),
            SizedBox(height: groupGutter),
            Text(
              AppStrings.reminders.cadence,
              style: body2_text.copyWith(
                fontWeight: FontWeight.w600,
                color: neopopBackground,
              ),
            ),
            SizedBox(height: groupGap10),
            Wrap(
              spacing: groupGapSm,
              runSpacing: groupGapSm,
              children: ReminderCadence.values.map((c) {
                final selected = _settings.cadence == c;
                final proOnly = reminderCadenceRequiresPro(c);
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _reminderCadenceLabel(c),
                        style: body2_text.copyWith(
                          color: groupChipSelectedFg,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      if (proOnly) ...[
                        const SizedBox(width: groupGapXxs),
                        const PremiumLockBadge(),
                      ],
                    ],
                  ),
                  selected: selected,
                  showCheckmark: true,
                  checkmarkColor: groupChipSelectedFg,
                  onSelected: (_) async {
                    if (proOnly &&
                        !Get.find<PremiumSubscriptionController>()
                            .isPremium
                            .value) {
                      final ok = await requirePremium(
                        featureLabel: AppStrings.reminders.escalatedCadence,
                      );
                      if (!ok) return;
                    }
                    setState(() => _settings.cadence = c);
                  },
                  selectedColor: neopopAccentSelected,
                  backgroundColor: neopopBackground,
                  side: BorderSide(
                    color: selected ? neopopAccent : neopopGreyBorderMedium,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: groupGutter),
            Text(
              AppStrings.reminders.tone,
              style: body2_text.copyWith(
                fontWeight: FontWeight.w600,
                color: neopopBackground,
              ),
            ),
            SizedBox(height: groupGap10),
            SegmentedButton<ReminderTone>(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return neopopAccentBorderHairline;
                  }
                  return groupChipTrackBg;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return neopopBackground;
                  }
                  return neopopGrey;
                }),
              ),
              segments: [
                ButtonSegment(
                  value: ReminderTone.friendly,
                  label: Text(AppStrings.reminders.friendly),
                ),
                ButtonSegment(
                  value: ReminderTone.casual,
                  label: Text(AppStrings.reminders.casual),
                ),
                ButtonSegment(
                  value: ReminderTone.formal,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AppStrings.reminders.formal),
                      SizedBox(width: groupGapXxs),
                      PremiumLockBadge(),
                    ],
                  ),
                ),
              ],
              selected: {_settings.tone},
              onSelectionChanged: (s) async {
                final tone = s.first;
                if (reminderToneRequiresPro(tone) &&
                    !Get.find<PremiumSubscriptionController>()
                        .isPremium
                        .value) {
                  final ok = await requirePremium(
                    featureLabel: AppStrings.reminders.professionalTone,
                  );
                  if (!ok) return;
                }
                setState(() => _settings.tone = tone);
              },
            ),
            if (widget.members.isNotEmpty) ...[
              SizedBox(height: groupGutter),
              Text(
                AppStrings.reminders.muteFor,
                style: body2_text.copyWith(
                  fontWeight: FontWeight.w600,
                  color: neopopBackground,
                ),
              ),
              SizedBox(height: groupGap10),
              ...widget.members.map((m) {
                final id = m.userID!;
                final muted = _settings.mutedMemberIds.contains(id);
                return CheckboxListTile(
                  value: muted,
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _settings.mutedMemberIds = [
                          ..._settings.mutedMemberIds,
                          id,
                        ];
                      } else {
                        _settings.mutedMemberIds = _settings.mutedMemberIds
                            .where((x) => x != id)
                            .toList();
                      }
                    });
                  },
                  title: Text(
                    m.userName ?? DisplayFallbacks.member,
                    style: body2_text.copyWith(color: neopopBackground),
                  ),
                  activeColor: neopopAccent,
                  checkColor: neopopBackground,
                  contentPadding: EdgeInsets.zero,
                );
              }),
            ],
            SizedBox(height: groupGutter),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: neopopAccent,
                  foregroundColor: neopopBackground,
                ),
                child: _saving
                    ? const SizedBox(
                        height: AppDimensions.loadingIndicatorSm,
                        width: AppDimensions.loadingIndicatorSm,
                        child: CircularProgressIndicator(
                          strokeWidth: groupProgressStrokeWidth,
                        ),
                      )
                    : Text(
                        AppStrings.actions.save,
                        style: button_text.copyWith(color: neopopBackground),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _reminderCadenceLabel(ReminderCadence cadence) {
    switch (cadence) {
      case ReminderCadence.off:
        return AppStrings.reminders.cadenceOff;
      case ReminderCadence.daily:
        return AppStrings.reminders.cadenceDaily;
      case ReminderCadence.weekly:
        return AppStrings.reminders.cadenceWeekly;
      case ReminderCadence.biweekly:
        return AppStrings.reminders.cadenceBiweekly;
      case ReminderCadence.monthly:
        return AppStrings.reminders.cadenceMonthly;
    }
  }
}
