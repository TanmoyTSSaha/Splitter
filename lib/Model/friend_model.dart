/// Model for a friend relationship record.
class FriendModel {
  final String? id;
  final String? userID;
  final String? friendUserID;
  final String? friendName;
  final String? friendEmail;
  final String? friendPic;
  final String? status; // 'pending', 'accepted', 'rejected'
  final DateTime? createdAt;

  FriendModel({
    this.id,
    this.userID,
    this.friendUserID,
    this.friendName,
    this.friendEmail,
    this.friendPic,
    this.status,
    this.createdAt,
  });

  factory FriendModel.fromJSON(Map<String, dynamic> json) {
    return FriendModel(
      id: json['id']?.toString(),
      userID: json['user_id']?.toString(),
      friendUserID: json['friend_id']?.toString(),
      friendName: json['friend_name']?.toString(),
      friendEmail: json['friend_email']?.toString(),
      friendPic: json['friend_pic']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

/// Model for a friend's aggregated balance across groups.
class FriendBalanceModel {
  final String? friendUserID;
  final String? friendName;
  final String? friendEmail;
  final String? friendPic;
  final double totalOwed; // Total they owe you
  final double totalOwing; // Total you owe them
  final double netBalance; // Positive = they owe you, Negative = you owe them
  final List<GroupBalanceBreakdown> groupBreakdown;

  FriendBalanceModel({
    this.friendUserID,
    this.friendName,
    this.friendEmail,
    this.friendPic,
    this.totalOwed = 0.0,
    this.totalOwing = 0.0,
    this.netBalance = 0.0,
    this.groupBreakdown = const [],
  });
}

/// Per-group balance detail for a friend.
class GroupBalanceBreakdown {
  final String groupName;
  final String groupID;
  final double amount; // Positive = they owe you, Negative = you owe them

  GroupBalanceBreakdown({
    required this.groupName,
    required this.groupID,
    required this.amount,
  });
}
