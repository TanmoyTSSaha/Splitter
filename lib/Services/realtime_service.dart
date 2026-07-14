import 'dart:async';
import 'package:splitr/Widgets/splitr_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/app_strings.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Utils/currency_utils.dart';

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
    if (_channels.containsKey('${RealtimeChannelPrefixes.group}$groupId'))
      return;

    final channel =
        _supabase.channel('${RealtimeChannelPrefixes.group}$groupId');
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: RealtimeSchemas.public,
          table: SupabaseTables.groupTransaction,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: SupabaseColumns.groupId,
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
              final amount = newData[SupabaseColumns.totalTransactionAmount];
              final description = newData[SupabaseColumns.description] ??
                  TransactionCopy.newExpense;
              SplitrToast.show('${AppStrings.services.realtime.expenseToastPrefix}$description${AppStrings.services.realtime.expenseToastSeparator}${userCurrencySymbol()}$amount');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: RealtimeSchemas.public,
          table: SupabaseTables.groupWishlists,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: SupabaseColumns.groupId,
            value: groupId,
          ),
          callback: (_) => _wishlistController.add(groupId),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: RealtimeSchemas.public,
          table: SupabaseTables.wishlistUpvotes,
          callback: (_) => _wishlistController.add(groupId),
        )
        .subscribe();

    _channels['${RealtimeChannelPrefixes.group}$groupId'] = channel;
    debugPrint('Subscribed to realtime for group $groupId');
  }

  /// Subscribe to friend requests/updates for a user.
  void subscribeToFriends(String userId) {
    if (_channels.containsKey('${RealtimeChannelPrefixes.friends}$userId'))
      return;

    final channel =
        _supabase.channel('${RealtimeChannelPrefixes.friends}$userId');
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: RealtimeSchemas.public,
          table: SupabaseTables.friends,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: SupabaseColumns.friendId,
            value: userId,
          ),
          callback: (payload) {
            _friendController.add(RealtimeFriendEvent(
              eventType: payload.eventType.name,
              newRecord: payload.newRecord,
            ));

            if (payload.eventType == PostgresChangeEvent.insert) {
              SplitrToast.show(AppStrings.services.realtime.newFriendRequest);
            }
          },
        )
        .subscribe();

    _channels['${RealtimeChannelPrefixes.friends}$userId'] = channel;
    debugPrint('Subscribed to friend updates for $userId');
  }

  /// Unsubscribe from a specific group.
  void unsubscribeFromGroup(String groupId) {
    final key = '${RealtimeChannelPrefixes.group}$groupId';
    if (_channels.containsKey(key)) {
      _supabase.removeChannel(_channels[key]!);
      _channels.remove(key);
      debugPrint('Unsubscribed from group $groupId');
    }
  }

  /// Drop all realtime channels without closing broadcast streams.
  void unsubscribeAll() {
    for (final channel in _channels.values) {
      _supabase.removeChannel(channel);
    }
    _channels.clear();
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
