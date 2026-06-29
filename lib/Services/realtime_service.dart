import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:splitter/Constants/constants.dart';

/// Manages Supabase Realtime subscriptions for live group updates.
/// When a group member adds/edits an expense, all members see it instantly.
class RealtimeService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Map<String, RealtimeChannel> _channels = {};

  /// Callback when a group transaction changes.
  final _transactionController =
      StreamController<RealtimeTransactionEvent>.broadcast();
  Stream<RealtimeTransactionEvent> get onTransactionChange =>
      _transactionController.stream;

  /// Emits [groupId] when wishlist items or upvotes change for a subscribed group.
  final _wishlistController = StreamController<String>.broadcast();
  Stream<String> get onWishlistChange => _wishlistController.stream;

  /// Callback when a friend request arrives.
  final _friendController = StreamController<RealtimeFriendEvent>.broadcast();
  Stream<RealtimeFriendEvent> get onFriendChange => _friendController.stream;

  /// Subscribe to transaction changes in a specific group.
  void subscribeToGroup(String groupId) {
    if (_channels.containsKey('group_$groupId')) return;

    final channel = _supabase.channel('group_$groupId');
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'group_transaction',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'group_id',
            value: groupId,
          ),
          callback: (payload) {
            _transactionController.add(RealtimeTransactionEvent(
              groupId: groupId,
              eventType: payload.eventType.name,
              newRecord: payload.newRecord,
              oldRecord: payload.oldRecord,
            ));

            // Show toast for new expenses
            if (payload.eventType == PostgresChangeEvent.insert) {
              final newData = payload.newRecord;
              final amount = newData['total_transaction_amount'];
              final description = newData['description'] ?? 'New expense';
              Fluttertoast.showToast(
                msg: "💰 $description — ₹$amount",
                backgroundColor: neopopAccent,
                textColor: neopopBackground,
              );
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'group_wishlists',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'group_id',
            value: groupId,
          ),
          callback: (_) => _wishlistController.add(groupId),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'wishlist_upvotes',
          callback: (_) => _wishlistController.add(groupId),
        )
        .subscribe();

    _channels['group_$groupId'] = channel;
    debugPrint('Subscribed to realtime for group $groupId');
  }

  /// Subscribe to friend requests/updates for a user.
  void subscribeToFriends(String userId) {
    if (_channels.containsKey('friends_$userId')) return;

    final channel = _supabase.channel('friends_$userId');
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'friends',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'friend_id',
            value: userId,
          ),
          callback: (payload) {
            _friendController.add(RealtimeFriendEvent(
              eventType: payload.eventType.name,
              newRecord: payload.newRecord,
            ));

            if (payload.eventType == PostgresChangeEvent.insert) {
              Fluttertoast.showToast(
                msg: "👋 New friend request!",
                backgroundColor: neopopYellow,
                textColor: neopopBackground,
              );
            }
          },
        )
        .subscribe();

    _channels['friends_$userId'] = channel;
    debugPrint('Subscribed to friend updates for $userId');
  }

  /// Unsubscribe from a specific group.
  void unsubscribeFromGroup(String groupId) {
    final key = 'group_$groupId';
    if (_channels.containsKey(key)) {
      _supabase.removeChannel(_channels[key]!);
      _channels.remove(key);
      debugPrint('Unsubscribed from group $groupId');
    }
  }

  /// Dispose all channels.
  void dispose() {
    for (final channel in _channels.values) {
      _supabase.removeChannel(channel);
    }
    _channels.clear();
    _transactionController.close();
    _friendController.close();
    _wishlistController.close();
  }
}

class RealtimeTransactionEvent {
  final String groupId;
  final String eventType;
  final Map<String, dynamic> newRecord;
  final Map<String, dynamic> oldRecord;

  RealtimeTransactionEvent({
    required this.groupId,
    required this.eventType,
    required this.newRecord,
    required this.oldRecord,
  });
}

class RealtimeFriendEvent {
  final String eventType;
  final Map<String, dynamic> newRecord;

  RealtimeFriendEvent({
    required this.eventType,
    required this.newRecord,
  });
}
