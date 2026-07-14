import 'package:flutter/widgets.dart';
import 'package:splitr/Utils/app_error_reporter.dart';

/// Master error scope — tags the active screen for all [AppErrorReporter] calls.
class SplitrErrorScope extends StatefulWidget {
  const SplitrErrorScope({
    required this.child,
    this.screenTag,
    super.key,
  });

  final Widget child;
  final String? screenTag;

  static SplitrErrorScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_InheritedSplitrErrorScope>()
        ?.scope;
  }

  void reportUnexpected(
    String message, {
    Object? error,
    StackTrace? stack,
    Map<String, dynamic>? context,
  }) {
    AppErrorReporter.unexpected(
      message,
      error: error,
      stack: stack,
      context: context,
    );
  }

  void reportUserFacing(
    String message, {
    Object? error,
    Map<String, dynamic>? context,
    bool showToast = true,
  }) {
    AppErrorReporter.userFacing(
      message,
      error: error,
      context: context,
      showToast: showToast,
    );
  }

  void report(
    String message, {
    Object? error,
    StackTrace? stack,
    Map<String, dynamic>? context,
    bool showToastOnUserFacing = true,
  }) {
    AppErrorReporter.report(
      message,
      error: error,
      stack: stack,
      context: context,
      showToastOnUserFacing: showToastOnUserFacing,
    );
  }

  @override
  State<SplitrErrorScope> createState() => _SplitrErrorScopeState();
}

class _SplitrErrorScopeState extends State<SplitrErrorScope> {
  @override
  void initState() {
    super.initState();
    _applyTag();
  }

  @override
  void didUpdateWidget(covariant SplitrErrorScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.screenTag != widget.screenTag) _applyTag();
  }

  @override
  void dispose() {
    AppErrorReporter.setActiveScreenTag(null);
    super.dispose();
  }

  void _applyTag() => AppErrorReporter.setActiveScreenTag(widget.screenTag);

  @override
  Widget build(BuildContext context) {
    return _InheritedSplitrErrorScope(
      scope: widget,
      child: widget.child,
    );
  }
}

class _InheritedSplitrErrorScope extends InheritedWidget {
  const _InheritedSplitrErrorScope({
    required this.scope,
    required super.child,
  });

  final SplitrErrorScope scope;

  @override
  bool updateShouldNotify(_InheritedSplitrErrorScope oldWidget) =>
      oldWidget.scope.screenTag != scope.screenTag;
}
