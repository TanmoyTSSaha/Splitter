import 'package:get/get.dart';
import 'package:splitr/Screen/AuthScreens/reset_password_screen.dart';

/// Prevents duplicate navigation when [DeepLinkService] and the Supabase auth
/// listener both detect the same password-recovery session.
abstract final class AuthRecoveryCoordinator {
  static bool _routed = false;

  /// Routes to [ResetPasswordScreen]. Returns false if already routed.
  static bool routeToResetPassword() {
    if (_routed) return false;
    _routed = true;
    Get.offAll(() => const ResetPasswordScreen());
    return true;
  }

  static void reset() {
    _routed = false;
  }
}
