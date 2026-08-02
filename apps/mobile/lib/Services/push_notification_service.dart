import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:splitr/Controller/notification_badge_controller.dart';
import 'package:splitr/Screen/ProfileScreen/notifications_screen.dart';
import 'package:splitr/Services/SupabaseServices/device_token_service.dart';
import 'package:splitr/Services/app_logger.dart';
import 'package:splitr/Services/reminder_service.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:splitr/firebase_messaging_background.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Android FCM registration, foreground display, and tap routing.
class PushNotificationService {
  PushNotificationService({
    required ReminderService reminderService,
    DeviceTokenService? tokenService,
  })  : _reminderService = reminderService,
        _tokenService = tokenService ?? DeviceTokenService();

  final DeviceTokenService _tokenService;
  final ReminderService _reminderService;
  late final FirebaseMessaging _messaging;

  bool _initialized = false;
  String? _currentToken;

  bool get isAvailable => _initialized;

  Future<void> initialize() async {
    if (!Platform.isAndroid || kIsWeb) return;
    if (_initialized) return;

    try {
      await Firebase.initializeApp();
      _messaging = FirebaseMessaging.instance;
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      _initialized = true;
    } catch (e, stack) {
      AppLogger.warning(
        'PushNotificationService: Firebase init skipped',
        data: {'error': e.toString()},
      );
      return;
    }

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);
    _messaging.onTokenRefresh.listen(_onTokenRefresh);

    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _handleNavigation(initial.data);
    }
  }

  Future<void> registerForUser(String userId) async {
    if (!_initialized) return;

    try {
      final granted = await _reminderService.requestPermission();
      if (!granted) {
        AppLogger.warning('Push permission denied', data: {'userId': userId});
        return;
      }

      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;

      _currentToken = token;
      await _tokenService.upsertToken(userId: userId, token: token);
    } catch (e, stack) {
      if (!AppErrorReporter.shouldSkipSentry(e)) {
        AppErrorReporter.report(
          'PushNotificationService.registerForUser failed',
          error: e,
          stack: stack,
          context: {'feature': 'push', 'operation': 'registerForUser'},
          showToastOnUserFacing: false,
        );
      } else {
        AppLogger.warning(
          'PushNotificationService.registerForUser skipped',
          data: {'error': e.toString()},
        );
        _initialized = false;
      }
    }
  }

  Future<void> unregisterCurrentUser() async {
    if (!_initialized) return;
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final token = _currentToken ?? await _messaging.getToken();
    if (userId != null && token != null) {
      await _tokenService.deleteToken(userId: userId, token: token);
    }
    try {
      await _messaging.deleteToken();
    } catch (_) {
      // Token may already be gone.
    }
    _currentToken = null;
  }

  Future<void> _onTokenRefresh(String token) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    _currentToken = token;
    await _tokenService.upsertToken(userId: userId, token: token);
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _reminderService.showBudgetAlert(
      id: message.hashCode,
      title: notification.title ?? '',
      body: notification.body ?? '',
    );

    if (Get.isRegistered<NotificationBadgeController>()) {
      await Get.find<NotificationBadgeController>().updateBadge();
    }
  }

  void _onMessageOpened(RemoteMessage message) {
    _handleNavigation(message.data);
  }

  void _handleNavigation(Map<String, dynamic> data) {
    if (Get.currentRoute != '/NotificationsScreen') {
      Get.to(() => const NotificationsScreen());
    }
  }
}
