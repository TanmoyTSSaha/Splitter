import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Model/wishlist_model.dart';
import 'package:splitr/Utils/app_error_reporter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing group wishlists / planned expenses.
/// Backed by Supabase tables: `group_wishlists` and `wishlist_upvotes`.
class WishlistService {
  final _supabase = Supabase.instance.client;

  /// Fetches all wishlist items for a group, enriched with upvote counts
  /// and the current user's upvote state.
  Future<List<WishlistItem>> getWishlistItems({
    required String groupId,
    required String currentUserId,
  }) async {
    try {
      final items = await _supabase
          .from(SupabaseTables.groupWishlists)
          .select('*')
          .eq('group_id', groupId)
          .order('created_at', ascending: false);

      if (items.isEmpty) return [];

      final itemIds = items.map<String>((e) => e['id'] as String).toList();
      final userIds =
          items.map<String>((e) => e['added_by'] as String).toSet().toList();

      final results = await Future.wait([
        _supabase
            .from(SupabaseTables.wishlistUpvotes)
            .select('wishlist_item_id, user_id')
            .inFilter('wishlist_item_id', itemIds),
        _supabase
            .from(SupabaseTables.users)
            .select('user_id, firstname, lastname')
            .inFilter('user_id', userIds),
      ]);

      final upvotesRaw = results[0] as List<dynamic>;
      final usersRaw = results[1] as List<dynamic>;

      final Map<String, int> upvoteCountMap = {};
      final Set<String> userUpvotedSet = {};

      for (var upvote in upvotesRaw) {
        final itemId = upvote['wishlist_item_id'] as String;
        upvoteCountMap[itemId] = (upvoteCountMap[itemId] ?? 0) + 1;
        if (upvote['user_id'] == currentUserId) {
          userUpvotedSet.add(itemId);
        }
      }

      final Map<String, String> userNameMap = {};
      for (var user in usersRaw) {
        userNameMap[user['user_id'] as String] =
            '${user['firstname']} ${user['lastname']}';
      }

      return items.map<WishlistItem>((json) {
        final itemId = json['id'] as String;
        final addedBy = json['added_by'] as String;

        return WishlistItem.fromJSON(
          json,
          upvotes: upvoteCountMap[itemId] ?? 0,
          currentUserUpvoted: userUpvotedSet.contains(itemId),
          addedByName: userNameMap[addedBy] ?? DisplayFallbacks.unknown,
        );
      }).toList();
    } catch (e, stack) {
      AppErrorReporter.report(
        'WishlistService.getWishlistItems failed',
        error: e,
        stack: stack,
        context: {'feature': 'wishlist', 'operation': 'getWishlistItems'},
      );
      return [];
    }
  }

  /// Adds a new wishlist item.
  Future<bool> addWishlistItem({
    required String groupId,
    required String userId,
    required String title,
    double? estimatedAmount,
  }) async {
    try {
      await _supabase.from(SupabaseTables.groupWishlists).insert({
        'group_id': groupId,
        'title': title,
        'estimated_amount': estimatedAmount,
        'added_by': userId,
      });
      return true;
    } catch (e, stack) {
      AppErrorReporter.report(
        'WishlistService.addWishlistItem failed',
        error: e,
        stack: stack,
        context: {'feature': 'wishlist', 'operation': 'addWishlistItem'},
      );
      return false;
    }
  }

  /// Toggles the current user's upvote on a wishlist item.
  /// Returns `true` if upvoted, `false` if un-upvoted.
  Future<bool?> toggleUpvote({
    required String itemId,
    required String userId,
  }) async {
    try {
      final existing = await _supabase
          .from(SupabaseTables.wishlistUpvotes)
          .select()
          .eq('wishlist_item_id', itemId)
          .eq('user_id', userId);

      if (existing.isNotEmpty) {
        await _supabase
            .from(SupabaseTables.wishlistUpvotes)
            .delete()
            .eq('wishlist_item_id', itemId)
            .eq('user_id', userId);
        return false;
      } else {
        await _supabase.from(SupabaseTables.wishlistUpvotes).insert({
          'wishlist_item_id': itemId,
          'user_id': userId,
        });
        return true;
      }
    } catch (e, stack) {
      AppErrorReporter.report(
        'WishlistService.toggleUpvote failed',
        error: e,
        stack: stack,
        context: {'feature': 'wishlist', 'operation': 'toggleUpvote'},
      );
      return null;
    }
  }

  /// Marks a wishlist item as added to actual expenses.
  Future<bool> markAsAdded({required String itemId}) async {
    try {
      await _supabase
          .from(SupabaseTables.groupWishlists)
          .update({'is_added_to_expenses': true}).eq('id', itemId);
      return true;
    } catch (e, stack) {
      AppErrorReporter.report(
        'WishlistService.markAsAdded failed',
        error: e,
        stack: stack,
        context: {'feature': 'wishlist', 'operation': 'markAsAdded'},
      );
      return false;
    }
  }

  /// Deletes a wishlist item (only the creator can delete).
  Future<bool> deleteItem({required String itemId}) async {
    try {
      await _supabase
          .from(SupabaseTables.groupWishlists)
          .delete()
          .eq('id', itemId);
      return true;
    } catch (e, stack) {
      AppErrorReporter.report(
        'WishlistService.deleteItem failed',
        error: e,
        stack: stack,
        context: {'feature': 'wishlist', 'operation': 'deleteItem'},
      );
      return false;
    }
  }
}
