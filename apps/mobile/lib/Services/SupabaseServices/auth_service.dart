import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitr/Services/local/database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:splitr/Constants/app_branding.dart';
import 'package:splitr/Constants/auth_validators.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/config/app_secrets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;
  static bool _googleSignInInitialized = false;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: AppSecrets.googleWebClientId,
    );
    _googleSignInInitialized = true;
  }

  Future<void> _clearLocalUserCache() async {
    if (Get.isRegistered<AppDatabase>()) {
      await Get.find<AppDatabase>().clearAllUserData();
    }
  }

  Future<void> _recordLastLoginMethod(String method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefKeys.lastUsedLoginMethod, method);
  }

  Future<String?> getLastUsedLoginMethod() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefKeys.lastUsedLoginMethod);
  }

  Future<void> recordLastUsedLoginMethod(String method) =>
      _recordLastLoginMethod(method);

  String? _googleAuthUserMessage(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('email not confirmed') ||
        msg.contains('email_not_confirmed')) {
      return AppStrings.services.auth.verifyEmailBeforeGoogle;
    }
    return null;
  }

  bool _isLikelyOAuthOnlySignup(User user) {
    final identities = user.identities;
    return identities == null || identities.isEmpty;
  }

  String supabaseGetUserID() {
    final currentUser = supabase.auth.currentUser;

    if (currentUser == null) {
      SplitrToast.show(AppStrings.services.auth.somethingWentWrong);

      return '';
    }

    return currentUser.id;
  }

  Future<bool> supabaseEmailPassSignIn(
      {required String userEmail, required String userPassword}) async {
    try {
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: userEmail,
        password: userPassword,
      );

      final User? user = response.user;

      if (user == null) {
        SplitrToast.show(AppStrings.services.auth.invalidUserDetails);

        return false;
      }

      await _clearLocalUserCache();
      await _recordLastLoginMethod(LoginMethods.email);

      return true;
    } on AuthException catch (e) {
      AppErrorReporter.userFacing(e.message, error: e, context: {'feature': 'auth'});
      return false;
    } catch (e, stack) {
      AppErrorReporter.report(
        'AuthService.supabaseEmailPassSignIn failed',
        error: e,
        stack: stack,
        context: {'feature': 'auth', 'operation': 'emailPassSignIn'},
      );
      return false;
    }
  }

  void supabaseSignOut() async {
    try {
      await supabase.auth.signOut();
      await _clearLocalUserCache();
      SplitrToast.show(AppStrings.services.auth.loggedOutSuccess);
    } catch (e, stack) {
      AppErrorReporter.report(
        'AuthService.supabaseSignOut failed',
        error: e,
        stack: stack,
        context: {'feature': 'auth', 'operation': 'signOut'},
      );
    }
  }

  Future<bool> supabaseSignUp({
    required String userEmail,
    required String userPassword,
    required String userName,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: userEmail,
        password: userPassword,
        data: {
          SupabaseAuthMetadata.userName: userName,
          SupabaseAuthMetadata.firstName: firstName,
          SupabaseAuthMetadata.lastName: lastName,
        },
        emailRedirectTo: AppBranding.authRedirectUrl,
      );

      final User? user = response.user;

      if (user == null) {
        SplitrToast.show(AppStrings.services.auth.signUpFailed);
        return false;
      }

      if (response.session == null && _isLikelyOAuthOnlySignup(user)) {
        SplitrToast.show(AppStrings.services.auth.emailAlreadyRegisteredUseGoogle);
        return false;
      }

      if (response.session != null) {
        try {
          await supabase.from(SupabaseTables.users).upsert({
            SupabaseColumns.userId: user.id,
            SupabaseColumns.userName: userName,
            SupabaseColumns.firstname: firstName,
            SupabaseColumns.lastname: lastName,
            SupabaseColumns.userEmail: userEmail,
            SupabaseColumns.createdAt: DateTime.now().toIso8601String(),
          });
        } catch (e) {
          // Profile upsert is best-effort when triggers already created the row.
        }
      }

      return true;
    } on AuthException catch (e) {
      AppErrorReporter.userFacing(e.message, error: e, context: {'feature': 'auth'});
      return false;
    } catch (e) {
      AppErrorReporter.userFacing(
        AppStrings.services.auth.unexpectedError,
        error: e,
        context: {'feature': 'auth', 'operation': 'signUp'},
      );
      return false;
    }
  }

  Future<bool> googleSignIn() async {
    try {
      if (AppSecrets.googleWebClientId.isNotEmpty) {
        await _ensureGoogleSignInInitialized();
        GoogleSignInAccount account;
        try {
          account = await GoogleSignIn.instance.authenticate();
        } on GoogleSignInException catch (e) {
          if (e.code == GoogleSignInExceptionCode.canceled) return false;
          rethrow;
        }

        const scopes = [OAuthScopes.googleEmail, OAuthScopes.googleProfile];
        final authorization =
            await account.authorizationClient.authorizationForScopes(scopes) ??
                await account.authorizationClient.authorizeScopes(scopes);

        final idToken = account.authentication.idToken;
        if (idToken == null) {
          SplitrToast.show(AppStrings.services.auth.googleNoIdToken);
          return false;
        }

        await supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: authorization.accessToken,
        );
        await _clearLocalUserCache();
        await _recordLastLoginMethod(LoginMethods.google);
        return true;
      }

      final bool result = await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: AppBranding.authRedirectUrl,
      );

      return result;
    } on AuthException catch (e) {
      final mapped = _googleAuthUserMessage(e);
      AppErrorReporter.userFacing(
        mapped ?? AppStrings.services.auth.googleSignInFailed,
        error: e,
        context: {'feature': 'auth', 'operation': 'googleSignIn'},
      );
      return false;
    } catch (e) {
      AppErrorReporter.userFacing(
        AppStrings.services.auth.googleSignInFailed,
        error: e,
        context: {'feature': 'auth', 'operation': 'googleSignIn'},
      );
      return false;
    }
  }

  Future<bool> resetPassword({required String email}) async {
    final trimmed = email.trim();
    final validationError = AuthValidators.email(trimmed);
    if (validationError != null) {
      SplitrToast.show(validationError);
      return false;
    }

    try {
      await supabase.auth.resetPasswordForEmail(
        trimmed,
        redirectTo: AppBranding.authRedirectUrl,
      );
      SplitrToast.show(AppStrings.services.auth.passwordResetSent);
      return true;
    } on AuthException catch (e) {
      final msg = e.message
              .toLowerCase()
              .contains(AppStrings.services.auth.rateLimitKeyword)
          ? AppStrings.services.auth.tooManyResetEmails
          : e.message;
      AppErrorReporter.userFacing(msg, error: e, context: {'feature': 'auth'});
      return false;
    } catch (e) {
      AppErrorReporter.userFacing(
        AppStrings.services.auth.couldNotSendResetLink,
        error: e,
        context: {'feature': 'auth', 'operation': 'resetPassword'},
      );
      return false;
    }
  }

  bool supabaseRetrieveSession() {
    try {
      final Session? session = supabase.auth.currentSession;

      if (session == null) {
        return false;
      }

      if (session.isExpired) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
