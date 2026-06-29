import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Controllers/currency_controller.dart';
import 'package:splitter/Services/currency_service.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const Color _bg = Color(0xFFF0F0F5);
const Color _cardBg = Colors.white;
const Color _sectionLabel = Color(0xFF9E9E9E);
const Color _titleColor = Color(0xFF1A1A1A);
const Color _borderColor = Color(0xFFEEEEEE);
const Color _neopopYellow = Color(0xFFEAFF41);

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

  // Groupings
  static const _regional = ['INR'];
  static const _popular = [
    'USD',
    'EUR',
    'GBP',
    'AED',
    'SGD',
    'AUD',
    'CAD',
    'JPY'
  ];

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Currency set to ${_cc.name} (${_cc.symbol})',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          backgroundColor: _neopopYellow,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
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
          'Edit Currency',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _titleColor,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── Search bar ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
            child: Container(
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _borderColor),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v.trim()),
                style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 14, color: _titleColor),
                decoration: InputDecoration(
                  hintText: 'Search currencies...',
                  hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: _sectionLabel.withOpacity(0.7)),
                  prefixIcon: const Icon(Icons.search_rounded,
                      size: 20, color: _sectionLabel),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),

          // ── Currency list ────────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                if (regional.isNotEmpty && _query.isEmpty) ...[
                  _sectionHeader('YOUR REGION'),
                  const SizedBox(height: 8),
                  _buildGroup(regional),
                  const SizedBox(height: 20),
                ],
                if (popular.isNotEmpty && _query.isEmpty) ...[
                  _sectionHeader('POPULAR'),
                  const SizedBox(height: 8),
                  _buildGroup(popular),
                  const SizedBox(height: 20),
                ],
                if (others.isNotEmpty || _query.isNotEmpty) ...[
                  if (_query.isEmpty) _sectionHeader('ALL CURRENCIES'),
                  if (_query.isEmpty) const SizedBox(height: 8),
                  _buildGroup(_query.isEmpty ? others : filtered),
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
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.6,
        color: _sectionLabel,
      ),
    );
  }

  Widget _buildGroup(List<MapEntry<String, String>> entries) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: entries.asMap().entries.map((e) {
          final isLast = e.key == entries.length - 1;
          final code = e.value.key;
          final name = e.value.value;
          return _buildCurrencyTile(code: code, name: name, isLast: isLast);
        }).toList(),
      ),
    );
  }

  Widget _buildCurrencyTile({
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
            borderRadius: isLast
                ? const BorderRadius.vertical(bottom: Radius.circular(16))
                : BorderRadius.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  // Symbol pill
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? _neopopYellow : _bg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      CurrencyService.symbolFor(code),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.black : _sectionLabel,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Name + code
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: _titleColor,
                          ),
                        ),
                        Text(
                          code,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: _sectionLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF4CAF50), size: 20),
                ],
              ),
            ),
          ),
          if (!isLast)
            const Divider(
                height: 1, color: _borderColor, indent: 18, endIndent: 18),
        ],
      );
    });
  }
}
