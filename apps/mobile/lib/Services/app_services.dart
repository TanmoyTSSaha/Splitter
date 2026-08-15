import 'package:splitr/Services/deep_link_service.dart';
import 'package:splitr/Services/local/database.dart';
import 'package:splitr/Services/push_notification_service.dart';
import 'package:splitr/Services/realtime_service.dart';
import 'package:splitr/Services/reminder_service.dart';
import 'package:splitr/Services/share_intent_service.dart';
import 'package:splitr/Services/sync_service.dart';

/// Global service instances — registered via GetX for DI.
late AppDatabase appDatabase;
late SyncService syncService;
late RealtimeService realtimeService;
late ReminderService reminderService;
late PushNotificationService pushNotificationService;
late DeepLinkService deepLinkService;
late ShareIntentService shareIntentService;
