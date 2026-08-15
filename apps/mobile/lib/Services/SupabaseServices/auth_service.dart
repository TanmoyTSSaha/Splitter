import 'package:connectivity_plus/connectivity_plus.dart';
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
import 'package:splitr/Services/google_auth_errors.dart';
import 'package:splitr/Services/google_auth_result.dart';
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

  String? _googleAuthUserMessage(AuthException e) =>
      GoogleAuthErrors.mapAuthException(e);

  bool _isLikelyOAuthOnlySignup(User user) {
    final identities = user.identities;
    return identities == null || identities.isEmpty;
  }

  bool _hasActiveSession() {
    final session = supabase.auth.currentSession;
    return session != null && !session.isExpired;
  }

  String? supabaseGetUserIDOrNull() => supabase.auth.currentUser?.id;

  String supabaseGetUserID() {
    final userId = supabaseGetUserIDOrNull();
    if (userId == null) {
      SplitrToast.show(AppStrings.services.auth.somethingWentWrong);
      return '';
    }
    return userId;
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

  /// Native Google Sign-In via [google_sign_in] + [signInWithIdToken] only (D-01).
  Future<GoogleAuthResult> signInWithGoogle() async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (!connectivity.any((r) => r != ConnectivityResult.none)) {
        return GoogleAuthResult.failed(
          AppStrings.services.auth.googleSignInOffline,
        );
      }

      if (AppSecrets.googleWebClientId.isEmpty) {
        AppErrorReporter.report(
          'Google Sign-In unavailable: missing GOOGLE_WEB_CLIENT_ID',
          context: {
            'feature': 'auth',
            'reason': 'missing_google_web_client_id',
          },
          showToastOnUserFacing: false,
        );
        return GoogleAuthResult.failed(
          AppStrings.services.auth.googleSignInUnavailableUseEmail,
        );
      }

      await _ensureGoogleSignInInitialized();
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {
        // Best-effort so account picker shows on repeat attempts (D-07).
      }

      GoogleSignInAccount account;
      try {
        account = await GoogleSignIn.instance.authenticate();
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled) {
          return const GoogleAuthResult.cancelled();
        }
        rethrow;
      }

      const scopes = [OAuthScopes.googleEmail, OAuthScopes.googleProfile];
      final authorization =
          await account.authorizationClient.authorizationForScopes(scopes) ??
              await account.authorizationClient.authorizeScopes(scopes);

      final idToken = account.authentication.idToken;
      if (idToken == null) {
        AppErrorReporter.report(
          'Google sign-in missing ID token',
          context: {'feature': 'auth', 'reason': 'missing_id_token'},
          showToastOnUserFacing: false,
        );
        return GoogleAuthResult.failed(
          AppStrings.services.auth.googleNoIdToken,
        );
      }

      return await _signInWithGoogleTokens(
        idToken: idToken,
        accessToken: authorization.accessToken,
      );
    } on GoogleSignInException catch (e, stack) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const GoogleAuthResult.cancelled();
      }
      AppErrorReporter.report(
        'AuthService.signInWithGoogle failed',
        error: e,
        stack: stack,
        context: {'feature': 'auth', 'operation': 'googleSignIn'},
        showToastOnUserFacing: false,
      );
      return GoogleAuthResult.failed(GoogleAuthErrors.mapThrowable(e));
    } on AuthException catch (e, stack) {
      return _googleAuthFailureFromException(e, stack: stack);
    } catch (e, stack) {
      if (GoogleAuthErrors.shouldReportGoogleAuthFailure(
        outcome: GoogleAuthOutcome.failed,
        error: e,
      )) {
        AppErrorReporter.report(
          'AuthService.signInWithGoogle failed',
          error: e,
          stack: stack,
          context: {'feature': 'auth', 'operation': 'googleSignIn'},
          showToastOnUserFacing: false,
        );
      }
      return GoogleAuthResult.failed(GoogleAuthErrors.mapThrowable(e));
    }
  }

  Future<GoogleAuthResult> _signInWithGoogleTokens({
    required String idToken,
    required String? accessToken,
  }) async {
    try {
      final response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.session == null && !_hasActiveSession()) {
        AppErrorReporter.report(
          'Google sign-in completed without session',
          context: {'feature': 'auth', 'operation': 'signInWithIdToken'},
          showToastOnUserFacing: false,
        );
        return GoogleAuthResult.failed(
          AppStrings.services.auth.googleSignInFailed,
        );
      }

      final user = response.user ?? supabase.auth.currentUser;
      if (user != null) {
        await _syncGoogleProfileIfNeeded(user);
      }

      return const GoogleAuthResult.completed();
    } on AuthException catch (e, stack) {
      if (GoogleAuthErrors.isVerifiedEmailIdentityConflict(e)) {
        try {
          final linkResponse = await supabase.auth.linkIdentityWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
            accessToken: accessToken,
          );

          if (linkResponse.session != null || _hasActiveSession()) {
            final user = linkResponse.user ?? supabase.auth.currentUser;
            if (user != null) {
              await _syncGoogleProfileIfNeeded(user);
            }
            return const GoogleAuthResult.completed();
          }
        } on AuthException catch (linkError, linkStack) {
          AppErrorReporter.report(
            'AuthService.linkIdentityWithIdToken failed',
            error: linkError,
            stack: linkStack,
            context: {
              'feature': 'auth',
              'operation': 'linkIdentityWithIdToken',
            },
            showToastOnUserFacing: false,
          );
          final mapped = _googleAuthUserMessage(linkError);
          return GoogleAuthResult.failed(
            mapped ?? AppStrings.services.auth.googleSignInConfigError,
          );
        }

        AppErrorReporter.report(
          'Google identity link did not establish session',
          error: e,
          stack: stack,
          context: {'feature': 'auth', 'operation': 'linkIdentityWithIdToken'},
          showToastOnUserFacing: false,
        );
        return GoogleAuthResult.failed(
          AppStrings.services.auth.googleEmailRegisteredWithPassword,
        );
      }
      return _googleAuthFailureFromException(e, stack: stack);
    }
  }

  GoogleAuthResult _googleAuthFailureFromException(
    AuthException e, {
    StackTrace? stack,
  }) {
    AppErrorReporter.report(
      'AuthService.signInWithGoogle AuthException',
      error: e,
      stack: stack,
      context: {'feature': 'auth', 'operation': 'googleSignIn'},
      showToastOnUserFacing: false,
    );
    final mapped = _googleAuthUserMessage(e);
    return GoogleAuthResult.failed(
      mapped ?? AppStrings.services.auth.googleSignInFailed,
    );
  }

  /// Backward-compatible wrapper; shows toast on failure.
  Future<bool> googleSignIn() async {
    final result = await signInWithGoogle();
    switch (result.outcome) {
      case GoogleAuthOutcome.completed:
        return true;
      case GoogleAuthOutcome.cancelled:
        SplitrToast.show(AppStrings.services.auth.googleSignInCancelled);
        return false;
      case GoogleAuthOutcome.failed:
        final message = result.userMessage;
        if (message != null && message.isNotEmpty) {
          SplitrToast.show(message);
        }
        return false;
    }
  }

  Future<void> _syncGoogleProfileIfNeeded(User user) async {
    final meta = user.userMetadata;
    if (meta == null || meta.isEmpty) return;

    final fullName = _readMetaString(meta, ['full_name', 'name']);
    final givenName = _readMetaString(meta, ['given_name', 'first_name']);
    final familyName = _readMetaString(meta, ['family_name', 'last_name']);
    final avatarUrl =
        _readMetaString(meta, ['avatar_url', 'picture', 'profile_picture_url']);

    String firstName = givenName ?? '';
    String lastName = familyName ?? '';
    if (firstName.isEmpty && fullName != null && fullName.isNotEmpty) {
      final parts = fullName.trim().split(RegExp(r'\s+'));
      firstName = parts.first;
      if (parts.length > 1) {
        lastName = parts.sublist(1).join(' ');
      }
    }

    final userName = _readMetaString(meta, ['user_name', 'preferred_username']) ??
        (firstName.isNotEmpty ? firstName : null) ??
        (user.email?.split('@').first ?? 'User');

    final row = <String, dynamic>{
      SupabaseColumns.userId: user.id,
      SupabaseColumns.userEmail: user.email ?? '',
      SupabaseColumns.userName: userName,
      SupabaseColumns.firstname: firstName,
      SupabaseColumns.lastname: lastName,
    };
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      row[SupabaseColumns.profilePictureUrl] = avatarUrl;
    }

    try {
      await supabase.from(SupabaseTables.users).upsert(row);
    } catch (e, stack) {
      AppErrorReporter.report(
        'AuthService._syncGoogleProfileIfNeeded failed',
        error: e,
        stack: stack,
        context: {'feature': 'auth', 'operation': 'syncGoogleProfile'},
        showToastOnUserFacing: false,
      );
    }
  }

  String? _readMetaString(Map<String, dynamic> meta, List<String> keys) {
    for (final key in keys) {
      final value = meta[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
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
