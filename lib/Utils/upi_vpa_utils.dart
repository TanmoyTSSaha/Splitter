// VPA validation and display masking for UPI settle-up.

abstract final class UpiVpaUtils {
  static final _vpaPattern = RegExp(
    r'^[a-z0-9._-]{2,256}@[a-z0-9.-]{2,64}$',
  );

  /// Normalizes and validates a UPI VPA. Returns normalized VPA or null.
  static String? validateAndNormalize(String raw) {
    final trimmed = raw.trim().toLowerCase();
    if (trimmed.isEmpty) return null;
    if (!_vpaPattern.hasMatch(trimmed)) return null;
    return trimmed;
  }

  /// Masks local part of VPA: `rahul@okhdfcbank` → `ra***@okhdfcbank`.
  static String maskVpa(String vpa) {
    final normalized = vpa.trim().toLowerCase();
    final at = normalized.indexOf('@');
    if (at <= 0) return '***';
    final local = normalized.substring(0, at);
    final domain = normalized.substring(at);
    if (local.length <= 2) {
      return '${local[0]}***$domain';
    }
    return '${local.substring(0, 2)}***$domain';
  }
}
