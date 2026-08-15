/// Outcome of a Google sign-in attempt from [AuthService.signInWithGoogle].
enum GoogleAuthOutcome {
  /// Native Google sign-in finished; session is active.
  completed,

  /// User dismissed the Google account picker.
  cancelled,

  /// Sign-in failed; see [GoogleAuthResult.userMessage].
  failed,
}

final class GoogleAuthResult {
  const GoogleAuthResult._(this.outcome, {this.userMessage});

  const GoogleAuthResult.completed() : this._(GoogleAuthOutcome.completed);

  const GoogleAuthResult.cancelled() : this._(GoogleAuthOutcome.cancelled);

  const GoogleAuthResult.failed(String message)
      : this._(GoogleAuthOutcome.failed, userMessage: message);

  final GoogleAuthOutcome outcome;
  final String? userMessage;

  bool get isCompleted => outcome == GoogleAuthOutcome.completed;
}
