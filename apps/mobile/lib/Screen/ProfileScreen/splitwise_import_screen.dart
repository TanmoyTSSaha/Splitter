import 'dart:convert';
import 'package:splitr/Widgets/splitr_toast.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Controller/group_screen_controller.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Services/supabase_service.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

/// Imports Splitwise-style CSV exports (group, description, amount, currency).
class SplitwiseImportScreen extends StatefulWidget {
  const SplitwiseImportScreen({super.key});

  @override
  State<SplitwiseImportScreen> createState() => _SplitwiseImportScreenState();
}

class _SplitwiseImportScreenState extends State<SplitwiseImportScreen> {
  bool _importing = false;
  String? _status;

  Future<void> _pickAndImport() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [ImportExtensions.csv],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final bytes = result.files.first.bytes;
    if (bytes == null) return;

    setState(() {
      _importing = true;
      _status = null;
    });

    try {
      final text = utf8.decode(bytes);
      final lines = const LineSplitter().convert(text);
      if (lines.length < 2) {
        setState(() => _status = AppStrings.splitwiseImport.csvNoData);
        return;
      }

      final groupName = _cell(lines[1], 0).isEmpty
          ? CategoryDefaults.importedFromSplitwise
          : _cell(lines[1], 0);

      await Supabase.instance.client
          .rpc(SupabaseRpc.createGroupWithMember, params: {
        SupabaseColumns.pGroupName: groupName,
      });

      final userId = SupabaseAuth().supabaseGetUserID();
      final db = SupabaseDatabase();
      var imported = 0;
      for (var i = 1; i < lines.length; i++) {
        final line = lines[i];
        if (line.trim().isEmpty) continue;
        final amount = double.tryParse(_cell(line, 2)) ?? 0;
        if (amount <= 0) continue;
        final description = _cell(line, 1);
        await db.addPersonalTransaction(
          userID: userId,
          amount: amount,
          description: description.isEmpty
              ? CategoryDefaults.importedExpense
              : description,
          category: CategoryDefaults.other,
          date: DateTime.now(),
          paymentMethod: PaymentMethodDefaults.online,
          currency:
              _cell(line, 3).isEmpty ? CurrencyDefaults.code : _cell(line, 3),
        );
        imported++;
      }

      GroupScreenController.refreshFromAnywhere();
      setState(() => _status =
          AppStringFormat.splitwiseImportSuccess(groupName, imported));
      SplitrToast.show(AppStrings.splitwiseImport.importComplete);
    } catch (e, stack) {
      AppErrorReporter.report(
        AppStrings.splitwiseImport.importFailedPrefix,
        error: e,
        stack: stack,
      );
      setState(
          () => _status = AppStrings.splitwiseImport.importFailedPrefix);
    } finally {
      setState(() => _importing = false);
    }
  }

  String _cell(String line, int index) {
    final parts = line.split(',');
    if (index >= parts.length) return '';
    return parts[index].trim().replaceAll('"', '');
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: surface,
      appBar: SplitrDetailAppBar(title: AppStrings.splitwiseImport.title),
      body: Padding(
        padding: const EdgeInsets.all(groupGutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.splitwiseImport.description,
              style: body2_text.copyWith(color: groupOnSurfaceMuted),
            ),
            const SizedBox(height: groupGapLg),
            ElevatedButton(
              onPressed: _importing ? null : _pickAndImport,
              style: ElevatedButton.styleFrom(
                backgroundColor: neopopAccent,
                foregroundColor: groupOnSurface,
              ),
              child: _importing
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: groupProgressStrokeWidth,
                        color: groupOnSurface,
                      ),
                    )
                  : Text(
                      AppStrings.splitwiseImport.chooseCsv,
                      style: body1_text.copyWith(
                        fontWeight: FontWeight.w600,
                        color: groupOnSurface,
                      ),
                    ),
            ),
            if (_status != null) ...[
              const SizedBox(height: groupGapLg),
              Text(_status!, style: body2_text.copyWith(color: groupOnSurface)),
            ],
          ],
        ),
      ),
    );
  }
}
