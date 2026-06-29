import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Controllers/premium_subscription_controller.dart';

// ─── Screen palette (matches profile_screen.dart) ─────────────────────────────
const Color _bg = Color(0xFFF0F0F5);
const Color _cardBg = Colors.white;
const Color _sectionLabel = Color(0xFF9E9E9E);
const Color _titleColor = Color(0xFF1A1A1A);
const Color _borderColor = Color(0xFFEEEEEE);
const Color _premiumDark = Color(0xFF0F0F0F);
const Color _accentGreen = Color(0xFFB5F542);
const Color _accentPurple = Color(0xFF8B5CF6);
const Color _neopopYellow = Color(0xFFEAFF41);

class PremiumPlanScreen extends StatefulWidget {
  final String? highlightFeature;

  const PremiumPlanScreen({this.highlightFeature, super.key});

  @override
  State<PremiumPlanScreen> createState() => _PremiumPlanScreenState();
}

class _PremiumPlanScreenState extends State<PremiumPlanScreen> {
  bool _isYearly = false;
  late final PremiumSubscriptionController _premium;

  @override
  void initState() {
    super.initState();
    _premium = Get.find<PremiumSubscriptionController>();
  }

  @override
  Widget build(BuildContext context) {
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
          'Premium Plans',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _titleColor,
            letterSpacing: 0.2,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ─────────────────────────────────────────────────────────
            const Text(
              'unlock the full\npotential.',
              style: TextStyle(
                fontFamily: 'Albra',
                fontSize: 32,
                fontWeight: FontWeight.w400,
                height: 1.2,
                color: _titleColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Charge for convenience, not your right to split.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: _sectionLabel,
              ),
            ),
            const SizedBox(height: 28),

            if (widget.highlightFeature != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _neopopYellow.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _neopopYellow.withOpacity(0.4)),
                ),
                child: Text(
                  'Unlock ${widget.highlightFeature} with Pro',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _titleColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── BILLING TOGGLE ─────────────────────────────────────────────────
            _buildBillingToggle(),
            const SizedBox(height: 28),

            // ── BASIC CARD ──────────────────────────────────────────────────────
            _buildBasicCard(),
            const SizedBox(height: 16),

            // ── PREMIUM CARD ────────────────────────────────────────────────────
            _buildPremiumCard(),
            const SizedBox(height: 24),

            // ── FOOTER NOTE ─────────────────────────────────────────────────────
            Center(
              child: Text(
                'Cancel anytime. No questions asked.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: _sectionLabel.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () async {
                  try {
                    await _premium.restorePurchases();
                    if (_premium.isPremium.value && mounted) {
                      Get.back(result: true);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Restore failed: $e')),
                      );
                    }
                  }
                },
                child: const Text(
                  'Restore purchases',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: _sectionLabel,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () async {
                    await _premium.enableDevPremium();
                    if (mounted) Get.back(result: true);
                  },
                  child: const Text(
                    'Enable dev Pro (debug only)',
                    style: TextStyle(fontSize: 11, color: _accentPurple),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Billing Toggle ──────────────────────────────────────────────────────────
  Widget _buildBillingToggle() {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildToggleOption('Monthly', !_isYearly),
          _buildToggleOption('Yearly  (Save 25%)', _isYearly),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isYearly = label.startsWith('Yearly')),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? _titleColor : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : _sectionLabel,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Basic Card ──────────────────────────────────────────────────────────────
  Widget _buildBasicCard() {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'BASIC',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: _sectionLabel,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'CURRENT PLAN',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: _sectionLabel,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Free',
            style: TextStyle(
              fontFamily: 'Albra',
              fontSize: 28,
              fontWeight: FontWeight.w400,
              color: _titleColor,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: _borderColor),
          const SizedBox(height: 16),
          _buildFeatureRow('Unlimited expense splitting', true),
          _buildFeatureRow('Unlimited groups', true),
          _buildFeatureRow('Basic monthly stats', true),
          _buildFeatureRow('Standard support', true),
          _buildFeatureRow('AI Receipt scanning', false),
          _buildFeatureRow('UPI Quick Settle links', false),
          _buildFeatureRow('Advanced analytics', false),
          _buildFeatureRow('CSV / PDF export', false),
        ],
      ),
    );
  }

  // ─── Premium Card ────────────────────────────────────────────────────────────
  Widget _buildPremiumCard() {
    final storeProduct = _premium.productFor(_isYearly);
    final price = storeProduct?.price ??
        (_isYearly ? '₹799/yr' : '₹89/mo');
    final sub = storeProduct != null
        ? storeProduct.description
        : (_isYearly ? 'Billed annually (₹66.58/mo)' : 'Billed monthly');

    return Container(
      decoration: BoxDecoration(
        color: _premiumDark,
        borderRadius: BorderRadius.circular(20),
        // Subtle green-purple glow matching the avatar
        boxShadow: [
          BoxShadow(
              color: _accentGreen.withOpacity(0.25),
              blurRadius: 32,
              offset: const Offset(-4, 8)),
          BoxShadow(
              color: _accentPurple.withOpacity(0.25),
              blurRadius: 32,
              offset: const Offset(4, -8)),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Text(
                    '✦ ',
                    style: TextStyle(fontSize: 14, color: _neopopYellow),
                  ),
                  Text(
                    'PREMIUM',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: _neopopYellow,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _neopopYellow.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _neopopYellow.withOpacity(0.4)),
                ),
                child: const Text(
                  'RECOMMENDED',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: _neopopYellow,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: const TextStyle(
              fontFamily: 'Albra',
              fontSize: 32,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: Colors.white.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          _buildPremiumFeatureRow('Everything in Basic'),
          _buildPremiumFeatureRow('🧾  AI Receipt Scanning (OCR)'),
          _buildPremiumFeatureRow('⚡  UPI Quick Settle Links'),
          _buildPremiumFeatureRow('📊  Advanced Analytics & Charts'),
          _buildPremiumFeatureRow('📂  CSV & PDF Export'),
          _buildPremiumFeatureRow('✦  Elite Splitter Badge'),
          const SizedBox(height: 20),

          Obx(() {
            final loading = _premium.isLoading.value;
            final isPro = _premium.isPremium.value;
            return GestureDetector(
              onTap: loading || isPro
                  ? null
                  : () async {
                      try {
                        if (_isYearly) {
                          await _premium.purchaseYearly();
                        } else {
                          await _premium.purchaseMonthly();
                        }
                        if (_premium.isPremium.value && mounted) {
                          Get.back(result: true);
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                e.toString().contains('Store not available')
                                    ? 'Store unavailable — use Restore or dev Pro in debug'
                                    : 'Purchase failed: $e',
                              ),
                            ),
                          );
                        }
                      }
                    },
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: isPro ? _accentGreen : _neopopYellow,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        isPro
                            ? 'YOU\'RE ON PRO ✦'
                            : 'SUBSCRIBE — $price',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: Colors.black,
                        ),
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String label, bool included) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            included ? Icons.check_circle_rounded : Icons.cancel_outlined,
            size: 17,
            color: included ? const Color(0xFF4CAF50) : const Color(0xFFCCCCCC),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: included ? _titleColor : _sectionLabel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFeatureRow(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, size: 17, color: _accentGreen),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
