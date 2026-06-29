/// Data models for Group Activity Feed
/// Represents aggregated events in a group: expense added, settled up, member joined, or comments.

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
  final String description; // "added 'Dinner at Toscano'"
  final double? amount;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata; // Can store related expenseId, etc.
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
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      type: ActivityType.values.firstWhere(
          (e) => e.toString().split('.').last == json['type'],
          orElse: () => ActivityType.expenseAdded),
      actorId: json['actor_id'] as String,
      actorName: json['actor_name'] as String,
      actorPic: json['actor_pic'] as String?,
      description: json['description'] as String,
      amount: json['amount'] != null
          ? double.tryParse(json['amount'].toString())
          : null,
      timestamp: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((r) => Reaction.fromJSON(r))
              .toList() ??
          [],
      commentCount: json['comment_count'] as int? ?? 0,
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
      emoji: json['emoji'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
    );
  }

  Map<String, dynamic> toJSON() => {
        'emoji': emoji,
        'user_id': userId,
        'user_name': userName,
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
      id: json['id'] as String,
      activityId: json['activity_id'] as String,
      groupId: json['group_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String? ?? 'User',
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
