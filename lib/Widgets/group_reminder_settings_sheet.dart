import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Constants/shared.dart';
import 'package:splitter/Model/group_model.dart';
import 'package:splitter/Model/reminder_settings_model.dart';
import 'package:splitter/Services/reminder_settings_service.dart';

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
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: GroupReminderSettingsSheet(
          groupId: groupId,
          members: members,
        ),
      ),
    );
  }

  @override
  State<GroupReminderSettingsSheet> createState() =>
      _GroupReminderSettingsSheetState();
}

class _GroupReminderSettingsSheetState extends State<GroupReminderSettingsSheet> {
  final _service = Get.find<ReminderSettingsService>();
  late ReminderSettings _settings;
  bool _loading = true;
  bool _saving = false;

  ThemeData get _lightSheetTheme => ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: neopopAccent,
          onPrimary: Colors.white,
          surface: Colors.white,
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
        height: devSysHeight * 0.4,
        child: const Center(child: LoadingWidget()),
      );
    }

    return Theme(
      data: _lightSheetTheme,
      child: Padding(
        padding: EdgeInsets.only(
          left: width_16,
          right: width_16,
          top: height_16,
          bottom: MediaQuery.of(context).viewInsets.bottom + height_16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settlement reminders',
              style: sub_headline4_text.copyWith(color: neopopBackground),
            ),
            SizedBox(height: height_10),
            Text(
              'Friendly nudges when balances are still open.',
              style: caption_text.copyWith(
                color: neopopGrey,
                fontStyle: FontStyle.normal,
              ),
            ),
            SizedBox(height: height_16),
            Text(
              'Cadence',
              style: body2_text.copyWith(
                fontWeight: FontWeight.w600,
                color: neopopBackground,
              ),
            ),
            SizedBox(height: height_10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ReminderCadence.values.map((c) {
                final selected = _settings.cadence == c;
                return ChoiceChip(
                  label: Text(
                    c.name,
                    style: body2_text.copyWith(
                      color: Colors.white,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  selected: selected,
                  showCheckmark: true,
                  checkmarkColor: Colors.white,
                  onSelected: (_) => setState(() => _settings.cadence = c),
                  selectedColor: neopopAccent.withValues(alpha: 0.45),
                  backgroundColor: neopopBackground,
                  side: BorderSide(
                    color: selected
                        ? neopopAccent
                        : neopopGrey.withValues(alpha: 0.35),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: height_16),
            Text(
              'Tone',
              style: body2_text.copyWith(
                fontWeight: FontWeight.w600,
                color: neopopBackground,
              ),
            ),
            SizedBox(height: height_10),
            SegmentedButton<ReminderTone>(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return neopopAccent.withValues(alpha: 0.25);
                  }
                  return neopopSecondaryGrey.withValues(alpha: 0.12);
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return neopopBackground;
                  }
                  return neopopGrey;
                }),
              ),
              segments: const [
                ButtonSegment(
                  value: ReminderTone.friendly,
                  label: Text('Friendly'),
                ),
                ButtonSegment(
                  value: ReminderTone.casual,
                  label: Text('Casual'),
                ),
                ButtonSegment(
                  value: ReminderTone.formal,
                  label: Text('Formal'),
                ),
              ],
              selected: {_settings.tone},
              onSelectionChanged: (s) =>
                  setState(() => _settings.tone = s.first),
            ),
            if (widget.members.isNotEmpty) ...[
              SizedBox(height: height_16),
              Text(
                'Mute reminders for',
                style: body2_text.copyWith(
                  fontWeight: FontWeight.w600,
                  color: neopopBackground,
                ),
              ),
              SizedBox(height: height_10),
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
                    m.userName ?? 'Member',
                    style: body2_text.copyWith(color: neopopBackground),
                  ),
                  activeColor: neopopAccent,
                  checkColor: neopopBackground,
                  contentPadding: EdgeInsets.zero,
                );
              }),
            ],
            SizedBox(height: height_16),
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
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Save',
                        style: button_text.copyWith(color: neopopBackground),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
