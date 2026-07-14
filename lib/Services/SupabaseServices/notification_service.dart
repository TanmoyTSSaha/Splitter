import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationModel {

  final String id;

  final String type;

  final String title;

  final String? body;

  final bool isRead;

  final Map<String, dynamic>? metadata;

  final DateTime createdAt;



  NotificationModel({

    required this.id,

    required this.type,

    required this.title,

    this.body,

    required this.isRead,

    this.metadata,

    required this.createdAt,

  });



  factory NotificationModel.fromMap(Map<String, dynamic> m) {

    return NotificationModel(

      id: m['id'] as String,

      type: m['type'] as String,

      title: m['title'] as String,

      body: m['body'] as String?,

      isRead: m['is_read'] as bool? ?? false,

      metadata: m['metadata'] as Map<String, dynamic>?,

      createdAt: DateTime.parse(m['created_at'] as String),

    );

  }

}



class NotificationService {

  final supabase = Supabase.instance.client;



  Future<List<NotificationModel>> getNotifications({

    required String userID,

  }) async {

    try {

      final data = await supabase

          .from(SupabaseTables.notifications)

          .select()

          .eq('user_id', userID)

          .order('created_at', ascending: false)

          .limit(50);

      return (data as List)

          .map((m) => NotificationModel.fromMap(m as Map<String, dynamic>))

          .toList();

    } catch (e, stack) {

      AppErrorReporter.report(

        'NotificationService.getNotifications failed',

        error: e,

        stack: stack,

        context: {'feature': 'notifications', 'operation': 'getNotifications'},

      );

      return [];

    }

  }



  Future<int> getUnreadCount({required String userID}) async {

    try {

      final data = await supabase

          .from(SupabaseTables.notifications)

          .select('id')

          .eq('user_id', userID)

          .eq('is_read', false);

      return (data as List).length;

    } catch (e, stack) {

      AppErrorReporter.report(

        'NotificationService.getUnreadCount failed',

        error: e,

        stack: stack,

        context: {'feature': 'notifications', 'operation': 'getUnreadCount'},

      );

      return 0;

    }

  }



  Future<void> markRead({required String notificationID}) async {

    try {

      await supabase

          .from(SupabaseTables.notifications)

          .update({'is_read': true}).eq('id', notificationID);

    } catch (e, stack) {

      AppErrorReporter.report(

        'NotificationService.markRead failed',

        error: e,

        stack: stack,

        context: {'feature': 'notifications', 'operation': 'markRead'},

      );

    }

  }



  Future<void> markAllRead({required String userID}) async {

    try {

      await supabase

          .from(SupabaseTables.notifications)

          .update({'is_read': true}).eq('user_id', userID);

    } catch (e, stack) {

      AppErrorReporter.report(

        'NotificationService.markAllRead failed',

        error: e,

        stack: stack,

        context: {'feature': 'notifications', 'operation': 'markAllRead'},

      );

    }

  }



  Future<void> deleteNotification({required String notificationID}) async {

    try {

      await supabase

          .from(SupabaseTables.notifications)

          .delete()

          .eq('id', notificationID);

    } catch (e, stack) {

      AppErrorReporter.report(

        'NotificationService.deleteNotification failed',

        error: e,

        stack: stack,

        context: {'feature': 'notifications', 'operation': 'deleteNotification'},

      );

    }

  }



  Future<void> createNotification({

    required String userId,

    required String type,

    required String title,

    String? body,

    Map<String, dynamic>? metadata,

  }) async {

    try {

      final callerId = supabase.auth.currentUser?.id;

      if (callerId == null) {

        AppErrorReporter.unexpected(

          'NotificationService.createNotification called without auth',

          context: {

            'feature': 'notifications',

            'operation': 'createNotification',

            'targetUserId': userId,

            'type': type,

          },

        );

        return;

      }



      if (userId == callerId) {

        await supabase.from(SupabaseTables.notifications).insert({

          'user_id': userId,

          'type': type,

          'title': title,

          'body': body,

          'metadata': metadata,

          'is_read': false,

        });

        return;

      }



      await supabase.rpc(

        'create_notification_for_user',

        params: {

          'p_user_id': userId,

          'p_type': type,

          'p_title': title,

          'p_body': body,

          'p_metadata': metadata,

        },

      );

    } catch (e, stack) {

      final context = <String, dynamic>{

        'feature': 'notifications',

        'operation': 'createNotification',

        'targetUserId': userId,

        'type': type,

      };

      if (e is PostgrestException) {

        if (e.message.contains('create_notification_for_user') ||

            e.code == '42883') {

          context['hint'] = 'missing_rpc_migration';

        } else if (e.message.contains('Forbidden')) {

          context['hint'] = 'forbidden_target';

        } else if (e.message.contains('row-level security')) {

          context['hint'] = 'rls_violation';

        }

      }

      AppErrorReporter.report(

        'NotificationService.createNotification failed',

        error: e,

        stack: stack,

        context: context,

      );

    }

  }

}


