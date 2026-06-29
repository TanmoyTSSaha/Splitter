import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitter/Constants/constants.dart';
import 'package:splitter/Screen/BottomNavigationController/bottom_navigation_controller.dart';
import 'package:splitter/Services/biometric_auth_service.dart';

/// Full-screen biometric lock shown on cold start when biometric lock is enabled.
class BiometricLockScreen extends StatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen> {
  final BiometricAuthService _bioService = BiometricAuthService();
  bool _isAuthenticating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) _authenticate();
    });
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    final result = await _bioService.authenticate();

    if (!mounted) return;

    if (result.isSuccess) {
      Get.offAll(() => const BottomNavigationController());
      return;
    }

    setState(() {
      _isAuthenticating = false;
      if (result.status == BiometricAuthStatus.cancelled) {
        _errorMessage = null;
      } else {
        _errorMessage =
            result.message ?? 'Authentication failed. Tap to retry.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: neopopBackground,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // ── App Icon ──
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      neopopAccent,
                      neopopAccent.withOpacity(0.6),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: neopopAccent.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'S',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Title ──
              Text(
                'SplitO',
                style: headline1_text.copyWith(
                  color: neopopOnPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Locked',
                style: body1_text.copyWith(
                  color: neopopOnPrimary.withOpacity(0.4),
                ),
              ),

              const Spacer(flex: 2),

              // ── Fingerprint Button ──
              GestureDetector(
                onTap: _isAuthenticating ? null : _authenticate,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isAuthenticating
                        ? neopopAccent.withOpacity(0.1)
                        : neopopAccent.withOpacity(0.15),
                    border: Border.all(
                      color: neopopAccent.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: _isAuthenticating
                      ? const Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: neopopAccent,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.fingerprint_rounded,
                          color: neopopAccent,
                          size: 36,
                        ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                _isAuthenticating ? 'Authenticating...' : 'Tap to unlock',
                style: caption_text.copyWith(
                  color: neopopOnPrimary.withOpacity(0.5),
                ),
              ),

              // ── Error Message ──
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _authenticate,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: neopopYellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: caption_text.copyWith(
                        color: neopopYellow,
                      ),
                    ),
                  ),
                ),
              ],

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
