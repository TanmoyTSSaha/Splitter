/// Centralized brand name, share copy, and technical identifiers for Splitr.
abstract final class AppBranding {
  static const brandName = 'Splitr';
  static const brandLogo = 'Splitr.';
  static const brandPro = 'Splitr Pro';
  static const shareHashtag = '#SplitrApp';
  static const shareAttribution = 'Shared from Splitr ✨';

  // Deep links (canonical)
  static const appScheme = 'splitr';
  static const webBaseUrl = 'https://splitr.app';

  /// Supabase OAuth / email confirm / password recovery redirect.
  static String get authRedirectUrl => '$appScheme://login-callback/';

  /// Android application id (Play Store).
  static const androidApplicationId = 'money.splitr.app';

  // Legacy deep links (parse only — do not emit in new shares)
  static const legacyAppScheme = 'splito';
  static const legacyWebHost = 'splito.app';

  // Razorpay Pro plan display names (IDs live in Supabase Edge Function secrets)
  static const proPlanMonthlyLabel = 'splitr_pro_monthly';
  static const proPlanYearlyLabel = 'splitr_pro_yearly';

  // Local storage / filenames
  static const localDbFileName = 'splitr_local.db';
  static const legacyLocalDbFileName = 'splito_local.db';
  static const notificationChannelId = 'splitr_reminders';
  static const budgetChannelId = 'splitr_budget_alerts';
  static const exportFilePrefix = 'splitr';
}
