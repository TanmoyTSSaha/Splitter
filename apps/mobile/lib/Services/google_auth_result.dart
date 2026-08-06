/// Outcome of a Google sign-in attempt from [AuthService.signInWithGoogle].
enum GoogleAuthOutcome {
  /// Native or browser OAuth finished; session is active.
  completed,

  /// Browser OAuth launched; session will arrive via deep link.
  pendingBrowser,

  /// User dismissed the Google account picker.
  cancelled,

  /// Sign-in failed; see [GoogleAuthResult.userMessage].
  failed,
}

final class GoogleAuthResult {
  const GoogleAuthResult._(this.outcome, {this.userMessage});

  const GoogleAuthResult.completed() : this._(GoogleAuthOutcome.completed);

  const GoogleAuthResult.pendingBrowser()
      : this._(GoogleAuthOutcome.pendingBrowser);

  const GoogleAuthResult.cancelled() : this._(GoogleAuthOutcome.cancelled);

  const GoogleAuthResult.failed(String message)
      : this._(GoogleAuthOutcome.failed, userMessage: message);

  final GoogleAuthOutcome outcome;
  final String? userMessage;

  bool get isCompleted => outcome == GoogleAuthOutcome.completed;

  bool get isPendingBrowser => outcome == GoogleAuthOutcome.pendingBrowser;
}
