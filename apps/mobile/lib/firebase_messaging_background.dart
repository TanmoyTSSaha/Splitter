import 'package:firebase_messaging/firebase_messaging.dart';

/// Top-level background handler required by `firebase_messaging`.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No UI work in background isolate; OS shows notification from FCM payload.
}
