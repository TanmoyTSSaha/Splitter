import 'package:flutter/foundation.dart';
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
          .from('notifications')
          .select()
          .eq('user_id', userID)
          .order('created_at', ascending: false)
          .limit(50);
      return (data as List)
          .map((m) => NotificationModel.fromMap(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('NotificationService.getNotifications: $e');
      return [];
    }
  }

  Future<int> getUnreadCount({required String userID}) async {
    try {
      final data = await supabase
          .from('notifications')
          .select('id')
          .eq('user_id', userID)
          .eq('is_read', false);
      return (data as List).length;
    } catch (e) {
      return 0;
    }
  }

  Future<void> markRead({required String notificationID}) async {
    try {
      await supabase
          .from('notifications')
          .update({'is_read': true}).eq('id', notificationID);
    } catch (e) {
      debugPrint('NotificationService.markRead: $e');
    }
  }

  Future<void> markAllRead({required String userID}) async {
    try {
      await supabase
          .from('notifications')
          .update({'is_read': true}).eq('user_id', userID);
    } catch (e) {
      debugPrint('NotificationService.markAllRead: $e');
    }
  }

  Future<void> deleteNotification({required String notificationID}) async {
    try {
      await supabase.from('notifications').delete().eq('id', notificationID);
    } catch (e) {
      debugPrint('NotificationService.delete: $e');
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
      await supabase.from('notifications').insert({
        'user_id': userId,
        'type': type,
        'title': title,
        'body': body,
        'metadata': metadata,
        'is_read': false,
      });
    } catch (e) {
      debugPrint('NotificationService.createNotification: $e');
    }
  }
}
