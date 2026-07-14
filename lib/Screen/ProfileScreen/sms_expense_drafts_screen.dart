import 'package:flutter/material.dart';
import 'package:splitr/Utils/currency_utils.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Model/receipt_model.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Screen/HomeScreen/add_personal_transaction_screen.dart';
import 'package:splitr/Utils/upi_sms_parser.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';

/// Paste UPI/bank SMS text → draft expense (no SMS permission; Play-policy safe).
class SmsExpenseDraftsScreen extends StatefulWidget {
  const SmsExpenseDraftsScreen({super.key});

  @override
  State<SmsExpenseDraftsScreen> createState() => _SmsExpenseDraftsScreenState();
}

class _SmsExpenseDraftsScreenState extends State<SmsExpenseDraftsScreen> {
  final _controller = TextEditingController();
  UpiSmsDraft? _draft;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      _controller.text = data!.text!;
      _parse();
    }
  }

  void _parse() {
    setState(() => _draft = UpiSmsParser.parse(_controller.text));
  }

  void _addExpense() {
    final d = _draft;
    if (d == null) return;
    Get.to(
      () => AddPersonalTransactionScreen(
        receiptPrefill: ReceiptData(
          total: d.amount,
          merchantName: d.merchant ?? AppStrings.smsDraft.defaultMerchant,
          date: d.date,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: surface,
      appBar: SplitrDetailAppBar(title: AppStrings.smsDraft.title),
      body: Padding(
        padding: const EdgeInsets.all(groupGutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.smsDraft.description,
              style: body2_text.copyWith(color: groupOnSurfaceMuted),
            ),
            const SizedBox(height: groupGapMd),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: AppStrings.smsDraft.hint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(groupControlRadius),
                  borderSide: BorderSide(color: groupSurfaceBorder),
                ),
              ),
              onChanged: (_) => _parse(),
            ),
            const SizedBox(height: groupGapSm),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _pasteFromClipboard,
                  icon: const Icon(Icons.content_paste_go_rounded, size: 18),
                  label: Text(AppStrings.smsDraft.paste),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _draft == null ? null : _addExpense,
                  style: FilledButton.styleFrom(
                    backgroundColor: neopopYellow,
                    foregroundColor: groupOnSurface,
                  ),
                  child: Text(AppStrings.smsDraft.addExpense),
                ),
              ],
            ),
            if (_draft != null) ...[
              const SizedBox(height: groupGapMd),
              Card(
                child: ListTile(
                  title: Text(
                    '${userCurrencySymbol()}${_draft!.amount.toStringAsFixed(2)}',
                    style: sub_headline4_text.copyWith(color: groupOnSurface),
                  ),
                  subtitle: Text(
                      _draft!.merchant ?? AppStrings.smsDraft.unknownPayee),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
