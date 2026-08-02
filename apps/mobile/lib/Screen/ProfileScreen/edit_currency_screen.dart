import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitr/Constants/constants.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Controllers/currency_controller.dart';
import 'package:splitr/Screen/GroupScreen/group_screen_spacing.dart';
import 'package:splitr/Services/currency_service.dart';
import 'package:splitr/Widgets/bordered_input_field.dart';
import 'package:splitr/Widgets/splitr_detail_app_bar.dart';
import 'package:splitr/Constants/business_rules.dart';

class EditCurrencyScreen extends StatefulWidget {
  const EditCurrencyScreen({super.key});

  @override
  State<EditCurrencyScreen> createState() => _EditCurrencyScreenState();
}

class _EditCurrencyScreenState extends State<EditCurrencyScreen> {
  final _cc = Get.find<CurrencyController>();
  final _searchCtrl = TextEditingController();
  String _query = '';
  bool _isSaving = false;

  static const _regional = PopularCurrencyCodes.regional;
  static const _popular = PopularCurrencyCodes.international;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<MapEntry<String, String>> _filtered() {
    final q = _query.toLowerCase();
    return CurrencyService.supportedCurrencies.entries
        .where((e) =>
            q.isEmpty ||
            e.key.toLowerCase().contains(q) ||
            e.value.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _pick(String code) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    await _cc.setCurrency(code);
    if (mounted) {
      setState(() => _isSaving = false);
      SplitrToast.showFromContext(
        context,
        AppStringFormat.currencySet(_cc.name, _cc.symbol),
      );
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered();
    final regional = filtered.where((e) => _regional.contains(e.key)).toList();
    final popular = filtered.where((e) => _popular.contains(e.key)).toList();
    final others = filtered
        .where((e) => !_regional.contains(e.key) && !_popular.contains(e.key))
        .toList();

    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: surface,
      appBar: SplitrDetailAppBar(title: AppStrings.currency.title),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              groupGutter,
              groupGapSm,
              groupGutter,
              groupGapSm,
            ),
            child: BorderedInputField(
              controller: _searchCtrl,
              hintText: AppStrings.currency.searchHint,
              onChanged: (v) => setState(() => _query = v.trim()),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 20,
                color: groupOnSurfaceMuted,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                groupGutter,
                groupGapSm,
                groupGutter,
                groupGapLg,
              ),
              children: [
                if (regional.isNotEmpty && _query.isEmpty) ...[
                  _sectionHeader(AppStrings.currency.yourRegion),
                  const SizedBox(height: 8),
                  _buildGroup(context, regional),
                  const SizedBox(height: 20),
                ],
                if (popular.isNotEmpty && _query.isEmpty) ...[
                  _sectionHeader(AppStrings.currency.popular),
                  const SizedBox(height: 8),
                  _buildGroup(context, popular),
                  const SizedBox(height: 20),
                ],
                if (others.isNotEmpty || _query.isNotEmpty) ...[
                  if (_query.isEmpty)
                    _sectionHeader(AppStrings.currency.allCurrencies),
                  if (_query.isEmpty) const SizedBox(height: 8),
                  _buildGroup(context, _query.isEmpty ? others : filtered),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: caption_text.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 1.6,
        color: groupOnSurfaceMuted,
        fontStyle: FontStyle.normal,
      ),
    );
  }

  Widget _buildGroup(
      BuildContext context, List<MapEntry<String, String>> entries) {
    final surface = Theme.of(context).colorScheme.surface;
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(groupCardRadius),
        border: Border.all(color: groupMutedBorderHairline),
      ),
      child: Column(
        children: entries.asMap().entries.map((e) {
          final isLast = e.key == entries.length - 1;
          final code = e.value.key;
          final name = e.value.value;
          return _buildCurrencyTile(
            context: context,
            code: code,
            name: name,
            isLast: isLast,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCurrencyTile({
    required BuildContext context,
    required String code,
    required String name,
    bool isLast = false,
  }) {
    return Obx(() {
      final isSelected = _cc.code == code;
      return Column(
        children: [
          InkWell(
            onTap: () => _pick(code),
            borderRadius:
                isLast ? groupSheetBottomBorderRadius : BorderRadius.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: groupGap18, vertical: groupGap14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? neopopYellow : groupMutedFillMedium,
                      borderRadius: BorderRadius.circular(groupRadiusMd),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      CurrencyService.symbolFor(code),
                      style: TextStyle(
                        fontSize: splitrFontBodyLg,
                        fontWeight: FontWeight.w700,
                        color:
                            isSelected ? neopopBackground : groupOnSurfaceMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: body2_text.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: groupOnSurface,
                          ),
                        ),
                        Text(
                          code,
                          style: caption_text.copyWith(
                            color: groupOnSurfaceMuted,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded,
                        color: neopopAccent, size: 20),
                ],
              ),
            ),
          ),
          if (!isLast)
            Divider(
                height: 1, color: groupMutedBorder, indent: 18, endIndent: 18),
        ],
      );
    });
  }
}
