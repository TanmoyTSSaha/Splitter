/// Data models for Group Activity Feed
/// Represents aggregated events in a group: expense added, settled up, member joined, or comments.
library;

import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Constants/domain_values.dart';

enum ActivityType {
  expenseAdded,
  settledUp,
  memberJoined,
  comment,
}

class ActivityItem {
  final String id;
  final String groupId;
  final ActivityType type;
  final String actorId;
  final String actorName;
  final String? actorPic;
  final String description;
  final double? amount;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final List<Reaction> reactions;
  final int commentCount;

  ActivityItem({
    required this.id,
    required this.groupId,
    required this.type,
    required this.actorId,
    required this.actorName,
    this.actorPic,
    required this.description,
    this.amount,
    required this.timestamp,
    this.metadata,
    this.reactions = const [],
    this.commentCount = 0,
  });

  factory ActivityItem.fromJSON(Map<String, dynamic> json) {
    return ActivityItem(
      id: json[SupabaseColumns.id] as String,
      groupId: json[SupabaseColumns.groupId] as String,
      type: ActivityType.values.firstWhere(
          (e) => e.toString().split('.').last == json[SupabaseColumns.type],
          orElse: () => ActivityType.expenseAdded),
      actorId: json[SupabaseColumns.actorId] as String,
      actorName: json[SupabaseColumns.actorName] as String,
      actorPic: json[SupabaseColumns.actorPic] as String?,
      description: json[SupabaseColumns.description] as String,
      amount: json[SupabaseColumns.amount] != null
          ? double.tryParse(json[SupabaseColumns.amount].toString())
          : null,
      timestamp: DateTime.parse(json[SupabaseColumns.createdAt] as String),
      metadata: json[SupabaseColumns.metadata] as Map<String, dynamic>?,
      reactions: (json[SupabaseColumns.reactions] as List<dynamic>?)
              ?.map((r) => Reaction.fromJSON(r))
              .toList() ??
          [],
      commentCount: json[SupabaseColumns.commentCount] as int? ?? 0,
    );
  }
}

class Reaction {
  final String emoji;
  final String userId;
  final String userName;

  Reaction({
    required this.emoji,
    required this.userId,
    required this.userName,
  });

  factory Reaction.fromJSON(Map<String, dynamic> json) {
    return Reaction(
      emoji: json[SupabaseColumns.emoji] as String,
      userId: json[SupabaseColumns.userId] as String,
      userName: json[SupabaseColumns.userName] as String,
    );
  }

  Map<String, dynamic> toJSON() => {
        SupabaseColumns.emoji: emoji,
        SupabaseColumns.userId: userId,
        SupabaseColumns.userName: userName,
      };
}

class ActivityComment {
  final String id;
  final String activityId;
  final String groupId;
  final String userId;
  final String userName;
  final String body;
  final DateTime createdAt;

  ActivityComment({
    required this.id,
    required this.activityId,
    required this.groupId,
    required this.userId,
    required this.userName,
    required this.body,
    required this.createdAt,
  });

  factory ActivityComment.fromJSON(Map<String, dynamic> json) {
    return ActivityComment(
      id: json[SupabaseColumns.id] as String,
      activityId: json[SupabaseColumns.activityId] as String,
      groupId: json[SupabaseColumns.groupId] as String,
      userId: json[SupabaseColumns.userId] as String,
      userName:
          json[SupabaseColumns.userName] as String? ?? DisplayFallbacks.user,
      body: json[SupabaseColumns.body] as String,
      createdAt: DateTime.parse(json[SupabaseColumns.createdAt] as String),
    );
  }
}
