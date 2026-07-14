import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime secrets — never commit real values.
///
/// Resolution order per key:
/// 1. `--dart-define=KEY=value` or `--dart-define-from-file=env.json` (CI / release)
/// 2. `.env` file in project root (local dev, gitignored)
abstract final class AppSecrets {
  static String _resolve(String dartDefineKey, String envKey) {
    const empty = '';
    final fromDefine =
        String.fromEnvironment(dartDefineKey, defaultValue: empty);
    if (fromDefine.isNotEmpty) return fromDefine;
    try {
      return dotenv.maybeGet(envKey) ?? empty;
    } catch (_) {
      return empty;
    }
  }

  static String get supabaseUrl => _resolve('SUPABASE_URL', 'SUPABASE_URL');

  static String get supabaseAnonKey =>
      _resolve('SUPABASE_ANON_KEY', 'SUPABASE_ANON_KEY');

  static String get supabasePassword =>
      _resolve('SUPABASE_PASSWORD', 'SUPABASE_PASSWORD');

  static String get supabaseDirectDatabaseConnectionString =>
      _resolve('SUPABASE_DB_URL', 'SUPABASE_DB_URL');

  static String get geminiApiKey =>
      _resolve('GEMINI_API_KEY', 'GEMINI_API_KEY');

  static String get googleWebClientId =>
      _resolve('GOOGLE_WEB_CLIENT_ID', 'GOOGLE_WEB_CLIENT_ID');

  static String get razorpayKeyId =>
      _resolve('RAZORPAY_KEY_ID', 'RAZORPAY_KEY_ID');

  static String get sentryDsn => _resolve('SENTRY_DSN', 'SENTRY_DSN');

  static String get sentryEnvironment =>
      _resolve('SENTRY_ENVIRONMENT', 'SENTRY_ENVIRONMENT');

  static bool get sentryEnabled => sentryDsn.isNotEmpty;

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
