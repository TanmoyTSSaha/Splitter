import 'package:drift/drift.dart';
import 'package:splitr/Constants/app_formats.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Model/friend_model.dart';
import 'package:splitr/Services/local/database.dart';
import 'package:splitr/Services/SupabaseServices/friend_service.dart';
import 'package:splitr/Services/sync_service.dart';

/// Local cache + server refresh for friend relationships.
class FriendRepository {
  final AppDatabase _db;
  final SyncService _syncService;
  final FriendService _friendService = FriendService();

  FriendRepository(this._db, this._syncService);

  Stream<List<LocalFriend>> watchForUser(String userId) =>
      _db.watchFriendsForUser(userId);

  /// Reads cached relationships enriched with user display fields.
  Future<List<FriendModel>> getFriends(String userId) async {
    final rows = await _db.getFriendsForUser(userId);
    return _toFriendModels(userId, rows);
  }

  /// Pull friends from Supabase into Drift and user cache.
  Future<void> refreshFromServer(String userId) async {
    try {
      final friends = await _friendService.getFriends(userID: userId);
      final companions = friends
          .where((f) => f.id != null)
          .map(
            (f) => LocalFriendsCompanion(
              id: Value(f.id!),
              userId: Value(f.userID ?? userId),
              friendId: Value(
                f.tableFriendId ?? f.friendUserID ?? StringDefaults.empty,
              ),
              status: Value(f.status ?? FriendStatusValues.pending),
              createdAt: Value(f.createdAt),
              syncStatus: const Value(SyncStatusValues.synced),
            ),
          )
          .toList();

      await _db.replaceFriendsForUser(userId, companions);

      for (final friend in friends) {
        final otherId = friend.friendUserID;
        if (otherId == null) continue;
        await _db.upsertUser(
          LocalUsersCacheCompanion(
            userId: Value(otherId),
            firstName: Value(_firstName(friend.friendName)),
            lastName: Value(_lastName(friend.friendName)),
            email: Value(friend.friendEmail),
            profilePictureUrl: Value(friend.friendPic),
          ),
        );
      }
    } catch (_) {
      _syncService;
    }
  }

  Future<List<FriendBalanceModel>> getFriendBalances({
    required String userId,
    required List<FriendModel> friends,
  }) =>
      _friendService.getFriendBalances(userID: userId, friends: friends);

  Future<bool> sendFriendRequest({
    required String fromUserId,
    required String toUserId,
  }) async {
    final created = await _friendService.sendFriendRequest(
      fromUserID: fromUserId,
      toUserID: toUserId,
    );
    await refreshFromServer(fromUserId);
    return created;
  }

  Future<void> acceptFriendRequest({
    required String requestId,
    required String userId,
  }) async {
    await _friendService.acceptFriendRequest(requestID: requestId);
    await refreshFromServer(userId);
  }

  Future<void> cancelFriendRequest({
    required String requestId,
    required String fromUserId,
  }) async {
    await _friendService.cancelFriendRequest(
      requestID: requestId,
      fromUserID: fromUserId,
    );
    await refreshFromServer(fromUserId);
  }

  Future<List<FriendModel>> _toFriendModels(
    String userId,
    List<LocalFriend> rows,
  ) async {
    final models = <FriendModel>[];
    for (final row in rows) {
      final otherId = row.userId == userId ? row.friendId : row.userId;
      final cached = await _db.getUser(otherId);
      final displayName = cached == null
          ? null
          : DisplayFormatters.joinFirstLast(
              cached.firstName,
              cached.lastName,
            );

      models.add(FriendModel(
        id: row.id,
        userID: row.userId,
        friendUserID: otherId,
        friendName:
            (displayName == null || displayName.isEmpty) ? null : displayName,
        friendEmail: cached?.email,
        friendPic: cached?.profilePictureUrl,
        status: row.status,
        createdAt: row.createdAt,
      ));
    }
    return models;
  }

  String? _firstName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return null;
    final parts = fullName.trim().split(RegExp(InputPatterns.whitespace));
    return parts.first;
  }

  String? _lastName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return null;
    final parts = fullName.trim().split(RegExp(InputPatterns.whitespace));
    if (parts.length < 2) return null;
    return parts.sublist(1).join(AppSeparators.monthYearJoiner);
  }
}
